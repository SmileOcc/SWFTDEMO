//
//  CurrencyViewModel.h
//  ZZZZZ
//
//  Created by DBP on 17/2/14.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "BaseViewModel.h"

typedef enum : NSUInteger {
    CurrencyComeFrom_AccountCurrency,
    CurrencyComeFrom_GuideSetting
} ZFCurrencyVCComeFromType;


@interface CurrencyViewModel : BaseViewModel <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView       *tableView;
@property (nonatomic, copy) void (^selectCurrencyBlock)(NSString *currency);
/** 从启动引导进来需要选中之前选择的货币 */
@property (nonatomic, strong) NSString *shouldSelectedCurrency;

- (void)requestData:(ZFCurrencyVCComeFromType)comeFromType;

@end
