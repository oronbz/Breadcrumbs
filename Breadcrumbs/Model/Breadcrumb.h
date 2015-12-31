//
//  Breadcrumb.h
//  Breadcrumbs
//
//  Created by Oron Ben Zvi on 26/12/2015.
//  Copyright © 2015 Oron Ben Zvi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Breadcrumb : NSObject

@property (strong, nonatomic) NSString *locationName;
@property (strong, nonatomic) NSString *contents;
@property (strong, nonatomic) NSString *author;
@property (strong, nonatomic) NSString *imageURL;
@property (assign, nonatomic) double latitude;
@property (assign, nonatomic) double longitude;
@property (strong, nonatomic) NSDate *date;

- (instancetype)initWithLocationName:(NSString *)locationName
                            contents:(NSString *)contents
                              author:(NSString *)author
                            imageURL:(NSString *)imageURL
                            latitude:(double)latitude
                           longitude:(double)longitude
                                date:(NSDate *)date;

@end
