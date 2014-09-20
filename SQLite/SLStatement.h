//
//  Statement.h
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

/*!
 *  @file
 *  @brief SLStatement is objective-c model for sqlite3_stmt
 *
 *  This provides simple map for sqlite3 api and some shortcuts.
 */

#include <sqlite3.h>

/*!
 *  @breif destructor for bind function
 */
typedef void(* SLStatementBindDestructor)(void*);


@class SLDatabase;
/*!
 *  @brief sqlite3_stmt wrapper
 */
@interface SLStatement : NSObject<NSFastEnumeration> {
    sqlite3 *_sqlite3;
    sqlite3_stmt *_stmt;
    int _resultCode;
    struct {
        int freeWhenDone: 1;
    } statementFlags;
}

@property(nonatomic, readonly) int resultCode;

/*!
 *  @brief Minimal initializer.
 */
- (instancetype)initWithSQLite:(sqlite3 *)sqlite3;
/*!
 *  @brief init and import statement
 */
- (instancetype)initWithSQLite:(sqlite3 *)sqlite3 statement:(sqlite3_stmt *)statement freeWhenDone:(BOOL)flag;
/*!
 *  @brief init and prepare query
 */
- (instancetype)initWithDatabase:(SLDatabase *)database query:(NSString *)query error:(NSError **)errorPtr;

/*!
 *  @brief Minimal initializer.
 */
+ (instancetype)statementWithSQLite:(sqlite3 *)sqlite3;
/*!
 *  @brief init and import statement
 */
+ (instancetype)statementWithSQLite:(sqlite3 *)sqlite3 statement:(sqlite3_stmt *)statement freeWhenDone:(BOOL)flag;
/*!
 *  @brief init and prepare query
 */
+ (instancetype)statementWithDatabase:(SLDatabase *)database query:(NSString *)query error:(NSError **)errorPtr;

/*!
 *  @name low level api
 */

/*!
 *  @brief sqlite3_prepare_v2
 */
- (void)prepareQuery:(NSString *)query error:(NSError **)errorPtr;
/*!
 *  @brief sqlite3_step
 */
- (void)step:(NSError **)errorPtr;
/*!
 *  @brief sqlite3_reset
 */
- (void)reset:(NSError **)errorPtr;

/*!
 *  @brief sqlite3_data_count
 */
- (NSInteger)rowCount __deprecated; // deprecated due to wrong implementation
/*!
 *  @brief sqlite3_column_count
 */
@property (nonatomic, readonly) NSInteger columnCount;
/*!
 *  @brief sqlite3_column_name
 */
- (NSString *)nameAtColumnIndex:(NSInteger)index;
//- (NSString *)databaseNameAtColumnIndex:(NSInteger)index;
//- (NSString *)tableNameAtColumnIndex:(NSInteger)index;
//- (NSString *)originNameAtColumnIndex:(NSInteger)index;
/*!
 *  @brief sqlite3_column_type
 */
- (int)typeForColumnIndex:(NSInteger)index;
/*!
 *  @brief NSString conversion for sqlite3_column_text
 */
- (NSString *)stringValueAtColumnIndex:(NSInteger)index;
/*!
 *  @brief sqlite3_column_int
 */
- (NSInteger)integerValueAtColumnIndex:(NSInteger)index;
/*!
 *  @brief NSData conversion for sqlite3_column_blob
 */
- (NSData *)dataValueAtColumnIndex:(NSInteger)index;
/*!
 *  @brief sqlite3_column_float
 */
- (double)floatValueAtColumnIndex:(NSInteger)index;
/*!
 *  @brief sqlite3_column_type == SQLITE_NULL
 */
- (BOOL)isNullAtColumnIndex:(NSInteger)index;

/*!
 *  @name low level shortcuts
 */
/*!
 *  @brief NSNumber for sqlite3_column_int or sqlite3_column_float
 */
- (NSNumber *)numberValueAtColumnIndex:(NSInteger)index;
/*!
 *  @brief sqlite3_column_type based value object
 */
- (id)valueAtColumnIndex:(NSInteger)index;
/*!
 *  @brief Dictionary formed row
 */
@property (nonatomic, readonly, copy) NSDictionary *values;
/*
 *  @brief Array formed row
 */
@property (nonatomic, readonly, copy) NSArray *valueArray;

/*
 *  @name binds
 */
- (void)bindIndex:(int)index sqlite3Value:(sqlite3_value *)value error:(NSError **)errorPtr;

- (void)bindIndexNull:(int)index error:(NSError **)errorPtr;
- (void)bindIndex:(int)index int:(int)integer error:(NSError **)errorPtr;
- (void)bindIndex:(int)index integer:(UInt64)integer error:(NSError **)errorPtr;
- (void)bindIndex:(int)index float:(double)value error:(NSError **)errorPtr;

- (void)bindIndex:(int)index UTF8String:(const char *)text length:(NSUInteger)bytes desctuctor:(SLStatementBindDestructor)destructor error:(NSError **)errorPtr;
- (void)bindIndex:(int)index string:(NSString *)string error:(NSError **)errorPtr;

- (void)bindIndex:(int)index zeroBlobLength:(NSUInteger)bytes error:(NSError **)errorPtr;
- (void)bindIndex:(int)index blob:(const void *)blob length:(NSUInteger)bytes desctuctor:(SLStatementBindDestructor)destructor error:(NSError **)errorPtr;
- (void)bindIndex:(int)index data:(NSData *)data error:(NSError **)errorPtr;

@property (nonatomic, readonly) NSInteger numberOfBindParameters;
- (void)removeBinding:(NSError **)errorPtr;

@end

/*!
 *  @brief high-level shortcuts
 */
@interface SLStatement (Shortcut)

/*!
 *  @brief values for first row
 */
@property (nonatomic, readonly, copy) NSDictionary *firstRow;
/*!
 *  @brief values for all rows. Use enumeration protocol for enumerator.
 */
@property (nonatomic, readonly, copy) NSArray *allRows; // use enumerator protocol for enumeration

@end

