//
//  YXHkVolumnModel.h
//  uSmartOversea
//
//  Created by chenmingmao on 2020/3/12.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface YXHkVolumnSubModel : NSObject
//日期类型，1：最近1日，5：最近5日，20：最近20日，60：最近60日
@property (nonatomic, assign) NSInteger dateType;
//持股变更比例
@property (nonatomic, assign) int changeRatio;
//净买卖成交量
@property (nonatomic, assign) int64_t changeVolume;
//净买成交额
@property (nonatomic, assign) int64_t changeAmount;

@end

@interface YXHkVolumnModel : NSObject

@property (nonatomic, strong) NSArray <YXHkVolumnSubModel *> *list;

@property (nonatomic, assign) NSInteger priceBase;


@end

NS_ASSUME_NONNULL_END
