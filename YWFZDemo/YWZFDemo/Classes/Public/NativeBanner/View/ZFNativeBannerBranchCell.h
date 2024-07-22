//
//  ZFNativeBannerBranchCell.h
//  ZZZZZ
//
//  Created by YW on 1/8/18.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZFNativeBannerModel;

@interface ZFNativeBannerBranchCell : UICollectionViewCell

+ (ZFNativeBannerBranchCell *)branchBannerCellWith:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, strong) ZFNativeBannerModel       *branchBannerModel;

@property (nonatomic, assign) NSInteger                 branch;

/**
 * 主动暂停视频播放
 */
- (void)pausePlayVideo;

@end
