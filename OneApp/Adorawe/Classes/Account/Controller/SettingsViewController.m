//
//  OSSVSettinsgsVC.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/31.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVSettinsgsVC.h"
#import "STLLanguageSettingCtrl.h"
#import "STLCurrencyCtrl.h"
#import "STLAlertControllerView.h"

#import "AccountFooterView.h"

#import "SettingViewModel.h"
#import "AppDelegate.h"

//v1.4.6 已废弃
@interface OSSVSettinsgsVC ()

@property (nonatomic, strong) UITableView               *tableView;
@property (nonatomic, strong) SettingViewModel          *viewModel;
@property (nonatomic, strong) UIView                    *pannelView;
@property (nonatomic, strong) UIToolbar                 *toolbar;
@property (nonatomic, strong) UIPickerView              *pickerView;

@property (nonatomic, strong) AccountFooterView         *footerView;


@end

@implementation OSSVSettinsgsVC

#pragma mark - Life Cycle

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotif_Currency object:nil];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.title = STLLocalizedString_(@"Settings", nil);
    self.view.backgroundColor = [STLThemeColor col_F5F5F5];
    [self initSubViews];
    
    // 汇率改变的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCurrency:) name:kNotif_Currency object:nil]; 
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.firstEnter) {
    }
    self.firstEnter = YES;
    
    self.tableView.tableFooterView.hidden = ![AccountManager sharedManager].isSignIn;
}

#pragma mark - Method
- (void)cancelItemTouch:(id)sender {
    self.pannelView.hidden = !self.pannelView.hidden;
}

- (void)doneItemTouch:(id)sender {
   // picker selct
    [self.viewModel pickerViewDidSelected:self.pickerView];
    [self.tableView reloadData];
    self.pannelView.hidden = !self.pannelView.hidden;
}

- (void)actionDo:(id)sender {

    self.pannelView.hidden = !self.pannelView.hidden;
}

#pragma mark - Delegate

#pragma mark - MakeUI
- (void)initSubViews {
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.rowHeight = 50;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.separatorColor = STLThemeColor.col_F1F1F1;
    self.tableView.dataSource = self.viewModel;
    self.tableView.delegate = self.viewModel;
    self.tableView.tableFooterView = self.footerView;


    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (kIS_IPHONEX) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, STL_TABBAR_IPHONEX_H, 0));
        } else {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
        }
    }];
    
    // PickerView
    self.pannelView = [UIView new];
    self.pannelView.backgroundColor = [UIColor clearColor];
    self.pannelView.hidden = YES;
    [self.view addSubview:self.pannelView];
    
    [self.pannelView  mas_makeConstraints:^(MASConstraintMaker *make) {
        if (kIS_IPHONEX) {
            make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(0, 0, STL_TABBAR_IPHONEX_H, 0));
        } else {
            make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
        }
    }];
 
    
    self.pickerView = [[UIPickerView alloc] init];
    self.pickerView.backgroundColor =[STLThemeColor col_0D0D0D:0.3];
    self.pickerView.dataSource = self.viewModel;
    self.pickerView.delegate = self.viewModel;
    [self.pannelView  addSubview:self.pickerView];
    
    [self.pickerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.pannelView.mas_leading);
        make.trailing.mas_equalTo(self.pannelView.mas_trailing);
        make.bottom.mas_equalTo(self.pannelView.mas_bottom);
    }];

    
    self.toolbar =  [[UIToolbar alloc] init];
    [self.toolbar setBarStyle:UIBarStyleDefault];
    // Item
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:APP_TYPE == 3 ? STLLocalizedString_(@"cancel", nil) : STLLocalizedString_(@"cancel", nil).uppercaseString style:UIBarButtonItemStylePlain target:self action:@selector(cancelItemTouch:)];
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithTitle:APP_TYPE == 3 ? STLLocalizedString_(@"done", nil) : STLLocalizedString_(@"done", nil).uppercaseString style:UIBarButtonItemStylePlain target:self action:@selector(doneItemTouch:)];
    self.toolbar.items = @[cancelItem,spaceItem,doneItem];
    [self.pannelView addSubview:self.toolbar];
    
    [self.toolbar mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.leading.mas_equalTo(self.pannelView.mas_leading);
        make.trailing.mas_equalTo(self.pannelView.mas_trailing);
        make.bottom.mas_equalTo(self.pickerView.mas_top);
    }];

    
    UIView *coverView = [UIView new];
    coverView.backgroundColor = [UIColor blackColor];
    coverView.alpha = 0.3;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionDo:)];
    [coverView addGestureRecognizer:tapGesture];
    [self.pannelView addSubview:coverView];
    
    [coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.pannelView.mas_top);
        make.bottom.mas_equalTo(self.toolbar.mas_top);
        make.leading.mas_equalTo(self.pannelView.mas_leading);
        make.trailing.mas_equalTo(self.pannelView.mas_trailing);
    }];
}

#pragma mark - Notification
//货币改变通知
- (void)changeCurrency:(NSNotification *)notify {
    [self.viewModel updateCurrentCurrency];
}

#pragma mark 退出
- (void)exitUserLogin {

    [[CartOperationManager sharedManager] cartSaveValidGoodsAllCount:0];
    
    [self makeAlertWithSignOut];
}

- (void)makeAlertWithSignOut{
    
    [STLAlertControllerView showCtrl:self
                         alertTitle:nil
                            message:STLLocalizedString_(@"sureSignOut", nil)
                              oneMsg:APP_TYPE == 3 ? STLLocalizedString_(@"cancel", nil) : STLLocalizedString_(@"cancel", nil).uppercaseString
                              twoMsg:APP_TYPE == 3 ? STLLocalizedString_(@"sure", nil) : STLLocalizedString_(@"sure", nil).uppercaseString
                  completionHandler:^(NSInteger flag) {
        if (flag == 1) {
        } else {
            
            [[AccountManager sharedManager] clearUserInfo];
            [self.navigationController popToRootViewControllerAnimated:NO];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_Logout object:nil];
        }
    }];
}


#pragma mark - LazyLoad
- (SettingViewModel *)viewModel {
    
    if(!_viewModel) {
        _viewModel = [[SettingViewModel alloc] init];
        _viewModel.controller = self;
        @weakify(self)
        _viewModel.showPickerBlock = ^{
            @strongify(self)
//            self.pannelView.hidden = !self.pannelView.hidden;
            
            STLCurrencyCtrl *currencyVC = [[STLCurrencyCtrl alloc] init];
            [self.navigationController pushViewController:currencyVC animated:YES];
        };
        _viewModel.langageBlock = ^{
            @strongify(self)
            STLLanguageSettingCtrl *ctrl = [[STLLanguageSettingCtrl alloc] init];
            [self.navigationController pushViewController:ctrl animated:YES];
        };
   
    }
    return _viewModel;
}

- (AccountFooterView *)footerView {
    if (!_footerView) {
        _footerView = [[AccountFooterView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 100 * DSCREEN_WIDTH_SCALE)];
        
        @weakify(self)
        self.footerView.signOutBlock = ^{
            @strongify(self)
            [self exitUserLogin];
        };
    }
    return _footerView;
}



@end
