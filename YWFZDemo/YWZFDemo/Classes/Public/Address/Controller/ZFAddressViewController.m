//
//  ZFAddressViewController.m
//  ZZZZZ
//
//  Created by YW on 2017/8/29.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFAddressViewController.h"
#import "ZFInitViewProtocol.h"
#import "ZFBottomToolView.h"
#import "ZFAddressEditViewController.h"
#import "ZFAddressListTableViewCell.h"
#import "ZFAddressInfoModel.h"
#import "ZFAddressViewModel.h"

#import "ZFThemeManager.h"
#import "ZFProgressHUD.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "YSAlertView.h"
#import "Masonry.h"
#import "Constants.h"

static NSString *const kZFAddressListTableViewCellIdentifier = @"kZFAddressListTableViewCellIdentifier";

@interface ZFAddressViewController () <ZFInitViewProtocol, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign) NSInteger                             currentSelectIndex;
@property (nonatomic, strong) UITableView                           *tableView;
@property (nonatomic, strong) UIView                            *bottomBgView;
@property (nonatomic, strong) ZFBottomToolView                      *addAddressView;
@property (nonatomic, strong) ZFAddressViewModel                    *viewModel;
@property (nonatomic, strong) NSMutableArray<ZFAddressInfoModel *>  *dataArray;
@end

@implementation ZFAddressViewController

#pragma mark - Life Cycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self zfInitView];
    [self zfAutoLayoutView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.title = ZFLocalizedString(@"Address_VC_Title", nil);
    self.view.backgroundColor = ZFC0xF2F2F2();
    
    if (self.addressShowType == AddressInfoShowTypeCheckOrderInfo) {
        
        //关闭按钮
        //NSString *close = ZFLocalizedString(@"CartOrderInfo_Address_List_Close",nil);
        UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithImage:ZFImageWithName(@"login_dismiss") style:UIBarButtonItemStyleDone target:self action:@selector(closeButtonAction:)];
        self.navigationItem.leftBarButtonItem = closeItem;
    }
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.bottomBgView];
    [self.bottomBgView addSubview:self.addAddressView];
}

- (void)zfAutoLayoutView {
    
    [self.bottomBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view.mas_bottom);
    }];
    
    [self.addAddressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.bottomBgView.mas_bottom).offset(-kiphoneXHomeBarHeight);
        make.height.mas_equalTo(56);
        make.top.mas_equalTo(self.bottomBgView.mas_top);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.bottomBgView.mas_top);
    }];
}

//v4.4.0 不隐藏
- (void)updateAddAddressLayoutWithCanAdd:(BOOL)canAdd {
    self.addAddressView.hidden = YES;
    if (canAdd) {
        self.addAddressView.hidden = NO;
        [self.addAddressView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(64);
        }];
    } else {
        [self.addAddressView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
    }
}

#pragma mark - ===========编辑操作===========

#pragma mark  action methods

- (void)backUpperVC:(ZFAddressInfoModel *)model {

    if (self.addressChooseCompletionHandler && model) {
        self.addressChooseCompletionHandler(model);
    }
    NSArray *viewcontrollers=self.navigationController.viewControllers;
    
    if (viewcontrollers.count > 1) {
        if (viewcontrollers.firstObject != self){
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
    }
    //present方式
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)closeButtonAction:(id)sender {
    @weakify(self);
    if (self.dataArray.count <= self.currentSelectIndex) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    ZFAddressInfoModel *model = self.dataArray[self.currentSelectIndex];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:self.currentSelectIndex];
    [self selectDefaulAddressWithAddressId:model.address_id andIndexPath:indexPath completion:^(BOOL success){
        @strongify(self);
        // 退出时不管成功失败都返回
        if (self.addressChooseCompletionHandler) {
            NSInteger row = indexPath.section;
            self.addressChooseCompletionHandler(self.dataArray[row]);
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

/**
 * 进入编辑地址页面
 */
- (void)editAddressAction:(ZFAddressInfoModel *)model{
    @weakify(self)
    ZFAddressEditViewController *addressEditVC = [[ZFAddressEditViewController alloc] init];
    if (self.addressShowType == AddressInfoShowTypeCheckOrderInfo) {
        addressEditVC.isFromOrderCheckEdit = YES;
    }
    if (model) {
        addressEditVC.title = ZFLocalizedString(@"ModifyAddress_Edit_VC_title",nil);
        addressEditVC.model = model;
    } else {
        addressEditVC.title = ZFLocalizedString(@"Modify_Address_VC_Title",nil);
    }
    
    addressEditVC.addressEditSuccessCompletionHandler = ^(AddressEditStateType editStateType) {
        @strongify(self);
        [self.tableView.mj_header beginRefreshing];
        if (editStateType != AddressEditStateFail) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                ShowToastToViewWithText(self.view, ZFLocalizedString(@"Edited_successfully",nil));
            });
        }
    };
    [self.navigationController pushViewController:addressEditVC animated:YES];
}


#pragma mark - ===========请求地址数据===========

- (void)requestLocalLocationInfoOption {
    [self.viewModel requestAddressLocationInfoNetwork:nil completion:nil];
}

- (void)selectDefaulAddressWithAddressId:(NSString *)addressId
                            andIndexPath:(NSIndexPath *)indexPath
                              completion:(void (^)(BOOL success))completion
{
    NSDictionary *dict = @{@"address_id" : addressId,
                           kLoadingView  : self.view };
    @weakify(self);
    [self.viewModel requestsetDefaultAddressNetwork:dict completion:^(BOOL isOK) {
        @strongify(self);
        if (!isOK) {
            if (completion) {
                completion(NO);
            }
            return ;
        }
        ZFAddressInfoModel *selectModel = self.dataArray[indexPath.section];
        selectModel.is_default = YES;
        self.dataArray[indexPath.section] = selectModel;
        ZFAddressInfoModel *currentSelectModel = self.dataArray[self.currentSelectIndex];
        currentSelectModel.is_default = NO;
        self.dataArray[self.currentSelectIndex] = currentSelectModel;
        self.currentSelectIndex = indexPath.section;
        [self.tableView reloadData];
        if (completion) {
            completion(YES);
        }
    }];
}

- (void)requestDeleteAddressData:(ZFAddressInfoModel *)model dalteindexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = @{@"address_id" : model.address_id,
                           kLoadingView  : self.view };
    @weakify(self);
    [self.viewModel requestDeleteAddressNetwork:dict completion:^(BOOL isOK) {
        @strongify(self);
        if (isOK && indexPath.section < self.dataArray.count) {
            [self.dataArray removeObjectAtIndex:indexPath.section];
//            [self updateAddAddressLayoutWithCanAdd:(self.dataArray.count < 5)];
        }
//        [self.tableView showRequestTip:@{}];
        [self.tableView reloadData];
        
        // 每次删除地址后重新请求地址列表
        [self.tableView.mj_header beginRefreshing];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            ShowToastToViewWithText(self.view, ZFLocalizedString(@"Deleted_successfully",nil));
        });
    }];
}

- (void)dealWithAddressEditSelectCompletion:(ZFAddressInfoModel *)model event:(ZFAddressListCellEvent)event indexPath:(NSIndexPath *)indexPath {
    
    if (self.addressShowType == AddressInfoShowTypeCheckOrderInfo
        && event == ZFAddressListCellEventSelect) { //结算页 选择地址  ---> 3.8.0调整进入编辑

        //v5.7.0调整
//        [self editAddressAction:model];
        @weakify(self)
               [self selectDefaulAddressWithAddressId:model.address_id
                                         andIndexPath:indexPath
                                           completion:^(BOOL success){
                                               @strongify(self);
                                               if (success) {
                                                   if (self.addressChooseCompletionHandler) {
                                                       self.addressChooseCompletionHandler(self.dataArray[indexPath.section]);
                                                   }
                                                   [self dismissViewControllerAnimated:YES completion:nil];
                                               }
                                           }];

    } else if(self.addressShowType == AddressInfoShowTypeCheckOrderInfo && event == ZFAddressListCellEventDefault) {
        
        @weakify(self)
        [self selectDefaulAddressWithAddressId:model.address_id
                                  andIndexPath:indexPath
                                    completion:^(BOOL success){
                                        @strongify(self);
                                        if (success) {
                                            if (self.addressChooseCompletionHandler) {
                                                self.addressChooseCompletionHandler(self.dataArray[indexPath.section]);
                                            }
                                            [self dismissViewControllerAnimated:YES completion:nil];
                                        }
                                    }];
        
    } else if(event == ZFAddressListCellEventDefault
              && self.addressShowType != AddressInfoShowTypeCheckOrderInfo
              && !model.is_default) {//默认地址,不能取消
        @weakify(self)
        [self selectDefaulAddressWithAddressId:model.address_id
                                  andIndexPath:indexPath
                                    completion:^(BOOL success){
                                        @strongify(self)
                                        ShowToastToViewWithText(self.view, ZFLocalizedString(@"Edited_successfully",nil));
                                    }];
        
    } else if(event == ZFAddressListCellEventEdit || event == ZFAddressListCellEventSelect) {//编辑地址
        [self editAddressAction:model];
        
    } else if(event == ZFAddressListCellEventDelete) {//删除地址
        
        if (self.dataArray.count > 1) {
            
            NSString *title = ZFLocalizedString(@"ModifyAddress_sure_delete_item",nil);
            NSArray *btnArr = @[ZFLocalizedString(@"Account_VC_SignOut_Alert_Yes",nil)];
            NSString *cancelTitle = ZFLocalizedString(@"Account_VC_SignOut_Alert_No",nil);
            
            ShowAlertView(title, nil, btnArr, ^(NSInteger buttonIndex, id title) {
                [self requestDeleteAddressData:model dalteindexPath:indexPath];
            }, cancelTitle, nil);
            
        } else {
            
            NSString *title = ZFLocalizedString(@"ModifyAddress_can't_delete_all_addresses",nil);
            NSString *cancelTitle = ZFLocalizedString(@"OK",nil);
            ShowAlertSingleBtnView(nil, title, cancelTitle);
        }
    }
}

- (void)requestAddressListData {
    @weakify(self)
    NSString *source = self.addressShowType == AddressInfoShowTypeCheckOrderInfo ? @"1" : @"0";
    [self.viewModel requestAddressListNetwork:@{@"source":source} completion:^(id obj) {
        @strongify(self);
        self.dataArray = obj;
        NSInteger count = self.dataArray.count;
        for (int i = 0; i < count; i++) {
            ZFAddressInfoModel *infoModel = self.dataArray[i];
            if (infoModel.is_default) {
                self.currentSelectIndex = i;
                break;
            }
        }
//        [self updateAddAddressLayoutWithCanAdd:(self.dataArray.count < 5)];
        [self.tableView reloadData];
        [self.tableView showRequestTip:@{}];
    } failure:^(id obj) {
        @strongify(self);
        [self.tableView reloadData];
        [self.tableView showRequestTip:nil];
    }];
}

#pragma mark - <UITableViewDelegate, UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footer = [[UIView alloc] init];
    return footer;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZFAddressListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kZFAddressListTableViewCellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (self.dataArray.count > indexPath.section) {
        BOOL isEdit = self.addressShowType == AddressInfoShowTypeCheckOrderInfo ? NO : YES;
        ZFAddressInfoModel *model = self.dataArray[indexPath.section];
        [cell updateInfoModel:model edit:isEdit isOrder:(self.addressShowType == AddressInfoShowTypeCheckOrderInfo ? YES : NO)];
    }
    
    @weakify(self);
    cell.addressEditSelectCompletionHandler = ^(ZFAddressInfoModel *model, ZFAddressListCellEvent event) {
        @strongify(self);
        [self dealWithAddressEditSelectCompletion:model event:event indexPath:indexPath];
    };
    return cell;
 }

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return section == self.dataArray.count - 1 ? 10 : CGFLOAT_MIN;
}

#pragma mark - setter
- (void)setAddressShowType:(AddressInfoShowType)showType {
    _addressShowType = showType;
}

#pragma mark - getter
- (NSMutableArray<ZFAddressInfoModel *> *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (ZFAddressViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[ZFAddressViewModel alloc] init];
        _viewModel.controller = self;
    }
    return _viewModel;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.estimatedRowHeight = 120;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.showsVerticalScrollIndicator = YES;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[ZFAddressListTableViewCell class] forCellReuseIdentifier:kZFAddressListTableViewCellIdentifier];
        _tableView.emptyDataImage = [UIImage imageNamed:@"blankPage_noAddress"];
        _tableView.emptyDataTitle = ZFLocalizedString(@"ModifyAddress_no_address_adding_5_addresses_msg", nil);
        _tableView.blankPageViewCenter = CGPointMake(KScreenWidth/2, KScreenHeight/3);
        
        //添加刷新控件,请求数据
        @weakify(self);
        [_tableView addHeaderRefreshBlock:^{
            @strongify(self);
            [self requestAddressListData];
        } footerRefreshBlock:nil startRefreshing:YES];
    }
    return _tableView;
}

- (UIView *)bottomBgView {
    if (!_bottomBgView) {
        _bottomBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 64 + kiphoneXHomeBarHeight)];
        _bottomBgView.backgroundColor = ZFC0xFFFFFF();
    }
    return _bottomBgView;
}

- (ZFBottomToolView *)addAddressView {
    if (!_addAddressView) {
        _addAddressView = [[ZFBottomToolView alloc] initWithFrame:CGRectZero];
        _addAddressView.backgroundColor = ZFC0xFFFFFF();
        _addAddressView.bottomTitle = ZFLocalizedString(@"Address_VC_Add_Address",nil);
        _addAddressView.showTopShadowline = YES;
        //_addAddressView.hidden = YES;
        @weakify(self);
        _addAddressView.bottomButtonBlock = ^{
            @strongify(self);
            [self editAddressAction:nil];
        };
    }
    return _addAddressView;
}
@end
