//
//  ListViewController.m
//  Breadcrumbs
//
//  Created by Oron Ben Zvi on 26/12/2015.
//  Copyright © 2015 Oron Ben Zvi. All rights reserved.
//

#import "Breadcrumb.h"
#import "ListViewController.h"

@interface ListViewController ()

@property (weak, nonatomic) IBOutlet UITableView* tableView;

@end

@implementation ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)setBreadcrumbs:(NSArray*)breadcrumbs {
    _breadcrumbs = breadcrumbs;
    [self.tableView reloadData];
}

- (void)setDistances:(NSArray*)distances {
    _distances = distances;
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    if ([self.delegate respondsToSelector:@selector(didSelectBreadcrumb:)]) {
        [self.delegate didSelectBreadcrumb:self.breadcrumbs[indexPath.row]];
    }
    [tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:NO];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.breadcrumbs count];
}

- (UITableViewCell*)tableView:(UITableView*)tableView
        cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    Breadcrumb* breadcrumb = self.breadcrumbs[indexPath.row];
    cell.textLabel.text = breadcrumb.locationName;
    int meters = (int)[self.distances[indexPath.row] integerValue];
    cell.detailTextLabel.text = meters >= 1000
                                    ? [NSString stringWithFormat:@"%d kilometer(s)", meters / 1000]
                                    : [NSString stringWithFormat:@"%d meter(s)", meters];
    return cell;
}

@end
