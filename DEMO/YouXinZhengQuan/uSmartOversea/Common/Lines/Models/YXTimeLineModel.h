//
//  YXTimeLineModel.h
//  LIne
//
//  Created by Kelvin on 2019/4/4.
//  Copyright © 2019年 Kelvin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YXTimeLineSingleModel : NSObject

@property (nonatomic, copy) NSString *market;
@property (nonatomic, copy) NSString *time; //当前时间(47)
@property (nonatomic, copy) NSString *avg; //均价(18)
@property (nonatomic, copy) NSString *price; //分时价(19)
@property (nonatomic, copy) NSString *volume; //成交量(20)
@property (nonatomic, copy) NSString *pclose; //昨日收盘价(2)
@property (nonatomic, copy) NSString *amount; //成交金额(21)
@property (nonatomic, copy) NSString *change; //涨跌值 (24)
@property (nonatomic, copy) NSString *roc; //涨跌幅(25) 除以100
@property (nonatomic, copy) NSString *priceBase; //除数位
@property (nonatomic, assign) NSInteger index; //指数

@end

@interface YXTimeLineModel : NSObject

@property (nonatomic, copy) NSString *price_base;
@property (nonatomic, copy) NSString *market;
@property (nonatomic, copy) NSString *days;
@property (nonatomic, assign) NSInteger chartType; //0：1日，1：5日，2：1月，3：6月，4：1年，5：5年
@property (nonatomic, assign) BOOL delay;
@property (nonatomic, strong) NSMutableArray<YXTimeLineSingleModel *> *list;
@property (nonatomic, assign) NSInteger type; //0：非暗盘，1：暗盘全日（16:15~18:30），2：暗盘半日（14:15~16:30）

@end

NS_ASSUME_NONNULL_END
