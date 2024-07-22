//
//  ZFCMSCouponManager.h
//  ZZZZZ
//
//  Created by YW on 2019/11/8.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"
#import "YWCFunctionTool.h"
#import "ZFCMSCouponModel.h"


@interface ZFCMSCouponManager : NSObject

+ (instancetype)manager;

@property (nonatomic, strong) NSMutableArray<ZFCMSCouponModel*> *localCouponList;


+ (void)saveCouponStateModel:(ZFCMSCouponModel *)couponModel;

+ (void)clearLocalCmsCoupon:(NSString *)fileName;

- (NSArray<ZFCMSCouponModel *> *)getLocalCmsCouponList;

- (ZFCMSCouponModel *)localCouponModelForID:(NSString *)couponId;

@end

