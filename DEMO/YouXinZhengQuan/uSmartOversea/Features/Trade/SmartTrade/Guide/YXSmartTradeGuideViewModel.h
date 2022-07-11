//
//  YXSmartTradeGuideViewModel.h
//  YouXinZhengQuan
//
//  Created by Mac on 2020/4/7.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXViewModel.h"
//#import "YXSmartTradeViewModel.h"

NS_ASSUME_NONNULL_BEGIN
@class YXBannerActivityDetailModel;
@class TradeModel;
@interface YXSmartTradeGuideViewModel : YXViewModel

@property (nonatomic, strong) TradeModel *tradeModel; //交易模型
//顶部图片
@property (nonatomic, strong) RACCommand *advertiseCommand;
//风险提示
@property (nonatomic, strong) RACCommand *kindlyReminderCommand;


@property (nonatomic, strong) NSArray <YXBannerActivityDetailModel *>*bannerList;

- (void)pushToSmartOrderWith:(NSInteger)type;

@property (nonatomic, strong) NSArray *configs;


@end

NS_ASSUME_NONNULL_END
