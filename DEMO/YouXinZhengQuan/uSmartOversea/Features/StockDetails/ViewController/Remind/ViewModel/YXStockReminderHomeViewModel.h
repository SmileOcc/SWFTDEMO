//
//  YXStockReminderHomeViewModel.h
//  uSmartOversea
//
//  Created by chenmingmao on 2020/10/26.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXTableViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface YXStockReminderHomeViewModel : YXTableViewModel

//market + symbol
@property (nonatomic, copy) NSString *market;
@property (nonatomic, copy) NSString *symbol;

//跳转到"我的提醒"
@property (nonatomic, strong) RACCommand *pushToMyRemindsCommand;

@property (nonatomic, strong) RACCommand *deleteCommand;

@property (nonatomic, strong) RACCommand *updateCommand;

@property (nonatomic, strong) NSArray *formArr;


@end

NS_ASSUME_NONNULL_END
