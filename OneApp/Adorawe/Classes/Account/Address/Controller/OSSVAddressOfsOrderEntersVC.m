//
//  OSSVAddressOfsOrderEntersVC.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/25.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVAddressOfsOrderEntersVC.h"
#import "OSSVAddresesOfOrdereEnterViewModel.h"
#import "OSSVAddresseBookeModel.h"
#import "UIViewController+PopBackButtonAction.h"
#import "UINavigationController+FDFullscreenPopGesture.h"

#import "Adorawe-Swift.h"

static const CGFloat kAddAddressButtonBackHeight = 60; // 底部的高度

@interface OSSVAddressOfsOrderEntersVC ()

@property (nonatomic, strong) UITableView                     *tableView;
@property (nonatomic, strong) UIButton                        *addNewAddressButton;
@property (nonatomic, strong) OSSVAddresesOfOrdereEnterViewModel    *viewModel;
@property (nonatomic, strong) NSArray                         *dataArray;
@property (nonatomic, strong) OSSVAddresseBookeModel                *modifyAddressModel;
@property (nonatomic, assign) BOOL                            isEdit;


@end

@implementation OSSVAddressOfsOrderEntersVC

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.fd_interactivePopDisabled = NO;
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.title = [STLLocalizedString_(@"AddressBook", nil) capitalizedString];
    [self initNavAndReadySet];
    [self initSubViews];
    [self setRequestData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 谷歌统计
    if (!self.firstEnter) {
    }
    self.firstEnter = YES;
//    self.fd_interactivePopDisabled = YES;
}

#pragma mark - Method
- (void)initNavAndReadySet {
    //Nav
    self.view.backgroundColor = OSSVThemesColors.col_F1F1F1;
    self.automaticallyAdjustsScrollViewInsets = NO;
}
#pragma mark load Data
- (void)setRequestData {
    
    self.viewModel.selectedAddressId = self.selectedAddressId;
    @weakify(self)
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self)
        [self refresh];
    }];
    // 隐藏时间
    header.lastUpdatedTimeLabel.hidden = YES;

    // 隐藏状态
    header.stateLabel.hidden = YES;
    self.tableView.mj_header = header;
    
//    [self.tableView.mj_header beginRefreshing];
    [self refresh];
}

- (void)refresh {
    if (!self.tableView.mj_header.isRefreshing) {
        [HUDManager showLoading];
    }
    
    @weakify(self)
    [self.viewModel requestNetwork:nil completion:^(id obj) {
        [HUDManager hiddenHUD];
        @strongify(self)
        // tableView 的处理
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
        // 保存临时 dataArrayCount 的临时值
        self.dataArray  = [NSArray arrayWithArray:(NSArray *)obj];
        
    } failure:^(id obj) {
        @strongify(self)
        [self.tableView.mj_header endRefreshing];
    }];
}
#pragma mark 直接点击返回
- (BOOL)navigationShouldPopOnBackButton {
    // 直接返回
    if (self.modifyAddressModel) {
        if (self.directReBackActionBlock) {
            self.directReBackActionBlock(self.modifyAddressModel);
        }
    }
    return YES;
}



#pragma mark 添加地址事件
- (void)addNewAddressAction {
    
    // 此处需要注意的是
    if (self.dataArray.count > 4) {
        // 提示最多只能添加 5 条
        [self showHUDWithErrorText:STLLocalizedString_(@"addressListAbove5", nil)];
        return;
    }
    
    [GATools logAddressBookEventWithAction:@"Add Address"];
    @weakify(self)
    //跳转添加地址界面
    OSSVEditAddressVC *addVc = [[OSSVEditAddressVC alloc]init];
    addVc.saveBtnTitle = APP_TYPE == 3 ? STLLocalizedString_(@"SaveNContinue", nil) : STLLocalizedString_(@"SaveNContinue", nil).uppercaseString;
    addVc.isModify = @(NO);
    addVc.needPopToLastBefore = @(YES);
    addVc.successBlock = ^(NSString *addressID) {
        @strongify(self)
        ///1.4.2 添加完成后直接使用
        if (self.chooseDefaultAddressBlock) {
            OSSVAddresseBookeModel *model = [[OSSVAddresseBookeModel alloc] init];
            model.addressId = addressID;
            self.chooseDefaultAddressBlock(model);
        }
//        [self.navigationController popViewControllerAnimated:YES];
    };
    [self.navigationController pushViewController:addVc animated:YES];
}


#pragma mark - Private Check HUD
- (void)showHUDWithErrorText:(NSString *)text {
    [HUDManager showHUDWithMessage:text customView:[[YYAnimatedImageView alloc] initWithImage:[UIImage imageNamed:@"prompt"]]];
}

#pragma mark - MakeUI
- (void)initSubViews {
    
    // tableView
    self.tableView = [[UITableView alloc] init];
    self.tableView.estimatedRowHeight = 120;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.dataSource = self.viewModel;
    self.tableView.delegate = self.viewModel;
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.equalTo(@0);
        if (kIS_IPHONEX) {
            make.bottom.equalTo(@(-kAddAddressButtonBackHeight -24));
        } else {
            make.bottom.equalTo(@(-kAddAddressButtonBackHeight));
        }
    }];
    
    self.tableView.contentInset = UIEdgeInsetsMake(2, 0, 0, 0);
    
    // addNewAddressButton
    self.addNewAddressButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.addNewAddressButton.backgroundColor = OSSVThemesColors.col_0D0D0D;
    [self.addNewAddressButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    if (APP_TYPE == 3) {
        [self.addNewAddressButton setTitle:STLLocalizedString_(@"addressAddAdress", nil) forState:UIControlStateNormal];
    } else {
        [self.addNewAddressButton setTitle:STLLocalizedString_(@"addressAddAdress", nil).uppercaseString forState:UIControlStateNormal];
    }
    self.addNewAddressButton.layer.cornerRadius = 0;
    self.addNewAddressButton.titleLabel.font = [UIFont stl_buttonFont:14];
    [self.addNewAddressButton addTarget:self action:@selector(addNewAddressAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.addNewAddressButton];
    [self.addNewAddressButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(12);
        make.trailing.mas_equalTo(-12);
        make.height.mas_equalTo(44);
        make.bottom.equalTo(self.view.mas_bottomMargin).offset(-8);
    }];
    
    UIView *addressBg = [[UIView alloc] init];
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = OSSVThemesColors.col_EEEEEE;
    [self.view insertSubview:addressBg belowSubview:self.addNewAddressButton];
    addressBg.backgroundColor = UIColor.whiteColor;
    [addressBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(0);
        make.top.equalTo(self.addNewAddressButton.mas_top).offset(-8);
    }];
    [addressBg addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(0);
        make.height.equalTo(0.5);
    }];
    
}

#pragma mark - LazyLoad
- (OSSVAddresesOfOrdereEnterViewModel *)viewModel {
    
    if(!_viewModel) {
        _viewModel = [[OSSVAddresesOfOrdereEnterViewModel alloc] init];
        _viewModel.controller = self;
        _viewModel.editOrRebackType = AddressRebackType;
        _viewModel.selectedAddressId = self.selectedAddressId;
         @weakify(self)
        _viewModel.updateBlock = ^{
            @strongify(self)
            // 为了点击修改后，为了少点一次
//             self.viewModel.editOrRebackType= AddressRebackType;
//             self.isEdit = NO;
//            // 刷新获取 数据
//            [self handleEditState:AddressRebackType];
            [self.tableView.mj_header beginRefreshing];
 

        };
        
        _viewModel.completeExecuteBlock = ^{
            @strongify(self)
            [self.tableView.mj_header beginRefreshing];
        };

        _viewModel.getDefalutModelBlock = ^(OSSVAddresseBookeModel *model){
            @strongify(self)
            // 选择点击cell 返回的Model
            if (self.chooseDefaultAddressBlock) {
                self.chooseDefaultAddressBlock(model);
            }
        };
        _viewModel.getModifyAddressModelBlock = ^(OSSVAddresseBookeModel *model){
            @strongify(self)
            // 直接修改获取的Model
//            [self handleEditState:AddressRebackType];
            self.modifyAddressModel = model;
        };
        
        _viewModel.defaultBlock = ^{
            @strongify(self)
            [self refresh];
        };
        
    }
    return _viewModel;
}

@end
