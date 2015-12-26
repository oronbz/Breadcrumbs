//
//  Breadcrumb.h
//  Breadcrumbs
//
//  Created by Oron Ben Zvi on 26/12/2015.
//  Copyright © 2015 Oron Ben Zvi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Breadcrumb : NSObject

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *contents;
@property (strong, nonatomic) NSString *author;
@property (strong, nonatomic) NSURL *imageUrl;
@property (assign, nonatomic) double latitude;
@property (assign, nonatomic) double longitude;

@end
