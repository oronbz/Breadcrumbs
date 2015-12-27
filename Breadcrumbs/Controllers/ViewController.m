//
//  ViewController.m
//  Breadcrumbs
//
//  Created by Oron Ben Zvi on 25/12/2015.
//  Copyright © 2015 Oron Ben Zvi. All rights reserved.
//

#import "Breadcrumb.h"
#import "BreadcrumbAnnotation.h"
#import "DetailViewController.h"
#import "ListViewController.h"
#import "Model.h"
#import "UIView+Shadow.h"
#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *listViewContainerBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *listViewContainer;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *overlay;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UIButton *curLocationButton;
@property (weak, nonatomic) IBOutlet UIButton *listButton;

@property (strong, nonatomic) Model *model;
@property (strong, nonatomic) CLLocationManager *locationManager;

@property (assign, nonatomic) BOOL shouldUpdateLocation;
@property (strong, nonatomic) NSMutableArray *annotations;
@property (strong, nonatomic) ListViewController *listViewController;
@property (strong, nonatomic) Breadcrumb *selectedBreadcrumb;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)setup {
    self.model = [[Model alloc] init];

    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;

    self.annotations = [[NSMutableArray alloc] init];

    // add gesture recognizer to close the listView
    UITapGestureRecognizer *tapRecognizer =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(overlayTap:)];
    [self.overlay addGestureRecognizer:tapRecognizer];

    [self.addButton addShadow];
    [self.listButton addShadow];
    [self.curLocationButton addShadow];
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
    CLLocationDegrees latDelta = 0.01;
    CLLocationDegrees lonDelta = 0.01;

    MKCoordinateSpan span = MKCoordinateSpanMake(latDelta, lonDelta);
    MKCoordinateRegion region = MKCoordinateRegionMake(coordinate, span);

    [self updateNearbyBreadcrumbs:coordinate];

    [self.mapView setRegion:region animated:YES];
}

- (void)updateNearbyBreadcrumbs:(CLLocationCoordinate2D)coordinate {
    [self.mapView removeAnnotations:self.annotations];
    [self.annotations removeAllObjects];

    NSArray *breadcrumbs = [self.model getBreadcrumbsNearCoordinate:coordinate];

    for (Breadcrumb *breadcrumb in breadcrumbs) {
        CLLocationCoordinate2D breadcrumbCoordinate =
            CLLocationCoordinate2DMake(breadcrumb.latitude, breadcrumb.longitude);
        BreadcrumbAnnotation *annotation =
            [[BreadcrumbAnnotation alloc] initWithCoordinate:breadcrumbCoordinate
                                               andBreadcrumb:breadcrumb];
        annotation.title = breadcrumb.title;
        annotation.subtitle = @"Oron Ben Zvi";

        [self.annotations addObject:annotation];
        [self.mapView addAnnotation:annotation];
    }

    [self updateListViewWithBreadcrumbs:breadcrumbs];
}

- (void)updateListViewWithBreadcrumbs:(NSArray *)breadcrumbs {
    [self.listViewController setBreadcrumbs:breadcrumbs];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    }
}

#pragma mark - ListViewDelegate

- (void)didSelectBreadcrumb:(Breadcrumb *)breadcrumb {
    self.selectedBreadcrumb = breadcrumb;
    [self closeListView];
    [self performSegueWithIdentifier:@"detail" sender:nil];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations {
    if (self.shouldUpdateLocation) {
        self.mapView.showsUserLocation = YES;
        CLLocation *userLocation = locations[0];
        CLLocationDegrees latitude = userLocation.coordinate.latitude;
        CLLocationDegrees longitude = userLocation.coordinate.longitude;
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
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
        view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pin"];
        view.canShowCallout = YES;
        view.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    } else {
        view.annotation = annotation;
    }
    return view;
}

- (void)mapView:(MKMapView *)mapView
                   annotationView:(MKAnnotationView *)view
    calloutAccessoryControlTapped:(UIControl *)control {
    BreadcrumbAnnotation *annotation = view.annotation;
    self.selectedBreadcrumb = annotation.breadcrumb;
    [self performSegueWithIdentifier:@"detail" sender:nil];
}

@end
