//
//  UIView+Shadow.m
//  Breadcrumbs
//
//  Created by Oron Ben Zvi on 26/12/2015.
//  Copyright © 2015 Oron Ben Zvi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+Shadow.h"

@implementation UIView (Shadow)

- (void)addShadow {
    self.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.layer.shadowOpacity = 0.5;
    self.layer.shadowOffset = CGSizeMake(0, 2);
    self.layer.shadowRadius = 4;
}

@end
