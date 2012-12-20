//
//  _Error.h
//  Sqlite3
//
//  Created by Jeong YunWon on 12. 12. 21..
//  Copyright (c) 2012년 youknowone.org. All rights reserved.
//

@interface SLError : NSError

- (id)initWithDatabase:(sqlite3 *)db;
+ (id)errorWithDatabase:(sqlite3 *)db;

@end
