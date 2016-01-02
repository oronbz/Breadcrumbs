//
//  LastUpdateSql.m
//  Breadcrumbs
//
//  Created by Oron Ben Zvi on 02/01/2016.
//  Copyright © 2016 Oron Ben Zvi. All rights reserved.
//

#import "LastUpdateSql.h"

@implementation LastUpdateSql
static NSString* LAST_UPDATE = @"LAST_UPDATE";
static NSString* TABLE_NAME = @"TABLE_NAME";
static NSString* LAST_UPDATE_DATE = @"LAST_UPDATE_DATE";

+ (BOOL)createTable:(sqlite3*)database {
    char* errormsg;

    NSString* sql =
        [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@ TEXT PRIMARY KEY, %@ TEXT)",
                                   LAST_UPDATE, TABLE_NAME, LAST_UPDATE_DATE];
    int res = sqlite3_exec(database, [sql UTF8String], NULL, NULL, &errormsg);
    if (res != SQLITE_OK) {
        NSLog(@"ERROR: failed creating %@ table", LAST_UPDATE);
        return NO;
    }
    return YES;
}

+ (NSString*)getLastUpdateDate:(sqlite3*)database forTable:(NSString*)table {
    sqlite3_stmt* statment;

    NSString* query = [NSString stringWithFormat:@"SELECT %@ from %@ where %@ = ?;",
                                                 LAST_UPDATE_DATE, LAST_UPDATE, TABLE_NAME];

    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statment, nil) == SQLITE_OK) {
        sqlite3_bind_text(statment, 1, [table UTF8String], -1, NULL);
        while (sqlite3_step(statment) == SQLITE_ROW) {
            NSString* lastUpdate =
                [NSString stringWithFormat:@"%s", sqlite3_column_text(statment, 0)];
            return lastUpdate;
        }
    } else {
        NSLog(@"ERROR: get last update failed failed %s", sqlite3_errmsg(database));
        return nil;
    }
    return nil;
}

+ (void)setLastUpdateDate:(sqlite3*)database date:(NSString*)date forTable:(NSString*)table {
    sqlite3_stmt* statment;

    NSString* query =
        [NSString stringWithFormat:@"INSERT OR REPLACE INTO  %@ (%@,%@) values (?,?);", LAST_UPDATE,
                                   TABLE_NAME, LAST_UPDATE_DATE];

    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statment, nil) == SQLITE_OK) {
        sqlite3_bind_text(statment, 1, [table UTF8String], -1, NULL);
        sqlite3_bind_text(statment, 2, [date UTF8String], -1, NULL);
        if (sqlite3_step(statment) == SQLITE_DONE) {
            return;
        }
        NSLog(@"failed update last update date");
    } else {
        NSLog(@"ERROR: failed update last update date %s", sqlite3_errmsg(database));
    }
}

@end
