//
//  ZFCommunityTopicDetailPicSection.m
//  ZZZZZ
//
//  Created by YW on 2018/7/10.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityTopicDetailPicSection.h"
#import "ZFCommunityPictureModel.h"
#import "ZFFrameDefiner.h"

@implementation ZFCommunityTopicDetailPicSection

- (instancetype)init {
    if (self = [super init]) {
        self.type               = ZFTopicSectionTypePic;
        self.minimumLineSpacing = 2.0f;
    }
    return self;
}

- (CGSize)picSizeWithIndex:(NSInteger)index {
    if (self.pictureModelArray.count > index) {
        ZFCommunityPictureModel *model = self.pictureModelArray[index];
        CGFloat width  = KScreenWidth;
        CGFloat height = 0.0;
        if ([model.bigPicWidth floatValue] != 0) {
            height = width * [model.bigPicHeight floatValue] / [model.bigPicWidth floatValue];
        }
        return CGSizeMake(width, height);
    }
    return CGSizeZero;
}

- (void)setPictureModelArray:(NSArray<ZFCommunityPictureModel *> *)pictureModelArray {
    _pictureModelArray = pictureModelArray;
    self.rowCount = pictureModelArray.count;
}

- (NSString *)picURLWithIndex:(NSInteger)index {
    if (self.pictureModelArray.count > index) {
        ZFCommunityPictureModel *model = [self.pictureModelArray objectAtIndex:index];
        return model.bigPic;
    }
    return nil;
}

@end
