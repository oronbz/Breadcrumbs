//
//  BreadcrumbSql.m
//  Breadcrumbs
//
//  Created by Oron Ben Zvi on 02/01/2016.
//  Copyright © 2016 Oron Ben Zvi. All rights reserved.
//

#import "Breadcrumb.h"
#import "BreadcrumbSql.h"
#import "LastUpdateSql.h"

@implementation BreadcrumbSql
static NSString* BREADCRUMB_TABLE = @"BREADCRUMBS";
static NSString* BREADCRUMB_ID = @"ID";
static NSString* BREADCRUMB_LOCATION_NAME = @"LOCATION_NAME";
static NSString* BREADCRUMB_CONTENTS = @"CONTENTS";
static NSString* BREADCRUMB_IMAGE_NAME = @"IMAGE_NAME";
static NSString* BREADCRUMB_AUTHOR = @"AUTHOR";
static NSString* BREADCRUMB_LATITUDE = @"LATITUDE";
static NSString* BREADCRUMB_LONGITUDE = @"LONGITUDE";
static NSString* BREADCRUMB_CREATED_AT = @"CREATED_AT";

+ (BOOL)createTable:(sqlite3*)database {
    char* errormsg;

    NSString* sql = [NSString
        stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@ TEXT PRIMARY KEY, %@ TEXT, %@ TEXT, "
                         @"%@ TEXT, %@ TEXT, %@ REAL, %@ REAL, %@ TEXT)",
                         BREADCRUMB_TABLE, BREADCRUMB_ID, BREADCRUMB_LOCATION_NAME,
                         BREADCRUMB_CONTENTS, BREADCRUMB_IMAGE_NAME, BREADCRUMB_AUTHOR,
                         BREADCRUMB_LATITUDE, BREADCRUMB_LONGITUDE, BREADCRUMB_CREATED_AT];
    int res = sqlite3_exec(database, [sql UTF8String], NULL, NULL, &errormsg);
    if (res != SQLITE_OK) {
        NSLog(@"ERROR: failed creating STUDENTS table");
        return NO;
    }
    return YES;
}

+ (NSArray*)getBreadcrumbs:(sqlite3*)database {
    NSMutableArray* data = [[NSMutableArray alloc] init];
    NSString* query = [NSString stringWithFormat:@"SELECT * from %@;", BREADCRUMB_TABLE];
    sqlite3_stmt* statment;
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statment, nil) == SQLITE_OK) {
        while (sqlite3_step(statment) == SQLITE_ROW) {
            NSString* breadcrumbId =
                [NSString stringWithFormat:@"%s", sqlite3_column_text(statment, 0)];
            NSString* locationName =
                [NSString stringWithFormat:@"%s", sqlite3_column_text(statment, 1)];
            NSString* contents =
                [NSString stringWithFormat:@"%s", sqlite3_column_text(statment, 2)];
            NSString* imageName = nil;
            if (sqlite3_column_type(statment, 3) != SQLITE_NULL) {
                imageName = [NSString stringWithFormat:@"%s", sqlite3_column_text(statment, 3)];
            }

            NSString* author = [NSString stringWithFormat:@"%s", sqlite3_column_text(statment, 4)];
            double latitude = sqlite3_column_double(statment, 5);
            double longitude = sqlite3_column_double(statment, 6);
            NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSDate* createdAt = [dateFormat
                dateFromString:[NSString
                                   stringWithUTF8String:(char*)sqlite3_column_text(statment, 7)]];

            if (!imageName) {
                imageName = nil;
            }

            Breadcrumb* breadcrumb = [[Breadcrumb alloc] initWithBreadcrumbId:breadcrumbId
                                                                 locationName:locationName
                                                                     contents:contents
                                                                       author:author
                                                                    imageName:imageName
                                                                     latitude:latitude
                                                                    longitude:longitude
                                                                         date:createdAt];
            [data addObject:breadcrumb];
        }
    } else {
        NSLog(@"ERROR: getBreadcrumbs failed %s", sqlite3_errmsg(database));
        return nil;
    }

    return data;
}

+ (void)addBreadcrumb:(sqlite3*)database breadcrumb:(Breadcrumb*)breadcrumb {
    sqlite3_stmt* statment;
    NSString* query = [NSString
        stringWithFormat:
            @"INSERT OR REPLACE INTO %@ (%@,%@,%@,%@,%@,%@,%@,%@) values (?,?,?,?,?,?,?,?);",
            BREADCRUMB_TABLE, BREADCRUMB_ID, BREADCRUMB_LOCATION_NAME, BREADCRUMB_CONTENTS,
            BREADCRUMB_IMAGE_NAME, BREADCRUMB_AUTHOR, BREADCRUMB_LATITUDE, BREADCRUMB_LONGITUDE,
            BREADCRUMB_CREATED_AT];

    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString* dateString = [dateFormat stringFromDate:breadcrumb.date];

    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statment, nil) == SQLITE_OK) {
        sqlite3_bind_text(statment, 1, [breadcrumb.breadcrumbId UTF8String], -1, NULL);
        sqlite3_bind_text(statment, 2, [breadcrumb.locationName UTF8String], -1, NULL);
        sqlite3_bind_text(statment, 3, [breadcrumb.contents UTF8String], -1, NULL);
        sqlite3_bind_text(statment, 4, [breadcrumb.imageName UTF8String], -1, NULL);
        sqlite3_bind_text(statment, 5, [breadcrumb.author UTF8String], -1, NULL);
        sqlite3_bind_double(statment, 6, breadcrumb.latitude);
        sqlite3_bind_double(statment, 7, breadcrumb.longitude);
        sqlite3_bind_text(statment, 8, [dateString UTF8String], -1, NULL);
        if (sqlite3_step(statment) == SQLITE_DONE) {
            return;
        }
    }

    NSLog(@"ERROR: addStudent failed %s", sqlite3_errmsg(database));
}

+ (void)deleteBreadcrumb:(sqlite3*)database breadcrumb:(Breadcrumb*)breadcrumb {
    sqlite3_stmt* statement;
    NSString* query = [NSString
        stringWithFormat:@"DELETE FROM %@ WHERE %@ = ?;", BREADCRUMB_TABLE, BREADCRUMB_ID];

    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        sqlite3_bind_text(statement, 1, [breadcrumb.breadcrumbId UTF8String], -1, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE) {
            return;
        }
        NSLog(@"ERROR: deleteBreadcrumb failed %s", sqlite3_errmsg(database));
        return;
    }
    NSLog(@"ERROR: deleteBreadcrumb failed %s", sqlite3_errmsg(database));
    return;
}

+ (void)setLastUpdateDate:(sqlite3*)database date:(NSString*)date {
    [LastUpdateSql setLastUpdateDate:database date:date forTable:BREADCRUMB_TABLE];
}

+ (NSString*)getLastUpdateDate:(sqlite3*)database {
    return [LastUpdateSql getLastUpdateDate:database forTable:BREADCRUMB_TABLE];
}

+ (void)updateBreadcrumbs:(sqlite3*)database breadcrumbs:(NSArray*)breadcrumbs {
    for (Breadcrumb* breadcrumb in breadcrumbs) {
        [BreadcrumbSql addBreadcrumb:database breadcrumb:breadcrumb];
    }
}

@end
