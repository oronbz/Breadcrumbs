//
//  LastUpdateSql.h
//  Breadcrumbs
//
//  Created by Oron Ben Zvi on 02/01/2016.
//  Copyright © 2016 Oron Ben Zvi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface LastUpdateSql : NSObject

+ (BOOL)createTable:(sqlite3*)database;
+ (NSString*)getLastUpdateDate:(sqlite3*)database forTable:(NSString*)table;
+ (void)setLastUpdateDate:(sqlite3*)database date:(NSString*)date forTable:(NSString*)table;

@end
