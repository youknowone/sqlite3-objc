//
//  Statement.m
//  SQLite
//
//  Created by Jeong YunWon on 12. 12. 19..
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

#import "SLStatement.h"

#import "SLDatabase.h"
#import "SLError.h"

@interface SLStatement ()

- (BOOL)_handleResult:(NSError **)errorPtr;

@end


@implementation SLStatement

- (BOOL)_handleResult:(NSError **)errorPtr {
    if (self->_resultCode != SQLITE_OK && self->_resultCode != SQLITE_ROW && self->_resultCode != SQLITE_DONE) {
        if (errorPtr) {
            *errorPtr = [SLError errorWithDatabase:self->_sqlite3];
        }
        return YES;
    }
    return NO;
}

- (id)initWithSQLite:(sqlite3 *)sqlite3 {
    if (sqlite3 == NULL) {
        goto drop;
    }
    self = [super init];
    if (self != nil) {
        self->_sqlite3 = sqlite3;
    }
    return self;
    
drop:
    [self release];
    return nil;
}

- (id)initWithSQLite:(sqlite3 *)sqlite3 statement:(sqlite3_stmt *)statement freeWhenDone:(BOOL)flag {
    if (statement == NULL) {
        goto drop;
    }
    self = [self initWithSQLite:sqlite3];
    if (self != nil) {
        self->_stmt = statement;
        self->statementFlags.freeWhenDone = flag;
    }
    return self;
    
drop:
    [self release];
    return nil;
}

- (id)initWithDatabase:(SLDatabase *)database query:(NSString *)query error:(NSError **)errorPtr {
    if (database == nil || query == nil) {
        goto drop;
    }
    self = [self initWithSQLite:database.sqlite3];
    if (self != nil) {
        [self prepareQuery:query error:errorPtr];
        if (self->_stmt == NULL) {
            goto drop;
        };
    }
    return self;
    
drop:
    [self release];
    return nil;
}

+ (id)statementWithSQLite:(sqlite3 *)sqlite3 {
    return [[[self alloc] initWithSQLite:sqlite3] autorelease];
}

+ (id)statementWithSQLite:(sqlite3 *)sqlite3 statement:(sqlite3_stmt *)statement freeWhenDone:(BOOL)flag {
    return [[[self alloc] initWithSQLite:sqlite3 statement:statement freeWhenDone:flag] autorelease];
}

+ (id)statementWithDatabase:(SLDatabase *)database query:(NSString *)query error:(NSError **)errorPtr {
    return [[[self alloc] initWithDatabase:database query:query error:errorPtr] autorelease];
}

- (void)dealloc {
    if (self->statementFlags.freeWhenDone) {
        self->_resultCode = sqlite3_finalize(self->_stmt);
    }
    [super dealloc];
}

- (void)prepareQuery:(NSString *)query error:(NSError **)errorPtr {
    const char *sql = query.UTF8String;
    self->_resultCode = sqlite3_prepare_v2(self->_sqlite3, sql, -1, &self->_stmt, NULL);
    if (![self _handleResult:errorPtr]) {
        self->statementFlags.freeWhenDone = YES;
    }
}

- (void)step:(NSError **)errorPtr {
    self->_resultCode = sqlite3_step(self->_stmt);
    [self _handleResult:errorPtr];
}

- (void)reset:(NSError **)errorPtr {
    self->_resultCode = sqlite3_reset(self->_stmt);
    [self _handleResult:errorPtr];
}

- (NSInteger)rowCount {
    return (NSInteger)sqlite3_data_count(self->_stmt);
}

- (NSInteger)columnCount {
    return (NSInteger)sqlite3_column_count(self->_stmt);
}

- (NSString *)nameAtColumnIndex:(NSInteger)index {
    return [NSString stringWithUTF8String:sqlite3_column_name(self->_stmt, (int)index)];
}

//- (NSString *)databaseNameAtColumnIndex:(NSInteger)index {
//    return [NSString stringWithUTF8String:sqlite3_column_database_name(self->_stmt, (int)index)];
//}
//
//- (NSString *)tableNameAtColumnIndex:(NSInteger)index {
//    return [NSString stringWithUTF8String:sqlite3_column_table_name(self->_stmt, (int)index)];
//}
//
//- (NSString *)originNameAtColumnIndex:(NSInteger)index {
//     return [NSString stringWithUTF8String:sqlite3_column_origin_name(self->_stmt, (int)index)];
//}

- (int)typeForColumnIndex:(NSInteger)index {
    return sqlite3_column_type(self->_stmt, (int)index);
}

- (NSString *)stringValueAtColumnIndex:(NSInteger)index {
    const char *text = (const char*)sqlite3_column_text(self->_stmt, (int)index);
    if (text == NULL) return nil;
    return [NSString stringWithUTF8String:text];
}

- (NSInteger)integerValueAtColumnIndex:(NSInteger)index {
    NSInteger result = sqlite3_column_int(self->_stmt, (int)index);
    return result;
}

- (NSData *)dataValueAtColumnIndex:(NSInteger)index {
    NSUInteger size = sqlite3_column_bytes(self->_stmt, (int)index);
    const void *blob = sqlite3_column_blob(self->_stmt, (int)index);
    return [NSData dataWithBytes:blob length:size];
}

- (double)floatValueAtColumnIndex:(NSInteger)index {
    return sqlite3_column_double(self->_stmt, (int)index);
}

- (BOOL)isNullAtColumnIndex:(NSInteger)index {
    return sqlite3_column_type(self->_stmt, (int)index) == SQLITE_NULL;
}

- (NSNumber *)numberValueAtColumnIndex:(NSInteger)index {
    int type = sqlite3_column_type(self->_stmt, (int)index);
    switch (type) {
        case SQLITE_NULL:
            return nil;
        case SQLITE_INTEGER:
            return [NSNumber numberWithInteger:[self integerValueAtColumnIndex:index]];
        case SQLITE_FLOAT:
            return [NSNumber numberWithDouble:[self floatValueAtColumnIndex:index]];
        default:
            dassert(NO);
            return nil;
    }
    dassert(NO);
    return nil;
}

- (id)valueAtColumnIndex:(NSInteger)index {
    int type = sqlite3_column_type(self->_stmt, (int)index);
    switch (type) {
        case SQLITE_NULL:
            return [NSNull null];
        case SQLITE_INTEGER:
            return [NSNumber numberWithInteger:[self integerValueAtColumnIndex:index]];
        case SQLITE_FLOAT:
            return [NSNumber numberWithFloat:[self floatValueAtColumnIndex:index]];
        case SQLITE_TEXT:
            return [self stringValueAtColumnIndex:index];
        case SQLITE_BLOB:
            return [self dataValueAtColumnIndex:index];
        default:
            dassert(NO);
            break;
    }
    dassert(NO);
    return nil;
}

- (NSDictionary *)values {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    NSInteger columnCount = self.columnCount;
    for (NSInteger i = 0; i < columnCount; i++) {
        NSString *name = [self nameAtColumnIndex:i];
        NSString *value = [self valueAtColumnIndex:i];
        [dictionary setObject:value forKey:name];
    }
    return [dictionary copy];
}

- (NSArray *)valueArray {
    NSMutableArray *array = [NSMutableArray array];
    NSInteger columnCount = self.columnCount;
    for (NSInteger i = 0; i < columnCount; i++) {
        NSString *value = [self valueAtColumnIndex:i];
        [array addObject:value];
    }
    return [array copy];
}

#pragma mark - bind

- (void)bindIndex:(int)index sqlite3Value:(sqlite3_value *)value error:(NSError **)errorPtr {
    self->_resultCode = sqlite3_bind_value(self->_stmt, index, value);
    [self _handleResult:errorPtr];
}

- (void)bindIndexNull:(int)index error:(NSError **)errorPtr {
    self->_resultCode = sqlite3_bind_null(self->_stmt, index);
    [self _handleResult:errorPtr];
}

- (void)bindIndex:(int)index int:(int)integer error:(NSError **)errorPtr {
    self->_resultCode = sqlite3_bind_int(self->_stmt, index, integer);
    [self _handleResult:errorPtr];
}

- (void)bindIndex:(int)index integer:(UInt64)integer error:(NSError **)errorPtr {
    self->_resultCode = sqlite3_bind_int64(self->_stmt, index, integer);
    [self _handleResult:errorPtr];
}

- (void)bindIndex:(int)index float:(double)value error:(NSError **)errorPtr {
    self->_resultCode = sqlite3_bind_double(self->_stmt, index, value);
    [self _handleResult:errorPtr];
}

- (void)bindIndex:(int)index UTF8String:(const char *)text length:(NSUInteger)bytes desctuctor:(SLStatementBindDestructor)destructor error:(NSError **)errorPtr {
    self->_resultCode = sqlite3_bind_text(self->_stmt, index, text, (int)bytes, destructor);
    [self _handleResult:errorPtr];
}

- (void)bindIndex:(int)index string:(NSString *)string error:(NSError **)errorPtr {
    [self bindIndex:index UTF8String:string.UTF8String length:-1 desctuctor:SQLITE_TRANSIENT error:errorPtr];
}

- (void)bindIndex:(int)index zeroBlobLength:(NSUInteger)bytes error:(NSError **)errorPtr {
    self->_resultCode = sqlite3_bind_zeroblob(self->_stmt, index, (int)bytes);
}

- (void)bindIndex:(int)index blob:(const void *)blob length:(NSUInteger)bytes desctuctor:(SLStatementBindDestructor)destructor error:(NSError **)errorPtr {
    self->_resultCode = sqlite3_bind_blob(self->_stmt, index, blob, (int)bytes, destructor);
    [self _handleResult:errorPtr];
}

- (void)bindIndex:(int)index data:(NSData *)data error:(NSError **)errorPtr {
    [self bindIndex:index UTF8String:data.bytes length:data.length desctuctor:SQLITE_TRANSIENT error:errorPtr];
}

- (NSInteger)numberOfBindParameters {
    return sqlite3_bind_parameter_count(self->_stmt);
}

- (void)removeBinding:(NSError **)errorPtr {
    self->_resultCode = sqlite3_clear_bindings(self->_stmt);
    [self _handleResult:errorPtr];
}

#pragma mark fast enumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id [])buffer count:(NSUInteger)len {
    NSError *error = nil;
    if(state->state == 0)
    {
        state->state = 1;
        state->mutationsPtr = &state->extra[0];
        [self reset:&error];
        if (error != nil) {
            return 0;
        }
    }
    state->itemsPtr = buffer;
    if (self->_resultCode == SQLITE_DONE) {
        [self reset:&error];
        return 0;
    }

    NSUInteger count = 0;
    while (count < len) {
        [self step:&error];
        if (error || self->_resultCode == SQLITE_DONE) {
            break;
        }
        buffer[count] = [self values];
        count += 1;
    }
    return count;
}


@end


@implementation SLStatement (Shortcut)


- (NSDictionary *)firstRow {
    NSError *error = nil;
    [self step:&error];
    if ([self _handleResult:&error]) return nil;
    
    id result = [self values];
    [self reset:&error];
    return result;
}

- (NSArray *)allRows {
    NSMutableArray *array = [NSMutableArray array];
    for (id row in self) {
        [array addObject:row];
    }
    return [array copy];
}

@end
