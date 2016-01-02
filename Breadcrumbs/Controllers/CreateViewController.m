//
//  CreateViewController.m
//  Breadcrumbs
//
//  Created by Oron Ben Zvi on 28/12/2015.
//  Copyright © 2015 Oron Ben Zvi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BreadcrumbAnnotation.h"
#import "CreateViewController.h"
#import "MKMapView+Focus.h"
#import "Model.h"

@interface CreateViewController ()
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UITextField *contentsTextField;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) UIImage *pickedImage;

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
    if (![self validateFields]) {
        return;
    }
    NSString *possibleImageName = [NSString stringWithFormat:@"%@.jpg", [[NSUUID UUID] UUIDString]];
    NSString *imageName = self.pickedImage ? possibleImageName : nil;
    NSString *author = [[Model instance] user];
    Breadcrumb *breadcrumb =
        [[Breadcrumb alloc] initWithBreadcrumbId:nil
                                    locationName:self.titleTextField.text
                                        contents:self.contentsTextField.text
                                          author:author
                                       imageName:imageName
                                        latitude:self.breadcrumbCoordinate.latitude
                                       longitude:self.breadcrumbCoordinate.longitude
                                            date:nil];
    [self.delegate onCreateBreadcrumb:breadcrumb uploadImage:self.pickedImage];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)validateFields {
    NSString *locationName = self.titleTextField.text;
    NSString *contents = self.contentsTextField.text;
    if (locationName.length == 0) {
        [self.titleTextField becomeFirstResponder];
        return NO;
    }
    if (contents.length == 0) {
        [self.contentsTextField becomeFirstResponder];
        return NO;
    }
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self dismissKeyboard];
}

- (void)dismissKeyboard {
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
    self.pickedImage = info[UIImagePickerControllerEditedImage];
    self.imageView.image = self.pickedImage;
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
