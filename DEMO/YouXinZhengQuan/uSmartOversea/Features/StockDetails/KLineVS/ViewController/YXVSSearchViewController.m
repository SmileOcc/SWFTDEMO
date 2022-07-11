//
//  YXVSSearchViewController.m
//  YouXinZhengQuan
//
//  Created by youxin on 2021/2/5.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import "YXVSSearchViewController.h"
#import "YXSearchTextField.h"
#import "YXSearchCell.h"
#import "YXVSSearchViewModel.h"
#import "YXMarketDefine.h"
#import "YXSearchResponseModel.h"
#import "UIScrollView+YYAdd.h"
#import "uSmartOversea-Swift.h"
//#import "YXOptionalManager.h"
#import "YXStockIndexAccessoryShadeView.h"
#import <Masonry/Masonry.h>

@interface YXVSSearchViewController ()

/**
 自定义搜索框
 */
@property (nonatomic, strong) YXSearchTextField *searchTextField;

@property (nonatomic, strong) YXVSSearchViewModel *viewModel;

@property (nonatomic, strong) YXVSSearchResultView *ownResultView;
@property (nonatomic, strong) YXVSSearchResultView *searchResultView;
@property (nonatomic, strong) YXVSSearchResultView *selectResultView;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UIButton *confirmButton;

@property (nonatomic, strong) NSArray *ownList;

@property (nonatomic, strong) YXStockIndexAccessoryShadeView *stockIndexShadeView;
@property (nonatomic, strong) YXStockIndexAccessoryShadeView *quoteStatementShadeView;

@end

@implementation YXVSSearchViewController
@dynamic viewModel;

- (void)viewDidLoad {
    [super viewDidLoad];

    self.forceToLandscapeRight = YES;

    [self loadStockName];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshUserInfo:) name:YX_Noti_Login object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshUserInfo:) name:YX_Noti_LoginOut object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshQuoteLevel:) name:YX_Noti_Quote_Kick object:nil];
}

- (void)loadStockName {
    
    NSArray *list = [YXSecuGroupManager shareInstance].allSecuGroup.list;
    NSMutableArray<YXSecu *> *arrM = [NSMutableArray array];
    NSMutableArray *mArr = [NSMutableArray array];
    for (YXSecuID *item in list) {
        Secu *s_item = [[Secu alloc] initWithMarket:item.market symbol:item.symbol];
        [mArr addObject:s_item];
    }
    
    for (YXSecuID *item in list) {
        YXSecu *secu = [[YXSecu alloc] init];
        secu.symbol = item.symbol;
        secu.market = item.market;
        [arrM addObject:secu];
    }
    self.ownList = arrM;
    [self initialUI];
    
    [self showLoading:@"" inView:self.view];
    @weakify(self)
    [[YXQuoteManager sharedInstance] onceRtFullQuoteWithSecus:mArr level:QuoteLevelDelay handler:^(NSArray<YXV2Quote *> * _Nonnull quotes, enum Scheme scheme) {
        @strongify(self)
        [arrM removeAllObjects];
        for (YXSecuID *item in list) {
            YXSecu *secu = [[YXSecu alloc] init];
            secu.symbol = item.symbol;
            secu.market = item.market;
            for (YXV2Quote *v2item in quotes) {
                if ([v2item.market isEqualToString:item.market] && [v2item.symbol isEqualToString:item.symbol]) {
                    secu.name = v2item.name;
                    secu.type1 = v2item.type1.value;
                }
            }
            [arrM addObject:secu];
        }
            self.ownList = arrM;
            self.ownResultView.list = self.ownList;
            [self.ownResultView refreshUI];
            [self hideHud];
        } failed:^{
            [arrM removeAllObjects];
            for (YXSecuID *item in list) {
                YXSecu *secu = [[YXSecu alloc] init];
                secu.symbol = item.symbol;
                secu.market = item.market;
                [arrM addObject:secu];
            }
            self.ownList = arrM;
            self.ownResultView.list = self.ownList;

            [self.ownResultView refreshUI];
            [self hideHud];
        }];
}

- (void)bindViewModel{
    [super bindViewModel];

    @weakify(self)
    [[[RACObserve(self.searchTextField, text) throttle:0.5] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSString *word) {
        @strongify(self)
        if (word !=nil && word.length > 0) {
            [[[self.viewModel.searchRequestCommand execute:word] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id  _Nullable x) {

                YXSearchResponseModel *model = (YXSearchResponseModel *)x;
                if (model.list && [model.list isKindOfClass: [NSArray class]]) {
                    self.searchResultView.list = model.list;
                } else {
                    self.searchResultView.list = @[];
                }
            } error:^(NSError * _Nullable error) {
                LOG_ERROR(kOther, @"%@",error);
            } completed:^{
            }];
        }
    }];
    
    [[RACObserve(self.searchTextField, text) takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSString *word) {
        @strongify(self)
        //清空数组展示 自选列表
        if (word == nil || word.length < 1) {
            if (self.ownList.count > 0) {
                self.ownResultView.hidden = NO;
                [self.ownResultView refreshUI];
                self.searchResultView.hidden = YES;
            } else {
                self.searchResultView.list = @[];
                [self.searchResultView refreshUI];
            }
        } else {
            if (self.ownList.count > 0) {
                self.ownResultView.hidden = YES;
            }
            self.searchResultView.hidden = NO;
        }
    }];

    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"YX_Noti_UpdateUserInfo" object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self);
        if (![YXToolUtility needFinishQuoteNotify] && self.quoteStatementShadeView.hidden == false) {
            self.quoteStatementShadeView.hidden = true;
        }
    }];
    

    [[[self rac_signalForSelector:@selector(scrollViewWillBeginDragging:) fromProtocol:@protocol(UIScrollViewDelegate)] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(RACTuple * _Nullable x) {
        @strongify(self)
        [self.searchTextField.textField resignFirstResponder];
    }];

    self.searchResultView.rightActionBlock = ^(YXSecu * _Nullable secu) {
        @strongify(self)
        [self handleSelectSecu:secu];
    };

    self.ownResultView.rightActionBlock = ^(YXSecu * _Nullable secu) {
        @strongify(self)
        [self handleSelectSecu:secu];
    };

    self.selectResultView.rightActionBlock = ^(YXSecu * _Nullable secu) {
        @strongify(self)
        [self handleSelectSecu:secu];
    };

    self.selectResultView.closeActionBlock = ^{
        @strongify(self)
//        [self.viewModel.services popViewModelAnimated:YES];
        [self.navigationController popViewControllerAnimated:NO];
    };
}

- (void)handleSelectSecu:(YXSecu *)secu {
    BOOL isContain = NO;
    for (YXVSSearchModel *model in YXKlineVSTool.shared.selectList) {
        if ([YXKlineVSTool isSecuEqualWithLeft: model.secu right: secu]) {
            isContain = YES;
            break;
        }
    }

    if (isContain) { //已经包含，移除
        [YXKlineVSTool.shared removeItem:secu];
    } else { //未包含，添加

        if (YXKlineVSTool.shared.selectList.count >= 3) {
            [YXProgressHUD showMessage:[YXLanguageUtility kLangWithKey:@"maxnum_vs_note"] in:self.view hideAfterDelay:2];
            return ;
        }
        [YXKlineVSTool.shared addItem:secu];
    }

    if (_ownResultView.hidden == NO) {
        [_ownResultView refreshUI];
    }

    if (_searchResultView.hidden == NO) {
        [_searchResultView refreshUI];
    }

    self.selectResultView.list = YXKlineVSTool.shared.secuList;
    
    if (self.selectResultView.list.count == 0){
        self.stockIndexShadeView.hidden = YES;
    }
    
    [self updateShadeView];
}

- (BOOL)preferredNavigationBarHidden {
    return true;
}

#pragma mark - UI

- (void)initialUI {
    self.view.backgroundColor = [QMUITheme foregroundColor];

    UIView *leftView = [[UIView alloc] init];
    leftView.backgroundColor = [QMUITheme foregroundColor];
    [self.view addSubview:leftView];
    [leftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.view);
        make.width.mas_equalTo(265);
        if (@available(iOS 11.0, *)) {
            make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft);
        } else {
            make.left.equalTo(self.view);
        }
    }];

    [leftView addSubview:self.searchTextField];
    [leftView addSubview:self.searchResultView];

    [self.searchTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(leftView).offset(12);
        make.right.equalTo(leftView).offset(-12);
        make.height.mas_equalTo(33);
        make.top.equalTo(leftView).offset(17);
    }];

    [self.searchResultView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(leftView);
        make.top.equalTo(self.searchTextField.mas_bottom);
    }];
    if (self.ownList.count > 0) {
        [leftView addSubview:self.ownResultView];
        [self.ownResultView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(leftView);
            make.top.equalTo(self.searchTextField.mas_bottom);
        }];

        self.ownResultView.list = self.ownList;
        self.ownResultView.hidden = NO;
    } else {
        self.searchResultView.hidden = NO;
    }


    UIView *rightView = [[UIView alloc] init];
    rightView.backgroundColor = [QMUITheme foregroundColor];
    [self.view addSubview:rightView];
    [rightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.view);
        make.left.equalTo(leftView.mas_right);
        make.right.equalTo(self.view);
    }];

    [rightView addSubview:self.selectResultView];
    [self.selectResultView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight);
        } else {
            make.right.equalTo(self.view);
        }
        make.left.top.equalTo(rightView);
        make.bottom.equalTo(rightView).offset(-78);
    }];

    [self.view addSubview:self.stockIndexShadeView];
    [self.stockIndexShadeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(48);
        make.leading.trailing.equalTo(self.selectResultView);
        make.bottom.equalTo(self.view);
    }];
    
    [self.view addSubview:self.quoteStatementShadeView];
    [self.quoteStatementShadeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(48);
        make.leading.trailing.equalTo(self.selectResultView);
        make.bottom.equalTo(self.view);
    }];
    
    
    self.selectResultView.list = YXKlineVSTool.shared.secuList;
    
    [self updateShadeView];
    
    [rightView addSubview:self.tipLabel];
    [rightView addSubview:self.confirmButton];
    
    [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.selectResultView);
        make.bottom.equalTo(rightView).offset(-24);
        make.left.equalTo(rightView.mas_left).offset(46);
        make.right.equalTo(rightView.mas_right).offset(-46);
        make.height.mas_equalTo(48);
    }];
    
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.selectResultView);
        make.bottom.equalTo(self.confirmButton.mas_top).offset(-12);
        make.left.equalTo(rightView.mas_left);
        make.right.equalTo(rightView.mas_right);
        make.height.mas_equalTo(16);
    }];

//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.searchTextField.textField becomeFirstResponder];
//    });

}

- (UILabel *)tipLabel {
    if (_tipLabel == nil) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.text = [YXLanguageUtility kLangWithKey:@"support_vs_note"];
        _tipLabel.textColor = [QMUITheme textColorLevel3];
        _tipLabel.font = [UIFont systemFontOfSize:14];
    }
    return _tipLabel;
}

 -(void)updateShadeView {

     if (self.selectResultView.list.count == 0) {
         self.stockIndexShadeView.hidden = YES;
         self.quoteStatementShadeView.hidden = YES;
         return;
     }

     [self.selectResultView.list enumerateObjectsUsingBlock:^(YXSecu * _Nonnull secu, NSUInteger idx, BOOL * _Nonnull stop) {
         
         if( secu.type1 == OBJECT_SECUSecuType1_StIndex && [secu.market isEqualToString:kYXMarketUS] ) {
             
            if ([YXToolUtility needFinishQuoteNotify]) {
                 self.quoteStatementShadeView.hidden = NO;
             }else if (![YXUserManager isOpenAccountWithBroker:YXBrokersBitTypeSg]){
                 
                 [self.stockIndexShadeView setButtonType:OPENACCOUNTVSBUTTON];
                 self.stockIndexShadeView.hidden = NO;
                 *stop = YES;
             } else {
                 self.stockIndexShadeView.hidden = YES;
                 self.quoteStatementShadeView.hidden = YES;
             }
             *stop = YES;
         } else {
             self.stockIndexShadeView.hidden = YES;
             self.quoteStatementShadeView.hidden = YES;
         }
     }];
         
//     for (YXSecu* secu in self.selectResultView.list) {
//         if( secu.type1 == OBJECT_SECUSecuType1_StIndex && [secu.market isEqualToString:kYXMarketUS]){
//
//             if (![YXUserManager isOpenAccountWithBroker:YXBrokersBitTypeSg]){
//
//                 BOOL isKick = [[YXQuoteKickTool shared] isQuoteLevelKickToDelay:secu.market symbol:secu.symbol];
//                 if( isKick ){
//                     [self.stockIndexShadeView setButtonType:KICKBUTTON];
//                     self.stockIndexShadeView.hidden = NO;
//                     break;
//                 } else {
//
//                     [self.stockIndexShadeView setButtonType:OPENACCOUNTVSBUTTON];
//                     if ( [[YXUserManager shared] getUsaThreeLevel] == QuoteLevelNone ) {
//                         self.stockIndexShadeView.hidden = NO;
//                         break;
//                     } else {
//                         self.stockIndexShadeView.hidden = YES;
//                     }
//                 }
//             } else if ([YXToolUtility needFinishQuoteNotify]) {
//                 self.quoteStatementShadeView.hidden = NO;
//             }else {
//                 self.quoteStatementShadeView.hidden = NO;
//             }
//             break;
//         } else {
//             self.stockIndexShadeView.hidden = YES;
//             self.quoteStatementShadeView.hidden = NO;
//         }
//     }
     
     
     
 }


- (YXSearchTextField *)searchTextField {
    if (_searchTextField == nil) {
        _searchTextField = [[YXSearchTextField alloc] init];
        //_searchTextField.textField.placeholder = @"请输入股票代码／名称";
    }
    return _searchTextField;
}

- (YXVSSearchResultView *)ownResultView {
    if (!_ownResultView) {
        _ownResultView = [[YXVSSearchResultView alloc] initWithFrame: CGRectZero type: KLineVSResultTypeOwn];
        _ownResultView.hidden = YES;
    }
    return _ownResultView;
}

- (YXVSSearchResultView *)searchResultView {
    if (!_searchResultView) {
        _searchResultView = [[YXVSSearchResultView alloc] initWithFrame: CGRectZero type: KLineVSResultTypeResult];
        _searchResultView.hidden = YES;
    }
    return _searchResultView;
}

- (YXVSSearchResultView *)selectResultView {
    if (!_selectResultView) {
        _selectResultView = [[YXVSSearchResultView alloc] initWithFrame: CGRectZero type: KLineVSResultTypeSelect];
    }
    return _selectResultView;
}

- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom title:[YXLanguageUtility kLangWithKey:@"common_confirm3"] font:[UIFont systemFontOfSize:16] titleColor:[UIColor whiteColor] target:self action:@selector(confirmAction)];
        _confirmButton.backgroundColor = QMUITheme.themeTextColor;
        _confirmButton.layer.cornerRadius = 6;
        _confirmButton.layer.masksToBounds = YES;
    }
    return _confirmButton;
}

-(YXStockIndexAccessoryShadeView *)stockIndexShadeView {
    if (_stockIndexShadeView == nil) {
        _stockIndexShadeView = [[YXStockIndexAccessoryShadeView alloc] init];
        [_stockIndexShadeView setLandscape:true];
        [_stockIndexShadeView setButtonType:OPENACCOUNTBUTTON];
        _stockIndexShadeView.hidden = YES;
    }
    return  _stockIndexShadeView;
}

-(YXStockIndexAccessoryShadeView *)quoteStatementShadeView {
    if (_quoteStatementShadeView == nil) {
        _quoteStatementShadeView = [[YXStockIndexAccessoryShadeView alloc] init];
        [_quoteStatementShadeView setButtonType:QUOTESTATEMENTBUTTON];
        [_quoteStatementShadeView setLandscape:NO];
        _quoteStatementShadeView.hidden = YES;
    }
    return  _quoteStatementShadeView;
}

- (void)confirmAction {
    if (YXKlineVSTool.shared.selectList.count < 2) {
        [YXProgressHUD showMessage:[YXLanguageUtility kLangWithKey:@"min_vs_note"] in:self.view hideAfterDelay:2];
        return ;
    }
    YXKlineVSLandViewModel *searchViewModel = [[YXKlineVSLandViewModel alloc] initWithServices:self.viewModel.services params:nil];
    [self.viewModel.services pushPath:YXModulePathsKlineVSLand context:@{} animated:YES];

}


#pragma mark - vc翻转
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
//    return UIInterfaceOrientationMaskLandscapeRight;
//}
//
//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
//    return UIInterfaceOrientationLandscapeRight;
//}

#pragma mark - 导航栏相关
//横屏默认隐藏
- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (BOOL)shouldPopViewControllerByBackButtonOrPopGesture:(BOOL)byPopGesture {

    return NO;
}

#pragma mark - 行情互踢
- (void)refreshQuoteLevel:(NSNotification *)noti {
    [self updateShadeView];
}

#pragma mark - 用户数据刷新
- (void)refreshUserInfo:(NSNotification *)noti {
    [self updateShadeView];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
