//
//  ParseModel.h
//  Breadcrumbs
//
//  Created by Oron Ben Zvi on 01/01/2016.
//  Copyright © 2016 Oron Ben Zvi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Breadcrumb.h"

@interface ParseModel : NSObject

- (void)addBreadcrumb:(Breadcrumb *)breadcrumb;
- (void)deleteBreadcrumb:(Breadcrumb *)breadcrumb;

- (NSArray *)getBreadcrumbs;
- (NSArray *)getBreadcrumbsByCoordinate:(CLLocationCoordinate2D)coordinate;
- (NSArray *)getBreadcrumbsFromDate:(NSString *)date;

- (void)saveImage:(UIImage *)image withName:(NSString *)imageName;
- (UIImage *)getImage:(NSString *)imageName;
- (BOOL)logInWithUsername:(NSString *)username password:(NSString *)password;
- (BOOL)signUpWithusername:(NSString *)username password:(NSString *)password;
- (void)logOut;
- (NSString *)getCurrentUser;

@end
