//
//  ZFNativeSlideBannerCell.h
//  ZZZZZ
//
//  Created by YW on 1/8/18.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZFNativeBannerModel;
@class ZFBannerModel;

@interface ZFNativeSlideBannerCell : UICollectionViewCell

@property (nonatomic, strong) NSArray<ZFNativeBannerModel *> *scrollerBannerArray;

@property (nonatomic, copy) void(^sliderBannerClick)(ZFBannerModel *sliderBannerModel);

+ (ZFNativeSlideBannerCell *)sliderBannerCellWith:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath;

@end
