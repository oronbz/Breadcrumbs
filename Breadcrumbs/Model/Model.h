//
//  Model.h
//  Breadcrumbs
//
//  Created by Oron Ben Zvi on 26/12/2015.
//  Copyright © 2015 Oron Ben Zvi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Model : NSObject

- (NSArray *)getBreadcrumbsNearCoordinate:(CLLocationCoordinate2D)coordinate;

@end
