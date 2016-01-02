//
//  Breadcrumb.m
//  Breadcrumbs
//
//  Created by Oron Ben Zvi on 26/12/2015.
//  Copyright © 2015 Oron Ben Zvi. All rights reserved.
//

#import "Breadcrumb.h"

@implementation Breadcrumb

- (instancetype)initWithBreadcrumbId:(NSString *)breadcrumbId
                        locationName:(NSString *)locationName
                            contents:(NSString *)contents
                              author:(NSString *)author
                           imageName:(NSString *)imageName
                            latitude:(double)latitude
                           longitude:(double)longitude
                                date:(NSDate *)date {
    if ((self = [super init])) {
        _breadcrumbId = breadcrumbId;
        _locationName = locationName;
        _contents = contents;
        _author = author;
        _imageName = imageName;
        _latitude = latitude;
        _longitude = longitude;
        _date = date;
    }
    return self;
}

- (CLLocationDistance)distanceFromCoordinate:(CLLocationCoordinate2D)coordinate {
    if (coordinate.latitude == 0 || coordinate.longitude == 0) {
        return 0;
    }
    CLLocation *location =
        [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    CLLocation *breadcrumbLocation =
        [[CLLocation alloc] initWithLatitude:self.latitude longitude:self.longitude];
    return [location distanceFromLocation:breadcrumbLocation];
}

@end
