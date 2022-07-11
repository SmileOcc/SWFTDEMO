//
//  YXCanBuyModel.h
//  YouXinZhengQuan
//
//  Created by mac on 2019/5/17.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface YXCanBuyModel : YXModel


@property (nonatomic, assign) NSNumber *buyEnableAmount;//最大可买数量   ---> 融资可买
@property (nonatomic, assign) NSNumber *oddEnableAmount;//最大可卖碎股数量
@property (nonatomic, assign) NSNumber *saleEnableAmount;//最大可卖数量
@property (nonatomic, assign) NSNumber *saleEnableIntAmount;//最大整手可卖数量

@property (nonatomic, assign) NSNumber *cashEnableAmount; /// 现金可买数量-包含碎股    51758000
@property (nonatomic, assign) NSNumber *cashEnableIntAmount; /// 现金可买整手数量  51758000
@property (nonatomic, copy) NSString *cashPurchasingPower; /// 现金购买力   "19964631.64";
@property (nonatomic, copy) NSString * fundAccoutType; /// 资金账户类型(0-现金账号，M-融资账号)
@property (nonatomic, copy) NSString *maxPurchasingPower; /// 融资购买力，margin账户   "<null>";


@end

@interface YXShortSellCanBuyModel : YXModel


@property (nonatomic, assign) NSString *availableCash;
@property (nonatomic, assign) NSNumber *buyMax;
@property (nonatomic, assign) NSNumber *buyMin;
@property (nonatomic, assign) NSNumber *clinchQty;

@property (nonatomic, assign) NSNumber *orderQty;
@property (nonatomic, assign) NSNumber *sellMax;
@property (nonatomic, assign) NSNumber *sellMin;


@end


NS_ASSUME_NONNULL_END
