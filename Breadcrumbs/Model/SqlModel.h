//
//  SqlModel.h
//  Breadcrumbs
//
//  Created by Oron Ben Zvi on 02/01/2016.
//  Copyright © 2016 Oron Ben Zvi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface SqlModel : NSObject {
    sqlite3 *database;
}

- (void)addBreadcrumb:(Breadcrumb *)breadcrumb;
- (void)deleteBreadcrumb:(Breadcrumb *)breadcrumb;

- (NSArray *)getBreadcrumbs;
- (NSString *)getBreadcrumbsLastUpdateDate;
- (void)setBreadcrumbsLastUpdateDate:(NSString *)date;
- (void)updateBreadcrumbs:(NSArray *)breadcrumbs;

@end
