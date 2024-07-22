//
//  ZFZFNewUserActivetyViewModel.h
//  ZZZZZ
//
//  Created by mac on 2019/1/5.
//  Copyright © 2019年 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ZFNativeBannerResultModel;
@class ZFNewUserExclusiveModel;
@class ZFNewUserSecckillModel;
@class ZFNewUserHeckReceivingStatusModel;

NS_ASSUME_NONNULL_BEGIN

@interface ZFZFNewUserActivetyViewModel : NSObject

@property (nonatomic, strong) ZFNewUserExclusiveModel      *homeExclusiveModel;

@property (nonatomic, strong) ZFNewUserSecckillModel       *homeSecckillModel;

@property (nonatomic, strong) ZFNewUserHeckReceivingStatusModel *heckReceivingStatusModel;

@property (nonatomic, strong) NSArray                   *exclusiveControllerArr;

@property (nonatomic, strong) NSArray                   *exclusiveTitleArr;

@property (nonatomic, strong) NSArray                   *secckillcontrollerArr;

@property (nonatomic, strong) NSArray                   *secckilltitleArr;

@property (nonatomic, strong) NSArray                   *secckillSubtitleArr;

@property (nonatomic, assign) double                    remainingTime;

/** 访问新人专享商品列表接口：新人专享商品列表 */
- (void)requestGetExclusiveListWihtCompletion:(void (^)(ZFNewUserExclusiveModel *homeExclusiveModel,BOOL isSuccess))completion;

/** 访问新人专享商品列表接口：秒杀商品列表 */
- (void)requestGetSecckillListWihtCompletion:(void (^)(ZFNewUserSecckillModel *bannerModel,BOOL isSuccess))completion;

/** 访问用户领取优惠券状态 */
- (void)requestCheckReceivingStatusWihtCompletion:(void (^)(ZFNewUserHeckReceivingStatusModel *bannerModel,BOOL isSuccess))completion;

@end

NS_ASSUME_NONNULL_END
