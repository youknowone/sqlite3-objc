//
//  SLDatabase.h
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

#include <sqlite3.h>

typedef bool (^SLExecuteCallback)(int, char**, char**);

@class SLCursor;
@class SLStatement;
@interface SLDatabase : NSObject {
    int _resultCode;
    const char *_errorMessage;
@public
    sqlite3 *_sqlite3;
}

@property(nonatomic, readonly) int resultCode;
@property(nonatomic, readonly) int errorCode;
@property(nonatomic, readonly) NSString *errorMessage;
@property(nonatomic, readonly) sqlite3 *sqlite3;

// initializers
- (instancetype)initWithMemory;
+ (instancetype)databaseWithMemory;

- (instancetype)initWithMemory:(NSError **)errorPtr;
- (instancetype)initWithFile:(NSString*)filename error:(NSError **)errorPtr;
+ (instancetype)databaseWithFile:(NSString*)filename error:(NSError **)errorPtr;

- (id)initWithFile:(NSString*)filename __deprecated;
+ (id)databaseWithFile:(NSString*)filename __deprecated;

// open & close
- (bool)openMemory;
- (bool)openFile:(NSString *)filename;

- (void)openMemory:(NSError **)errorPtr;
- (void)openFile:(NSString *)filename error:(NSError **)errorPtr;
- (void)openFile:(NSString *)filename flags:(int)flags vfs:(const char *)zVfsOrNull error:(NSError **)errorPtr;

- (bool)openFile:(NSString *)filename flags:(int)flags vfs:(const char *)zVfsOrNull __deprecated;

- (bool)close;
- (void)close:(NSError **)errorPtr;

// operation

- (bool)executeQuery:(NSString *)sql;
//- (bool)executeQuery:(NSString *)sql target:(id)target selector:(SEL)selector;
//#if NS_BLOCKS_AVAILABLE
//- (bool)executeQuery:(NSString *)sql completions:(SLExecuteCallback)callback;
//#endif

- (SLStatement *)prepareQuery:(NSString *)sql error:(NSError **)errorPtr;
- (NSArray *)prepareQueries:(NSString *)sql error:(NSError **)errorPtr;

+ (int)versionNumber;
+ (int)libraryVersionNumber;

@end




// temporary paste here for partial implementation

@interface SLSQLInsertBuilder : NSObject {
    NSString *_table;
    NSMutableDictionary *_data;
}

@property(nonatomic, readonly) NSString *query;
@property(nonatomic, copy) NSString *table;
@property(nonatomic, readonly) NSMutableDictionary *data;

- (instancetype)initWithTable:(NSString *)table;
- (instancetype)initWithTable:(NSString *)table data:(NSDictionary *)data;

- (void)setData:(id)data forKey:(id)key;

@end
