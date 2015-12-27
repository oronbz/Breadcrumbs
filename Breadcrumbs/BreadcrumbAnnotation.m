//
//  BreadcrumbAnnotation.m
//  Breadcrumbs
//
//  Created by Oron Ben Zvi on 26/12/2015.
//  Copyright © 2015 Oron Ben Zvi. All rights reserved.
//

#import "BreadcrumbAnnotation.h"

@implementation BreadcrumbAnnotation

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate
                     andBreadcrumb:(Breadcrumb *)breadcrumb {
    if ((self = [super init])) {
        self.coordinate = coordinate;
        self.breadcrumb = breadcrumb;
    }
    return self;
}

@end
