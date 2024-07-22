//
//  ZFCommunityLiveVideoCouponCCell.h
//  ZZZZZ
//
//  Created by YW on 2019/4/19.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFGoodsDetailCouponModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^CommunityLiveVideoCouponBlock)(ZFGoodsDetailCouponModel *couponModel);


@interface ZFCommunityLiveVideoCouponCCell : UICollectionViewCell

@property (nonatomic, strong) ZFGoodsDetailCouponModel *couponModel;

@property (nonatomic, copy) CommunityLiveVideoCouponBlock receiveCouponBlock;

@end

NS_ASSUME_NONNULL_END
