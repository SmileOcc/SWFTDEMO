//
//  YXStockDetailReminderSettingController.m
//  uSmartOversea
//
//  Created by 姜轶群 on 2018/11/20.
//  Copyright © 2018年 RenRenDai. All rights reserved.
//

#import "YXStockDetailReminderSettingController.h"
#import "YXStockDetailReminderSettingViewModel.h"
#import "uSmartOversea-Swift.h"
#import <QMUIKit/QMUIKit.h>
#import "YXAuthorityReminderTool.h"
//#import "YXStockDetailTool.h"
#import "YXReminderStockView.h"
#import "YXStockReminderTypeSelectView.h"
#import "YXRemindTool.h"
#import "NSNumber+YYAdd.h"
#import "YXStockReminderTypeViewModel.h"
#import <Masonry/Masonry.h>

@interface YXStockDetailReminderSettingController () <YXSocketReceiveDataProtocol, YXAuthorityReminderToolDelegate>

@property (nonatomic, strong, readwrite) YXStockDetailReminderSettingViewModel *viewModel;

//@property (nonatomic, strong) NSMutableArray *remindSetViewArr;
//
@property (nonatomic, strong) NSMutableArray *remindSettingDataArr;
@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) YXAuthorityReminderTool *authorityTool;

@property (nonatomic, strong) YXQuoteRequest *quoteRequest;

@property (nonatomic, strong) YXReminderFrequencyView *frequencyView;

@property (nonatomic, strong) YXReminderStockView *stockInfoView;

@property (nonatomic, strong) YXStockReminderTypeSelectView *typeView;

@property (nonatomic, strong) YXStockReminderInputView *inputView;

@property (nonatomic, strong) UIView *inputContainView;

@property (nonatomic, strong) UIButton *rightBtn;

@end

@implementation YXStockDetailReminderSettingController
@dynamic viewModel;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //1, init UI
    [self initUI];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self updateAuthorityUI];
    [self loadQuoteData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.quoteRequest cancel];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.inputContainView.mj_h > 0) {
        [self.inputView.textField becomeFirstResponder];
    } else {
        self.rightBtn.enabled = YES;
    }
}

#pragma mark - bindViewModel
- (void)bindViewModel {

    //加载设置数据
    @weakify(self);
    RAC(self.viewModel.reminderModel, ntfValue) = [self.inputView.textField.rac_textSignal flattenMap:^__kindof RACSignal * _Nullable(NSString * _Nullable value) {
        @strongify(self);
        YXReminderType type = [YXRemindTool getTypeWithReminderModel: self.viewModel.reminderModel];
        if (value.doubleValue > 0) {
            int a = [YXRemindTool getUnitWithType:type];
            return [RACReturnSignal return:@(value.doubleValue * a)];
        } else {
            return [RACReturnSignal return:nil];
        }
    }];
    
    [self.inputView.textField.rac_textSignal subscribeNext:^(NSString * _Nullable x) {
        @strongify(self);
        if (self.viewModel.reminderModel.ntfType > 0) {
            self.rightBtn.enabled = [x length] > 0;
        } else {
            self.rightBtn.enabled = YES;
        }
    }];
    
    [[self.typeView.clickBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        [self.view endEditing:YES];
        NSMutableDictionary *para = [NSMutableDictionary dictionaryWithDictionary:self.viewModel.params];
        // 是否有财报提醒选项
        if (self.stockInfoView.quote.type1.value == OBJECT_SECUSecuType1_StStock && [self.stockInfoView.quote.market isEqualToString:kYXMarketHK]) {
            para[@"isNeedFinancialReport"] = @(YES);
        }
        BOOL isNeedAnnouncement = YES;
        if ([self.stockInfoView.quote.market isEqualToString:kYXMarketSG]) {
            isNeedAnnouncement = NO;
        }
        para[@"isNeedAnnouncement"] = @(isNeedAnnouncement);
        
        YXStockReminderTypeViewModel *viewModel = [[YXStockReminderTypeViewModel alloc] initWithServices:self.viewModel.services params:para];
    
        if (self.viewModel.reminderModel.id.length > 0) {
            if (self.viewModel.reminderModel.ntfType > 0) {
                viewModel.addType = YXReminderVCTypeEditPrice;
            } else {
                viewModel.addType = YXReminderVCTypeEditForm;
            }
        } else {
            viewModel.addType = YXReminderVCTypeNew;
        }
        
        if (self.viewModel.reminderModel.ntfType > 0) {
            viewModel.selecType = self.viewModel.reminderModel.ntfType;
        } else {
            viewModel.selecType = self.viewModel.reminderModel.formShowType;
        }
        
        viewModel.comeFromPop = YES;
        [viewModel setDataCallBack:^(NSNumber *object) {
            @strongify(self);
            
            if ([YXRemindTool isFormWithType:object.integerValue]) {
                self.viewModel.reminderModel.formShowType = object.integerValue;
                self.viewModel.reminderModel.ntfType = 0;
            } else {
                self.viewModel.reminderModel.ntfType = object.integerValue;
                self.viewModel.reminderModel.ntfValue = nil;
                self.viewModel.reminderModel.formShowType = 0;
            }
            self.viewModel.reminderModel.notifyType = 1;
            [self refreshUI];
        }];
        [self.viewModel.services pushViewModel:viewModel animated:YES];
    }];
    
    [[self.scrollView rac_signalForSelector:@selector(scrollViewDidScroll:)] subscribeNext:^(RACTuple * _Nullable x) {
        @strongify(self);
        [self.view endEditing:YES];
    }];
    
//    [self.frequencyView setSelectIndexClosure:^(NSInteger select) {
//        NSString *title = @"";
//        if (select == 0) {
//            title = @"仅提醒一次";
//        } else if (select == 1) {
//            title = @"每日一次";
//        } else {
//            title = @"持续提醒";
//        }
//    }];
}


- (void)loadQuoteData {
    @weakify(self);
    Secu *secu = [[Secu alloc] initWithMarket:self.viewModel.market symbol:self.viewModel.symbol];    
    self.quoteRequest = [[YXQuoteManager sharedInstance] subRtSimpleQuoteWithSecus:@[secu] level:[[YXUserManager shared] getLevelWith:self.viewModel.market] handler:^(NSArray<YXV2Quote *> * _Nonnull list, enum Scheme scheme) {
        @strongify(self);
        if (scheme == SchemeHttp) {
            [self.scrollView.mj_header endRefreshing];
        }
        YXV2Quote *quote = list.firstObject;
        self.stockInfoView.quote = quote;
    } failed:^{
        
    }];
}

#pragma mark - initUI
- (void)initUI {
    
    self.view.backgroundColor = QMUITheme.backgroundColor;
    
    if (self.viewModel.reminderModel.id.length > 0) {
        self.title = [YXLanguageUtility kLangWithKey:@"remind_price_edit"];
    } else {
        self.title = [YXLanguageUtility kLangWithKey:@"remind_add"];
    }
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    self.rightBtn = btn;
    [btn setTitle:[YXLanguageUtility kLangWithKey:@"user_save"] forState:UIControlStateNormal];
    [btn setTitleColor:QMUITheme.mainThemeColor forState:UIControlStateNormal];
    [btn setTitleColor:[QMUITheme.mainThemeColor colorWithAlphaComponent:0.4] forState:UIControlStateDisabled];
    [btn addTarget:self action:@selector(rightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItems = @[item];

    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.view).offset(0);
    }];
    
    [self.scrollView addSubview:self.stockInfoView];
    [self.stockInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.scrollView);
        make.right.equalTo(self.scrollView);
        make.top.mas_equalTo(self.scrollView).offset(1);
        make.height.mas_equalTo(77);
        make.width.mas_equalTo(YXConstant.screenWidth);
    }];

    UIView *typeHeaderView = [self createHeaderViewWithTitle:[YXLanguageUtility kLangWithKey:@"remind_alert_type"]];
    [self.scrollView addSubview:typeHeaderView];
    [typeHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.scrollView);
        make.top.equalTo(self.stockInfoView.mas_bottom);
        make.height.mas_equalTo(35);
    }];
    
    [self.scrollView addSubview:self.typeView];
    [self.typeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.scrollView);
        make.top.equalTo(typeHeaderView.mas_bottom);
        make.height.mas_equalTo(56);
    }];
    
    UIView *inputHeaderView = [self createHeaderViewWithTitle:[YXLanguageUtility kLangWithKey:@"remind_value"]];
    
    self.inputContainView = [[UIView alloc] init];
    self.inputContainView.clipsToBounds = YES;
    [self.inputContainView addSubview:inputHeaderView];
    [self.inputContainView addSubview:self.inputView];
    
    [inputHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.inputContainView);
        make.top.equalTo(self.inputContainView);
        make.height.mas_equalTo(35);
    }];
    
    [self.inputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.inputContainView);
        make.top.equalTo(inputHeaderView.mas_bottom);
        make.height.mas_equalTo(56);
    }];
    
    [self.scrollView addSubview:self.inputContainView];
    [self.inputContainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.scrollView);
        make.top.equalTo(self.typeView.mas_bottom);
        make.height.mas_equalTo(91);
    }];
    
    UIView *remindHeaderView = [self createHeaderViewWithTitle:[YXLanguageUtility kLangWithKey:@"remind_frequency"]];
    [self.scrollView addSubview:remindHeaderView];
    [remindHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.scrollView);
        make.top.equalTo(self.inputContainView.mas_bottom);
        make.height.mas_equalTo(35);
    }];
    
    //frequencyView内部已有约束撑起了frequencyView的高度
    [self.scrollView addSubview:self.frequencyView];
    [self.frequencyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.scrollView);
        make.right.equalTo(self.view);
        make.top.mas_equalTo(remindHeaderView.mas_bottom);
        make.bottom.equalTo(self.scrollView);
    }];
    
    [self refreshUI];
}

- (void)rightBtnClick:(UIButton *)sender {
    self.viewModel.reminderModel.notifyType = self.frequencyView.selectIndex + 1;
    [self.viewModel.remindSettingSaveCommand execute:nil];
}

- (void)refreshUI {
    
    YXReminderType type = [YXRemindTool getTypeWithReminderModel: self.viewModel.reminderModel];
    
//    self.typeView.iconImageView.image = [UIImage imageNamed:[YXRemindTool getImageNameWithType:type]];
    self.typeView.nameLabel.text = [YXRemindTool getTitleWithType:type];
    
    if (self.viewModel.reminderModel.notifyType - 1 < 3) {
        self.frequencyView.selectIndex = self.viewModel.reminderModel.notifyType - 1;
    }
    
    if (self.viewModel.reminderModel.ntfType > 0) {
        [self.inputContainView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(91);
        }];
        self.inputView.type = self.viewModel.reminderModel.ntfType;
        if (self.viewModel.reminderModel.ntfValue) {
            int a = [YXRemindTool getUnitWithType:self.viewModel.reminderModel.ntfType];
            self.inputView.textField.text = [YXRemindTool formatFloat:(self.viewModel.reminderModel.ntfValue.doubleValue / a) andType:self.viewModel.reminderModel.ntfType];
        } else {
            self.inputView.textField.text = nil;
        }
    } else {
        [self.inputContainView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
    }
}

- (void)updateAuthorityUI {
    
//    YXQuoteAuthority level = [[YXUserManager shareInstance] getQuoteAuthority:self.viewModel.market];
//    if (level == YXQuoteAuthorityBMP) {
//        [self.authorityTool showReminderText:@"应港交所要求，港股BMP行情需手动刷新"];
//        self.authorityTool.alignment = NSTextAlignmentCenter;
//    } else if (level == YXQuoteAuthorityDelay) {
//        [self.authorityTool showReminderDelayText];
//    } else {
//        [self.authorityTool removeReminderText];
//    }
}

- (UIView *)createHeaderViewWithTitle: (NSString *)title {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, YXConstant.screenWidth, 35)];
    view.backgroundColor = QMUITheme.backgroundColor;
    UILabel *label = [UILabel labelWithText:title textColor:QMUITheme.textColorLevel2 textFont:[UIFont systemFontOfSize:14]];
    label.frame = CGRectMake(16, 0, 200, 35);
    [view addSubview:label];    
    return view;
}


#pragma mark - lazy load
- (UIScrollView *)scrollView {
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        @weakify(self);
        YXRefreshHeader *header = [YXRefreshHeader headerWithRefreshingBlock:^{
            @strongify(self);
            //加载股价及涨跌幅数据
            [self.quoteRequest cancel];
            [self loadQuoteData];
        }];
        _scrollView.mj_header = header;
    }
    return _scrollView;
}


- (YXReminderFrequencyView *)frequencyView {
    if (!_frequencyView) {
        _frequencyView = [[YXReminderFrequencyView alloc] init];
    }
    return _frequencyView;
}


- (NSMutableArray *)remindSettingDataArr{
    
    if (!_remindSettingDataArr) {
        _remindSettingDataArr = [NSMutableArray array];
    }
    return _remindSettingDataArr;
    
}

//跳转到"我的提醒"
- (void)myReminderButtonEvent{
    
    if (self.viewModel.pushToMyRemindsCommand) {
        [self.viewModel.pushToMyRemindsCommand execute:nil];
    }
    
}

- (YXAuthorityReminderTool *)authorityTool {
    if (!_authorityTool) {
        _authorityTool = [[YXAuthorityReminderTool alloc] init];
        _authorityTool.delegate = self;
        _authorityTool.position = YXAuthorityReminderPositionViewBottom;
    }
    return _authorityTool;
}

- (YXReminderStockView *)stockInfoView {
    if (_stockInfoView == nil) {
        _stockInfoView = [[YXReminderStockView alloc] init];
    }
    return _stockInfoView;
}

- (YXStockReminderTypeSelectView *)typeView {
    if (_typeView == nil) {
        _typeView = [[YXStockReminderTypeSelectView alloc] init];
    }
    return _typeView;
}

- (YXStockReminderInputView *)inputView {
    if (_inputView == nil) {
        _inputView = [[YXStockReminderInputView alloc] init];
    }
    return _inputView;
}


#pragma YXAuthorityReminderToolDelegate

- (UIView *)reminderLabelSuperView {
    return self.view;
}

@end
