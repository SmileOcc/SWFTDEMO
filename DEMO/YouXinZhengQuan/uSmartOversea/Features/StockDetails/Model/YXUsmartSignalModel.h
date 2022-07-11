//
//  YXUsmartSignalModel.h
//  uSmartOversea
//
//  Created by chenmingmao on 2021/3/2.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YXUsmartSignalModel : NSObject

// 日期（时间戳）
@property (nonatomic, strong) NSString *date;
// 1-买入 2-卖出
@property (nonatomic, assign) NSInteger signal_type;
// 信号涨跌幅  1、0+50% 2、0+100% 3、50+100%  4、100-50% 5、100-0% 6、50-0%
@property (nonatomic, assign) NSInteger signal_chg;
// 触发价格 收盘价
@property (nonatomic, assign) NSInteger trigger_price;
// 区间涨跌幅
@property (nonatomic, assign) NSInteger range_pctchng;
@end

NS_ASSUME_NONNULL_END
