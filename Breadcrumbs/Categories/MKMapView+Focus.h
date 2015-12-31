//
//  MKMapView+Focus.h
//  Breadcrumbs
//
//  Created by Oron Ben Zvi on 29/12/2015.
//  Copyright © 2015 Oron Ben Zvi. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKMapView (Focus)

- (void)focusOnCoordinate:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated;

@end
