//
//  BreadcrumbAnnotationView.m
//  Breadcrumbs
//
//  Created by Oron Ben Zvi on 29/12/2015.
//  Copyright © 2015 Oron Ben Zvi. All rights reserved.
//

#import "BreadcrumbAnnotationView.h"

@implementation BreadcrumbAnnotationView

- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation
                   reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super init])) {
        self.image = [UIImage imageNamed:@"MapPin"];
    }
    return self;
}

@end
