//
//  ViewController.m
//  Breadcrumbs
//
//  Created by Oron Ben Zvi on 25/12/2015.
//  Copyright © 2015 Oron Ben Zvi. All rights reserved.
//

#import "Breadcrumb.h"
#import "BreadcrumbAnnotation.h"
#import "BreadcrumbAnnotationView.h"
#import "CreateViewController.h"
#import "DetailViewController.h"
#import "ListViewController.h"
#import "MKMapView+Focus.h"
#import "Model.h"
#import "UIView+Shadow.h"
#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *listViewContainerBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *listViewContainer;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *overlay;
@property (weak, nonatomic) IBOutlet UIButton *curLocationButton;
@property (weak, nonatomic) IBOutlet UIButton *listButton;

@property (strong, nonatomic) Model *model;
@property (strong, nonatomic) NSArray *breadcrumbs;
@property (strong, nonatomic) CLLocationManager *locationManager;

@property (assign, nonatomic) BOOL shouldUpdateLocation;
@property (strong, nonatomic) NSMutableArray *annotations;
@property (strong, nonatomic) ListViewController *listViewController;
@property (strong, nonatomic) Breadcrumb *selectedBreadcrumb;
@property (assign, nonatomic) CLLocationCoordinate2D currentLocation;
@property (assign, nonatomic) CLLocationCoordinate2D newBreadcrumbCoordinate;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self goToCurrentLocation];
}

- (void)setup {
    self.model = [[Model alloc] init];

    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;

    self.annotations = [[NSMutableArray alloc] init];

    // add tap recognizer to close the listView
    UITapGestureRecognizer *tapRecognizer =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(overlayTap:)];
    [self.overlay addGestureRecognizer:tapRecognizer];

    // add long press recognizer to add a breadcrumb on map
    UILongPressGestureRecognizer *lpgr =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                      action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 1.0;  // user needs to press for 2 seconds
    [self.mapView addGestureRecognizer:lpgr];

    [self.listButton addShadow];
    [self.curLocationButton addShadow];
}

- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;

    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D coordinate =
        [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];

    BreadcrumbAnnotation *annotation = [[BreadcrumbAnnotation alloc] init];
    annotation.coordinate = coordinate;
    [self.mapView addAnnotation:annotation];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
                       self.newBreadcrumbCoordinate = coordinate;
                       [self performSegueWithIdentifier:@"create" sender:nil];
                       dispatch_after(
                           dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)),
                           dispatch_get_main_queue(), ^{
                               [self.mapView removeAnnotation:annotation];
                           });
                   });
}

- (IBAction)createButtonClicked:(id)sender {
    self.newBreadcrumbCoordinate = self.currentLocation;
    [self performSegueWithIdentifier:@"create" sender:nil];
}

- (IBAction)listButtonClicked:(id)sender {
    [self openListView];
}

- (void)openListView {
    [self.view layoutIfNeeded];
    self.listViewContainerBottomConstraint.constant = 0;
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.overlay.alpha = 0.7;
                         [self.view layoutIfNeeded];
                     }
                     completion:nil];
}

- (void)closeListView {
    [self.view layoutIfNeeded];
    self.listViewContainerBottomConstraint.constant = -250;
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.overlay.alpha = 0;
                         [self.view layoutIfNeeded];

                     }
                     completion:nil];
}

- (void)overlayTap:(UITapGestureRecognizer *)recognizer {
    [self closeListView];
}
- (IBAction)currentLocationClicked:(id)sender {
    [self goToCurrentLocation];
}

- (void)goToCurrentLocation {
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
    self.shouldUpdateLocation = YES;
}

- (void)goToCoordinate:(CLLocationCoordinate2D)coordinate {
    [self.mapView focusOnCoordinate:coordinate animated:NO];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self getNearbyBreadcrumbs:coordinate];
    });
}

- (void)getNearbyBreadcrumbs:(CLLocationCoordinate2D)coordinate {
    [self.mapView removeAnnotations:self.annotations];
    [self.annotations removeAllObjects];

    self.breadcrumbs = [self.model getBreadcrumbsNearCoordinate:coordinate];

    for (Breadcrumb *breadcrumb in self.breadcrumbs) {
        CLLocationCoordinate2D breadcrumbCoordinate =
            CLLocationCoordinate2DMake(breadcrumb.latitude, breadcrumb.longitude);
        [self addAnnotationwithCoordinate:breadcrumbCoordinate andBreadcrumb:breadcrumb];
    }

    [self updateListViewWithBreadcrumbs:self.breadcrumbs];
}

- (void)addAnnotationwithCoordinate:(CLLocationCoordinate2D)coordinate
                      andBreadcrumb:(Breadcrumb *)breadcrumb {
    BreadcrumbAnnotation *annotation =
        [[BreadcrumbAnnotation alloc] initWithCoordinate:coordinate andBreadcrumb:breadcrumb];
    annotation.title = breadcrumb.locationName;
    annotation.subtitle = breadcrumb.author;

    [self.annotations addObject:annotation];
    [self.mapView addAnnotation:annotation];
}

- (void)updateListViewWithBreadcrumbs:(NSArray *)breadcrumbs {
    self.listViewController.breadcrumbs = breadcrumbs;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"listView"]) {
        self.listViewController = segue.destinationViewController;
        self.listViewController.delegate = self;
    }
    if ([segue.identifier isEqualToString:@"detail"]) {
        DetailViewController *dvc = segue.destinationViewController;
        dvc.breadcrumb = self.selectedBreadcrumb;
        dvc.mapViewDelegate = self;
        dvc.delegate = self;
    }
    if ([segue.identifier isEqualToString:@"create"]) {
        UINavigationController *nc = segue.destinationViewController;
        CreateViewController *cvc = nc.viewControllers[0];
        cvc.breadcrumbCoordinate = self.newBreadcrumbCoordinate;
        cvc.mapViewDelegate = self;
        cvc.delegate = self;
        cvc.author = @"Replace me";
    }
}

#pragma mark - ListViewDelegate

- (void)didSelectBreadcrumb:(Breadcrumb *)breadcrumb {
    self.selectedBreadcrumb = breadcrumb;
    [self closeListView];
    [self performSegueWithIdentifier:@"detail" sender:nil];
}

#pragma mark - CreateViewDelegate

- (void)onCreateBreadcrumb:(Breadcrumb *)breadcrumb {
    CLLocationCoordinate2D coordinate =
        CLLocationCoordinate2DMake(breadcrumb.latitude, breadcrumb.longitude);
    [self addAnnotationwithCoordinate:coordinate andBreadcrumb:breadcrumb];
    [self.model addBreadcrumb:breadcrumb];
    self.breadcrumbs = [self.breadcrumbs arrayByAddingObject:breadcrumb];
    self.listViewController.breadcrumbs = self.breadcrumbs;
    [self.listViewController reloadData];
}

#pragma mark - DetailViewDelegate

- (void)onDeleteBreadcrumb:(Breadcrumb *)breadcrumb {
    [self.model deleteBreadcrumb:breadcrumb];
    for (BreadcrumbAnnotation *annotation in self.annotations) {
        if (annotation.breadcrumb == breadcrumb) {
            [self.mapView removeAnnotation:annotation];
            [self.annotations removeObject:annotation];
            [self.model deleteBreadcrumb:breadcrumb];
            self.breadcrumbs = [self.model getBreadcrumbsNearCoordinate:self.currentLocation];
            self.listViewController.breadcrumbs = self.breadcrumbs;
            [self.listViewController reloadData];
            break;
        }
    }
    [self.listViewController reloadData];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *userLocation = locations[0];
    CLLocationDegrees latitude = userLocation.coordinate.latitude;
    CLLocationDegrees longitude = userLocation.coordinate.longitude;
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    self.currentLocation = coordinate;
    if (self.shouldUpdateLocation) {
        self.mapView.showsUserLocation = YES;
        [self goToCoordinate:coordinate];
        self.shouldUpdateLocation = NO;
    }
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isMemberOfClass:MKUserLocation.class]) {
        return nil;
    }
    MKAnnotationView *view = [mapView dequeueReusableAnnotationViewWithIdentifier:@"pin"];
    if (view == nil) {
        view =
            [[BreadcrumbAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pin"];
        view.canShowCallout = YES;
        view.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    } else {
        view.annotation = annotation;
    }
    return view;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray<MKAnnotationView *> *)views {
    CGFloat delay = 0.00;
    for (MKAnnotationView *av in views) {
        if ([av isMemberOfClass:[BreadcrumbAnnotationView class]]) {
            av.layer.anchorPoint = CGPointMake(0.5, 1.0);
            av.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
            delay += 0.1;
            [UIView animateWithDuration:0.45
                                  delay:delay
                 usingSpringWithDamping:0.5
                  initialSpringVelocity:10
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 av.transform =
                                     CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
                             }
                             completion:nil];
        }
    }
}

- (void)mapView:(MKMapView *)mapView
                   annotationView:(MKAnnotationView *)view
    calloutAccessoryControlTapped:(UIControl *)control {
    BreadcrumbAnnotation *annotation = view.annotation;
    self.selectedBreadcrumb = annotation.breadcrumb;
    [self performSegueWithIdentifier:@"detail" sender:nil];
}

@end
