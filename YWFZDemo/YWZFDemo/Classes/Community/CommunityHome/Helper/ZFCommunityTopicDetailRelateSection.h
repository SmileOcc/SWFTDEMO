//
//  ZFCommunityTopicDetailRelateSection.h
//  ZZZZZ
//
//  Created by YW on 2018/7/10.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityTopicDetailBaseSection.h"

@class ZFCommunityPostListInfoModel;
@interface ZFCommunityTopicDetailRelateSection : ZFCommunityTopicDetailBaseSection

@property (nonatomic, strong) NSArray<ZFCommunityPostListInfoModel *> *topicArray;
- (CGSize)goodsItemSizeWithIndex:(NSInteger)index;

- (NSString *)topicImageURLWithIndex:(NSInteger)index;
- (NSString *)topicContentWithIndex:(NSInteger)index;
- (NSString *)topicListContentWithIndex:(NSInteger)index;
- (NSString *)topicUserImageURLWithIndex:(NSInteger)index;
- (NSString *)topicUserNickNameWithIndex:(NSInteger)index;
- (NSString *)topicLikeNumWithIndex:(NSInteger)index;
- (NSString *)topicIDNumWithIndex:(NSInteger)index;
- (NSString *)topicUserIDNumWithIndex:(NSInteger)index;
- (CGFloat)imageRateWidthToHeight:(NSInteger)index;
- (BOOL)topicIsLikedWithIndex:(NSInteger)index;
- (ZFCommunityPostListInfoModel *)topicPicModelWithIndex:(NSInteger)index;

+ (CGFloat)relateCellWidth;

@end
