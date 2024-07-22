//
//  ZFBannerCollectionReusableView.h
//  ZZZZZ
//
//  Created by YW on 2018/11/21.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZFCateBranchBanner, ZFBannerModel;
@interface ZFBannerCollectionView : UICollectionViewCell

@property (nonatomic, copy) void(^bannerHandle)(ZFBannerModel *model, NSInteger index);

- (void)configWithModel:(ZFCateBranchBanner *)branceBanner;

@end

