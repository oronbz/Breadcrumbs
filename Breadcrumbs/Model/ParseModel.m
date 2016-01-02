//
//  ParseModel.m
//  Breadcrumbs
//
//  Created by Oron Ben Zvi on 01/01/2016.
//  Copyright © 2016 Oron Ben Zvi. All rights reserved.
//

#import <Parse/Parse.h>
#import "ParseModel.h"

#define kBreadcrumbsClassName @"Breadcrumb"
#define kImagesClassName @"Images"

#define kCoordinate @"coordinate"
#define kLocationName @"locationName"
#define kContents @"contents"
#define kAuthor @"author"
#define kImageName @"imageName"
#define kFile @"file"

@implementation ParseModel

- (id)init {
    if ((self = [super init])) {
        [Parse setApplicationId:@"VwMa8STMsYp7BouToDcsp7P0nW8DOFW4CRD6CqkV"
                      clientKey:@"hJo7gXQYHTBnTwXe3v5LUu4LIlZXVheGrAlUZLsz"];
    }
    return self;
}

- (NSString *)getCurrentUser {
    PFUser *user = [PFUser currentUser];
    if (user != nil) {
        return user.username;
    } else {
        return nil;
    }
}

- (BOOL)logInWithUsername:(NSString *)username password:(NSString *)password {
    NSError *error;
    PFUser *puser = [PFUser logInWithUsername:username password:password error:&error];
    if (error == nil && puser != nil) {
        return YES;
    }
    return NO;
}

- (BOOL)signUpWithusername:(NSString *)username password:(NSString *)password {
    NSError *error;
    PFUser *puser = [PFUser user];
    puser.username = username;
    puser.password = password;
    return [puser signUp:&error];
}

- (void)logOut {
    [PFUser logOut];
}

- (void)addBreadcrumb:(Breadcrumb *)breadcrumb {
    PFGeoPoint *geoPoint =
        [PFGeoPoint geoPointWithLatitude:breadcrumb.latitude longitude:breadcrumb.longitude];
    PFObject *obj = [PFObject objectWithClassName:kBreadcrumbsClassName];
    obj[kCoordinate] = geoPoint;
    obj[kLocationName] = breadcrumb.locationName;
    obj[kContents] = breadcrumb.contents;
    obj[kAuthor] = breadcrumb.author;
    if (breadcrumb.imageName) {
        obj[kImageName] = breadcrumb.imageName;
    }
    PFACL *acl = [PFACL ACL];
    [acl setPublicReadAccess:YES];
    [acl setWriteAccess:YES forUser:[PFUser currentUser]];
    obj.ACL = acl;
    [obj save];
    breadcrumb.breadcrumbId = obj.objectId;
    breadcrumb.date = obj.createdAt;
}

- (void)deleteBreadcrumb:(Breadcrumb *)breadcrumb {
    PFQuery *query = [PFQuery queryWithClassName:kBreadcrumbsClassName];
    PFObject *obj = [query getObjectWithId:breadcrumb.breadcrumbId];
    if (obj != nil) {
        if (obj[kImageName] != nil) {
            [self deleteImage:obj[kImageName]];
        }
        [obj delete];
    }
}

- (void)deleteImage:(NSString *)imageName {
    PFQuery *query = [PFQuery queryWithClassName:kImagesClassName];
    [query whereKey:kImageName equalTo:imageName];
    NSArray *res = [query findObjects];
    for (PFObject *obj in res) {
        [obj delete];
    }
}

- (NSArray *)getBreadcrumbs {
    NSMutableArray *breadcrumbs = [[NSMutableArray alloc] init];
    PFQuery *query = [PFQuery queryWithClassName:kBreadcrumbsClassName];
    NSArray *res = [query findObjects];
    for (PFObject *obj in res) {
        PFGeoPoint *geoPoint = obj[kCoordinate];
        Breadcrumb *breadcrumb = [[Breadcrumb alloc] initWithBreadcrumbId:obj.objectId
                                                             locationName:obj[kLocationName]
                                                                 contents:obj[kContents]
                                                                   author:obj[kAuthor]
                                                                imageName:obj[kImageName]
                                                                 latitude:geoPoint.latitude
                                                                longitude:geoPoint.longitude
                                                                     date:obj.createdAt];
        [breadcrumbs addObject:breadcrumb];
    }
    return breadcrumbs;
}

- (NSArray *)getBreadcrumbsByCoordinate:(CLLocationCoordinate2D)coordinate {
    NSMutableArray *breadcrumbs = [[NSMutableArray alloc] init];
    PFQuery *query = [PFQuery queryWithClassName:kBreadcrumbsClassName];
    PFGeoPoint *geoPoint =
        [PFGeoPoint geoPointWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    [query whereKey:kCoordinate nearGeoPoint:geoPoint];
    NSArray *res = [query findObjects];
    for (PFObject *obj in res) {
        PFGeoPoint *geoPoint = obj[kCoordinate];
        Breadcrumb *breadcrumb = [[Breadcrumb alloc] initWithBreadcrumbId:obj.objectId
                                                             locationName:obj[kLocationName]
                                                                 contents:obj[kContents]
                                                                   author:obj[kAuthor]
                                                                imageName:obj[kImageName]
                                                                 latitude:geoPoint.latitude
                                                                longitude:geoPoint.longitude
                                                                     date:obj.createdAt];
        [breadcrumbs addObject:breadcrumb];
    }
    return breadcrumbs;
}

- (NSArray *)getBreadcrumbsFromDate:(NSString *)date {
    NSMutableArray *breadcrumbs = [[NSMutableArray alloc] init];
    PFQuery *query = [PFQuery queryWithClassName:kBreadcrumbsClassName];
    NSDate *dated = [NSDate dateWithTimeIntervalSince1970:[date doubleValue]];
    [query whereKey:@"updatedAt" greaterThanOrEqualTo:dated];

    NSArray *res = [query findObjects];
    for (PFObject *obj in res) {
        PFGeoPoint *geoPoint = obj[kCoordinate];
        Breadcrumb *breadcrumb = [[Breadcrumb alloc] initWithBreadcrumbId:obj.objectId
                                                             locationName:obj[kLocationName]
                                                                 contents:obj[kContents]
                                                                   author:obj[kAuthor]
                                                                imageName:obj[kImageName]
                                                                 latitude:geoPoint.latitude
                                                                longitude:geoPoint.longitude
                                                                     date:obj.createdAt];
        [breadcrumbs addObject:breadcrumb];
    }
    return breadcrumbs;
}

- (void)saveImage:(UIImage *)image withName:(NSString *)imageName {
    NSData *imageData = UIImageJPEGRepresentation(image, 0);
    PFFile *file = [PFFile fileWithName:imageName data:imageData];
    PFObject *fileObj = [PFObject objectWithClassName:kImagesClassName];
    fileObj[kImageName] = imageName;
    fileObj[kFile] = file;
    PFACL *acl = [PFACL ACL];
    [acl setPublicReadAccess:YES];
    [acl setWriteAccess:YES forUser:[PFUser currentUser]];
    fileObj.ACL = acl;
    [fileObj save];
}

- (UIImage *)getImage:(NSString *)imageName {
    PFQuery *query = [PFQuery queryWithClassName:kImagesClassName];
    [query whereKey:kImageName equalTo:imageName];
    NSArray *res = [query findObjects];
    UIImage *image = nil;
    if (res.count == 1) {
        PFObject *imObj = [res objectAtIndex:0];
        PFFile *file = imObj[kFile];
        NSData *data = [file getData];
        image = [UIImage imageWithData:data];
    }
    return image;
}

@end
