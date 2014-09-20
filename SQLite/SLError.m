//
//  _Error.m
//  SQLite
//
//  Created by Jeong YunWon on 12. 12. 21..
//  Copyright (c) 2012 youknowone.org. All rights reserved.
//

#include <sqlite3.h>

#import "SLError.h"

@implementation SLError

- (id)initWithDatabase:(sqlite3 *)db {
    self = [super initWithDomain:@"sqlite" code:sqlite3_errcode(db) userInfo:@{@"message":[NSString stringWithUTF8String:sqlite3_errmsg(db)]}];
    return self;
}

+ (id)errorWithDatabase:(sqlite3 *)db {
    return [[[self alloc] initWithDatabase:db] autorelease];
}

@end
