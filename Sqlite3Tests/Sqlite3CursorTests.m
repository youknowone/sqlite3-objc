//
//  Sqlite3CursorTests.m
//  Sqlite3
//
//  Created by Jeong YunWon on 12. 12. 21..
//  Copyright (c) 2012년 youknowone.org. All rights reserved.
//

#import "Sqlite3CursorTests.h"

#import "Sqlite.h"

#import "SQL.h"
#import "Cursor.h"

@implementation Sqlite3CursorTests

- (SLDatabase *)aDatabase {
    SLDatabase *db = [SLDatabase databaseWithMemory];
    NSString *create = @"create table `test` (`field1` integer, `field2` varchar(20))";
    [db executeQuery:create];
    STAssertEquals(SQLITE_OK, db.resultCode, @"create table error: %@", db.errorMessage);
    
    for (int i = 0; i < 20; i++) {
        NSString *insert = [NSString stringWithFormat:@"insert into `test` values (%d, 'field %d')", i, i];
        [db executeQuery:insert];
        STAssertEquals(SQLITE_OK, db.resultCode, @"insert error query: %@ / result:%@", insert, db.errorMessage);
    }

    STAssertNotNil(db, @"");
    return db;
}

- (void)testSelectRow
{
    SLDatabase *db = [self aDatabase];
    NSString *query = @"select * from `test` order by `field1` limit 1";
    SLCursor *cursor = [db cursorByQuery:query];
    STAssertEquals(SQLITE_ROW, db.resultCode, @"query: %@ result: %@", query, db.errorMessage);
    
    STAssertEquals((NSInteger)0, [cursor integerValueAtColumnIndex:0], @"");
}

- (void)testSelectRows
{
    SLDatabase *db = [self aDatabase];
    NSString *query = @"select * from `test` order by `field1`";
    SLCursor *cursor = [db cursorByQuery:query];
    
    NSInteger count = 0;
    while (![cursor isEndOfCursor]) {
        STAssertEquals(SQLITE_ROW, db.resultCode, @"query: %@ result: %@", query, db.errorMessage);
        NSInteger value = [cursor integerValueAtColumnIndex:0];
        STAssertEquals(value, count, @"");
        [cursor next];
        count += 1;
    }
    STAssertEquals(count, (NSInteger)20, @"");
}

- (void)testUpdateRow
{
    SLDatabase *db = [self aDatabase];
    NSString *query = @"select * from `test` where `rowid` = 3";
    SLCursor *cursor = [db cursorByQuery:query];
    STAssertEquals(SQLITE_ROW, db.resultCode, @"query: %@ result: %@", query, db.errorMessage);
    
    NSInteger f1 = [cursor integerValueAtColumnIndex:0];
    STAssertEquals((NSInteger)2, f1, @"");
    
    query =  [NSString stringWithFormat:@"update `test` set `field1` = 1000 where `field1` = %ld", f1];
    [db executeQuery:query];
    STAssertEquals(SQLITE_OK, db.resultCode, @"query: %@ result: %@", query, db.errorMessage);
    
    query = @"select * from `test` where `rowid` = 3";
    cursor = [db cursorByQuery:query];
    STAssertEquals(SQLITE_ROW, db.resultCode, @"query: %@ result: %@", query, db.errorMessage);
    
    STAssertEquals((NSInteger)1000, [cursor integerValueAtColumnIndex:0], @"");
}

@end
