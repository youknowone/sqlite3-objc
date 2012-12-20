//
//  Sqlite3Tests.m
//  Sqlite3Tests
//
//  Created by youknowone on 12. 10. 5..
//  Copyright (c) 2012 youknowone.org All rights reserved.
//

#import "Sqlite3Tests.h"


@implementation Sqlite3Tests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

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
    
    return db;
}

@end
