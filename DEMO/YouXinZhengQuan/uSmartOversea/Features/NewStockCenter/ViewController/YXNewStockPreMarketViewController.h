//
//  YXNewStockPreMarketViewController.h
//  uSmartOversea
//
//  Created by Kelvin on 2019/2/18.
//  Copyright © 2019年 RenRenDai. All rights reserved.
//

#import "YXTableViewController.h"
#import "YXNewStockPreMarketViewModel.h"

//认购中 + 待上市
@interface YXNewStockPreMarketViewController : YXTableViewController

@property (nonatomic, strong, readonly) YXNewStockPreMarketViewModel *viewModel;

@property (nonatomic, strong)RACCommand *goProCommand;

@property (nonatomic, assign) BOOL financingAccountDiff; //是否区分高级账户

//- (void)showProWithTip:(NSString *)tip;


@end


