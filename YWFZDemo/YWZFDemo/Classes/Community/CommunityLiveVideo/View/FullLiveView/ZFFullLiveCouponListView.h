//
//  ZFFullLiveCouponListView.h
//  ZZZZZ
//
//  Created by YW on 2019/12/18.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFGoodsDetailCouponModel.h"
#import "ZFVideoLiveConfigureInfoUtils.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFFullLiveCouponListView : UIView

@property (nonatomic, copy) void (^closeBlock)(void);

@property (nonatomic, copy) void (^selectCouponBlock)(ZFGoodsDetailCouponModel *couponModel);

@property (nonatomic, copy) NSString *live_code;
@property (nonatomic, assign) BOOL isCanReceive;

- (void)updateDatas:(ZFGoodsDetailCouponModel *)couponModel;
- (void)zfViewWillAppear;
//- (void)updateHotActivity:(NSArray <ZFCommunityLiveVideoRedNetModel*> *)activityModel;


- (void)showCouponListView:(BOOL)show;
@end

NS_ASSUME_NONNULL_END
