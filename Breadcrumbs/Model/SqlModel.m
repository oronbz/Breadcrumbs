//
//  SqlModel.m
//  Breadcrumbs
//
//  Created by Oron Ben Zvi on 02/01/2016.
//  Copyright © 2016 Oron Ben Zvi. All rights reserved.
//

#import "BreadcrumbSql.h"
#import "LastUpdateSql.h"
#import "SqlModel.h"

@implementation SqlModel

- (instancetype)init {
    self = [super init];
    if (self) {
        NSFileManager* fileManager = [NSFileManager defaultManager];
        NSArray* paths =
            [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
        NSURL* directoryUrl = [paths objectAtIndex:0];
        NSURL* fileUrl = [directoryUrl URLByAppendingPathComponent:@"database.db"];
        NSString* filePath = [fileUrl path];
        const char* cFilePath = [filePath UTF8String];
        int res = sqlite3_open(cFilePath, &database);
        if (res != SQLITE_OK) {
            NSLog(@"ERROR: fail to open db");
            database = nil;
        }
        [BreadcrumbSql createTable:database];
        [LastUpdateSql createTable:database];
    }
    return self;
}

- (void)addBreadcrumb:(Breadcrumb*)breadcrumb {
    [BreadcrumbSql addBreadcrumb:database breadcrumb:breadcrumb];
}

- (void)deleteBreadcrumb:(Breadcrumb*)breadcrumb {
    [BreadcrumbSql deleteBreadcrumb:database breadcrumb:breadcrumb];
}

- (NSArray*)getBreadcrumbs {
    return [BreadcrumbSql getBreadcrumbs:database];
}

- (NSString*)getBreadcrumbsLastUpdateDate {
    return [BreadcrumbSql getLastUpdateDate:database];
}

- (void)setBreadcrumbsLastUpdateDate:(NSString*)date {
    [BreadcrumbSql setLastUpdateDate:database date:date];
}

- (void)updateBreadcrumbs:(NSArray*)breadcrumbs {
    [BreadcrumbSql updateBreadcrumbs:database breadcrumbs:breadcrumbs];
}

@end
