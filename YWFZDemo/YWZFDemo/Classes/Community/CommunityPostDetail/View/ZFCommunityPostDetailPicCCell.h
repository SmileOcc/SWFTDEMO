//
//  ZFCommunityPostDetailPicCCell.h
//  ZZZZZ
//
//  Created by YW on 2018/7/10.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYWebImage/UIImageView+YYWebImage.h>
#import <YYImage/YYImage.h>

typedef void(^TopicDetailPicTapBlock)(BOOL isDouble);

@interface ZFCommunityPostDetailPicCCell : UICollectionViewCell

@property (nonatomic, strong) YYAnimatedImageView *imageView;

@property (nonatomic, copy) TopicDetailPicTapBlock picTapBlock;


+ (ZFCommunityPostDetailPicCCell *)picCellWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;
- (void)configWithPicURL:(NSString *)picURL;

/// 发帖预发布用
- (void)previewImage:(UIImage *)image;

@end
