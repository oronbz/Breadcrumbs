//
//  Model.m
//  Breadcrumbs
//
//  Created by Oron Ben Zvi on 26/12/2015.
//  Copyright © 2015 Oron Ben Zvi. All rights reserved.
//

#import "Model.h"
#import "ParseModel.h"
#import "SqlModel.h"

@implementation Model {
    ParseModel *parseModelImpl;
    SqlModel *sqlModelImpl;
}

static Model *instance = nil;

+ (Model *)instance {
    @synchronized(self) {
        if (instance == nil) {
            instance = [[Model alloc] init];
        }
    }
    return instance;
}

- (instancetype)init {
    if ((self = [super init])) {
        parseModelImpl = [[ParseModel alloc] init];
        sqlModelImpl = [[SqlModel alloc] init];
        _user = [parseModelImpl getCurrentUser];
    }
    return self;
}

- (void)logInWithUsername:(NSString *)username
                 password:(NSString *)password
               completion:(void (^)(BOOL))completion {
    dispatch_queue_t myQueue = dispatch_queue_create("myQueueName", NULL);

    dispatch_async(myQueue, ^{
        BOOL res = [parseModelImpl logInWithUsername:username password:password];
        if (res) {
            self.user = username;
        }
        dispatch_queue_t mainQ = dispatch_get_main_queue();
        dispatch_async(mainQ, ^{
            completion(res);
        });
    });
}

- (void)signUpWithUsername:(NSString *)username
                  password:(NSString *)password
                completion:(void (^)(BOOL))completion {
    dispatch_queue_t myQueue = dispatch_queue_create("myQueueName", NULL);

    dispatch_async(myQueue, ^{
        BOOL res = [parseModelImpl signUpWithusername:username password:password];
        if (res) {
            self.user = username;
        }
        dispatch_queue_t mainQ = dispatch_get_main_queue();
        dispatch_async(mainQ, ^{
            completion(res);
        });
    });
}

- (void)logOutWithCompletion:(void (^)())completion {
    dispatch_queue_t myQueue = dispatch_queue_create("myQueueName", NULL);

    dispatch_async(myQueue, ^{
        [parseModelImpl logOut];
        self.user = [parseModelImpl getCurrentUser];
        dispatch_queue_t mainQ = dispatch_get_main_queue();
        dispatch_async(mainQ, ^{
            completion();
        });
    });
}

// this method fetch everything from the server every time but works
- (void)getBreadcrumbsWithCompletion:(void (^)(NSArray *))completion {
    dispatch_queue_t myQueue = dispatch_queue_create("myQueueName", NULL);
    dispatch_async(myQueue, ^{
        NSMutableArray *data = (NSMutableArray *)[parseModelImpl getBreadcrumbs];
        dispatch_queue_t mainQ = dispatch_get_main_queue();
        dispatch_async(mainQ, ^{
            completion(data);
        });
    });
}

/*
 * This (last update) method is problematic since it won't update deleted breadcrumbs

- (void)getBreadcrumbsWithCompletion:(void (^)(NSArray *))completion {
    dispatch_queue_t myQueue = dispatch_queue_create("myQueueName", NULL);
    dispatch_async(myQueue, ^{
        NSMutableArray *data = (NSMutableArray *)[sqlModelImpl getBreadcrumbs];
        NSString *lastUpdate = [sqlModelImpl getBreadcrumbsLastUpdateDate];
        NSMutableArray *updatedData;
        if (lastUpdate != nil) {
            updatedData = (NSMutableArray *)[parseModelImpl getBreadcrumbsFromDate:lastUpdate];
        } else {
            updatedData = (NSMutableArray *)[parseModelImpl getBreadcrumbs];
        }
        if (updatedData.count > 0) {
            [sqlModelImpl updateBreadcrumbs:updatedData];
            [sqlModelImpl
                setBreadcrumbsLastUpdateDate:[NSString
                                                 stringWithFormat:@"%f",
                                                                  [[NSDate date]
                                                                      timeIntervalSince1970]]];
            data = (NSMutableArray *)[sqlModelImpl getBreadcrumbs];
        }
        dispatch_queue_t mainQ = dispatch_get_main_queue();
        dispatch_async(mainQ, ^{
            completion(data);
        });
    });
}
*/

- (void)getBreadcrumbsByCoordinate:(CLLocationCoordinate2D)coordinate
                        completion:(void (^)(NSArray *))completion {
    dispatch_queue_t myQueue = dispatch_queue_create("myQueueName", NULL);
    dispatch_async(myQueue, ^{
        NSMutableArray *data =
            (NSMutableArray *)[parseModelImpl getBreadcrumbsByCoordinate:coordinate];
        dispatch_queue_t mainQ = dispatch_get_main_queue();
        dispatch_async(mainQ, ^{
            completion(data);
        });
    });
}

- (void)addBreadcrumb:(Breadcrumb *)breadcrumb completion:(void (^)())completion {
    dispatch_queue_t myQueue = dispatch_queue_create("myQueueName", NULL);
    dispatch_async(myQueue, ^{
        [parseModelImpl addBreadcrumb:breadcrumb];
        [sqlModelImpl addBreadcrumb:breadcrumb];
        dispatch_queue_t mainQ = dispatch_get_main_queue();
        dispatch_async(mainQ, ^{
            completion();
        });
    });
}

- (void)deleteBreadcrumb:(Breadcrumb *)breadcrumb completion:(void (^)())completion {
    dispatch_queue_t myQueue = dispatch_queue_create("myQueueName", NULL);
    dispatch_async(myQueue, ^{
        [parseModelImpl deleteBreadcrumb:breadcrumb];
        [sqlModelImpl deleteBreadcrumb:breadcrumb];
        dispatch_queue_t mainQ = dispatch_get_main_queue();
        dispatch_async(mainQ, ^{
            completion();
        });
    });
}

- (void)getImageForBreadcrumb:(Breadcrumb *)breadcrumb completion:(void (^)(UIImage *))completion {
    dispatch_queue_t myQueue = dispatch_queue_create("myQueueName", NULL);
    dispatch_async(myQueue, ^{
        // first try to get the image from local file
        UIImage *image = [self readingImageFromFile:breadcrumb.imageName];
        // if failed to get image from file try to get it from parse
        if (image == nil) {
            image = [parseModelImpl getImage:breadcrumb.imageName];
            // one the image is loaded save it localy
            if (image != nil) {
                [self savingImageToFile:image fileName:breadcrumb.imageName];
            }
        }
        dispatch_queue_t mainQ = dispatch_get_main_queue();
        dispatch_async(mainQ, ^{
            completion(image);
        });
    });
}

- (void)saveImageForBreadcrumb:(Breadcrumb *)breadcrumb
                         image:(UIImage *)image
                    completion:(void (^)(NSError *))completion {
    dispatch_queue_t myQueue = dispatch_queue_create("myQueueName", NULL);
    dispatch_async(myQueue, ^{
        // save the image to parse
        [parseModelImpl saveImage:image withName:breadcrumb.imageName];
        // save the image localy
        [self savingImageToFile:image fileName:breadcrumb.imageName];
        dispatch_queue_t mainQ = dispatch_get_main_queue();
        dispatch_async(mainQ, ^{
            completion(nil);
        });
    });
}

#pragma mark - Private Methods

- (void)savingImageToFile:(UIImage *)image fileName:(NSString *)fileName {
    NSData *pngData = UIImagePNGRepresentation(image);
    [self saveToFile:pngData fileName:fileName];
}

- (UIImage *)readingImageFromFile:(NSString *)fileName {
    NSData *pngData = [self readFromFile:fileName];
    if (pngData == nil)
        return nil;
    return [UIImage imageWithData:pngData];
}

- (NSString *)getLocalFilePath:(NSString *)fileName {
    NSArray *paths =
        NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];  // Get the docs directory
    NSString *filePath = [documentsPath stringByAppendingPathComponent:fileName];
    return filePath;
}

- (void)saveToFile:(NSData *)data fileName:(NSString *)fileName {
    NSString *filePath = [self getLocalFilePath:fileName];
    [data writeToFile:filePath atomically:YES];  // Write the file
}

- (NSData *)readFromFile:(NSString *)fileName {
    NSString *filePath = [self getLocalFilePath:fileName];
    NSData *pngData = [NSData dataWithContentsOfFile:filePath];
    return pngData;
}

@end
