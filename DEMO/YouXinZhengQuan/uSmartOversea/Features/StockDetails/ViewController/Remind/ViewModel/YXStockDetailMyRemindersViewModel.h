//
//  YXStockDetailMyRemindersViewModel.h
//  uSmartOversea
//
//  Created by 姜轶群 on 2018/11/21.
//  Copyright © 2018年 RenRenDai. All rights reserved.
//

#import "YXTableViewModel.h"

typedef void(^GetHttpQuoteResultBlock)(id _Nullable result); // result @"0":不满足条件 @"1"：成功  NSError *error：失败

NS_ASSUME_NONNULL_BEGIN

@interface YXStockDetailMyRemindersViewModel : YXTableViewModel

@property (nonatomic, copy) NSString *market;
@property (nonatomic, copy) NSString *symbol;
@property (nonatomic, copy) NSString *marketSymbol;


//加载行情数据
@property (nonatomic, strong) RACSubject *quotaSubject;
//编辑
@property (nonatomic, strong) RACCommand *editRemindCommand;
//删除
@property (nonatomic, strong) RACCommand *deleteRemindCommand;
//删除之后的通知
@property (nonatomic, strong) RACSubject *deleteRemindNotifySubject;

//加载行情数据
@property (nonatomic, strong) RACSubject *remindListSubject;

@end

NS_ASSUME_NONNULL_END
