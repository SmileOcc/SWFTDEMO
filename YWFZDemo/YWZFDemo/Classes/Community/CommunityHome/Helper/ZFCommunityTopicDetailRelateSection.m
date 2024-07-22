//
//  ZFCommunityTopicDetailRelateSection.m
//  ZZZZZ
//
//  Created by YW on 2018/7/10.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityTopicDetailRelateSection.h"
#import "ZFCommunityPostListInfoModel.h"
#import "ZFCommunityPictureModel.h"
#import "ZFFrameDefiner.h"

@implementation ZFCommunityTopicDetailRelateSection


+ (CGFloat)relateCellWidth {
    return (KScreenWidth - 12.0 * 3) / 2;
}
- (instancetype)init {
    if (self = [super init]) {
        self.type = ZFTopicSectionTypeRelated;
        self.columnCount             = 2;
        self.headerSize              = CGSizeMake(KScreenWidth, 44.0);
        self.minimumLineSpacing      = 12.0f;
        self.minimumInteritemSpacing = 12.0f;
        self.edgeInsets              = UIEdgeInsetsMake(0.0, 12.0, 0.0, 12.0);
    }
    return self;
}

- (void)setTopicArray:(NSArray<ZFCommunityPostListInfoModel *> *)topicArray {
    _topicArray   = topicArray;
    self.rowCount = topicArray.count;
}

- (CGSize)goodsItemSizeWithIndex:(NSInteger)index {
    if (self.topicArray.count > index) {
        ZFCommunityPostListInfoModel *model = [self.topicArray objectAtIndex:index];
        if (model.reviewPic.count > 0) {
            ZFCommunityPictureModel *picModel = model.reviewPic[0];
            CGFloat cellWidth  = [ZFCommunityTopicDetailRelateSection relateCellWidth];
            CGFloat cellHeight = [picModel.bigPicWidth floatValue] > 0 ? cellWidth * [picModel.bigPicHeight floatValue] / [picModel.bigPicWidth floatValue] : 0.0;
            CGSize contentSize = [[self topicListContentWithIndex:index] sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12.0]}];
            if (contentSize.width > cellWidth - 24.0) {
                return CGSizeMake(cellWidth, cellHeight + 76.0);
            }
            return CGSizeMake(cellWidth, cellHeight + 62.0);
        }
    }
    return CGSizeZero;
}

- (ZFCommunityPostListInfoModel *)topicPicModelWithIndex:(NSInteger)index {
    if (self.topicArray.count > index) {
        ZFCommunityPostListInfoModel *model = [self.topicArray objectAtIndex:index];
        return model;
    }
    return [ZFCommunityPostListInfoModel new];
}

- (NSString *)topicImageURLWithIndex:(NSInteger)index {
    ZFCommunityPostListInfoModel *model = [self topicPicModelWithIndex:index];
    if (model.reviewPic.count > 0) {
        ZFCommunityPictureModel *picModel = model.reviewPic[0];
        return picModel.originPic;
    }
    return nil;
}

- (NSString *)topicContentWithIndex:(NSInteger)index {
    return [self topicPicModelWithIndex:index].content;
}

- (NSString *)topicListContentWithIndex:(NSInteger)index {
    ZFCommunityPostListInfoModel *model = [self topicPicModelWithIndex:index];
    NSMutableString *contentString = [NSMutableString new];
    for (NSString *tagString in model.topicList) {
        [contentString appendString:tagString];
    }
    
    if (model.content.length > 0) {
        [contentString appendFormat:@" %@", model.content];
    }
    NSString *replaceString = [contentString stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    replaceString  = [replaceString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return replaceString;
}

- (NSString *)topicUserImageURLWithIndex:(NSInteger)index {
    return [self topicPicModelWithIndex:index].avatar;
}

- (NSString *)topicUserNickNameWithIndex:(NSInteger)index {
    return [self topicPicModelWithIndex:index].nickname;
}

- (NSString *)topicLikeNumWithIndex:(NSInteger)index {
    return [NSString stringWithFormat:@"%ld", [self topicPicModelWithIndex:index].likeCount];
}

- (NSString *)topicIDNumWithIndex:(NSInteger)index {
    return [self topicPicModelWithIndex:index].reviewId;
}

- (BOOL)topicIsLikedWithIndex:(NSInteger)index {
    return [self topicPicModelWithIndex:index].isLiked;
}

- (NSString *)topicUserIDNumWithIndex:(NSInteger)index {
    return [self topicPicModelWithIndex:index].userId;
}

- (CGFloat)imageRateWidthToHeight:(NSInteger)index {
    ZFCommunityPostListInfoModel *model = [self topicPicModelWithIndex:index];
    if (model.reviewPic.count > 0) {
        ZFCommunityPictureModel *picModel = model.reviewPic[0];
        return [picModel.bigPicWidth floatValue] > 0 ? [picModel.bigPicHeight floatValue] / [picModel.bigPicWidth floatValue] : 0.0;
    }
    return 0.0;
}

@end
