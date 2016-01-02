//
//  Model.h
//  Breadcrumbs
//
//  Created by Oron Ben Zvi on 26/12/2015.
//  Copyright © 2015 Oron Ben Zvi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Breadcrumb.h"

@interface Model : NSObject

@property (strong, nonatomic) NSString *user;

+ (Model *)instance;

- (void)getBreadcrumbsWithCompletion:(void (^)(NSArray *))completion;
- (void)getBreadcrumbsByCoordinate:(CLLocationCoordinate2D)coordinate
                        completion:(void (^)(NSArray *))completion;
- (void)getImageForBreadcrumb:(Breadcrumb *)breadcrumb completion:(void (^)(UIImage *))completion;
- (void)saveImageForBreadcrumb:(Breadcrumb *)breadcrumb
                         image:(UIImage *)image
                    completion:(void (^)(NSError *))completion;
- (void)addBreadcrumb:(Breadcrumb *)breadcrumb completion:(void (^)())completion;
- (void)deleteBreadcrumb:(Breadcrumb *)breadcrumb completion:(void (^)())completion;

- (void)logInWithUsername:(NSString *)username
                 password:(NSString *)password
               completion:(void (^)(BOOL))completion;
- (void)signUpWithUsername:(NSString *)username
                  password:(NSString *)password
                completion:(void (^)(BOOL))completion;
- (void)logOutWithCompletion:(void (^)())completion;

@end
