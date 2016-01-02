//
//  LogInViewController.m
//  Breadcrumbs
//
//  Created by Oron Ben Zvi on 01/01/2016.
//  Copyright © 2016 Oron Ben Zvi. All rights reserved.
//

#import "LogInViewController.h"
#import "Model.h"
#import "ViewController.h"

@interface LogInViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIButton *logInButton;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;

@end

@implementation LogInViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([[Model instance] user] != nil) {
        [self performSegueWithIdentifier:@"loggedIn" sender:self];
    }
}

- (IBAction)logInClicked:(id)sender {
    [self dismissKeyboard];
    if (![self validateFields]) {
        return;
    }
    [self loading];
    [[Model instance] logInWithUsername:self.usernameField.text
                               password:self.passwordField.text
                             completion:^(BOOL res) {
                                 self.activityIndicator.hidden = YES;
                                 if (res) {
                                     [self performSegueWithIdentifier:@"loggedIn" sender:self];
                                     [self done];
                                 } else {
                                     [self onError:@"Log In failed, try again"];
                                 }
                             }];
}
- (IBAction)signUpClicked:(id)sender {
    [self dismissKeyboard];
    if (![self validateFields]) {
        return;
    }
    [self loading];
    [[Model instance] signUpWithUsername:self.usernameField.text
                                password:self.passwordField.text
                              completion:^(BOOL res) {
                                  self.activityIndicator.hidden = YES;
                                  if (res) {
                                      [self performSegueWithIdentifier:@"loggedIn" sender:self];
                                      [self done];
                                  } else {
                                      [self onError:@"Sign Up failed, try again"];
                                  }
                              }];
}

- (BOOL)validateFields {
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    if (username.length == 0) {
        [self.usernameField becomeFirstResponder];
        return NO;
    }
    if (password.length == 0) {
        [self.passwordField becomeFirstResponder];
        return NO;
    }
    return YES;
}

- (void)dismissKeyboard {
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
}

- (void)loading {
    self.activityIndicator.hidden = NO;
    self.errorLabel.text = @"";
    self.logInButton.enabled = NO;
    self.signUpButton.enabled = NO;
}

- (void)done {
    self.activityIndicator.hidden = YES;
    self.errorLabel.text = @"";
    self.logInButton.enabled = YES;
    self.signUpButton.enabled = YES;
    self.usernameField.text = @"";
    self.passwordField.text = @"";
}

- (void)onError:(NSString *)errorMessage {
    self.activityIndicator.hidden = YES;
    self.errorLabel.text = errorMessage;
    self.logInButton.enabled = YES;
    self.signUpButton.enabled = YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self dismissKeyboard];
}

- (IBAction)unwindToThisViewController:(UIStoryboardSegue *)unwindSegue {
}

#pragma mark - UITextFieldDeleagate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.usernameField) {
        [self.passwordField becomeFirstResponder];
    }

    if (textField == self.passwordField) {
        [textField resignFirstResponder];
    }
    return YES;
}

@end
