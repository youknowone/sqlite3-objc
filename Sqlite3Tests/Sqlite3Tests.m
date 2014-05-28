//
//  Sqlite3Tests.m
//  Sqlite3Tests
//
//  Created by youknowone on 12. 10. 5..
//  Copyright (c) 2012 youknowone.org All rights reserved.
//

#import "Sqlite3Tests.h"


@implementation Sqlite3Tests

- (SLDatabase *)aDatabase {
    SLDatabase *db = [SLDatabase databaseWithMemory];
    NSString *create = @"create table `test` (`field1` integer, `field2` varchar(20))";
    [db executeQuery:create];
    XCTAssertEqual(SQLITE_OK, db.resultCode, @"create table error: %@", db.errorMessage);

    for (int i = 0; i < 20; i++) {
        NSString *insert = [NSString stringWithFormat:@"insert into `test` values (%d, 'field %d')", i, i];
        [db executeQuery:insert];
        XCTAssertEqual(SQLITE_OK, db.resultCode, @"insert error query: %@ / result:%@", insert, db.errorMessage);
    }

    XCTAssertNotNil(db, @"");
    return db;
}

- (void)testError
{
    NSError *error = nil;
    SLDatabase *db = [self aDatabase];
    NSString *query = @"select * where x = ?";
    [db prepareQuery:query error:&error];
    XCTAssertNotNil(error, @"");
    XCTAssertEqual(error.code, (NSInteger)SQLITE_ERROR, @"error %d: %@", error.code, error.description);

    error = nil;
    query = @"select * from test where field1 = ?";
    SLStatement *statement = [db prepareQuery:query error:&error];
    XCTAssertNil(error, @"error %d: %@", error.code, error);
    [statement bindIndex:0 integer:0 error:&error];
    XCTAssertNotNil(error, @"error %d: %@", error.code, error);
    XCTAssertEqual(error.code, (NSInteger)SQLITE_RANGE, @"");
    error = nil;
    [statement bindIndex:1 string:@"1" error:&error];
    XCTAssertNil(error, @"error %d: %@", error.code, error);
    [statement step:&error];
    XCTAssertNil(error, @"error %d: %@", error.code, error);
    XCTAssertEqual(statement.resultCode, SQLITE_ROW, @"");
    [statement bindIndexNull:1 error:&error];
    XCTAssertNotNil(error, @"error %d: %@", error.code, error);
    XCTAssertEqual(statement.resultCode, SQLITE_MISUSE, @"");
    error = nil;
    [statement reset:&error];
    XCTAssertNil(error, @"");

    error = nil;
    query = @"select * from test where field2 = ?";
    statement = [db prepareQuery:query error:&error];
    XCTAssertNil(error, @"error %d: %@", error.code, error);
    [statement bindIndex:1 integer:1 error:&error];
    XCTAssertNil(error, @"error %d: %@", error.code, error);
    [statement step:&error];
    XCTAssertNil(error, @"error %d: %@", error.code, error);
    XCTAssertEqual(statement.resultCode, SQLITE_DONE, @"");
    [statement reset:&error];
    XCTAssertNil(error, @"");
    [statement bindIndex:1 string:@"field 1" error:&error];
    XCTAssertNil(error, @"error %d: %@", error.code, error);
    [statement step:&error];
    XCTAssertNil(error, @"error %d: %@", error.code, error);
    XCTAssertEqual(statement.resultCode, SQLITE_ROW, @"");
}

- (void)testSelectRow
{
    NSError *error = nil;
    SLDatabase *db = [self aDatabase];
    NSString *query = @"select * from `test` order by `field1` limit 1";
    SLStatement *statement = [db prepareQuery:query error:&error];
    XCTAssertNil(error, @"");
    XCTAssertEqual(SQLITE_OK, statement.resultCode, @"query: %@ result: %@", query, db.errorMessage);

    NSDictionary *row = [statement firstRow];

    XCTAssertEqual((NSInteger)0, [[row objectForKey:@"field1"] integerValue], @"");
    XCTAssertEqual((NSInteger)0, [[row objectForKey:@"field2"] integerValue], @"");
}

- (void)testSelectRows
{
    NSError *error = nil;
    SLDatabase *db = [self aDatabase];
    NSString *query = @"select * from `test` order by `field1`";
    SLStatement *statement = [db prepareQuery:query error:&error];
    XCTAssertNil(error, @"");

    NSInteger count = 0;
    for (NSDictionary *row in statement) {
        NSInteger value = [[row objectForKey:@"field1"] integerValue];
        XCTAssertEqual(value, count, @"");
        count += 1;
    }
}

- (void)testUpdateRow
{
    NSError *error = nil;
    SLDatabase *db = [self aDatabase];
    NSString *query = @"select * from `test` where `rowid` = ?";
    SLStatement *statement = [db prepareQuery:query error:&error];
    XCTAssertNil(error, @"");
    [statement bindIndex:1 integer:3 error:&error];
    XCTAssertNil(error, @"");
    XCTAssertEqual(SQLITE_OK, statement.resultCode, @"query: %@ result: %@", query, db.errorMessage);

    NSDictionary *row = [statement firstRow];
    NSInteger f1 = [[row objectForKey:@"field1"] integerValue];
    XCTAssertEqual((NSInteger)2, f1, @"");

    query =  [NSString stringWithFormat:@"update `test` set `field1` = ? where `field1` = ?"];
    statement = [db prepareQuery:query error:&error];
    XCTAssertNil(error, @"");
    [statement bindIndex:1 integer:1000 error:&error];
    XCTAssertNil(error, @"");
    [statement bindIndex:2 integer:f1 error:&error];
    XCTAssertNil(error, @"");
    [statement step:&error];
    XCTAssertEqual(SQLITE_DONE, statement.resultCode, @"query: %@ result: %@", query, db.errorMessage);

    query = @"select * from `test` where `rowid` = 3";
    statement = [db prepareQuery:query error:&error];
    XCTAssertEqual(SQLITE_OK, statement.resultCode, @"query: %@ result: %@", query, db.errorMessage);

    XCTAssertEqual((NSInteger)1000, [[statement.firstRow objectForKey:@"field1"] integerValue], @"");
}

@end
