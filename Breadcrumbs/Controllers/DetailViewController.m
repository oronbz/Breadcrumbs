//
//  DetailViewController.m
//  Breadcrumbs
//
//  Created by Oron Ben Zvi on 26/12/2015.
//  Copyright © 2015 Oron Ben Zvi. All rights reserved.
//

#import "DetailViewController.h"
#import "UIVIew+Shadow.h"

@interface DetailViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentsLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addGradientToView:self.imageView];
    [self.closeButton addShadow];
    [self loadImage];

    self.titleLabel.text = self.breadcrumb.title;
    self.contentsLabel.text = self.breadcrumb.contents;
    self.authorLabel.text = self.breadcrumb.author;
}

- (void)loadImage {
    [[[NSURLSession sharedSession]
          dataTaskWithURL:self.breadcrumb.imageUrl
        completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response,
                            NSError *_Nullable error) {
            if (data != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.imageView.image = [UIImage imageWithData:data];
                });
            }
        }] resume];
}

- (void)addGradientToView:(UIView *)view {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = view.bounds;
    gradient.colors = @[ (id)[[UIColor clearColor] CGColor], (id)[[UIColor blackColor] CGColor] ];
    [view.layer insertSublayer:gradient atIndex:0];
}

- (void)viewDidLayoutSubviews {
}

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
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
