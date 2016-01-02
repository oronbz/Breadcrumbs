//
//  ListViewController.h
//  Breadcrumbs
//
//  Created by Oron Ben Zvi on 26/12/2015.
//  Copyright © 2015 Oron Ben Zvi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Breadcrumb.h"

@protocol ListViewDelegate <NSObject>

- (void)didSelectBreadcrumb:(Breadcrumb *)breadcrumb;

@end

@interface ListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) id<ListViewDelegate> delegate;
@property (strong, nonatomic) NSArray *breadcrumbs;
@property (strong, nonatomic) NSArray *distances;

@end
