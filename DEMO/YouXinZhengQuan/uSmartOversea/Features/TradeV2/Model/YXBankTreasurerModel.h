//
//  YXBankTreasurerModel.h
//  YouXinZhengQuan
//
//  Created by chenmingmao on 2020/8/20.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YXBankTreasurerModel : NSObject

// 转入 账户类型（0-普通账户，1-保证金账户，10-DA账户，11-MA账户，12-MA费用账户，20-日内融账户）
@property (nonatomic, assign) NSInteger inAccountType;
// 转出 账户类型（0-普通账户，1-保证金账户，10-DA账户，11-MA账户，12-MA费用账户，20-日内融账户）
@property (nonatomic, assign) NSInteger outAccountType;
// 金额
@property (nonatomic, assign) double amount;
// 处理状态 10待处理，20处理成功，30处理失败
@property (nonatomic, assign) int handleStatus;
// 币种类型。(0-人民币，1-美元，2-港币)
@property (nonatomic, assign) int moneyType;
// 完成时间
@property (nonatomic, strong) NSString *dealTime;
// 市场类别(0-香港，1-上海A，2-上海B，3-深圳A，4-深证B，5-美股，6-沪股通，7-深港通
@property (nonatomic, assign) int exchangeType;

@end

NS_ASSUME_NONNULL_END
