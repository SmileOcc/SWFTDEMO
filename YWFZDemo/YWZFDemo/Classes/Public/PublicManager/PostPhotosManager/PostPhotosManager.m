//
//  PostPhotosManager.m
//  ZZZZZ
//
//  Created by YW on 2016/11/29.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "PostPhotosManager.h"

@interface PostPhotosManager ()

@end

@implementation PostPhotosManager
+ (PostPhotosManager *)sharedManager {
    static PostPhotosManager *sharedManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedManagerInstance = [[self alloc] init];
        sharedManagerInstance.selectedPhotos = [NSMutableArray array];
        sharedManagerInstance.selectedAssets = [NSMutableArray array];
        sharedManagerInstance.isSelectOriginalPhoto = NO;
    });
    return sharedManagerInstance;
}

- (void)clearData {
    [self.selectedPhotos removeAllObjects];
    [self.selectedAssets removeAllObjects];
    self.isSelectOriginalPhoto = NO;
}
@end
