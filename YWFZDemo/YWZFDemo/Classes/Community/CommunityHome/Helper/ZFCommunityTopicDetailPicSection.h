//
//  ZFCommunityTopicDetailPicSection.h
//  ZZZZZ
//
//  Created by YW on 2018/7/10.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityTopicDetailBaseSection.h"

@class ZFCommunityPictureModel;
@interface ZFCommunityTopicDetailPicSection : ZFCommunityTopicDetailBaseSection

@property (nonatomic, strong) NSArray<ZFCommunityPictureModel *> *pictureModelArray;

@property (nonatomic, strong) NSArray<UIImage *> *preivewImages;

- (CGSize)picSizeWithIndex:(NSInteger)index;
- (NSString *)picURLWithIndex:(NSInteger)index;

@end
