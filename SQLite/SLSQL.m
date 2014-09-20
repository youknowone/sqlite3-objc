//
//  SLSQL.m
//  SQLite
//
//  Created by youknowone on 10. 11. 1..
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

#import "SLSQL.h"

#if __LP64__ || (TARGET_OS_EMBEDDED && !TARGET_OS_IPHONE) || TARGET_OS_WIN32 || NS_BUILD_32_LIKE_64
    #define NSUIntegerFormat "%lu"
#else
    #define NSUIntegerFormat "%u"
#endif

@implementation SLSQL
@synthesize SQL=_SQL;

- (instancetype)init {
    if ((self = [super init]) != nil) {
        _SQL = [[NSMutableString alloc] init];
    }
    return self;
}

- (instancetype)initWithString:(NSString *)string {
    if ((self = [self init]) != nil) {
        [_SQL appendString:string];
    }
    return self;
}

- (instancetype)initWithFormat:(NSString *)format, ... {
    if ((self = [self init]) != nil) {
        va_list args;
        va_start(args, format);
        NSString *string = [[NSString alloc] initWithFormat:format arguments:args];
        [_SQL appendString:string];
        [string release];
        va_end(args);
    }
    return self;    
}

- (void)dealloc {
    [_SQL release];
    [super dealloc];
}

- (NSString *)description {
    return _SQL;
}

- (SLSQL *)groupBy:(NSString *)groups {
    [_SQL appendString:@" GROUP BY "];
    [_SQL appendString:groups];
    return self;
}

- (SLSQL *)groupBy:(NSString *)groups having:(NSString*)groupContidion {
    [self groupBy:groups];
    [_SQL appendString:@" HAVING "];
    [_SQL appendString:groupContidion];
    return self;
}

- (SLSQL *)orderBy:(NSString *)condition {
    [_SQL appendFormat:@" ORDER BY %@", condition];
    return self;
}

- (SLSQL *)limit:(NSUInteger)count {
    [_SQL appendFormat:@" LIMIT "NSUIntegerFormat, count];
    return self;
}

- (SLSQL *)limit:(NSUInteger)from count:(NSUInteger)count {
    [_SQL appendFormat:@" LIMIT "NSUIntegerFormat","NSUIntegerFormat, from, count];
    return self;
}

+ (SLSQL *)SQLWithString:(NSString *)string {
    return [[[SLSQL alloc] initWithString:string] autorelease];
}

+ (SLSQL *)SQLWithFormat:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    id SQL = [[self alloc] initWithString:[[[NSString alloc] initWithFormat:format arguments:args] autorelease]];
    va_end(args);
    return [SQL autorelease];
}

+ (NSString *)alias:(NSString *)SQL as:(NSString *)alias {
    return [NSString stringWithFormat:@"%@ AS `%@`", SQL, alias];
}

+ (NSString *)customListSeparatedBy:(NSString *)separator withStrings:(NSString *)firstSQL, ... {
    va_list args;
    va_start(args, firstSQL);
    NSString *arg = firstSQL;
    NSMutableString *sql = [NSMutableString stringWithFormat:@"`%@`", arg];
    for ( arg = va_arg(args, NSString*); arg != nil; arg = va_arg(args, NSString*) )
    {
        [sql appendFormat:@"%@ %@", separator, arg];
    }
    va_end(args);
    return sql;
}

+ (NSString *)commaListWithStrings:(NSString *)firstSQL, ... {
    va_list args;
    va_start(args, firstSQL);
    NSString *arg = firstSQL;
    NSMutableString *sql = [NSMutableString stringWithFormat:@"`%@`", arg];
    for ( arg = va_arg(args, NSString*); arg != nil; arg = va_arg(args, NSString*) )
    {
        [sql appendFormat:@", `%@`", arg];
    }
    va_end(args);
    return sql;
}

+ (NSString *)rawCommaListWithStrings:(NSString *)firstSQL, ... {
    va_list args;
    va_start(args, firstSQL);
    NSString *arg = firstSQL;
    NSMutableString *sql = [NSMutableString stringWithString:arg];
    for ( arg = va_arg(args, NSString*); arg != nil; arg = va_arg(args, NSString*) )
    {
        [sql appendString:@", "];
        [sql appendString:arg];
    }
    va_end(args);
    return sql;
}

+ (NSString *)andConditionWithStrings:(NSString *)firstSQL, ... {
    va_list args;
    va_start(args, firstSQL);
    NSString *arg = firstSQL;
    NSMutableString *sql = [NSMutableString stringWithString:arg];
    for ( arg = va_arg(args, NSString*); arg != nil; arg = va_arg(args, NSString*) )
    {
        [sql appendString:@" AND "];
        [sql appendString:arg];
    }
    va_end(args);
    return [NSString stringWithFormat:@"(%@)", sql];
}

+ (NSString *)orConditionWithStrings:(NSString *)firstSQL, ... {
    va_list args;
    va_start(args, firstSQL);
    NSString *arg = firstSQL;
    NSMutableString *sql = [NSMutableString stringWithString:arg];
    for ( arg = va_arg(args, NSString*); arg != nil; arg = va_arg(args, NSString*) )
    {
        [sql appendString:@" OR "];
        [sql appendString:arg];
    }
    va_end(args);
    return [NSString stringWithFormat:@"(%@)", sql];
}

+ (NSString *)customListSeparatedBy:(NSString *)separator withArray:(NSArray *)array {
    if ( nil == array || 0 == [array count] ) return nil;
    NSMutableString *sql = [NSMutableString stringWithString:array[0]];
    NSUInteger index = 1;
    while ( [array count] > index ) {
        [sql appendFormat:@"%@ %@", separator, array[index]];
        index++;
    }
    return sql;
}

+ (NSString *)commaListWithArray:(NSArray *)array {
    if ( nil == array || 0 == [array count] ) return nil;
    NSMutableString *sql = [NSMutableString stringWithString:array[0]];
    NSUInteger index = 1;
    while ( [array count] > index ) {
        [sql appendFormat:@", `%@`", array[index]];
        index++;
    }
    return sql;
}

+ (NSString *)rawCommaListWithArray:(NSArray *)array {
    return [self customListSeparatedBy:@", " withArray:array];    
}

+ (NSString *)andConditionWithArray:(NSArray *)array {
    return [NSString stringWithFormat:@"( %@ )", [self customListSeparatedBy:@" AND " withArray:array]];
}

+ (NSString *)orConditionWithArray:(NSArray *)array {
    return [NSString stringWithFormat:@"( %@ )", [self customListSeparatedBy:@" OR " withArray:array]];
}


+ (SLSQL *)SQLWithSelect:(NSString *)column from:(NSString *)table where:(NSString *)condition {
    return [SLSQL SQLWithString:[NSString stringWithFormat:@"SELECT %@ FROM %@ WHERE %@", column, table, condition]];
}

+ (SLSQL *)SQLWithDeleteFrom:(NSString *)table where:(NSString*)condition {
    return [[[SLSQL alloc] initWithFormat:@"DELETE FROM %@ WHERE %@", table, condition] autorelease];
}

+ (SLSQL *)SQLWithInsertInto:(NSString *)table values:(NSString*)values {
    return [[[SLSQL alloc] initWithFormat:@"INSERT INTO `%@` VALUES (%@)", table, values] autorelease];
}

+ (SLSQL *)SQLWithInsertInto:(NSString *)table columns:(NSString*)columns values:(NSString*)values {
    return [[[SLSQL alloc] initWithFormat:@"INSERT INTO `%@` (%@) VALUES (%@)", table, columns, values] autorelease];
}

+ (SLSQL *)SQLWithUpdate:(NSString *)table set:(NSString*)setStatements where:(NSString*)condition {
    return [[[SLSQL alloc] initWithFormat:@"UPDATE `%@` SET %@ WHERE %@", table, setStatements, condition] autorelease];
}

@end


@implementation SLDatabase (SLSQL)

- (void)executeSQL:(SLSQL *)sql {
    [self executeQuery:sql.SQL];
}

@end
