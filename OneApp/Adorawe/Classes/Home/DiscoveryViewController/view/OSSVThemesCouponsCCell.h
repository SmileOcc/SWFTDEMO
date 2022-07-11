//
//  OSSVThemesCouponsCCell.h
// OSSVThemesCouponsCCell
//
//  Created by Starlinke on 2021/7/5.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVCollectCCellProtocol.h"
#import "OSSVThemeCouponCCellModel.h"

NS_ASSUME_NONNULL_BEGIN

@class OSSVThemesCouponsCCell;
@class STLScrollerCouponsItemCell;

@protocol STLThemeCouponsCCellDelegate <CollectionCellDelegate>

-(void)stl_themeCouponsCCell:(OSSVThemesCouponsCCell *)themeCouponsCCell couponsString:(NSString *)couponsString;

@end

///功能注释：原生专题优惠券
@interface OSSVThemesCouponsCCell : UICollectionViewCell
<
OSSVCollectCCellProtocol
>
@property (nonatomic, weak) id<STLThemeCouponsCCellDelegate> delegate;

///原生专题滑动商品
@property (nonatomic, strong) OSSVThemeCouponCCellModel                      *dataSourceThemeModels;


+ (CGSize)itemSize:(CGFloat)imageScale;

+ (CGSize)subItemSize:(CGFloat)imageScale;

- (NSIndexPath *)indexPathForCell:(OSSVThemesCouponsCCell *)cell;

@end



@interface STLScrollerCouponsItemCell : UICollectionViewCell

// STLDiscoveryBlockSlideGoodsModel  HomeGoodListModel
@property (nonatomic, strong) id model;
@property (nonatomic, strong) id itemModel;

@property (nonatomic, copy) void (^couponsBlock)(NSString *coupon_code);

- (void)updateModel:(id)model;

@end



NS_ASSUME_NONNULL_END
