//
//  Model.m
//  Breadcrumbs
//
//  Created by Oron Ben Zvi on 26/12/2015.
//  Copyright © 2015 Oron Ben Zvi. All rights reserved.
//

#import "Breadcrumb.h"
#import "Model.h"

@implementation Model

- (NSArray *)getBreadcrumbsNearCoordinate:(CLLocationCoordinate2D)coordinate {
    NSMutableArray *breadcrumbs = [[NSMutableArray alloc] init];
    for (int i = 0; i < 5; i++) {
        Breadcrumb *breadcrumb = [[Breadcrumb alloc] init];
        breadcrumb.title = [NSString stringWithFormat:@"Crumb %d", i];
        breadcrumb.contents = [NSString stringWithFormat:@"Contents %d", i];
        breadcrumb.author = @"Oron Ben Zvi";
        breadcrumb.imageUrl =
            [NSURL URLWithString:@"http://www.alternet.org/files/story_images/bread.png"];
        breadcrumb.latitude = coordinate.latitude + i * 0.0005;
        breadcrumb.longitude = coordinate.longitude + i * 0.0005;
        [breadcrumbs addObject:breadcrumb];
    }
    return breadcrumbs;
}

@end
