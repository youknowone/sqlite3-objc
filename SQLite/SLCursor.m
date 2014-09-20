//
//  SLCursor.m
//  SQLite
//
//  Created by Jeong YunWon on 12. 12. 20..
//  Copyright (c) 2012 youknowone.org. All rights reserved.
//
/*
 ** 2001 September 15
 **
 ** The author disclaims copyright to original source code.  In place of
 ** a legal notice, here is a blessing:
 **
 **    May you do good and not evil.
 **    May you find forgiveness for yourself and forgive others.
 **    May you share freely, never taking more than you give.
 **
 */

#import "SLCursor.h"

#import "SLDatabase.h"
#import "SLStatement.h"
#import "SLSQL.h"

@implementation SLCursor

@synthesize resultCode=_resultCode;

- (id)initWithDatabase:(SLDatabase *)database sql:(NSString *)sql errorMessage:(const char **)bufferOrNull {
    self = [super init];
    if (self != nil) {
        self->_resultCode = sqlite3_prepare_v2(database.sqlite3, [sql UTF8String], -1, &self->_statement, bufferOrNull);
        [self next];
    }
    return self;
}

+ (SLCursor *)cursorWithSQLite:(SLDatabase *)sqlite3 sql:(NSString *)sql errorMessage:(const char**)bufferOrNull {
    return [[[self alloc] initWithDatabase:sqlite3 sql:sql errorMessage:bufferOrNull] autorelease];
}

- (void)dealloc {
    if (nil != self->_statement) {
        self->_resultCode = sqlite3_finalize(self->_statement);
    }
    [super dealloc];
}

- (void)reset {
    self->_resultCode = sqlite3_reset(self->_statement);
    [self next];
}

- (void)next {
    self->_resultCode = sqlite3_step(self->_statement);
}

- (NSInteger)rowCount {
    return (NSInteger)sqlite3_data_count(self->_statement);
}

- (NSInteger)columnCount {
    return (NSInteger)sqlite3_column_count(self->_statement);
}

- (NSString *)nameAtColumnIndex:(NSInteger)index {
    return [NSString stringWithUTF8String:sqlite3_column_name(self->_statement, (int)index)];
}

- (NSString *)stringValueAtColumnIndex:(NSInteger)index {
    const char *text = (const char*)sqlite3_column_text(self->_statement, (int)index);
    if (text == NULL) return nil;
    return [NSString stringWithUTF8String:text];
}

- (NSInteger)integerValueAtColumnIndex:(NSInteger)index {
    return sqlite3_column_int(self->_statement, (int)index);
}

- (BOOL)isEndOfCursor {
    return self->_resultCode == SQLITE_DONE;
}

/* deprecated set */
- (NSString*) getColumnName:(NSInteger)column {
    return [NSString stringWithUTF8String:sqlite3_column_name(self->_statement, (int)column)];
}

- (NSString*) getColumnAsString:(NSInteger)column {
    return [NSString stringWithUTF8String:(const char*)sqlite3_column_text(self->_statement, (int)column)];
}

- (NSUInteger)getColumnAsInteger:(NSInteger)column {
    return sqlite3_column_int(self->_statement, (int)column);
}

@end


@implementation SLDatabase (SLCursor)

- (SLCursor *)cursorByQuery:(NSString*)sql {
    dlog(SQLITE3_DEBUG, @"sql: %@", sql);
    SLCursor* cursor = [[SLCursor alloc] initWithDatabase:self sql:sql errorMessage:&self->_errorMessage];
    self->_resultCode = cursor.resultCode;
    return [cursor autorelease];
}

- (SLCursor *)cursorByFormat:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    SLCursor *cursor = [self cursorByQuery:[[[NSString alloc] initWithFormat:format arguments:args] autorelease]];
    va_end(args);
    return cursor;
}

- (SLCursor *)cursorBySQL:(SLSQL *)sql {
    return [self cursorByQuery:sql.SQL];
}


@end

