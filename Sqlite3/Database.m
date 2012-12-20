//
//  SLDatabase.m
//  Sqlite3
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

#import "Database.h"

#import "Statement.h"
#import "_Error.h"

#import "SQL.h"

#import "debug.h"

@interface SLStatement ()

- (BOOL)_handleResult:(NSError **)errorPtr;

@end


@implementation SLDatabase

@synthesize resultCode=_resultCode, sqlite3=_sqlite3;

- (BOOL)_handleResult:(NSError **)errorPtr {
    if (self->_resultCode != SQLITE_OK) {
        if (errorPtr) {
            *errorPtr = [SLError errorWithDatabase:self->_sqlite3];
        }
        return YES;
    }
    return NO;
}

- (id)initWithMemory {
    NSError *error = nil;
    self = [self initWithMemory:&error];
    return self;
}

- (id)initWithFile:(NSString*)filename {
    NSError *error = nil;
    self = [self initWithFile:filename error:&error];
    return self;
}

- (id)initWithMemory:(NSError **)errorPtr {
    self = [super init];
    if (self != nil) {
        [self openMemory:errorPtr];
        if (*errorPtr == nil) {
            [self release];
            return nil;
        }
    }
    return self;
}

- (id)initWithFile:(NSString *)filename error:(NSError **)errorPtr {
    self = [super init];
    if (self != nil) {
        [self openFile:filename error:errorPtr];
        if (*errorPtr == nil) {
            [self release];
            return nil;
        }
    }
    return self;
}

+ (id)databaseWithMemory {
    return [[[self alloc] initWithMemory] autorelease];
}

+ (id)databaseWithFile:(NSString *)filename {
    return [[[self alloc] initWithFile:filename] autorelease];
}

+ (id)databaseWithFile:(NSString *)filename error:(NSError **)errorPtr {
    return [[[self alloc] initWithFile:filename error:errorPtr] autorelease];
}

- (void)dealloc {
    if (nil != self->_sqlite3) {
        [self close];
    }
    [super dealloc];
}

- (int)errorCode {
    return sqlite3_errcode(self->_sqlite3);
}

- (NSString *)errorMessage {
    return [NSString stringWithUTF8String:sqlite3_errmsg(self->_sqlite3)];
}

#pragma mark -
#pragma mark sqlite3 wrapping

- (bool)openMemory {
    NSError *error = nil;
    [self openMemory:&error];
    return error == nil;
}

// UTF-8
- (bool)openFile:(NSString *)filename {
    NSError *error = nil;
    [self openFile:filename error:&error];
    return error == nil;
}
// UTF-8
- (bool)openFile:(NSString *)filename flags:(int)flags vfs:(const char *)zVfs {
    NSError *error = nil;
    [self openFile:filename flags:flags vfs:zVfs error:&error];
    return error == nil;
}

- (void)openMemory:(NSError **)errorPtr {
    [self openFile:@":memory:" flags:SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE vfs:NULL error:errorPtr];
}

- (void)openFile:(NSString *)filename error:(NSError **)errorPtr {
    dlog(SQLITE3_DEBUG, @"dbfile: %@", filename);
    self->_resultCode = sqlite3_open(filename.UTF8String, &self->_sqlite3);
    if (self->_resultCode != SQLITE_OK && errorPtr) {
        if (self->_sqlite3) {
            *errorPtr = [SLError errorWithDatabase:self->_sqlite3];
        } else {
            *errorPtr = [SLError errorWithDomain:@"sqlite" code:0 userInfo:@{@"description":@"Failed to initialization"}];
        }
    }
}

- (void)openFile:(NSString *)filename flags:(int)flags vfs:(const char *)zVfsOrNull error:(NSError **)errorPtr {
    dlog(SQLITE3_DEBUG, @"dbfile: %@", filename);
    self->_resultCode = sqlite3_open_v2(filename.UTF8String, &self->_sqlite3, flags, zVfsOrNull);
    if (self->_resultCode != SQLITE_OK && errorPtr) {
        if (self->_sqlite3) {
            *errorPtr = [SLError errorWithDatabase:self->_sqlite3];
        } else {
            *errorPtr = [SLError errorWithDomain:@"sqlite" code:0 userInfo:@{@"description":@"Failed to initialization"}];
        }
    }
}

- (bool)close {
    NSError *error = nil;
    [self close:&error];
    return error == nil;
}

- (void)close:(NSError **)errorPtr {
    self->_resultCode = sqlite3_close(self->_sqlite3);
    if (self->_resultCode != SQLITE_OK && errorPtr) {
        *errorPtr = [SLError errorWithDatabase:self->_sqlite3];
    } else {
        self->_sqlite3 = nil;
    }
}

- (bool)executeQuery:(NSString*)sql {
    self->_resultCode = sqlite3_exec(self->_sqlite3, [sql UTF8String], NULL, NULL, (char **)&self->_errorMessage);
    return self->_resultCode == SQLITE_OK || self->_resultCode == SQLITE_DONE || self->_resultCode ==SQLITE_ROW;
}

//int SLDatabaseExecuteCallbackSelecter(void *target, int columns, char **column_text, char **column_name) {
//    
//}
//
//- (bool)executeQuery:(NSString *)sql target:(id)target selector:(SEL)selector {
//    [self _freeErrorMessage];
//    sqlite3_exec(self->_sqlite3, sql.UTF8String, SLDatabaseExecuteCallbackSelecter, target, &self->_errorMessage);
//}
//
//- (bool)executeQuery:(NSString *)sql completions:(SLExecuteCallback)callback {
//
//}

- (SLStatement *)prepareQuery:(NSString *)sql error:(NSError **)errorPtr {
    return [[[SLStatement alloc] initWithDatabase:self query:sql error:errorPtr] autorelease];
}

- (NSArray *)prepareQueries:(NSString *)sql error:(NSError **)errorPtr {
    NSMutableArray *stack = [NSMutableArray array];
    const char *query = sql.UTF8String;
    const char *head = query;
    sqlite3_stmt *stmt;
    while (1) {
        self->_resultCode = sqlite3_prepare_v2(self->_sqlite3, head, -1, &stmt, &head);
        if ([self _handleResult:errorPtr]) {
            break;
        }
        [stack addObject:[SLStatement statementWithSqlite3:self->_sqlite3 statement:stmt freeWhenDone:YES]];
    }
    return [NSArray arrayWithArray:stack];
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

    return [NSString stringWithFormat:@"INSERT INTO `%@` (%@) VALUES (%@)", self.table, keyString, valueString];
}

- (NSString *)description {
    return self.query;
}

@end

