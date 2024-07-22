//
//  PYAssetModel.m
//  PYPhotoAblumManager
//
//  Created by YW on 2018/1/26.
//  Copyright © 2018年 李鹏跃. All rights reserved.
//

#import "PYAssetModel.h"
#import "PYAblum.h"
@implementation PYAssetModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isShowMask = false;
    }
    return self;
}
- (void)setIsBeyondTheMaximum:(BOOL)isBeyondTheMaximum {
    _isBeyondTheMaximum = isBeyondTheMaximum;
    self.isShowMask = isBeyondTheMaximum && !self.isSelected;
}

- (void)getOriginImage:(void(^)(UIImage *image))block progress:(void(^)(double progress))progressBlock {
    if (!block) return;
    
    if (self.originImage) {
        block(self.originImage);
    }else{
        [[PYAblum defaultAblum].imageManager getOriginPoto:self.asset andCompletion:^(UIImage *image) {
            self.originImage = image;
            block(image);
        } andProgress:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
            if (progressBlock) {
                progressBlock(progress);
            }
        }];
    }
}

- (void)getDelicateImageWidth: (CGFloat)imageW andBlock:(void(^)(UIImage *image))block {
    if (!block) return;
    
    [[PYAblum defaultAblum].imageManager getPotoWithAsset:self.asset andSetPotoWidth:imageW andnetworkAccessAllowed:false andCompletion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        if (isDegraded) {
            self.degradedImage = photo;
        }else{
            self.delicateImage = photo;
            block(photo);
        }
    } andProgress:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
    }];
}
@end
