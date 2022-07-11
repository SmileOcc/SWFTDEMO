//
//  YXStareDetailVC.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/1/17.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXStareDetailVC.h"
#import "uSmartOversea-Swift.h"
#import "YXStareDetailViewModel.h"
#import "YXStareUtility.h"
#import "NSArray+YYAdd.h"
#import <Masonry/Masonry.h>
#import "NSDictionary+Category.h"

@interface YXStareDetailVC ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) YXStareSecondTabView *topTabView;

@property (nonatomic, strong) YXStareListSectionView *sectionHeadView;

@property (nonatomic, strong) YXTableView *tableView;

@property (nonatomic, strong) YXStareBmpDefaultView * stareBmpDefaultView;

@property (nonatomic, strong) YXStareDetailViewModel *viewModel;

@property (nonatomic, assign) YXTimerFlag stareTimeFlag;

@property (nonatomic, strong) NSMutableArray *cacheArr;

@property (nonatomic, strong) YXStockDetailAskBidMaskView *updateView;

@property (nonatomic, assign) CGFloat updateViewHeight;

@end


@implementation YXStareDetailVC
@dynamic viewModel;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = QMUITheme.foregroundColor;
    [self initUI];
    self.automaticallyAdjustsScrollViewInsets = NO;
    if (@available(iOS 11.0, *)) {

    } else {
        [self.tableView.mj_header beginRefreshing];
    }
    
    QuoteLevel level = [[YXUserManager shared] getLevelWith:kYXMarketHK];
    if (self.viewModel.type == 3 && level == QuoteLevelBmp) {
        CGFloat height = YXConstant.deviceScaleEqualToXStyle ? 20 : 0;
        [self.updateView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(106 + height);
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadPushSetting];
    
    if (self.viewModel.type == 3) {
        // 自选和持仓
        NSInteger type = [YXStareUtility getHoldSubType];
        if (type == 0) {
            // 自选
            if (self.topTabView.selectIndex == 1) {
                self.topTabView.selectIndex = 0;
            }
        } else {
            // 持仓
            if (self.topTabView.selectIndex == 0) {
                self.topTabView.selectIndex = 1;
            }
        }
    } else {
        NSInteger type = [YXStareUtility getMarketSubType];
        
        if (self.viewModel.type == 2) {
            // a股
            if (type == 1) {
                // 新股(a股没新股)
                self.topTabView.selectIndex = 0;
            } else {
                if (self.topTabView.selectIndex != type) {
                    self.topTabView.selectIndex = type;
                }
            }
        } else {
            if (self.topTabView.selectIndex != type) {
                self.topTabView.selectIndex = type;
            }
        }
    }
    if (!self.tableView.mj_header.isRefreshing) {
        [self.tableView.mj_header beginRefreshing];
    }

    // 神策事件：开始记录
    [YXSensorAnalyticsTrack trackTimerStartWithEvent:YXSensorAnalyticsEventViewScreen];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self endPolling];

    // 神策事件：结束记录
    {
    NSString *propViewPage = @"";
    if (self.viewModel.type == 0) {
        propViewPage = @"盯盘精灵-港股";
    } else if (self.viewModel.type == 1) {
        propViewPage = @"盯盘精灵-美股";
    } else if (self.viewModel.type == 2) {
        propViewPage = @"盯盘精灵-沪深";
    } else {
        propViewPage = @"盯盘精灵-自选/持仓";
    }
   
    }
}

- (void)startPoll {
    @weakify(self);
    self.stareTimeFlag = [[YXTimerSingleton shareInstance] transactOperation:^(YXTimerFlag flag) {
        @strongify(self)
        [[self.viewModel.loadPollingRequestCommand execute:nil] subscribeNext:^(NSArray *list) {
            if (list.count > 0) {
                NSMutableArray *tempArr = [NSMutableArray array];
                for (YXStareSignalModel *model in list) {
                    if (self.cacheArr.count > 0) {
                        YXStareSignalModel *firstModel = self.cacheArr.firstObject;
                        if (model.unixTime > firstModel.unixTime) {
                            [tempArr addObject:model];
                        }
                    } else {
                        YXStareSignalModel *firstModel = self.viewModel.list.firstObject;
                        if (model.unixTime > firstModel.unixTime) {
                            [tempArr addObject:model];
                        }
                    }
                }
                [self.cacheArr addObjectsFromArray:tempArr];
                
                if (!([self.tableView isDragging] || [self.tableView isDecelerating])) {
                    [self inserCacheArr];
                }
            }
        }];
    } timeInterval:[YXGlobalConfigManager configFrequency:YXGlobalConfigParameterTypeSelfStockFreq] repeatTimes:NSIntegerMax atOnce:YES];
}

- (void)endPolling {
    if (self.stareTimeFlag > 0) {
        [[YXTimerSingleton shareInstance] invalidOperationWithFlag:self.stareTimeFlag];
        self.stareTimeFlag = 0;
    }
}

- (void)initUI {
    [self.view addSubview:self.topTabView];
    [self.view addSubview:self.sectionHeadView];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.updateView];
    [self.tableView registerClass:[YXStareHomeCell class] forCellReuseIdentifier:@"YXStareHomeCell"];
    
    BOOL isShowPush = [self isShowPush];
    [self.topTabView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(10);
        make.height.mas_equalTo(isShowPush ? 88 : 48);
        make.leading.trailing.equalTo(self.view);
    }];
    
    [self.sectionHeadView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.height.mas_equalTo(37);
        make.top.equalTo(self.topTabView.mas_bottom);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.sectionHeadView.mas_bottom);
        make.leading.trailing.equalTo(self.view);
        make.bottom.equalTo(self.updateView.mas_top);
    }];
    
    [self.updateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.mas_equalTo(0);
    }];
    
    if ((self.viewModel.type == 0)&& [[YXUserManager shared] getLevelWith:kYXMarketHK] == QuoteLevelBmp) {

        [self.view addSubview:self.stareBmpDefaultView];
        [self.stareBmpDefaultView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view);
            make.leading.trailing.bottom.equalTo(self.view);
        }];

        [self.view bringSubviewToFront:self.stareBmpDefaultView];
    }
    
    @weakify(self);
    if (self.viewModel.type != 3) {
            
        NSString *key = @"a";
        NSString *defalutIndex = @"";
        if (self.viewModel.type == 0) {
            key = @"hk";
            defalutIndex = @"HSI";
        } else if (self.viewModel.type == 1) {
            key = @"us";
            defalutIndex = @"DJI";
        } else {
            key = @"a";
            defalutIndex = @"000001";
        }
        
        // 解析数据-行业
        NSData *data = [[MMKV defaultMMKV] getDataForKey:@"industryListPath"];
        if (data == nil) {
            
        } else {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:NULL];
            NSString *languageKey = @"en";
            if ([YXUserManager isENMode]) {
                languageKey = @"en";
            } else if ([YXUserManager curLanguage] == YXLanguageTypeCN) {
                languageKey = @"cn";
            } else {
                languageKey = @"tc";
            }
            NSDictionary *languageDic = [dic yx_dictionaryValueForKey:languageKey];
            NSDictionary *aDic = [languageDic yx_dictionaryValueForKey:key];
            NSDictionary *map = [aDic yx_dictionaryValueForKey:@"map"];
            self.topTabView.industryDic = map;
            
            NSArray *arr;
            if ([YXUserManager isENMode]) {
                arr = [map yx_arrayValueForKey:@"I"];
                for (NSDictionary *dic in arr) {
                    NSString *pinyin = [dic yx_stringValueForKey:@"industry_pinyin"];
                    if ([pinyin hasPrefix:@"Insurance"]) {
                        self.topTabView.selectIndustryDic = dic;
                        self.viewModel.bkCode = [dic yx_stringValueForKey:@"industry_code_yx"];
                        break;
                    }
                }
            } else {
                arr = [map yx_arrayValueForKey:@"B"];
                for (NSDictionary *dic in arr) {
                    NSString *pinyin = [dic yx_stringValueForKey:@"industry_pinyin"];
                    if ([pinyin hasPrefix:@"baoxian"]) {
                        self.topTabView.selectIndustryDic = dic;
                        self.viewModel.bkCode = [dic yx_stringValueForKey:@"industry_code_yx"];
                        break;
                    }
                }
            }


            if (self.topTabView.selectIndustryDic.count == 0) {
                self.topTabView.selectIndustryDic = arr.firstObject;
                self.viewModel.bkCode = [arr.firstObject yx_stringValueForKey:@"industry_code_yx"];
            }
        }
        
        // 解析数据-指数
        NSData *indexData = [[MMKV defaultMMKV] getDataForKey:@"indexListPath"];
        if (data == nil) {
            
        } else {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:indexData options:kNilOptions error:NULL];
            NSArray *arr = [dic yx_arrayValueForKey:key];
            for (NSDictionary *dic in arr) {
                NSString *code = [dic yx_stringValueForKey:@"index_code"];
                if ([code hasSuffix:defalutIndex]) {
                    self.topTabView.selectIndexDic = dic;
                    self.viewModel.indexCode = code;
                    break;
                }
            }

            if (self.topTabView.selectIndexDic.count == 0) {
                self.topTabView.selectIndexDic = arr.firstObject;
                self.viewModel.indexCode = [arr.firstObject yx_stringValueForKey:@"index_code"];
            }
            self.topTabView.indexDic = @{
                @"market": key,
                @"list": arr ? : @[]
            };
        }
    }
    
    self.tableView.mj_header = [YXRefreshHeader headerWithRefreshingBlock:^{
        @strongify(self);
        [self refreshData];
    }];
    
    
    
    self.tableView.mj_footer = [YXRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @strongify(self);
        [self loadUpData];
    }];
}

- (void)bindViewModel {
    @weakify(self);
    [self.topTabView setClickBtnCallBack:^(NSInteger tag) {
        @strongify(self);
        self.viewModel.subTab = tag;
        BOOL isShowPush = [self isShowPush];
        if (self.viewModel.type != 3) {            
            
            [self.topTabView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(isShowPush ? 88 : 48);
            }];
            
            [YXStareUtility resetMarketSubType:tag];
        } else {
            [YXStareUtility resetHoldSubType:tag];
        }
        [self.tableView.mj_header beginRefreshing];
        [self trackClickEvent];
    }];

    [self.topTabView setClickIndustryCallBack:^(NSDictionary * _Nonnull dic) {
        @strongify(self);
        YXStareType type = [YXStareUtility getStareTypeWithType:self.viewModel.type andSubType:self.viewModel.subTab];
        if (type == YXStareTypeIndex) {
            // 指数
            self.viewModel.indexCode = [dic yx_stringValueForKey:@"index_code"];
        } else if (type == YXStareTypeIndustry) {
            // 行业
            self.viewModel.bkCode = [dic yx_stringValueForKey:@"industry_code_yx"];
        }
        [self.tableView.mj_header beginRefreshing];
    }];
    
    
    [self.topTabView setStValueCallBack:^(BOOL on) {
        @strongify(self);
        NSDictionary *dic;
        
        YXStareType type = [YXStareUtility getStareTypeWithType:self.viewModel.type andSubType:self.viewModel.subTab];
        
        NSNumber *tpyeNumber = @(0);
        
        if (type == YXStareTypeOptional) {
            // 自选
            tpyeNumber = @(0);
            dic = @{
                @"type": tpyeNumber,
                @"list": @[@{
                               @"status": on ? @(1) : @(0),
                               @"identifier": @"",
                }],
            };
        } else if (type == YXStareTypeHold) {
            // 持仓
            tpyeNumber = @(5);
            dic = @{
                @"type": tpyeNumber,
                @"list": @[@{
                               @"status": on ? @(1) : @(0),
                               @"identifier": @"",
                }],
            };
        } else if (type == YXStareTypeNewStock) {
            tpyeNumber = @(3);
            NSString *market = @"hk";
            // 新股
            if (self.viewModel.type == 0) {
                market = @"hk";
            } else if (self.viewModel.type == 1){
                market = @"us";
            } else {
                market = @"hs";
            }
            dic = @{
                
                @"type": tpyeNumber,
                @"list": @[@{
                               @"status": on ? @(1) : @(0),
                               @"identifier": market,
                }],
            };
        } else if (type == YXStareTypeIndustry) {
            tpyeNumber = @(1);
            // 行业
            dic = @{
                @"type": tpyeNumber,
                @"list": @[@{
                               @"status": on ? @(1) : @(0),
                               @"identifier": self.viewModel.bkCode?:@"",
                }],
            };
        }

        [[self.viewModel.updatePushSettingListRequestCommand execute: dic] subscribeNext:^(id x) {
            @strongify(self);
            
            YXStarePushSettingSubModel *selecModel = nil;
            YXStarePushSettingModel *lastModel = nil;
            for (YXStarePushSettingModel *model in self.viewModel.pushList) {
                if (model.type == tpyeNumber.intValue) {
                    lastModel = model;
                    for (YXStarePushSettingSubModel *subModel in model.list) {
                        if (type == YXStareTypeIndustry) {
                            if ([subModel.identifier isEqualToString:self.viewModel.bkCode]) {
                                // 选中的行业
                                selecModel = subModel;
                                break;
                            }
                        } else if (type == YXStareTypeHold || type == YXStareTypeOptional) {
                            selecModel = subModel;
                            break;
                        } else if (type == YXStareTypeNewStock) {
                            NSString *market = @"hk";
                            // 新股
                            if (self.viewModel.type == 0) {
                                market = @"hk";
                            } else if (self.viewModel.type == 1){
                                market = @"us";
                            } else {
                                market = @"hs";
                            }
                            if ([subModel.identifier isEqualToString:market]) {
                                selecModel = subModel;
                                break;
                            }
                        }
                    }
                }
            }

            if (!selecModel && x) {

                YXStarePushSettingSubModel *currentModel = [[YXStarePushSettingSubModel alloc] init];
                currentModel.status = on;
                currentModel.identifier = self.viewModel.bkCode;
                currentModel.type = tpyeNumber.intValue;
                if (lastModel != nil) {
                    NSMutableArray *listArray = lastModel.list.mutableCopy;
                    [listArray addObject:currentModel];
                    lastModel.list = listArray;
                } else {
                    YXStarePushSettingModel *lastSettingModel = [[YXStarePushSettingModel alloc] init];
                    lastSettingModel.type = tpyeNumber.intValue;
                    lastSettingModel.list = @[currentModel];
                    NSMutableArray *array =  self.viewModel.pushList.mutableCopy;
                    [array addObject:lastSettingModel];
                    self.viewModel.pushList = array;
                }
                self.topTabView.pushList = self.viewModel.pushList;
            }

            if (x) {
                if (on) {
                    [QMUITips showWithText:[YXLanguageUtility kLangWithKey:@"monitor_push_open_success"]];
                } else {
                    [QMUITips showWithText:[YXLanguageUtility kLangWithKey:@"monitor_push_close_success"]];
                }
                selecModel.status = on;

            } else {
                if (on) {
                    [QMUITips showWithText:[YXLanguageUtility kLangWithKey:@"monitor_push_open_fail"]];
                } else {
                    [QMUITips showWithText:[YXLanguageUtility kLangWithKey:@"monitor_push_close_fail"]];
                }
                selecModel.status = !on;
                self.topTabView.pushList = self.viewModel.pushList;
            }
        
        }];
    }];
    
}

- (void)trackClickEvent {
    NSString *propViewPage = @"";
    NSString *propViewName = @"";
    NSArray *titles;
    if (self.viewModel.type == 0) {
        propViewPage = @"盯盘精灵-港股";
        titles = @[@"全部", @"新股", @"行业", @"指数"];
    } else if (self.viewModel.type == 1) {
        propViewPage = @"盯盘精灵-美股";
        titles = @[@"全部", @"新股", @"行业", @"指数"];
    } else if (self.viewModel.type == 2) {
        propViewPage = @"盯盘精灵-沪深";
        titles = @[@"全部", @"行业", @"指数"];
    } else {
        propViewPage = @"盯盘精灵-自选/持仓";
        titles = @[@"自选", @"持仓"];
    }

    if (_topTabView.selectIndex < titles.count) {
        propViewName = titles[_topTabView.selectIndex];
    }


}

- (void)loadPushSetting {
    @weakify(self);
    [self endPolling];
    [self startPoll];
    [self.cacheArr removeAllObjects];
    [[self.viewModel.loadPushSettingListRequestCommand execute: nil] subscribeNext:^(NSArray *list) {
        @strongify(self);
        self.topTabView.pushList = list;
    }];
}

- (void)refreshData {
    @weakify(self);
    if ((self.viewModel.type == 0)&& [[YXUserManager shared] getLevelWith:kYXMarketHK] == QuoteLevelBmp) {
        [self.tableView.mj_footer resetNoMoreData];
        [self.tableView.mj_header endRefreshing];
    } else {
        [[self.viewModel.loadDownRequestCommand execute: nil] subscribeNext:^(NSArray *list) {
            @strongify(self);
            [self.tableView.mj_footer resetNoMoreData];
            [self.tableView.mj_header endRefreshing];
            [self.tableView reloadData];
        }];
    }
}


- (void)loadUpData {
    @weakify(self);
    [[self.viewModel.loadUpRequestCommand execute: nil] subscribeNext:^(NSArray *list) {
        @strongify(self);
        if (list.count == 0) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        } else {
            [self.tableView.mj_footer endRefreshing];
            [self.tableView reloadData];
        }
    }];
}

- (BOOL)isShowPush {
    
    YXStareType type = [YXStareUtility getStareTypeWithType:self.viewModel.type andSubType:self.viewModel.subTab];
    
    if (type == YXStareTypeAll || type == YXStareTypeNewStock) {
        return NO;
    } else {
        return YES;
    }
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    YXStareHomeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YXStareHomeCell" forIndexPath:indexPath];
    YXStareSignalModel *model = self.viewModel.list[indexPath.row];
    cell.model = model;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    YXStareSignalModel *model = self.viewModel.list[indexPath.row];
    NSString *market = [model.stockCode substringToIndex:2];
    NSString *code = [model.stockCode substringFromIndex:2];
    
    YXStockInputModel *input = [[YXStockInputModel alloc] init];
    input.market = market;
    input.symbol = code;
    input.name = model.stockName;
    [self.viewModel.services pushPath:YXModulePathsStockDetail context:@{@"dataSource": @[input], @"selectIndex": @(0)} animated:YES];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    

}

- (void)inserCacheArr {
    YXStareSignalModel *lastModel = self.cacheArr.lastObject;
    YXStareSignalModel *firstModel = self.viewModel.list.firstObject;
    if (lastModel.unixTime > firstModel.unixTime) {
//        for (YXStareSignalModel *model in self.cacheArr) {
//
//        }
        [self.viewModel.list insertObjects:self.cacheArr atIndex:0];
        [self.cacheArr removeAllObjects];
        [self.tableView reloadData];
    }
}

- (void)updateViewBtnClick:(UIButton *)sender {
    
    YXAlertView *alertView = [YXAlertView alertViewWithMessage:[YXLanguageUtility kLangWithKey:@"online_buy_tip"]];
    [alertView addAction:[YXAlertAction actionWithTitle:[YXLanguageUtility kLangWithKey:@"common_cancel"] style:YXAlertActionStyleCancel handler:^(YXAlertAction * _Nonnull action) {
            
    }]];
    [alertView addAction:[YXAlertAction actionWithTitle:[YXLanguageUtility kLangWithKey:@"depth_order_get"] style:YXAlertActionStyleDefault handler:^(YXAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[YXH5Urls goBuyOnLineUrl]]];
    }]];
    [alertView showInWindow];
}

#pragma mark - 懒加载
- (YXStareSecondTabView *)topTabView {
    if (_topTabView == nil) {
        _topTabView = [[YXStareSecondTabView alloc] initWithFrame:CGRectZero type: self.viewModel.type];
        _topTabView.backgroundColor = QMUITheme.foregroundColor;
    }
    return _topTabView;
}

- (YXStareListSectionView *)sectionHeadView {
    if (_sectionHeadView == nil) {
        _sectionHeadView = [[YXStareListSectionView alloc] init];
        _sectionHeadView.backgroundColor = QMUITheme.foregroundColor;
    }
    return _sectionHeadView;
}

- (YXTableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[YXTableView alloc] init];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 59;
        _tableView.backgroundColor = QMUITheme.foregroundColor;
    }
    return _tableView;
}

- (YXStareBmpDefaultView *)stareBmpDefaultView
{
    if (!_stareBmpDefaultView) {
        _stareBmpDefaultView = [[YXStareBmpDefaultView alloc] initWithFrame:CGRectZero];
        _stareBmpDefaultView.backgroundColor = QMUITheme.foregroundColor;
        _stareBmpDefaultView.fetchClick = ^{
            [UIApplication.sharedApplication openURL:[NSURL URLWithString:[YXH5Urls websiteBuyQuoteUrl]]];
        };
    }

    return _stareBmpDefaultView;
}

- (NSMutableArray *)cacheArr {
    if (_cacheArr == nil) {
        _cacheArr = [[NSMutableArray alloc] init];
    }    
    return _cacheArr;
}

- (YXStockDetailAskBidMaskView *)updateView {
    if (_updateView == nil) {
        _updateView = [[YXStockDetailAskBidMaskView alloc] init];
        [_updateView setDescText:[YXLanguageUtility kLangWithKey:@"tip_quote_permission_upgrade"]];
        [_updateView.registerButton setTitle:[YXLanguageUtility kLangWithKey:@"newStock_see_more"] forState:UIControlStateNormal];
        [_updateView.registerButton addTarget:self action:@selector(updateViewBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        _updateView.clipsToBounds = YES;
        _updateView.registerButton.userInteractionEnabled = YES;
    }
    return _updateView;
}

@end
