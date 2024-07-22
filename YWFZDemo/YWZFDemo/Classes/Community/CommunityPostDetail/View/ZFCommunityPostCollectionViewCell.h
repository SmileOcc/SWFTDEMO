//
//  ZFCommunityTopicCollectionViewCell.h
//  ZZZZZ
//
//  Created by YW on 2018/7/11.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFCommunityPostDetailViewModel.h"

@interface ZFCommunityPostCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) ZFCommunityPostListInfoModel *infoModel;

@property (nonatomic, copy) void(^likeTopicHandle)(void);
+ (ZFCommunityPostCollectionViewCell *)topicCellWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;
- (void)configWithViewModel:(ZFCommunityPostDetailViewModel *)viewModel indexPath:(NSIndexPath *)indexPath;

@end
