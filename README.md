
@mainpage

sqlite3-objc is Objective-C wrapper of libsqlite3

Cursor api in 0.1 is deprecated.

sqlite3-objc intends shallow wrapper but also provides higher level api

  * Shallow wrapper
  * High-level shortcuts
  * Objective-C style error

# Example
## Shallow wrappers

    #import <Sqlite3/Sqlite.h> // common header
    SLDatabase *database = [SLDatabase databaseWithMemory]; // sqlite3 wrapper
    // suppose some data
    [database executeQuery:@"UPDATE table SET field = 1"]; // no return!
    NSError *error = nil;
    NSString *query = @"SELECT * FROM table WHERE field = ?";
    SLStatement *statement = [SLDatabase prepareQuery:query error:&error]; // sqlite3_stmt wrapper
    [statement bindIndex:1 integer:0 error:&error]; // sqlite_bind_int
    [statement step:&error]; // sqlite3_step
    [statement integerValueAtColumnIndex:0]; // sqlite3_column_int
    [statement reset:&error]; // sqlite3_reset
    
## High-level shortcuts

    NSDictionary *firstRow = [statement firstRow]; // useful for 'unique' or 'limit 1' query.
    NSLog(@"first row: %@", firstRow); // by dictionary
    for (NSDictionary *row in statement) { // useful for enumerate table
        // each row as dictionary
        NSLog(@"field1 %@ field2 %@", [row objectForKey:@"field1"], [row objectForKey:@"field2");
    }
    NSArray *allRows = [statement allRows]; // useful to save result table
    NSDictionary *aRow = [allRows objectAtIndex:5]; // pick a row etc
