//
//  SLCursor.h
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

/*!
 *  @file
 *  @brief Cursor API is deprecated. Use Statement for future.
 *
 *  Cursor does not provide ways to control statement in sqlite3 level, even for binding.
 *  And it steps implicitly in some case.
 *  Statement provides transparent wrapper api for sqlite3_stmt and shortcut api too.
 *  Cursor api is kept only for legacy support.
 */

#include <sqlite3.h>

#import <SQLite/SLDatabase.h>

/*!
 *  @breif Cursor is deprecated. Use Statement for future.
 */
@interface SLCursor: NSObject {
    int _resultCode;
    sqlite3_stmt *_statement;
}

@property(nonatomic, readonly) int resultCode;
@property(nonatomic, readonly, getter = isEndOfCursor) BOOL endOfCursor;
@property(nonatomic, readonly) NSInteger rowCount  __deprecated; // deprecated due to wrong implementation
@property(nonatomic, readonly) NSInteger columnCount;

- (instancetype)initWithDatabase:(SLDatabase *)database sql:(NSString *)sql errorMessage:(const char**)bufferOrNull;
+ (instancetype)cursorWithSQLite:(SLDatabase *)database sql:(NSString *)sql errorMessage:(const char**)bufferOrNull;

- (void)reset;
- (void)next;

- (NSString *)nameAtColumnIndex:(NSInteger)index;
- (NSString *)stringValueAtColumnIndex:(NSInteger)index;
- (NSInteger)integerValueAtColumnIndex:(NSInteger)index;

@end


@class SLSQL;
@interface SLDatabase (SLCursor)

- (SLCursor *)cursorByFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1, 2);
- (SLCursor *)cursorByQuery:(NSString*)sql;
- (SLCursor *)cursorBySQL:(SLSQL *)wrapper;

@end
