//
//  BreadcrumbSql.h
//  Breadcrumbs
//
//  Created by Oron Ben Zvi on 02/01/2016.
//  Copyright © 2016 Oron Ben Zvi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "Breadcrumb.h"

@interface BreadcrumbSql : NSObject

+ (BOOL)createTable:(sqlite3 *)database;

+ (void)addBreadcrumb:(sqlite3 *)database breadcrumb:(Breadcrumb *)breadcrumb;
+ (void)deleteBreadcrumb:(sqlite3 *)database breadcrumb:(Breadcrumb *)breadcrumb;

+ (NSArray *)getBreadcrumbs:(sqlite3 *)database;
+ (NSString *)getLastUpdateDate:(sqlite3 *)database;
+ (void)setLastUpdateDate:(sqlite3 *)database date:(NSString *)date;
+ (void)updateBreadcrumbs:(sqlite3 *)database breadcrumbs:(NSArray *)breadcrumbs;

@end
