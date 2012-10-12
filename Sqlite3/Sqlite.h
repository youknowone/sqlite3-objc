//
//  SLDatabase.h
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

//
//    In this file:
//    Query is SQL statement as NSString type
//    SQL is SQL statement as SLSQL type

#include <sqlite3.h>

#import <Foundation/Foundation.h>

@class SLCursor;
@interface SLDatabase : NSObject {
    int _resultCode;
    const char *_errorMessage;
@public
    sqlite3 *_sqlite3;
}

@property(nonatomic, readonly) int resultCode;
@property(nonatomic, readonly) NSString *errorMessage;
@property(nonatomic, readonly) sqlite3 *sqlite3;

- (id)initWithMemory;
- (id)initWithFile:(NSString*)filename;

+ (id)databaseWithMemory;
+ (id)databaseWithFile:(NSString*)filename;

- (bool)openMemory;
- (bool)openFile:(NSString *)filename;
- (bool)openFile:(NSString *)filename flags:(int)flags vfs:(const char *)zVfsOrNull;
- (void)close;

- (bool)executeQuery:(NSString *)sql;
- (SLCursor *)cursorByQuery:(NSString *)sql;
- (SLCursor *)cursorByFormat:(NSString*)format, ... NS_FORMAT_FUNCTION(1,2);

+ (int)versionNumber;
+ (int)libraryVersionNumber;

@end

@class SLSQL;
@interface SLDatabase (SLSQL)

- (void)executeSQL:(SLSQL *)sql;
- (SLCursor*)cursorBySQL:(SLSQL *)wrapper;

@end

@interface SLCursor: NSObject {
    int _resultCode;
    sqlite3_stmt *_statement;
}

@property(nonatomic, readonly) int resultCode;
@property(nonatomic, readonly, getter = isEndOfCursor) BOOL endOfCursor;
@property(nonatomic, readonly) NSInteger rowCount, columnCount;

- (id)initWithDatabase:(SLDatabase *)database sql:(NSString *)sql errorMessage:(const char**)bufferOrNull;
+ (id)cursorWithSqlite3:(SLDatabase *)database sql:(NSString *)sql errorMessage:(const char**)bufferOrNull;

- (void)reset;
- (void)next;

- (NSString *)nameAtColumnIndex:(NSInteger)index;
- (NSString *)stringValueAtColumnIndex:(NSInteger)index;
- (NSInteger)integerValueAtColumnIndex:(NSInteger)index;

@end

// temporary paste here for partial implementation

@interface SLSQLInsertBuilder : NSObject {
    NSString *_table;
    NSMutableDictionary *_data;
}

@property(nonatomic, readonly) NSString *query;
@property(nonatomic, copy) NSString *table;
@property(nonatomic, readonly) NSMutableDictionary *data;

- (id)initWithTable:(NSString *)table;
- (id)initWithTable:(NSString *)table data:(NSDictionary *)data;

- (void)setData:(id)data forKey:(id)key;

@end
