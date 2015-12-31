//
//  Breadcrumb.m
//  Breadcrumbs
//
//  Created by Oron Ben Zvi on 26/12/2015.
//  Copyright © 2015 Oron Ben Zvi. All rights reserved.
//

#import "Breadcrumb.h"

@implementation Breadcrumb

- (instancetype)initWithLocationName:(NSString *)locationName
                            contents:(NSString *)contents
                              author:(NSString *)author
                            imageURL:(NSString *)imageURL
                            latitude:(double)latitude
                           longitude:(double)longitude
                                date:(NSDate *)date {
    if ((self = [super init])) {
        self.locationName = locationName;
        self.contents = contents;
        self.author = author;
        self.imageURL = imageURL;
        self.latitude = latitude;
        self.longitude = longitude;
        self.date = date;
    }
    return self;
}

@end
