//
//  ViewController.h
//  Breadcrumbs
//
//  Created by Oron Ben Zvi on 25/12/2015.
//  Copyright © 2015 Oron Ben Zvi. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>
#import "CreateViewController.h"
#import "DetailViewController.h"
#import "ListViewController.h"

@interface ViewController
    : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate, ListViewDelegate,
                        CreateViewDelegate, DetailViewDelegate>

@end
