//
//  MKMapView+Focus.m
//  Breadcrumbs
//
//  Created by Oron Ben Zvi on 29/12/2015.
//  Copyright © 2015 Oron Ben Zvi. All rights reserved.
//

#import "MKMapView+Focus.h"

@implementation MKMapView (Focus)

- (void)focusOnCoordinate:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated {
    CLLocationDegrees latDelta = 0.01;
    CLLocationDegrees lonDelta = 0.01;
    MKCoordinateSpan span = MKCoordinateSpanMake(latDelta, lonDelta);
    MKCoordinateRegion region = MKCoordinateRegionMake(coordinate, span);
    [self setRegion:region animated:animated];
}

@end
