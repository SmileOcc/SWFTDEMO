//
//  ZFCurrencyViewController.h
//  Dezzal
//
//  Created by 7FD75 on 16/8/1.
//  Copyright © 2016年 7FD75. All rights reserved.
//

#import "ZFBaseViewController.h"
#import "CurrencyViewModel.h"

@interface ZFCurrencyViewController : ZFBaseViewController


/** 从启动引导进来需要选中之前选择的货币 */
@property (nonatomic, strong) NSString *shouldSelectedCurrency;

@property (nonatomic, assign) ZFCurrencyVCComeFromType comeFromType;

@property (nonatomic, copy) void (^convertCurrencyBlock)(NSString *selectedCurrency);

@end
