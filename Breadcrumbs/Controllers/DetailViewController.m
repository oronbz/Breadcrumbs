//
//  DetailViewController.m
//  Breadcrumbs
//
//  Created by Oron Ben Zvi on 26/12/2015.
//  Copyright © 2015 Oron Ben Zvi. All rights reserved.
//

#import <MapKit/Mapkit.h>
#import "BreadcrumbAnnotation.h"
#import "DetailViewController.h"
#import "MKMapView+Focus.h"
#import "Model.h"

@interface DetailViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentsLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if (![self.breadcrumb.author isEqualToString:[[Model instance] user]]) {
        // hide the delete button when the author is not the current user
        [self.deleteButton setEnabled:NO];
        [self.deleteButton setTintColor:[UIColor clearColor]];
    }

    self.mapView.delegate = self.mapViewDelegate;
    [self loadImage];
    [self addGradientToView:self.imageView];
    self.titleLabel.text = self.breadcrumb.locationName;
    self.contentsLabel.text = self.breadcrumb.contents;
    self.authorLabel.text = self.breadcrumb.author;
    [self formatDate];
    CLLocationCoordinate2D breadcrumbCoordinate =
        CLLocationCoordinate2DMake(self.breadcrumb.latitude, self.breadcrumb.longitude);
    BreadcrumbAnnotation *annotation =
        [[BreadcrumbAnnotation alloc] initWithCoordinate:breadcrumbCoordinate andBreadcrumb:nil];
    [self.mapView addAnnotation:annotation];
    [self.mapView focusOnCoordinate:breadcrumbCoordinate animated:YES];
}

- (void)formatDate {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *formattedDateString = [dateFormatter stringFromDate:self.breadcrumb.date];
    self.dateLabel.text = formattedDateString;
}

- (void)loadImage {
    if (self.breadcrumb.imageName != nil) {
        self.imageView.image = [UIImage imageNamed:@"placeholder-640x480"];
        [[Model instance] getImageForBreadcrumb:self.breadcrumb
                                     completion:^(UIImage *image) {
                                         self.imageView.image = image;
                                     }];

    } else {
        self.imageView.image = [UIImage imageNamed:@"DefaultImage"];
    }
}

- (void)addGradientToView:(UIView *)view {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = view.bounds;
    UIColor *halfBlack = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    gradient.colors = @[ (id)[[UIColor clearColor] CGColor], (id)[halfBlack CGColor] ];
    [view.layer insertSublayer:gradient atIndex:0];
}

- (IBAction)deleteClicked:(id)sender {
    [self presentDeleteDialog];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)presentDeleteDialog {
    UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:@"Delete"
                                            message:@"Are you sure you want to delete this "
                                                    @"breadcrumb? This cannot be undone."
                                     preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *yesAction = [UIAlertAction
        actionWithTitle:@"YES"
                  style:UIAlertActionStyleDestructive
                handler:^(UIAlertAction *action) {
                    if ([self.delegate respondsToSelector:@selector(onDeleteBreadcrumb:)]) {
                        [self.delegate onDeleteBreadcrumb:self.breadcrumb];
                    }
                    [self.navigationController popViewControllerAnimated:YES];
                }];

    UIAlertAction *noAction =
        [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleCancel handler:nil];

    [alert addAction:yesAction];
    [alert addAction:noAction];
    [self presentViewController:alert animated:YES completion:nil];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before
navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
