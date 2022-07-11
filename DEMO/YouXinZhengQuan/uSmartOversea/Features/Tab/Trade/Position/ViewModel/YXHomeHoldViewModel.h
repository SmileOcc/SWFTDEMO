//
//  YXHomeHoldViewModel.h
//  YouXinZhengQuan
//
//  Created by ellison on 2019/1/11.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXStockListViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@class YXAccountAssetResModel;

@interface YXHomeHoldViewModel : YXStockListViewModel

@property (nonatomic, strong, readonly) RACCommand *didClickQuote;
@property (nonatomic, strong, readonly) RACCommand *didClickTrade;
@property (nonatomic, strong, readonly) RACCommand *didClickBuy;
@property (nonatomic, strong, readonly) RACCommand *didClickSell;

@property (nonatomic, assign) BOOL isOrder;
@property (nonatomic, strong) RACCommand *changeTrade;//切换交易股票
@property (nonatomic, strong) RACCommand *changeTradeBuy;//切换交易股票买入
@property (nonatomic, strong) RACCommand *changeTradeSell;//切换交易股票卖出

@property (nonatomic, assign) YXSortState hkstate; //记录当前的排序
@property (nonatomic, assign) YXMobileBrief1Type hktype;//记录当前的排序
@property (nonatomic, assign) YXSortState usstate; //记录当前的排序
@property (nonatomic, assign) YXMobileBrief1Type ustype;//记录当前的排序
@property (nonatomic, assign) YXSortState sgstate; //记录当前的排序
@property (nonatomic, assign) YXMobileBrief1Type sgtype;//记录当前的排序
@property (nonatomic, assign) YXSortState usOptionState; //记录当前的排序
@property (nonatomic, assign) YXMobileBrief1Type usOptionType;//记录当前的排序
@property (nonatomic, assign) YXSortState usFractionState; //记录当前的排序
@property (nonatomic, assign) YXMobileBrief1Type usFractionType;//记录当前的排序

// 持有证券数量
- (NSInteger)holdSecurityCount;

// 是否是快捷交易
@property (nonatomic, assign) BOOL isShortcut;
// 股票市场代码
@property (nonatomic, strong) NSString *marketSymblo;

@property (nonatomic, strong) RACCommand *didClickSmartTrade;   //「智能下单」
@property (nonatomic, strong) RACCommand *didClickWarrant;      //「论证」

@property (nonatomic, strong) RACCommand *changeSmartTrade; //在「智能交易」页，点了持仓的「智能下单」的响应
@property (nonatomic, assign) BOOL needShowEmptyImage; //个股详情页控制持仓为空时是否显示图标

@property (nonatomic, strong) YXAccountAssetResModel *assetModel;

@property (nonatomic, assign) BOOL isAssetPage; // 是否在资产页

- (void)reloadDataSource;

@end

NS_ASSUME_NONNULL_END
