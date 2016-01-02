//
//  DetailViewController.h
//  Breadcrumbs
//
//  Created by Oron Ben Zvi on 26/12/2015.
//  Copyright © 2015 Oron Ben Zvi. All rights reserved.
//

#import "Breadcrumb.h"

@protocol DetailViewDelegate <NSObject>

- (void)onDeleteBreadcrumb:(Breadcrumb *)breadcrumb;

@end

@interface DetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteButton;

@property (strong, nonatomic) Breadcrumb *breadcrumb;
@property (weak, nonatomic) id<DetailViewDelegate> delegate;
@property (weak, nonatomic) id<MKMapViewDelegate> mapViewDelegate;

@end
