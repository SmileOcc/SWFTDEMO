//
//  OSSVAddressBooksVC.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/31.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVAddressBooksVC.h"
#import "OSSVAddresseBookeViewModel.h"

#import "OSSVAddresseBookeModel.h"
#import "UIViewController+PopBackButtonAction.h"
#import "OSSVPersoneCentereAddressCell.h"

#import "Adorawe-Swift.h"


static const CGFloat kAddAddressButtonBackHeight = 60; // 底部的高度


@interface OSSVAddressBooksVC ()

@property (nonatomic, strong) UITableView            *tableView;
@property (nonatomic, strong) UIView                 *addressBgView;
@property (nonatomic, strong) UIButton               *addNewAddressButton;
@property (nonatomic, strong) UIButton               *editButton;
@property (nonatomic, strong) OSSVAddresseBookeViewModel   *viewModel;
@property (nonatomic, strong) NSArray                *dataArray;

@end

@implementation OSSVAddressBooksVC

#pragma mark - Life Cycle
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = [STLLocalizedString_(@"AddressBook", nil) capitalizedString];
    //一直编辑状态
//    [self initNavAndReadySet];
    [self initSubViews];
    [self setRequestData];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 谷歌统计
    if (!self.firstEnter) {
        self.firstEnter = YES;
    }
}

#pragma mark - Method
- (void)initNavAndReadySet {
    //Nav
    //UIImage *editOriginalImage = [UIImage imageNamed:@"edit_icon"];
    
    self.editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.editButton setTitle:STLLocalizedString_(@"edit", nil) forState:UIControlStateNormal];

    [self.editButton setTitleColor:OSSVThemesColors.col_666666 forState:UIControlStateNormal];
    self.editButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.editButton addTarget:self action:@selector(actionEdit:) forControlEvents:UIControlEventTouchUpInside];
    self.editButton.frame = CGRectMake(0, 0, 50, 30);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.editButton];
    self.view.backgroundColor = OSSVThemesColors.col_F1F1F1;
    self.automaticallyAdjustsScrollViewInsets = NO;
}
#pragma mark load Data
- (void)setRequestData {
   
    @weakify(self)
    MJRefreshNormalHeader* header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
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
        
        // 保存临时 dataArrayCount 的临时值
        self.dataArray  = [NSArray arrayWithArray:(NSArray *)obj];
        // 对 RightBar 做一次处理 和 底部按钮做处理
        if (self.dataArray.count > 0) {
            self.navigationItem.rightBarButtonItem.enabled = YES;
            self.addressBgView.hidden = NO;
            self.addNewAddressButton.hidden = NO;
            [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
//                make.bottom.mas_equalTo(@(-kAddAddressButtonBackHeight));
                make.bottom.equalTo(self.view.mas_bottomMargin).offset(-8-44-12);
            }];
            
        }
        else {
            self.navigationItem.rightBarButtonItem.enabled = NO;
            self.addressBgView.hidden = YES;
            self.addNewAddressButton.hidden = YES;
            [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(@0);
            }];
            
//            /**
//             *  这个地方需要处理，当刷新后 dataArrayCount === 0的时候，这边EmptyView 会出现上移 54 的Bug
//             暂时用重置 frame,而且必须是 endRefreshing 之后才会有DZNEmptyDataSetView
//             此处已经ViewModel 中改好（(void)emptyDataSetWillAppear:(UIScrollView *)scrollView），后期可删除
//             */
//            for (UIView *subView in self.tableView.subviews) {
//                if ([NSStringFromClass([subView class]) isEqualToString:DZNEmptyDataSetViewName]){
//                    // 此处重置 frame
//                    if (subView.frame.origin.y == 0) return;
//                    // 改变其位置就好啦
//                    CGRect rect = subView.frame;
//                    rect.origin = CGPointMake(0, 0);
//                    subView.frame =  rect;
//                    return;
//                }
//            }
        }
        
        [self.tableView showRequestTip:@{kTotalPageKey  : @(1),
                                             kCurrentPageKey: @(0)}];
    } failure:^(id obj) {
        @strongify(self)
        [HUDManager hiddenHUD];
        [self.tableView reloadData];
        [self.tableView showRequestTip:nil];
    }];
}


#pragma mark 监听返回事件
- (BOOL)navigationShouldPopOnBackButton {
    /**
        此处是为了防止，删除按钮没有恢复
        而让self.viewModel 在被释放后还继续使用
     */
    //[self.tableView setEditing:NO];
    [self handleEditState:NO];
    return YES;
}

#pragma mark 编辑事件
- (void)actionEdit:(UIButton *)sender {
    
    [self handleEditState:!self.viewModel.isEdit];

    [self.tableView reloadData];
}

- (void)handleEditState:(BOOL)state {
//    self.viewModel.isEdit = state;
    self.viewModel.isEdit = YES;
    
    /***
    if (state) {
        [self.editButton setTitleColor:OSSVThemesColors.col_FF6F04 forState:UIControlStateNormal];
        [self.editButton setTitle:STLLocalizedString_(@"done", nil) forState:UIControlStateNormal];
    } else {
        [self.editButton setTitleColor:OSSVThemesColors.col_666666 forState:UIControlStateNormal];
        [self.editButton setTitle:STLLocalizedString_(@"edit", nil) forState:UIControlStateNormal];
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.editButton];
     */
}

#pragma mark 添加地址事件
- (void)addNewAddressAction {
    // 此处需要注意的是
    if (self.dataArray.count > 4) {
        // 提示最多只能添加 5 条
        [self showHUDWithErrorText:STLLocalizedString_(@"addressListAbove5", nil)];
        return;
    }
    @weakify(self);
    //跳转添加地址界面
    OSSVEditAddressVC *addVc = [[OSSVEditAddressVC alloc]init];
    addVc.isModify = @(NO);
    addVc.successBlock = ^(NSString *addressID) {
        @strongify(self);
        [self.tableView.mj_header beginRefreshing];
    };
    [self.navigationController pushViewController:addVc animated:YES];
    [GATools logAddressBookEventWithAction:@"Add Address"];
}


#pragma mark - Private Check HUD
- (void)showHUDWithErrorText:(NSString *)text {
    [HUDManager showHUDWithMessage:text customView:[[YYAnimatedImageView alloc] initWithImage:[UIImage imageNamed:@"prompt"]]];
    
}

#pragma mark - MakeUI
- (void)initSubViews {
    
    // tableView
    self.tableView = [[UITableView alloc] init];
    self.tableView.bounds = self.view.bounds;
    self.tableView.estimatedRowHeight = 80;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.dataSource = self.viewModel;
    self.tableView.delegate = self.viewModel;
//    self.tableView.emptyDataSetDelegate = self.viewModel;
//    self.tableView.emptyDataSetSource = self.viewModel;
    
    [self.tableView registerClass:OSSVPersoneCentereAddressCell.class forCellReuseIdentifier:@"OSSVPersoneCentereAddressCell"];
    //[self.tableView setEditing:NO];
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:self.tableView];
    
    
    
    self.tableView.contentInset = UIEdgeInsetsMake(4, 0, 0, 0);
    
    self.tableView.blankPageImageViewTopDistance = 40;
    self.tableView.emptyDataTitle    = STLLocalizedString_(@"addressBook_blank",nil);
    self.tableView.emptyDataImage = [UIImage imageNamed:@"address_bank"];
    self.tableView.emptyDataBtnTitle = APP_TYPE == 3 ? STLLocalizedString_(@"addressAddAdress", nil) : STLLocalizedString_(@"addressAddAdress", nil).uppercaseString;
    
    @weakify(self)
    self.tableView.blankPageViewActionBlcok = ^(STLBlankPageViewStatus status) {
        @strongify(self)
        if (status == RequestEmptyDataStatus) {
            [self addNewAddressAction];
        } else {
            [self.tableView.mj_header beginRefreshing];
        }
        
    };
    
    // addNewAddressButton
    self.addNewAddressButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.addNewAddressButton.backgroundColor = OSSVThemesColors.col_0D0D0D;
    self.addNewAddressButton.hidden = YES;
    [self.addNewAddressButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    if (APP_TYPE == 3) {
        [self.addNewAddressButton setTitle:STLLocalizedString_(@"addressAddAdress", nil) forState:UIControlStateNormal];
    } else {
        [self.addNewAddressButton setTitle:STLLocalizedString_(@"addressAddAdress", nil).uppercaseString forState:UIControlStateNormal];
    }
    self.addNewAddressButton.titleLabel.font = [UIFont stl_buttonFont:14];
    self.addNewAddressButton.layer.cornerRadius = 0;
    [self.addNewAddressButton addTarget:self action:@selector(addNewAddressAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.addNewAddressButton];
    [self.addNewAddressButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(12);
        make.trailing.mas_equalTo(-12);
        make.bottom.equalTo(self.view.mas_bottomMargin).offset(-8);
        make.height.mas_equalTo(44);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(0);
        make.bottom.equalTo(self.view.mas_bottomMargin).offset(-8-44-4);
    }];
    
    self.addressBgView = [[UIView alloc] init];
    self.addressBgView.hidden = YES;
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = OSSVThemesColors.col_EEEEEE;
    [self.view insertSubview:self.addressBgView belowSubview:self.addNewAddressButton];
    self.addressBgView.backgroundColor = UIColor.whiteColor;
    [self.addressBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(0);
        make.top.equalTo(self.addNewAddressButton.mas_top).offset(-8);
    }];
    [self.addressBgView addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(0);
        make.height.equalTo(0.5);
    }];

}

#pragma mark - LazyLoad 
#pragma mark 注意此处ViewModel 中 多个Block 事件都是在此处添加的
- (OSSVAddresseBookeViewModel *)viewModel {
    
    if(!_viewModel) {
        _viewModel = [[OSSVAddresseBookeViewModel alloc] init];
        _viewModel.controller = self;
        //一直编辑状态
        _viewModel.isEdit = YES;
        @weakify(self)
        // 完成编辑状态下的操作
        _viewModel.completeExecuteBlock = ^{
            @strongify(self)
            [self.tableView.mj_header beginRefreshing];
            //[self.tableView setEditing:NO];
            [self handleEditState:NO];
        };
        //地址新增或者修改成功后回调刷新地址列表
        _viewModel.updateBlock = ^{
            @strongify(self)
            [self.tableView.mj_header beginRefreshing];

        };
//        // 当地址为空的时候，点击刷新按钮时的处理
//        _viewModel.emptyOperationBlock = ^{
//            @strongify(self)
//            [self.tableView.mj_header beginRefreshing];
//        };
//        // 当地址为空的时候，点击新增地址
//        _viewModel.emptyJumpOperationBlock = ^{
//            @strongify(self)
//            [self addNewAddressAction];
//        };
        // 恢复删除操作
        _viewModel.resumeDeleteActionBlock = ^{
             //@strongify(self)
            //[self.tableView setEditing:NO];
            //[self handleEditState:NO];
            
        };
        
        //默认操作
        _viewModel.defaultBlock = ^{
          @strongify(self)
            [self refresh];
        };
    }
    return _viewModel;
}

@end
