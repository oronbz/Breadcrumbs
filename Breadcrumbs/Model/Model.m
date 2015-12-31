//
//  Model.m
//  Breadcrumbs
//
//  Created by Oron Ben Zvi on 26/12/2015.
//  Copyright © 2015 Oron Ben Zvi. All rights reserved.
//

#import "Breadcrumb.h"
#import "Model.h"

@interface Model ()

@property (strong, nonatomic) NSMutableArray *breadcrumbs;

@end

@implementation Model

- (instancetype)init {
    if ((self = [super init])) {
        _breadcrumbs = [[NSMutableArray alloc] init];
        /*
        for (int i = 0; i < 5; i++) {
            Breadcrumb *breadcrumb = [[Breadcrumb alloc] init];
            breadcrumb.locationName = [NSString stringWithFormat:@"Crumb %d", i];
            breadcrumb.contents = [NSString stringWithFormat:@"Contents %d", i];
            breadcrumb.author = @"Oron Ben Zvi";
            breadcrumb.imageURL = @"http://www.alternet.org/files/story_images/bread.png";
            breadcrumb.latitude = coordinate.latitude + i * 0.0015;
            breadcrumb.longitude = coordinate.longitude + i * 0.0015;
            breadcrumb.date = [NSDate date];
            [self.breadcrumbs addObject:breadcrumb];
        }
        */
    }
    return self;
}

- (NSArray *)getBreadcrumbsNearCoordinate:(CLLocationCoordinate2D)coordinate {
    return [NSArray arrayWithArray:self.breadcrumbs];
}

- (void)addBreadcrumb:(Breadcrumb *)breadcrumb {
    [self.breadcrumbs addObject:breadcrumb];
}

- (void)deleteBreadcrumb:(Breadcrumb *)breadcrumb {
    [self.breadcrumbs removeObject:breadcrumb];
}

@end
