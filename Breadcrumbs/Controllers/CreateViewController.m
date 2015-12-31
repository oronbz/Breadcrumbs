//
//  CreateViewController.m
//  Breadcrumbs
//
//  Created by Oron Ben Zvi on 28/12/2015.
//  Copyright © 2015 Oron Ben Zvi. All rights reserved.
//

#import "BreadcrumbAnnotation.h"
#import "CreateViewController.h"
#import "MKMapView+Focus.h"

@interface CreateViewController ()
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UITextField *contentsTextField;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) NSString *imageUrl;

@end

@implementation CreateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView.delegate = self.mapViewDelegate;
    [self.titleTextField setInputAccessoryView:[self accessoryToolbar]];
    [self.contentsTextField setInputAccessoryView:[self accessoryToolbar]];
    [self.titleTextField becomeFirstResponder];
    BreadcrumbAnnotation *annotation =
        [[BreadcrumbAnnotation alloc] initWithCoordinate:self.breadcrumbCoordinate
                                           andBreadcrumb:nil];
    [self.mapView addAnnotation:annotation];
    [self.mapView focusOnCoordinate:self.breadcrumbCoordinate animated:NO];
}

- (UIToolbar *)accessoryToolbar {
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    [toolbar sizeToFit];
    toolbar.barStyle = UIBarStyleBlackOpaque;
    toolbar.barTintColor =
        [UIColor colorWithRed:40.0f / 255.0f green:120.0f / 255.0f blue:177.0f / 255.0f alpha:1.0];
    toolbar.tintColor = [UIColor whiteColor];

    UIBarButtonItem *cameraButton =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                                                      target:self
                                                      action:@selector(takePicture)];
    NSArray *itemsArray = [NSArray arrayWithObjects:cameraButton, nil];

    [toolbar setItems:itemsArray];
    return toolbar;
}

- (IBAction)doneClicked:(id)sender {
    Breadcrumb *breadcrumb =
        [[Breadcrumb alloc] initWithLocationName:self.titleTextField.text
                                        contents:self.contentsTextField.text
                                          author:self.author
                                        imageURL:self.imageUrl
                                        latitude:self.breadcrumbCoordinate.latitude
                                       longitude:self.breadcrumbCoordinate.longitude
                                            date:[NSDate date]];
    [self.delegate onCreateBreadcrumb:breadcrumb];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.titleTextField resignFirstResponder];
    [self.contentsTextField resignFirstResponder];
}

- (void)resignKeyboard {
    [self.titleTextField resignFirstResponder];
    [self.contentsTextField resignFirstResponder];
}

- (IBAction)cameraClicked:(id)sender {
    [self takePicture];
}

- (void)takePicture {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    // if camera available we take a picture
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else {
        // otherwise we use photo album
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    [self presentViewController:picker animated:YES completion:NULL];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.titleTextField) {
        [self.contentsTextField becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    return YES;
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary<NSString *, id> *)info {
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.imageView.image = chosenImage;
    [self.view layoutIfNeeded];
    self.imageViewHeightConstraint.constant = 200;
    [self.view layoutIfNeeded];
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)closeClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
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
