//
//  CreateViewController.h
//  Breadcrumbs
//
//  Created by Oron Ben Zvi on 28/12/2015.
//  Copyright © 2015 Oron Ben Zvi. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>

@class Breadcrumb;

@protocol CreateViewDelegate <NSObject>

- (void)onCreateBreadcrumb:(Breadcrumb *)breadcrumb;

@end

@interface CreateViewController
    : UIViewController <UITextFieldDelegate, UIImagePickerControllerDelegate,
                        UINavigationControllerDelegate>

@property (assign, nonatomic) CLLocationCoordinate2D breadcrumbCoordinate;
@property (weak, nonatomic) id<CreateViewDelegate> delegate;
@property (weak, nonatomic) id<MKMapViewDelegate> mapViewDelegate;
@property (strong, nonatomic) NSString *author;

@end
