//
//  _Error.h
//  SQLite
//
//  Created by Jeong YunWon on 12. 12. 21..
//  Copyright (c) 2012 youknowone.org. All rights reserved.
//

@interface SLError : NSError

- (id)initWithDatabase:(sqlite3 *)db;
+ (id)errorWithDatabase:(sqlite3 *)db;

@end
