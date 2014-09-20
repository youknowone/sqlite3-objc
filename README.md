
@mainpage

sqlite3-objc is Objective-C wrapper of libsqlite3

Cursor API in 0.1 is deprecated.

sqlite3-objc intends shallow wrapper but also provides higher level api

  * Shallow wrapper
  * High-level shortcuts
  * Objective-C style error

# Example

## High-level shortcuts

    #import <SQLite/SQLite.h> // common header
    SLDatabase *database = [SLDatabase databaseWithMemory]; // sqlite3 wrapper
    // suppose some data
    [database executeQuery:@"UPDATE `test` SET `field1` = 1"]; // no return!
    NSError *error = nil;
    NSString *query = @"SELECT * FROM `test` WHERE `rowid` = 1";
    SLStatement *statement = [database prepareQuery:query error:&error]; // sqlite3_stmt wrapper

    NSDictionary *firstRow = [statement firstRow]; // useful for 'unique' or 'limit 1' query.
    NSLog(@"first row: %@", firstRow); // by dictionary
    for (NSDictionary *row in statement) { // useful for enumerate table
        // each row as dictionary
        NSLog(@"field1 %@ field2 %@", [row objectForKey:@"field1"], [row objectForKey:@"field2"]);
    }
    NSArray *allRows = [statement allRows]; // useful to save result table
    NSDictionary *aRow = [allRows objectAtIndex:0]; // pick a row etc
    NSLog(@"a row: %@", aRow);

## Shallow wrappers

    #import <SQLite/SQLite.h> // common header
    SLDatabase *database = [SLDatabase databaseWithMemory]; // sqlite3 wrapper
    // suppose some data
    [database executeQuery:@"UPDATE `test` SET `field1` = 1"]; // no return!
    NSError *error = nil;
    NSString *query = @"SELECT * FROM `test` WHERE `field1` = ?";
    SLStatement *statement = [database prepareQuery:query error:&error]; // sqlite3_stmt wrapper
    [statement bindIndex:1 integer:0 error:&error]; // sqlite_bind_int
    [statement step:&error]; // sqlite3_step
    NSLog(@"integer value: %ld", [statement integerValueAtColumnIndex:1]); // sqlite3_column_int
    [statement reset:&error]; // sqlite3_reset

