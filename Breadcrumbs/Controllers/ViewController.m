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
@property (strong, nonatomic) NSMutableArray *breadcrumbs;
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
    self.model = [Model instance];
    [self setup];
    [self goToCurrentLocation];
}

- (void)setup {
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
                       [self performSegueWithIdentifier:@"create" sender:self];
                       dispatch_after(
                           dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)),
                           dispatch_get_main_queue(), ^{
                               [self.mapView removeAnnotation:annotation];
                           });
                   });
}

- (IBAction)createButtonClicked:(id)sender {
    self.newBreadcrumbCoordinate = self.currentLocation;
    [self performSegueWithIdentifier:@"create" sender:self];
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

    CLLocation *currentLocation = self.locationManager.location;
    if (currentLocation) {
        self.currentLocation = currentLocation.coordinate;
    }
}

- (void)goToCoordinate:(CLLocationCoordinate2D)coordinate {
    [self.mapView focusOnCoordinate:coordinate animated:NO];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self getBreadcrumbs];
    });
}

- (void)getBreadcrumbs {
    [self.model getBreadcrumbsWithCompletion:^(NSArray *breadcrumbs) {
        NSLog(@"Breadcrumbs fetched");
        [self.mapView removeAnnotations:self.annotations];
        [self.annotations removeAllObjects];
        self.breadcrumbs = (NSMutableArray *)breadcrumbs;
        for (Breadcrumb *breadcrumb in self.breadcrumbs) {
            CLLocationCoordinate2D breadcrumbCoordinate =
                CLLocationCoordinate2DMake(breadcrumb.latitude, breadcrumb.longitude);
            [self addAnnotationwithCoordinate:breadcrumbCoordinate andBreadcrumb:breadcrumb];
        }
        [self sortAndUpdateMeters];
    }];
}

- (void)getBreadcrumbsByCoordinate:(CLLocationCoordinate2D)coordinate {
    [self.model getBreadcrumbsByCoordinate:coordinate
                                completion:^(NSArray *breadcrumbs) {
                                    NSLog(@"Breadcrumbs fetched");
                                    [self.mapView removeAnnotations:self.annotations];
                                    [self.annotations removeAllObjects];
                                    self.breadcrumbs = (NSMutableArray *)breadcrumbs;
                                    for (Breadcrumb *breadcrumb in self.breadcrumbs) {
                                        CLLocationCoordinate2D breadcrumbCoordinate =
                                            CLLocationCoordinate2DMake(breadcrumb.latitude,
                                                                       breadcrumb.longitude);
                                        [self addAnnotationwithCoordinate:breadcrumbCoordinate
                                                            andBreadcrumb:breadcrumb];
                                    }
                                    [self sortAndUpdateMeters];
                                }];
}

- (void)addAnnotationwithCoordinate:(CLLocationCoordinate2D)coordinate
                      andBreadcrumb:(Breadcrumb *)breadcrumb {
    BreadcrumbAnnotation *annotation =
        [[BreadcrumbAnnotation alloc] initWithCoordinate:coordinate andBreadcrumb:breadcrumb];
    annotation.title = breadcrumb.locationName;
    int meters = [breadcrumb distanceFromCoordinate:self.currentLocation];
    annotation.subtitle = [NSString stringWithFormat:@"%d meters", meters];

    [self.annotations addObject:annotation];
    [self.mapView addAnnotation:annotation];
}

- (void)sortAndUpdateMeters {
    NSArray *sortedBreadcrumbs = [self.breadcrumbs sortedArrayUsingComparator:^NSComparisonResult(
                                                       id a, id b) {
        NSNumber *firstDistance = @([(Breadcrumb *)a distanceFromCoordinate:self.currentLocation]);
        NSNumber *secondDistance = @([(Breadcrumb *)b distanceFromCoordinate:self.currentLocation]);
        return [firstDistance compare:secondDistance];
    }];
    self.breadcrumbs = [NSMutableArray arrayWithArray:sortedBreadcrumbs];
    for (BreadcrumbAnnotation *annotation in self.annotations) {
        int meters = [annotation.breadcrumb distanceFromCoordinate:self.currentLocation];
        annotation.subtitle = meters >= 1000
                                  ? [NSString stringWithFormat:@"%d kilometer(s)", meters / 1000]
                                  : [NSString stringWithFormat:@"%d meter(s)", meters];
    }
    [self updateListView];
}

- (void)updateListView {
    self.listViewController.distances = [self distanceFromBreadcrumbs:self.breadcrumbs];
    self.listViewController.breadcrumbs = self.breadcrumbs;
}

- (IBAction)logOutClicked:(id)sender {
    [self.model logOutWithCompletion:^{
        NSLog(@"Logged out");
        [self performSegueWithIdentifier:@"logOut" sender:self];
    }];
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
    [self performSegueWithIdentifier:@"detail" sender:self];
}

#pragma mark - CreateViewDelegate

- (void)onCreateBreadcrumb:(Breadcrumb *)breadcrumb uploadImage:(UIImage *)image {
    CLLocationCoordinate2D coordinate =
        CLLocationCoordinate2DMake(breadcrumb.latitude, breadcrumb.longitude);
    [self addAnnotationwithCoordinate:coordinate andBreadcrumb:breadcrumb];
    [self.breadcrumbs addObject:breadcrumb];
    [self sortAndUpdateMeters];
    [self.model addBreadcrumb:breadcrumb
                   completion:^{
                       NSLog(@"Added breadcrumb");
                   }];
    if (image) {
        [self.model saveImageForBreadcrumb:breadcrumb
                                     image:image
                                completion:^(NSError *error) {
                                    if (error) {
                                        NSLog(@"Image failed to upload :%@", error);
                                    } else {
                                        NSLog(@"Image uploaded succesfully");
                                    }
                                }];
    }
}

#pragma mark - DetailViewDelegate

- (void)onDeleteBreadcrumb:(Breadcrumb *)breadcrumb {
    [self.model deleteBreadcrumb:breadcrumb
                      completion:^{
                          NSLog(@"Deleted breadcrumb");
                      }];
    for (BreadcrumbAnnotation *annotation in self.annotations) {
        if (annotation.breadcrumb == breadcrumb) {
            [self.mapView removeAnnotation:annotation];
            [self.annotations removeObject:annotation];
            [self.breadcrumbs removeObject:breadcrumb];
            break;
        }
    }
    [self sortAndUpdateMeters];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *userLocation = locations[0];
    CLLocationDegrees latitude = userLocation.coordinate.latitude;
    CLLocationDegrees longitude = userLocation.coordinate.longitude;
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    self.currentLocation = coordinate;
    [self sortAndUpdateMeters];
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
            delay = arc4random() % 100 / 200.0;
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
    [self performSegueWithIdentifier:@"detail" sender:self];
}

#pragma mark - Private Methods

- (NSArray *)distanceFromBreadcrumbs:(NSArray *)breadcrumbs {
    NSMutableArray *distances = [[NSMutableArray alloc] init];
    for (Breadcrumb *breadcrumb in breadcrumbs) {
        int meters = [breadcrumb distanceFromCoordinate:self.currentLocation];
        [distances addObject:@(meters)];
    }
    return distances;
}

@end
