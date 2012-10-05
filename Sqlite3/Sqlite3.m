//
//  SLDatabase.m
//  Sqlite3
//
//  Created by youknowone on 09. 12. 9..
//  Copyright 2010 youknowone.org All rights reserved.
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

#define SQLITE3_DEBUG FALSE
#import "Sqlite3.h"
#import "SQL.h"

#import "debug.h"

@implementation SLCursor

@synthesize resultCode=_resultCode;

- (id)initWithDatabase:(SLDatabase *)database sql:(NSString *)sql errorMessage:(const char **)bufferOrNull {
	if ((self = [self init]) != nil) {
		self->_resultCode = sqlite3_prepare_v2(database.sqlite3, [sql UTF8String], -1, &self->_statement, bufferOrNull);
		[self next];
	}
	return self;
}

+ (SLCursor *)cursorWithSqlite3:(SLDatabase *)sqlite3 sql:(NSString *)sql errorMessage:(const char**)bufferOrNull {
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

- (NSUInteger)integerValueAtColumnIndex:(NSInteger)index {
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


@implementation SLDatabase

@synthesize resultCode=_resultCode, sqlite3=_sqlite3;

- (id)init {
    self = [super init];
	if (self != nil ) {
		self->_sqlite3 = nil;
		self->_resultCode = 0;
		self->_errorMessage = nil;
	}
	return self;
}

- (id)initWithMemory {
	self = [self init];
	[self openMemory];
	return self;
}

- (id)initWithFile:(NSString*)filename {
	self = [self init];
	[self openFile:filename];
	return self;
}

- (void)dealloc {
	if (nil != self->_sqlite3) {
		[self close];
    }
	[super dealloc];
}

- (NSString *)errorMessage {
	if (nil == self->_errorMessage) {
		return nil;
	}
	NSString *msg = [[NSString alloc] initWithCString:self->_errorMessage encoding:NSASCIIStringEncoding];
	sqlite3_free(self->_errorMessage);
	self->_errorMessage = nil;
	return [msg autorelease];
}

#pragma mark -
#pragma mark sqlite3 wrapping

- (void)openMemory {
	self->_resultCode = sqlite3_open_v2(":memory:", &self->_sqlite3, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, NULL);
}

// UTF-8
- (void)openFile:(NSString *)filename {
	dlog(SQLITE3_DEBUG, @"dbfile: %@", filename);
	self->_resultCode = sqlite3_open([filename UTF8String], &self->_sqlite3);
}
// UTF-8
- (void)openFile:(NSString *)filename flags:(int)flags vfs:(const char *)zVfs {
	self->_resultCode = sqlite3_open_v2([filename UTF8String], &self->_sqlite3, flags, zVfs);
}

- (void)close {
	sqlite3_close(self->_sqlite3);
	self->_sqlite3 = nil;
}

- (void)executeQuery:(NSString*)sql {
	self->_resultCode = sqlite3_exec(self->_sqlite3, [sql UTF8String], NULL, NULL, &self->_errorMessage);
}

- (SLCursor*)cursorByQuery:(NSString*)sql {
	dlog(SQLITE3_DEBUG, @"sql: %@", sql);
	if (self->_errorMessage) {
		//sqlite3_free(errorMessage);
		self->_errorMessage = nil;
	}
	SLCursor* cursor = [[SLCursor alloc] initWithDatabase:self sql:sql errorMessage:(const char**)&self->_errorMessage];
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

#pragma mark -
#pragma mark sqlite3 constants

+ (int)versionNumber {
	return SQLITE_VERSION_NUMBER;
}

+ (int)libraryVersionNumber {
	return sqlite3_libversion_number();
}

@end

@implementation SLDatabase (SLSQL)

- (SLCursor*)cursorBySQL:(SLSQL *)sql {
	return [self cursorByQuery:sql.SQL];
}

- (void)executeSQL:(SLSQL *)sql {
	[self executeQuery:sql.SQL];
}

@end


@implementation SLSQLInsertBuilder
@synthesize table=_table, data=_data;

- (id)initWithTable:(NSString *)table {
    self = [super init];
    if (self != nil) {
        self.table = table;
        _data = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (id)initWithTable:(NSString *)table data:(NSDictionary *)data {
    self = [super init];
    if (self != nil) {
        self.table = table;
        _data = [[NSMutableDictionary alloc] initWithDictionary:data];
    }
    return self;
}

- (void)dealloc {
    self.table = nil;
    [_data release];
    [super dealloc];
}

- (void)setData:(id)data forKey:(id)key {
    [self.data setObject:data forKey:key];
}

#pragma mark -

- (NSString *)query {
    if (self.data.count == 0) return nil;
    
    // NOTE: fix to get key/value pair for faster iteration
    NSArray *allKeys = self.data.allKeys;
    NSMutableArray *allObjects = [NSMutableArray array];
    for (id key in allKeys) {
        [allObjects addObject:[self.data objectForKey:key]];
    }
    
    NSMutableString *keyString = [NSMutableString stringWithString:@"`"];
    [keyString appendString:[allKeys componentsJoinedByString:@"`,`"]];
    [keyString appendString:@"`"];
    
    NSMutableString *valueString = [NSMutableString string];
    BOOL firstObject = YES;
    for (id value in allObjects) {
        if (firstObject) {
            firstObject = NO;
        } else {
            [valueString appendString:@","];
        }
        if ([value isKindOfClass:[NSNumber class]]) {
            [valueString appendString:[value stringValue]];
        } else {
            [valueString appendFormat:@"'%@'", [value stringByReplacingOccurrencesOfString:@"'" withString:@"''"]];
        }
    }
    
    return [NSString stringWithFormat:@"INSERT INTO `%@` (%@) VALUES (%@)",
            self.table,
            keyString,
            valueString];
}

- (NSString *)description {
    return self.query;
}

@end


