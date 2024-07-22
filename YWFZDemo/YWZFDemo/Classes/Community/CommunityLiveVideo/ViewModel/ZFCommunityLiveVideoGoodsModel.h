//
//  ZFCommunityLiveVideoGoodsModel.h
//  ZZZZZ
//
//  Created by YW on 2019/4/2.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "BaseViewModel.h"
#import "ZFGoodsModel.h"
#import "ZFGoodsDetailCouponModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFCommunityLiveVideoGoodsModel : BaseViewModel

@property (nonatomic, strong) ZFGoodsDetailCouponModel *couponModel;

@property (nonatomic, strong) NSMutableArray<ZFGoodsModel *> *goodsArray;

@property (nonatomic, strong) NSMutableArray<ZFGoodsDetailCouponModel *> *couponsArray;

-(void)requestLiveVideoGoodsData:(BOOL)firstPage videoCoupon:(NSString *)coupon skus:(NSString *)skus completion:(void (^)(NSArray<ZFGoodsModel*> *goodsArray,NSDictionary *pageInfo))completion failure:(void (^)(id obj))failure;

-(void)requestLiveVideoCouponsData:(BOOL)firstPage coupon:(NSString *)coupons completion:(void (^)(NSArray<ZFGoodsDetailCouponModel*> *couponsArray,NSDictionary *pageInfo))completion failure:(void (^)(id obj))failure;
/**
 * 详情页面领取coupon
 */
+ (void)requestGetGoodsCoupon:(NSString *)couponId
                   completion:(void (^)(BOOL success, NSInteger couponStatus))completion;

@end

NS_ASSUME_NONNULL_END
