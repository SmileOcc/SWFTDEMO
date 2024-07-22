//
//  ZFAddressEditViewController.m
//  ZZZZZ
//
//  Created by YW on 2017/8/29.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFAddressEditViewController.h"
#import "ZFInitViewProtocol.h"
#import "ZFAddressCountryCitySelectVC.h"
#import "ZFAddressViewController.h"
#import "ZFHelpViewController.h"
#import "UIViewController+ZFViewControllerCategorySet.h"

#import "AlertWebView.h"
#import "DLPickerView.h"
#import "FFToast.h"
#import "FilterManager.h"

#import "ZFAddressInfoModel.h"
#import "ZFAddressCityModel.h"
#import "ZFAddressCountryModel.h"
#import "ZFAddressEditTypeModel.h"
#import "ZFAddressStateModel.h"
#import "ZFAddressTownModel.h"

#import "ZFAddressModifyViewModel.h"
#import "ZFCheckShippingAddressModel.h"
#import "ZFAddressLibraryManager.h"

#import "ZFGoogleIntelligentizeAddressVC.h"
#import "ZFBottomToolView.h"
#import "ZFAddressCityTableView.h"
#import "ZFPickerView.h"
#import "ZFAddressTableHeaderView.h"

#import "ZFAddressCheckView.h"
#import "YWLocalHostManager.h"
#import "ZFThemeManager.h"
#import "IQKeyboardManager.h"
#import "NSStringUtils.h"
#import "ZFProgressHUD.h"
#import "UIView+LayoutMethods.h"
#import "ZFLocalizationString.h"
#import "NSDictionary+SafeAccess.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "YSAlertView.h"
#import "ZFCommonRequestManager.h"
#import "Masonry.h"
#import "Constants.h"
#import "TZLocationManager.h"
#import "ZFAddressEditManager.h"
#import "ZFCustomerManager.h"

@interface ZFAddressEditViewController () <ZFInitViewProtocol, ZFBaseEditAddressCellDelegate, UITableViewDelegate, UITableViewDataSource>
{
    dispatch_queue_t queue;
}

@property (nonatomic, strong) UITableView                       *tableView;
@property (nonatomic, strong) UIView                            *bottomBgView;
@property (nonatomic, strong) ZFBottomToolView                  *bottomSaveView;
/** 电话选择弹窗*/
@property (nonatomic, strong) DLPickerView                      *pickerView;
/** 地址纠错弹窗*/
@property (nonatomic, strong) ZFAddressCheckView                *addressCheckView;
/** 邮编选择弹窗*/
@property (nonatomic, strong) ZFPickerView                      *zipPickerView;
/** 城市筛选弹窗*/
@property (nonatomic, strong) ZFAddressCityTableView            *cityFilterTable;
/** 订单地址修改提示*/
@property (nonatomic, strong) ZFAddressTableHeaderView          *headerView;

@property (nonatomic, strong) NSMutableArray                    *dataArray;
/** 编辑模型*/
@property (nonatomic, strong) ZFAddressInfoModel                *editModel;
/** 源模型*/
@property (nonatomic, strong) ZFAddressInfoModel                *sourceModel;
/** 地址请求模型*/
@property (nonatomic, strong) ZFAddressModifyViewModel          *viewModel;

/** 州、省是否可选*/
@property (nonatomic, assign) BOOL                              hasProvince;
/** 城市 是否可选*/
@property (nonatomic, assign) BOOL                              hasCity;
/** 乡村 是否可选*/
@property (nonatomic, assign) BOOL                              hasVillage;

@property (nonatomic, strong) NSString                          *country_code;
@property (nonatomic, assign) BOOL                              set_as_default_address;
@property (nonatomic, assign) BOOL                              source_set_as_default_address;

@property (nonatomic, assign) CGFloat                           keyboardHeight;
@property (nonatomic, strong) NSIndexPath                       *currentIndexPath;
@property (nonatomic, strong) NSIndexPath                       *zipIndexPath;

@property (nonatomic, assign) double                            lastInputTimer;
@property (nonatomic, strong) NSMutableDictionary               *dispatchOperations;

/**请求完成后*/
@property (nonatomic, assign) BOOL                              hasingRequestSuccess;
@property (nonatomic, assign) BOOL                              isFirstNoError;

/**是否已经编辑操作*/
@property (nonatomic, assign) BOOL                              hadEdit;
/**是否已经编辑 国家、省、城市操作*/
@property (nonatomic, assign) BOOL                              hadEditCountryCity;

@property (nonatomic, strong) ZFGoogleIntelligentizeAddressVC   *googleVC;

@property (nonatomic, strong) ZFAddressCountryModel             *selectCountryModel;
@property (nonatomic, strong) ZFAddressStateModel               *selectStateModel;
@property (nonatomic, strong) ZFAddressCityModel                *selectCityModel;
@property (nonatomic, strong) ZFAddressTownModel                *selectVillageModel;

/** 当前城市邮编*/
@property (nonatomic, strong) NSMutableDictionary               *cityZipDic;

@property (nonatomic, strong) CLLocation                         *addressLocation;

/**订单修改地址标识*/
@property (nonatomic, assign) BOOL                              isOrderUpdate;

/**是否编辑改变了国家、州、城市、城镇*/
//@property (nonatomic, assign) BOOL                              isEditCountryStateCity;

@end

@implementation ZFAddressEditViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.isOrderUpdate) {
        [[ZFAddressLibraryManager manager] removeAddressLibrary];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [IQKeyboardManager sharedManager].enable = NO;
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.hadEdit = YES;
    [IQKeyboardManager sharedManager].enable = YES;
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;

    [self.addressCheckView hideView];
    [self.zipPickerView dismissView];    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self zfInitView];
    [self zfAutoLayoutView];
    [self configAddressEditBookInfo];
    if (self.isCheck) {//一进来就校验
        [self isCheckEnterInfoSuccess];
    }
    
    if (self.isOrderUpdate) {
        // 修改订单地址时，清空持有的地址库数据
        [[ZFAddressLibraryManager manager] removeAddressLibrary];
        // 未付款订单修改地址，不显示
        [self showOrderTipView: self.addressNoPayOrder ? NO : YES];
        [self requestOrderAddressData];
    } else {
        //安全判断,因为修改订单地址的时候，地址库只有一个国家数据
        if ([ZFAddressLibraryManager manager].countryGroupKeys.count <= 1) {
            [[ZFAddressLibraryManager manager] removeAddressLibrary];
        }
        [self startUserLocation];
        [self requestCurrentCountryData];
    }
    
    [self addNotification];
}


#pragma mark - 请求数据
/// 获取订单地址信息
- (void)requestOrderAddressData {
    
    @weakify(self)
    [self judgePresentLoginVCCompletion:^{
        @strongify(self)
        
        ShowLoadingToView(self.view);
        @weakify(self)

        [self.viewModel requestAddressOrderSN:self.addressOrderSn completion:^(ZFAddressOMSOrderAddressModel *omsAddressModel, NSInteger status) {
            @strongify(self)
            HideLoadingFromView(self.view);
            
            self.hasingRequestSuccess = YES;
            self.isFirstNoError = YES;
            self.currentIndexPath = nil;
            [self.view endEditing:YES];
            
            if (status == 404) {
                [self orderAddressGetEditInforError];
            } else if (status != 1 || ZFIsEmptyString(omsAddressModel.country)) {
                [self orderAddressCanotEditMsg];
            } else {
                self.editModel.isSaveErrorFillZipTip = NO;
                self.editModel.addressline1 = ZFToString(omsAddressModel.address);
                self.editModel.addressline2 = ZFToString(omsAddressModel.address2);
                self.editModel.country_str = ZFToString(omsAddressModel.country);
                self.editModel.country_id = ZFToString(omsAddressModel.country_id);
                self.editModel.region_code = ZFToString(omsAddressModel.country_code);
                
                self.editModel.province = ZFToString(omsAddressModel.province);
                self.editModel.city = ZFToString(omsAddressModel.city);
                self.editModel.barangay = ZFToString(omsAddressModel.barangay);
                self.editModel.zipcode = ZFToString(omsAddressModel.zipcode);
                self.editModel.tel = ZFToString(omsAddressModel.tel);
                [self resetAddressZipFourTip:NO message:@""];
                [self resetAddressStateTip:NO message:@""];
                [self resetAddressCityTip:NO message:@""];
                
                if (omsAddressModel.data) {
                    
                    self.editModel.is_cod = omsAddressModel.data.is_cod;
                    self.editModel.ownState = omsAddressModel.data.ownState;
                    self.editModel.ownCity = omsAddressModel.data.ownCity;
                    self.editModel.ownBarangay = omsAddressModel.data.ownBarangay;
                    self.editModel.showFourLevel = omsAddressModel.data.showFourLevel;
                    self.hasProvince = self.editModel.ownState;
                    self.hasCity = self.editModel.ownCity;
                    self.hasVillage = self.editModel.ownBarangay;
                }
                
                self.sourceModel = [self.editModel mutableCopy];
                [self configAddressEditBookInfo];
            }
        }];
    } cancelCompetion:^{
        [self goBackActionOrder];
    }];
    
}

/// 保存订单地址修改
- (void)requestSaveOrderAddress {
    
    NSDictionary *parDic = @{@"order_sn"  : ZFToString(self.addressOrderSn),
                             @"landmark" : ZFToString(self.editModel.landmark),
                             @"country"   : ZFToString(self.editModel.region_code),
                             @"province"  : ZFToString(self.editModel.province),
                             @"city"      : ZFToString(self.editModel.city),
                             @"barangay"  : ZFToString(self.editModel.barangay),
                             @"zipcode"   : ZFToString(self.editModel.zipcode),
                             @"tel"       : ZFToString(self.editModel.tel),
                             @"address1"  : ZFToString(self.editModel.addressline1),
                             @"address2"  : ZFToString(self.editModel.addressline2)};
    
    ShowLoadingToView(self.view);
    @weakify(self)
    [self.viewModel requestSaveAddressOrder:parDic completion:^(NSString *msg,NSInteger status) {
        @strongify(self)
        HideLoadingFromView(self.view);
        if (status == 1) {
            [self orderAddressChangedSuccess];
        } else if (status == -1) {
            ShowToastToViewWithText(self.view, ZFToString(msg));
        } else {
            [self orderAddressSaveError:msg];
        }
    }];
}

/**
 * 新增地址时需要获取当前国家地址信息, 自动填充到地址栏
 */
- (void)requestCurrentCountryData {
    if (_model){
        return;
    }
    
    @weakify(self)
    [self.viewModel requestCountryName:^(NSDictionary *countryInfoDic) {
        @strongify(self)
        if (!countryInfoDic) {
            return ;
        }
        self.hasingRequestSuccess = YES;
        self.isFirstNoError = YES;
        self.currentIndexPath = nil;
        [self.view endEditing:YES];
        
        [ZFAddressEditManager configCurrentEdit:self.editModel countryData:countryInfoDic];
        self.country_code = self.editModel.region_code;
        self.hasProvince = self.editModel.ownState;
        self.hasCity = self.editModel.ownCity;
        self.sourceModel = [self.editModel mutableCopy];

        [self configAddressEditBookInfo];
        if (!self.hadEdit) {
            self.hadEdit = YES;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self firstNameBecomeFirstResponder];
            });
        }
        
        if (self.addressLocation) {
            YWLog(@"requesel : %@",self.addressLocation);
            [self requestLocationAddressInfor:self.addressLocation];
        }
    }];
}

//城市智能搜索
- (void)requestGoogleHintCity {
    
    if (ZFIsEmptyString(self.cityFilterTable.key)) {
        [self.cityFilterTable.cityDatas removeAllObjects];
        self.cityFilterTable.hidden = YES;
        [self.cityFilterTable reloadData];
        
    } else {
        
        NSDictionary *paramasCityDic = @{
                                         @"region_code" : ZFToString(self.country_code),
                                         @"province"    : ZFToString(self.editModel.province),
                                         @"province_id" : ZFToString(self.editModel.province_id),
                                         @"city"        : [NSStringUtils trimmingStartEndWhitespace:self.cityFilterTable.key]
                                         };
        NSString *currnetK = ZFToString(self.cityFilterTable.key);
        @weakify(self)
        [self.viewModel requestAddressGetCity:paramasCityDic completion:^(id obj) {
            @strongify(self)
            
            YWLog(@"--- curK: %@  tabkey: %@",currnetK,self.cityFilterTable.key);
            if ([self.cityFilterTable.key isEqualToString:currnetK]) {
                
                [self.cityFilterTable.cityDatas removeAllObjects];
                if ([obj isKindOfClass:[NSDictionary class]]) {
                    NSArray *cityList = obj[@"city_list"];
                    if ([cityList isKindOfClass:[NSArray class]]) {
                        for (NSDictionary *dic in cityList) {
                            ZFAddressHintCityModel *cityModel = [ZFAddressHintCityModel yy_modelWithJSON:dic];
                            [self.cityFilterTable.cityDatas addObject:cityModel];
                        }
                    }
                }
                [self.cityFilterTable setContentOffset:CGPointZero animated:NO];
                [self.cityFilterTable reloadData];
                if (self.cityFilterTable.cityDatas.count > 0) {
                    self.cityFilterTable.hidden = NO;
                } else {
                    self.cityFilterTable.hidden = YES;
                }
            }
        } failure:^(id obj) {
        }];
    }
}

//获取城市邮编
- (void)requestCityZipAutoFill:(BOOL)isAutoFill {
    
    NSString *country_code = ZFToString(self.country_code);
    NSString *state = ZFToString(self.editModel.province);
    NSString *city_name = ZFToString(self.editModel.city);
    NSString *towns = ZFToString(self.editModel.barangay);//区域
    
    if (ZFIsEmptyString(country_code) || ZFIsEmptyString(city_name)) {
        return;
    }
    
    NSString *countryCityKey = [NSString stringWithFormat:@"%@_%@_%@",country_code,city_name,towns];
    if ([self isHoldCityZip:countryCityKey]) {
        NSArray *cityZipArr = self.cityZipDic[countryCityKey];
        self.editModel.zipcode = ZFToString(cityZipArr.firstObject);
        [self.tableView reloadData];
        return;
    }
    
    NSDictionary *paramasCityDic = @{
                                     @"country_code" : country_code,
                                     @"city_name"    : city_name,
                                     @"state"        : state,
                                     @"towns"        : towns,
                                     @"user_ip"      : @""
                                     };
    
    ShowLoadingToView(self.view);
    @weakify(self)
    [self.viewModel requestCityZipAddress:paramasCityDic completion:^(id obj) {
        @strongify(self)
        HideLoadingFromView(self.view);
        
        if (ZFJudgeNSArray(obj)) {
            NSArray *zipArr = (NSArray *)obj;
            [self.cityZipDic setObject:obj forKey:countryCityKey];
            if (isAutoFill) {
                self.editModel.zipcode = ZFToString(zipArr.firstObject);
            }
        }
        [self.tableView reloadData];
    } failure:^(id obj) {
        HideLoadingFromView(self.view);
    }];
}

#pragma mark - 定位处理
// 定位获取填充
- (void)startUserLocation {
    
    CLAuthorizationStatus status = [[TZLocationManager manager] authorizationStatus];
    switch (status) {
        case kCLAuthorizationStatusAuthorizedAlways:
            YWLog(@"Always Authorized");
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            YWLog(@"AuthorizedWhenInUse");
            break;
        case kCLAuthorizationStatusDenied:
            YWLog(@"Denied");
            break;
        case kCLAuthorizationStatusNotDetermined:
            YWLog(@"not Determined");
            break;
        case kCLAuthorizationStatusRestricted:
            YWLog(@"Restricted");
            break;
        default:
            break;
    }
    
    if (_model) {//编辑地址时，不获取地位数据
        return;
    }
    
    @weakify(self)
    [[TZLocationManager manager] startLocationWithSuccessBlock:^(NSArray<CLLocation *> *locations) {
        YWLog(@"----cccccLocal: %@",locations);
        @strongify(self)
        self.addressLocation = locations.firstObject;
        if (self.hasingRequestSuccess) {
            [self requestLocationAddressInfor: self.addressLocation];
        }
    } failureBlock:^(NSError *error) {
    }];
}

- (void)requestLocationAddressInfor:(CLLocation *)location {
    if (self.isOrderUpdate) {
        return;
    }
    if (location) {
        NSNumber *lat = [NSNumber numberWithDouble:location.coordinate.latitude];
        NSNumber *lon = [NSNumber numberWithDouble:location.coordinate.longitude];
        NSString *latitude = [lat stringValue];
        NSString *longitude = [lon stringValue];
        NSDictionary *parmaters = @{@"latitude"  : latitude,
                                   @"longitude"  : longitude};
        
        [self.viewModel requestLocationAddress:parmaters completion:^(id obj) {
            if (obj && [obj isKindOfClass:[ZFAddressLocationInfoModel class]]) {
                [self autofillCountryCity:obj];
            }
        } failure:^(id obj) {}];
    }
}

- (void)autofillCountryCity:(ZFAddressLocationInfoModel *)infoModel {
    
    //已编辑城市了/国家简码不同，不自动填充
    if (self.hadEditCountryCity
        || ![ZFToString(infoModel.address_components.country_code) isEqualToString:self.country_code]
        || ZFIsEmptyString(infoModel.address_components.country_code)) {
        return ;
    }
    [ZFAddressEditManager autofillTable:self.tableView sourceData:self.dataArray editModel:self.editModel locationInfo:infoModel];
}

#pragma mark - action methods
//拦截返回按钮事件
-(void)goBackAction {
    
    //是否有地址搜索弹窗
    if (_googleVC.view.superview) {
        [_googleVC googleIntelligentizeAddressHideCompletion:nil];
        return;
    }
    
    BOOL isChange = [self isEditAddress];
    if (isChange) {
        NSString *title = ZFLocalizedString(@"ModifyAddress_save_address_before_leaving",nil);
        NSArray *btnArr = @[ZFLocalizedString(@"community_outfit_leave_confirm",nil)];
        NSString *cancelTitle = ZFLocalizedString(@"Leave",nil);
        
        ShowAlertView(title, nil, btnArr, ^(NSInteger buttonIndex, id title) {
            [self saveAddressButtonAction:nil];
        }, cancelTitle, ^(id cancelTitle) {
            [self.navigationController popViewControllerAnimated:YES];
        });
        
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)goBackActionOrder {
    //是否有地址搜索弹窗
    if (_googleVC.view.superview) {
        [_googleVC googleIntelligentizeAddressHideCompletion:nil];
        return;
    }
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)showCityFilterView:(BOOL)isShow {
    
    if (!self.cityFilterTable.superview) {
        [self.view addSubview:self.cityFilterTable];
    }
    
    if (self.currentIndexPath && isShow) {
        //防止网络请求成功时：self.currentIndexPath 设置成nil
        NSIndexPath *tempCurrentIndexPath = [self.currentIndexPath copy];
        ZFBaseEditAddressCell *baseCell = [self.tableView cellForRowAtIndexPath:tempCurrentIndexPath];
        if ([baseCell isKindOfClass:ZFAddressEditCityTableViewCell.class]) {
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //获取cell在tableView中的位置
                [self.cityFilterTable setContentOffset:CGPointZero animated:NO];
                self.cityFilterTable.hidden = self.cityFilterTable.cityDatas.count > 0 ? NO : YES;
                CGRect rectInTableView = [self.tableView rectForRowAtIndexPath:tempCurrentIndexPath];
                CGRect cellInView = [self.tableView convertRect:rectInTableView toView:WINDOW];
                self.cityFilterTable.frame = CGRectMake(0, (cellInView.origin.y + cellInView.size.height - 44 - kiphoneXTopOffsetY), KScreenWidth, KScreenHeight - (cellInView.origin.y + cellInView.size.height + self.keyboardHeight) );
            });
            return;
        }
    }
    self.cityFilterTable.hidden = !isShow;
}

/**
 * 第一个处于编辑状态
 */
- (void)firstNameBecomeFirstResponder {
    if (self.isOrderUpdate) {
        return;
    }
    [ZFAddressEditManager firstNameBecomeFirstResponderTable:self.tableView source:self.dataArray];
}

/**
 * 新增地址
 */
#pragma mark - 保存地址
- (void)saveAddressButtonAction:(UIButton *)sender {
    [self.view endEditing:YES];

    //先检查一遍，所有的输入是否已经合格。
    if (![self isCheckEnterInfoSuccess]) {
        [self.tableView reloadData];
        return ;
    }
    
    if (self.isOrderUpdate) {
        [self requestSaveOrderAddress];
        return;
    }
    
    //纠错暂时不验证电话相关
    NSDictionary *checkDic = @{
                               @"site"                   : @"ZZZZZ_ios",
                               @"firstname"              : [NSStringUtils trimmingStartEndWhitespace:self.editModel.firstname],
                               @"lastname"               : [NSStringUtils trimmingStartEndWhitespace:self.editModel.lastname],
                               //@"tel"                    : [NSStringUtils trimmingStartEndWhitespace:self.editModel.tel],
                               @"region_code"            : ZFToString(self.country_code),
                               @"region_id"              : ZFToString(self.editModel.country_id),
                               @"province"               : [NSStringUtils trimmingStartEndWhitespace:self.editModel.province],
                               @"province_id"            : ZFToString(self.editModel.province_id),
                               @"city"                   : [NSStringUtils trimmingStartEndWhitespace:self.editModel.city],
                               @"addressline1"           : [NSStringUtils trimmingStartEndWhitespace:self.editModel.addressline1],
                               @"addressline2"           : [NSStringUtils trimmingStartEndWhitespace:self.editModel.addressline2],
                               @"code"                   : ZFToString(self.editModel.code),
                               @"supplier_number"        : [NSStringUtils isEmptyString:self.editModel.supplier_number withReplaceString:@""],
                               @"supplier_number_spare"  : [NSStringUtils trimmingStartEndWhitespace:self.editModel.supplier_number_spare],
                               @"telspare"               : [NSStringUtils trimmingStartEndWhitespace:self.editModel.telspare],
                               @"zipcode"                : ZFToString(self.editModel.zipcode),
                               @"token"                  : ZFToString(TOKEN),
                               kLoadingView              :  self.view
                           };
    
    //地址纠错判断
    ShowLoadingToView(self.view);
    @weakify(self)
    [self.viewModel requestCheckShippingAddress:checkDic completion:^(id obj) {
        @strongify(self)
        if (obj && [obj isKindOfClass:[ZFCheckShippingAddressModel class]]) {
            HideLoadingFromView(self.view);
            ZFCheckShippingAddressModel *checkModel = (ZFCheckShippingAddressModel *)obj;
            [self.addressCheckView showView:checkModel];
        } else {
            [self saveAddressConfirm:nil];
        }
    } failure:^(id obj) {
        @strongify(self)
        [self saveAddressConfirm:nil];
    }];
    
}

- (void)saveAddressConfirm:(ZFCheckShippingAddressModel *)checkModel {
    
    if (self.isOrderUpdate) {
        [self requestSaveOrderAddress];
        return;
    }
    //纠错暂时不验证电话相关
    
    NSString *country_code = ZFToString(self.country_code);
    NSString *country_id = ZFToString(self.editModel.country_id);
    NSString *province = ZFToString(self.editModel.province);
    NSString *province_id = ZFToString(self.editModel.province_id);
    NSString *addressline1 = [NSStringUtils trimmingStartEndWhitespace:self.editModel.addressline1];
    NSString *addressline2 = [NSStringUtils trimmingStartEndWhitespace:self.editModel.addressline2];
    NSString *zipCode = ZFToString(self.editModel.zipcode);
    NSString *city = ZFToString(self.editModel.city);
    NSString *code = ZFToString(self.editModel.code);
    
    if (checkModel) {
        if (checkModel.suggested_address.isMark) {
            country_code = ZFToString(checkModel.suggested_address.region_code);
            province_id = ZFToString(checkModel.suggested_address.province_id);
            province = ZFToString(checkModel.suggested_address.province);
            addressline1 = [NSStringUtils trimmingStartEndWhitespace:checkModel.suggested_address.addressline1];
            addressline2 = [NSStringUtils trimmingStartEndWhitespace:checkModel.suggested_address.addressline2];
            zipCode = ZFToString(checkModel.suggested_address.zipcode);
            city = ZFToString(checkModel.suggested_address.city);
            country_id = ZFToString(checkModel.suggested_address.region_id);
            //暂时后台没验证
            if (!ZFIsEmptyString(checkModel.suggested_address.code)) {
                //code = ZFToString(checkModel.suggested_address.code);
            }
        }
    }
    
    //内容的去掉首尾空格
    NSDictionary *dict = @{
                           @"address_id"             : ZFToString(self.editModel.address_id),
                           @"firstname"              : [NSStringUtils trimmingStartEndWhitespace:self.editModel.firstname],
                           @"lastname"               : [NSStringUtils trimmingStartEndWhitespace:self.editModel.lastname],
                           @"email"                  : [NSStringUtils trimmingStartEndWhitespace:self.editModel.email],
                           @"tel"                    : [NSStringUtils trimmingStartEndWhitespace:self.editModel.tel],
                           @"id_card"                : [NSStringUtils isEmptyString:self.editModel.id_card withReplaceString:@""],
                           @"country"                : country_id,
                           @"province"               : province,
                           @"city"                   : city,
                           @"addressline1"           : addressline1,
                           @"addressline2"           : addressline2,
                           @"zipcode"                : zipCode,
                           @"code"                   : code,
                           @"supplier_number"        : [NSStringUtils isEmptyString:self.editModel.supplier_number withReplaceString:@""],
                           @"landmark"               : [NSStringUtils trimmingStartEndWhitespace:self.editModel.landmark],
                           @"telspare"               : [NSStringUtils trimmingStartEndWhitespace:self.editModel.telspare],
                           @"whatsapp"               : [NSStringUtils trimmingStartEndWhitespace:self.editModel.whatsapp],
                           @"supplier_number_spare"  : [NSStringUtils trimmingStartEndWhitespace:self.editModel.supplier_number_spare],
                           @"google_longitude"       : ZFToString(self.editModel.google_longitude),
                           @"google_latitude"        : ZFToString(self.editModel.google_latitude),
                           @"token"                  : ZFToString(TOKEN),
                           @"set_as_default_address" : self.isFromOrderCheckEdit ? @(YES) : @(self.set_as_default_address),
                           @"barangay"               : ZFToString(self.editModel.barangay),
                           kLoadingView   :  self.view
                           };
    
    @weakify(self)
    [self.viewModel requestNetwork:dict completion:^(id obj) {
        @strongify(self)
        HideLoadingFromView(self.view);
        if (self.addressEditSuccessCompletionHandler) {

            if (self.sourceCart) {
                self.addressEditSuccessCompletionHandler(AddressEditStateSuccess);
            } else {
                
                ZFAddressViewController *addressVC;
                NSArray *subVCs = self.navigationController.viewControllers;
                for (UIViewController *vc in subVCs) {
                    YWLog(@"-----1");
                    if ([vc isKindOfClass:[ZFAddressViewController class]]) {
                        addressVC = (ZFAddressViewController *)vc;
                        break;
                    }
                }
                
                if (self.model) {//更新国家id
                    self.model.country_id = ZFToString(country_id);
                }
                
                // v5.4.0 如果是订单结算页编辑地址的，直接返回的订单结算页
                if (subVCs.firstObject == addressVC && [obj[@"address_id"] integerValue] > 0 && self.isFromOrderCheckEdit) {//因为订单结算页是模态到地址列表的
                    NSString *address_id = [NSString stringWithFormat:@"%@",obj[@"address_id"]];
                    ZFAddressInfoModel *infoModel = [[ZFAddressInfoModel alloc] init];
                    infoModel.address_id = address_id;
                    infoModel.country_id = ZFToString(country_id);
                    // 编辑就返回编辑的地址
                    [addressVC backUpperVC:self.model ? self.model : infoModel];
                } else {
                    self.addressEditSuccessCompletionHandler(self.model ? AddressEditStateSuccess : AddressEditStateFail);
                }
                
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
    } failure:^(id obj) {
        @strongify(self)

        HideLoadingFromView(self.view);
        if (ZFJudgeNSDictionary(obj)) {
            [self handleAddressErrorClear:obj];
        }
    }];
}

- (void)handleAddressErrorClear:(NSDictionary *)dic {
    
    NSDictionary *dataDic = dic[@"data"];
    NSString *msg = dataDic[@"msg"];
    if (!ZFJudgeNSDictionary(dataDic)) {
        return;
    }
    
    self.editModel.isSaveErrorFillZipTip = NO;
    //不统一呀
    NSString *blank = !ZFIsEmptyString(dataDic[@"blank"]) ? dataDic[@"blank"] : dataDic[@"code"];
    
    // 菲律宾国家地址需要清空city 验证 blank='11'
    // 菲律宾国家的需要清空州省验证 blank ='12'
    // 菲律宾国家地址需要验证邮编 不需要清空 保持四位 blank ='10'
    if ([blank isEqualToString:@"11"] || [blank isEqualToString:@"12"]) {
        
        ZFAddressEditTypeModel *stateModel = [ZFAddressEditManager editTypeModelSource:self.dataArray editType:ZFAddressEditTypeState];
        NSIndexPath *stateIndexPath = [ZFAddressEditManager indexPathModelSource:self.dataArray editTypeModel:stateModel];
        
        ZFAddressEditTypeModel *cityModel = [ZFAddressEditManager editTypeModelSource:self.dataArray editType:ZFAddressEditTypeCity];
        NSIndexPath *cityIndexPath = [ZFAddressEditManager indexPathModelSource:self.dataArray editTypeModel:cityModel];
        
        ZFAddressEditTypeModel *barangayModel = [ZFAddressEditManager editTypeModelSource:self.dataArray editType:ZFAddressEditTypeVillage];
        NSIndexPath *barangayIndexPath = [ZFAddressEditManager indexPathModelSource:self.dataArray editTypeModel:barangayModel];
        
        if (stateIndexPath) {
            if ([blank isEqualToString:@"12"]) {
                stateModel.rowHeight = kZFAddressCellTipsErrorHeight;
                stateModel.isShowTips = YES;
                [self resetAddressStateTip:YES message:ZFToString(msg)];
            }
        }
        if (cityIndexPath) {
            if ([blank isEqualToString:@"11"]) {
                cityModel.rowHeight = kZFAddressCellTipsErrorHeight;
                cityModel.isShowTips = YES;
                [self resetAddressCityTip:YES message:ZFToString(msg)];
            }

        }
        
        // v452 需求定的，全清空
        if (self.checkPHAddress) {
            self.editModel.province = @"";
            self.editModel.city = @"";
            self.editModel.barangay = @"";
            
            if (stateIndexPath) {
                stateModel.rowHeight = kZFAddressCellTipsErrorHeight;
                stateModel.isShowTips = YES;
            }
            
            if (cityIndexPath) {
                cityModel.rowHeight = kZFAddressCellTipsErrorHeight;
                cityModel.isShowTips = YES;
            }
            
            if (barangayIndexPath) {
                barangayModel.rowHeight = kZFAddressCellTipsErrorHeight;
                barangayModel.isShowTips = YES;
            }
        }
        [self.tableView reloadData];
    
    } else if([blank isEqualToString:@"10"]) {
        
        ZFAddressEditTypeModel *zipModel = [ZFAddressEditManager editTypeModelSource:self.dataArray editType:ZFAddressEditTypeZipCode];
        NSIndexPath *indexPath = [ZFAddressEditManager indexPathModelSource:self.dataArray editTypeModel:zipModel];
        NSArray *postcodeArray = dataDic[@"postcode"];
        NSString *postcode = @"";
        if (ZFJudgeNSArray(postcodeArray) && postcodeArray.count > 0) {
            postcode = postcodeArray.firstObject;
        }
        if (!ZFIsEmptyString(postcode)) {
            
            //提示地址信息错误，通过修改弹窗跳转至编辑页时，将正确的邮编填充至输入框，且提示相关文案。
            self.editModel.isSaveErrorFillZipTip = YES;
            self.editModel.zipcode = postcode;
            self.editModel.saveErrorFillZipMsg = ZFToString(msg);
            [self.tableView reloadData];
            
        } else {
            
            if (indexPath) {
                zipModel.rowHeight = kZFAddressCellTipsErrorHeight;
                zipModel.isShowTips = YES;
                
                [self resetAddressZipFourTip:YES message:ZFToString(msg)];
                [self.tableView reloadData];
            }
        }
    }
}

//编辑纠错推荐地址
- (void)checkEditSuggestAddress:(ZFCheckShippingAddressModel *)checkAddressModel {
    if (checkAddressModel) {
        if (checkAddressModel.suggested_address) {
            self.country_code = ZFToString(checkAddressModel.suggested_address.region_code);
            self.editModel.region_code = self.country_code;
            self.editModel.country_id = ZFToString(checkAddressModel.suggested_address.region_id);
            self.editModel.country_str = ZFToString(checkAddressModel.suggested_address.country);
            self.editModel.province_id = ZFToString(checkAddressModel.suggested_address.province_id);
            self.editModel.province = ZFToString(checkAddressModel.suggested_address.province);
            self.editModel.addressline1 = ZFToString(checkAddressModel.suggested_address.addressline1);
            self.editModel.addressline2 = ZFToString(checkAddressModel.suggested_address.addressline2);
            self.editModel.city = ZFToString(checkAddressModel.suggested_address.city);
            
            self.editModel.zipcode = ZFToString(checkAddressModel.suggested_address.zipcode);
            self.editModel.code = ZFToString(checkAddressModel.suggested_address.code);
            self.editModel.isSaveErrorFillZipTip = NO;
            
            
            [self.tableView reloadData];
        }
    }
}

// 显示了zip四位错误提示，就需要判断是否编辑了国家、州、省、城镇、邮编，然后重置
- (void)resetAddressZipFourTip:(BOOL)isTip message:(NSString *)message{
    
    self.editModel.isZipFourTip = isTip;
    self.editModel.zipFourTipMsg = ZFToString(message);
    self.editModel.isSaveErrorFillZipTip = NO;

//    if (!isTip) {
//        // 是否编辑 重置状态
//        self.isEditCountryStateCity = NO;
//    }
}

- (void)resetAddressStateTip:(BOOL)isTip message:(NSString *)message{
    
    self.editModel.isStateTip = isTip;
    self.editModel.stateTipMsg = ZFToString(message);
}


- (void)resetAddressCityTip:(BOOL)isTip message:(NSString *)message{
    
    self.editModel.isCityTip = isTip;
    self.editModel.cityTipMsg = ZFToString(message);
}



- (void)selectPhoneSupplierNumberWithType:(ZFAddressEditTypeModel *)typeModel {
    [self.view endEditing:YES];
    NSArray *dataSource = self.editModel.supplier_number_list;
    
    @weakify(self)
    self.pickerView = [[DLPickerView alloc] initWithDataSource:dataSource withSelectedItem:nil withSelectedBlock:^(id selectedItem) {
        @strongify(self);
        if (typeModel.editType == ZFAddressEditTypePhoneNumber) {
            self.editModel.supplier_number = selectedItem;

            // 号码长度在数组返回长度之内才通过
            NSArray *scutNumberArr = self.editModel.scut_number_list;
            NSString *telLengthStr = [NSString stringWithFormat:@"%zd",self.editModel.tel.length];
            
            BOOL isOk = YES;
            if (self.editModel.supplier_number_list.count > 0 && self.editModel.supplier_number.length <= 0) {
                typeModel.rowHeight = kZFAddressCellTipsErrorHeight;
                typeModel.isShowTips = YES;
                isOk = NO;
            }
            
            if(self.editModel.tel.length <= 0){
                typeModel.rowHeight = kZFAddressCellTipsErrorHeight;
                typeModel.isShowTips = YES;
                isOk = NO;
            }
            if (isOk) {
                typeModel.rowHeight = kZFAddressCellNormalHeight;
                typeModel.isShowTips = NO;
            }
            
            if ([scutNumberArr containsObject:telLengthStr]) {
                [ZFAddressEditManager editAddressInfoModel:self.editModel whatApp:[NSString stringWithFormat:@"%@%@", self.editModel.supplier_number, self.editModel.tel]];
            }
            
        } else {
            self.editModel.supplier_number_spare = selectedItem;
        }
        [self.tableView reloadData];
    }];
    self.pickerView.shouldDismissWhenClickShadow = YES;
    [self.pickerView show];
}

- (void)configAddressEditBookInfo {
    [ZFAddressEditManager configAddressEditBookInfo:self.dataArray infoModel:self.editModel village:self.hasVillage isOrderUpdate:self.isOrderUpdate];
    
    if ([self.editModel isTestCountry] && [self.editModel isContainSpecialEmailMarkFirstAddressLine]) {
        
        ZFAddressEditTypeModel *firstAddressModel = [ZFAddressEditManager editTypeModelSource:self.dataArray editType:ZFAddressEditTypeAddressFirst];
        firstAddressModel.isShowTips = YES;
        firstAddressModel.rowHeight = kZFAddressCellTipsErrorHeight;
    }
    [self.tableView reloadData];
}


#pragma mark - <UITableViewDelegate, UITableViewDataSource>

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.hadEdit = YES;
    if (self.cityFilterTable.hidden == NO && self.cityFilterTable != scrollView) {
        self.cityFilterTable.hidden = YES;
        [self.view endEditing:YES];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.dataArray.count > section) {
        NSArray *grouDatas = self.dataArray[section];
        return grouDatas.count;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        if (self.isOrderUpdate) {
            return self.addressNoPayOrder ? 12 : 0.001;
        }
        return 12;
    }
    return 0.001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 12;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footer = [[UIView alloc] init];
    return footer;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *header = [[UIView alloc] init];
    return header;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ZFBaseEditAddressCell *cell;
    ZFAddressEditTypeModel *model = [self editTypeModelIndexPath:indexPath];
    
    if (model) {
        
        NSString *cellId = [ZFAddressEditManager currentCellIdentifier:model.editType];
        cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
        if (!cell) {
            return [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
        }
        cell.myDelegate = self;
        if (model.editType == ZFAddressEditTypeCity) {
            [cell updateInfo:self.editModel typeModel:model hasUpperLevel:self.hasCity];
            
        } else if(model.editType == ZFAddressEditTypeState) {
            [cell updateInfo:self.editModel typeModel:model hasUpperLevel:self.hasProvince];
            
        } else if(model.editType == ZFAddressEditTypeVillage) {
            [cell updateInfo:self.editModel typeModel:model hasUpperLevel:self.hasVillage];
            
        } else if(model.editType == ZFAddressEditTypeZipCode) {
            ZFAddressEditZipCodeTableViewCell *zipCell = (ZFAddressEditZipCodeTableViewCell *)cell;
            self.zipIndexPath = indexPath;
            
            NSString *country_code = ZFToString(self.country_code);
            NSString *city_name = ZFToString(self.editModel.city);
            NSString *town_name = ZFToString(self.editModel.barangay);
            
            NSArray *cityZipArr;
            if (!ZFIsEmptyString(country_code) && !ZFIsEmptyString(city_name)) {
                
                NSString *countryCityKey = [NSString stringWithFormat:@"%@_%@_%@",country_code,city_name,town_name];
                if ([self isHoldCityZip:countryCityKey]) {
                    cityZipArr = self.cityZipDic[countryCityKey];
                }
            }
            [zipCell updateInfo:self.editModel typeModel:model zips:cityZipArr];
        }
        else {
            [cell updateInfo:self.editModel typeModel:model];
        }
        return cell;
    }
    
    return [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.dataArray.count > indexPath.section) {
        NSArray *grouDatas = self.dataArray[indexPath.section];
        if (grouDatas.count > indexPath.row) {
            ZFAddressEditTypeModel *model = grouDatas[indexPath.row];
            
            if (model.editType == ZFAddressEditTypeZipCode) {
                
                if (self.editModel.isSaveErrorFillZipTip) {
                    model.isShowFillZipTips = self.editModel.isSaveErrorFillZipTip;
                    model.rowHeight = kZFAddressCellTipsErrorHeight;
                } else {
                    model.isShowFillZipTips = NO;
                    if(model.rowHeight > kZFAddressCellNormalHeight && !model.isShowTips) {
                        model.rowHeight = kZFAddressCellNormalHeight;
                    }
                }
            }

            
            return model.rowHeight;
        }
    }
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.hadEdit = YES;
    [self.view endEditing:YES];
    
    if (self.dataArray.count > indexPath.section) {
        NSArray *grouDatas = self.dataArray[indexPath.section];
        self.currentIndexPath = [indexPath copy];
        
        if (grouDatas.count > indexPath.row) {
            
            ZFAddressEditTypeModel *model = grouDatas[indexPath.row];
            if (model.editType == ZFAddressEditTypeAddressFirst) {
                [self googleAddressSearch];
                
            } else if (model.editType == ZFAddressEditTypeCountry) {
                [self selectCountryStateCityVillage:ZFAddressEditTypeCountry];
                
            } else if (model.editType == ZFAddressEditTypeState) {
                //先判断是否有选国家，国家下是否有省份
                if (self.editModel.country_id) {
                    [self selectCountryStateCityVillage:ZFAddressEditTypeState];
                }
            } else if (model.editType == ZFAddressEditTypeCity) {
                if (self.editModel.country_id) {
                    [self selectCountryStateCityVillage:ZFAddressEditTypeCity];
                }
            }  else if (model.editType == ZFAddressEditTypeVillage) {
                if (self.editModel.country_id) {
                    [self selectCountryStateCityVillage:ZFAddressEditTypeVillage];
                }
            } else if (model.editType == ZFAddressEditTypeZipCode) {
                //是否选中城市邮编
                [self selectCityZip:model];
            }
        }
    }
    
}


//取消那些显示最大值错误提示
- (void)updateTableIndexPaths:(NSArray *)indexPaths typeModel:(ZFAddressEditTypeModel *)typeModel {
    
    if (self.isFirstNoError) {//请求成功后，若有正在编辑时，不处理cell自己结束编辑的提示刷新
        self.isFirstNoError = NO;
        return;
    }
    
    NSMutableArray *reloadGroups = [[NSMutableArray alloc] init];
    for (int i=0; i<self.dataArray.count; i++) {
        NSArray *groudDatas = self.dataArray[i];
        for (int j=0; j<groudDatas.count; j++) {
            ZFAddressEditTypeModel *model = groudDatas[j];
            if (model.isShowTips && model.isOverMax && model.editType != typeModel.editType) {
                model.isShowTips = NO;
                model.isOverMax = NO;
                model.rowHeight = kZFAddressCellNormalHeight;
                if (model.editType == ZFAddressEditTypeWhatsApp) {
                    model.rowHeight = kZFAddressCellWhatsAppNormalHeight;
                }
                NSIndexPath *dataIndexPath = [NSIndexPath indexPathForRow:j inSection:i];
                [reloadGroups addObject:dataIndexPath];
            }
        }
    }
    
    if (!typeModel.isEditing) {
        [reloadGroups addObjectsFromArray:indexPaths];
    }
    if (reloadGroups.count > 0 && self.dataArray.count > 0) {
        [self.tableView reloadRowsAtIndexPaths:reloadGroups withRowAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark - <ZFBaseEditAddressCellDelegate>

//只针对电话选择
- (void)editAddressCell:(ZFBaseEditAddressCell *)cell showTips:(BOOL)showTips content:(NSString *)content resultTell:(NSString *)resultTel {
    self.hadEdit = YES;
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    ZFAddressEditTypeModel *model = [self editTypeModelIndexPath:indexPath];
    if (model && indexPath) {
        [ZFAddressEditManager updateAddressInfoModel:self.editModel editTypeModel:model content:content];
        
        if (model.editType == ZFAddressEditTypePhoneNumber) {//必填电话
            [ZFAddressEditManager editAddressInfoModel:self.editModel whatApp:resultTel];
            model.isShowTips = showTips;
            model.rowHeight = showTips ? kZFAddressCellTipsErrorHeight : kZFAddressCellNormalHeight;
            
            NSInteger whatappRow = indexPath.row + 2;
            NSMutableArray *indexPaths = [NSMutableArray new];
            
            NSArray *sectionDatas = self.dataArray[indexPath.section];
            if (whatappRow < sectionDatas.count) {
                NSIndexPath *whatAppIndexPath = [NSIndexPath indexPathForRow:whatappRow inSection:indexPath.section];
                [indexPaths addObjectsFromArray:@[whatAppIndexPath, indexPath]];
            } else {
                [indexPaths addObjectsFromArray:@[indexPath]];
            }
            model.isEditing = NO;
            [self updateTableIndexPaths:indexPaths typeModel:model];
            
        } else if(model.editType == ZFAddressEditTypeAlternatePhoneNumber) { //选填电话
            
            model.isShowTips = showTips;
            model.rowHeight = showTips ? kZFAddressCellTipsErrorHeight : kZFAddressCellNormalHeight;
            model.isEditing = NO;
            [self updateTableIndexPaths:@[indexPath] typeModel:model];
        }
    }
}

//只针对一个点击事件
- (void)editAddressCell:(ZFBaseEditAddressCell *)cell selectEvent:(BOOL)flag {
    self.hadEdit = YES;
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    ZFAddressEditTypeModel *model = [self editTypeModelIndexPath:indexPath];
    if (model) {
        if (model.editType == ZFAddressEditTypePhoneNumber
            || model.editType == ZFAddressEditTypeAlternatePhoneNumber) {
            [self selectPhoneSupplierNumberWithType:model];
            
        } else if(model.editType == ZFAddressEditTypeNationalId) {
            
            NSString *cardIntroURL = [YWLocalHostManager appCardIntroURL];
            AlertWebView *alertWeb = [[AlertWebView alloc] initWithUrlStr:[NSString stringWithFormat:cardIntroURL, [ZFLocalizationString shareLocalizable].nomarLocalizable]];
            [alertWeb show];
            
        } else if(model.editType == ZFAddressEditTypeSetDefault) {//默认地址选择事件
            self.set_as_default_address = flag;
            
        } else if(model.editType == ZFAddressEditTypeZipCode) {//选择邮编
            [self selectCityZip:model];
        }
        
    }
}

//只针对电话选
- (void)editAddressCell:(ZFBaseEditAddressCell *)cell selectFirstTips:(BOOL)flag {
    self.hadEdit = YES;
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    ZFAddressEditTypeModel *model = [self editTypeModelIndexPath:indexPath];
    if (model) {
        if (model.editType == ZFAddressEditTypePhoneNumber
            || model.editType == ZFAddressEditTypeAlternatePhoneNumber) {
            
            //提示用户先选择国家
            FFToast *toast = [[FFToast alloc] initToastWithTitle:nil message:ZFLocalizedString(@"ModifyAddressViewController_phone_message", nil) iconImage:nil];
            toast.toastType = FFToastTypeSuccess;
            toast.toastPosition = FFToastPositionBelowStatusBarWithFillet;
            toast.toastBackgroundColor = ZFCOLOR(202, 67, 67, 1);
            [toast show:^{
                [toast dismissCentreToast];
            }];
        }
    }
}

- (void)editAddressCell:(ZFBaseEditAddressCell *)cell showTips:(BOOL)showTips overMax:(BOOL)overMax content:(NSString *)content {
    self.hadEdit = YES;
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    ZFAddressEditTypeModel *model = [self editTypeModelIndexPath:indexPath];
    
    if (model && indexPath) {
                
        if (model.editType == ZFAddressEditTypeState && self.editModel.isStateTip) {
            if (![self.editModel.province isEqualToString:content]) {
                model.rowHeight = kZFAddressCellNormalHeight;
                model.isShowTips = NO;
                [self resetAddressStateTip:NO message:@""];
            }
        }
        if (model.editType == ZFAddressEditTypeCity && self.editModel.isCityTip) {
            if (![self.editModel.city isEqualToString:content]) {
                model.rowHeight = kZFAddressCellNormalHeight;
                model.isShowTips = NO;
                [self resetAddressCityTip:NO message:@""];
            }
        }
        
        if (model.editType == ZFAddressEditTypeZipCode && self.editModel.isZipFourTip) {
            model.rowHeight = kZFAddressCellNormalHeight;
            model.isShowTips = NO;
            [self resetAddressZipFourTip:NO message:@""];
        }
        
        model.isShowTips = showTips;
        model.isOverMax = overMax;
        model.rowHeight = showTips ? kZFAddressCellTipsErrorHeight : kZFAddressCellNormalHeight;
        [ZFAddressEditManager updateAddressInfoModel:self.editModel editTypeModel:model content:content];

        if (showTips) {
            model.isEditing = NO;
            [self updateTableIndexPaths:@[indexPath] typeModel:model];
        }
    }
}


//cell编辑内容
- (void)editAddressCell:(ZFBaseEditAddressCell *)cell cancelMaxContent:(NSString *)content {
    self.hadEdit = YES;
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    ZFAddressEditTypeModel *model = [self editTypeModelIndexPath:indexPath];
    if (model && indexPath) {
        
        NSMutableArray *indexsArray = [[NSMutableArray alloc] init];
        model.rowHeight = kZFAddressCellNormalHeight;
        model.isShowTips = NO;
        model.isOverMax = NO;
        model.isEditing = NO;
        
        if (model.editType == ZFAddressEditTypeState && self.editModel.isStateTip) {
            model.rowHeight = kZFAddressCellTipsErrorHeight;
            model.isShowTips = YES;
        }
        if (model.editType == ZFAddressEditTypeCity && self.editModel.isCityTip) {
            model.rowHeight = kZFAddressCellTipsErrorHeight;
            model.isShowTips = YES;
        }
        
        if (model.editType == ZFAddressEditTypeZipCode && self.editModel.isZipFourTip) {
            model.rowHeight = kZFAddressCellTipsErrorHeight;
            model.isShowTips = YES;
            model.isShowFillZipTips = NO;
            self.editModel.isSaveErrorFillZipTip = NO;
        }
 
        [indexsArray addObject:indexPath];
        
        [ZFAddressEditManager updateAddressInfoModel:self.editModel editTypeModel:model content:content];
        [self updateTableIndexPaths:indexsArray typeModel:model];
    }
}

//cell编辑状态
- (void)editAddressCell:(ZFBaseEditAddressCell *)cell isEditing:(BOOL)isEditing {
    self.hadEdit = YES;
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    ZFAddressEditTypeModel *model = [self editTypeModelIndexPath:indexPath];
    self.currentIndexPath = [indexPath copy];
    
    if (model.editType == ZFAddressEditTypeCountry
        || model.editType == ZFAddressEditTypeState
        || model.editType == ZFAddressEditTypeCity
        || model.editType == ZFAddressEditTypeVillage) {
        self.hadEditCountryCity = YES;
    }
    if (model && indexPath) {
        model.isEditing = isEditing;
        if (isEditing) {
            [self updateTableIndexPaths:@[indexPath] typeModel:model];
        }
    }
}

//实时编辑内容
- (void)editAddressCell:(ZFBaseEditAddressCell *)cell editContent:(NSString *)content {
    self.hadEdit = YES;
    
    if ([cell isKindOfClass:ZFAddressEditCityTableViewCell.class]) {
        if (self.currentIndexPath) {
            
            //防止网络请求成功时：self.currentIndexPath 设置成nil
            NSIndexPath *tempCurrentIndexPath = [self.currentIndexPath copy];
            UITableViewCell *tempCell = [self.tableView cellForRowAtIndexPath:tempCurrentIndexPath];
            if (!tempCell) {
                return;
            }
            self.cityFilterTable.key = content;
            if (self.cityFilterTable.origin.y > 150 || self.cityFilterTable.size.height <= 10) {//滚动不上去的时候
                
                NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:tempCurrentIndexPath.row - 1 inSection:tempCurrentIndexPath.section];
                CGRect currentRect = [self.tableView rectForRowAtIndexPath:lastIndexPath];
                
                [self.tableView setContentOffset:CGPointMake(0, CGRectGetMaxY(currentRect)) animated:YES];
                [self showCityFilterView:YES];
                YWLog(@"-------目标: %li,contentH:%f",(long)lastIndexPath.row,self.tableView.contentSize.height);
            }
            
            //获取智能相联城市数据
            if (content.length >= 3) {
                self.lastInputTimer = [[NSDate date] timeIntervalSince1970];
                dispatch_source_t oldTimer = [self.dispatchOperations objectForKey:@"timer"];
                if (!oldTimer) {
                    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
                    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC, 0.1 * NSEC_PER_SEC);
                    dispatch_source_set_event_handler(timer, ^{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSTimeInterval nowInterval = [[NSDate date] timeIntervalSince1970];
                            if (nowInterval - self.lastInputTimer > 0.8) {
                                dispatch_suspend(timer);
                                dispatch_source_cancel(timer);
                                [self.dispatchOperations removeObjectForKey:@"timer"];
                                [self requestGoogleHintCity];
                            }
                        });
                    });
                    dispatch_resume(timer);
                    [self.dispatchOperations setObject:timer forKey:@"timer"];
                }
            } else if(content.length <= 0) {
                [self requestGoogleHintCity];
            }
        }
    }
}

- (void)editAddressCell:(ZFBaseEditAddressCell *)cell showBottomPlaceholderTip:(BOOL)show {
    
    NSIndexPath *addressLine2IndexPath = [self.tableView indexPathForCell:cell];
    ZFAddressEditTypeModel *typeModel = [self editTypeModelIndexPath:addressLine2IndexPath];
    typeModel.isShowBottomTip = YES;
    typeModel.isShowTips = YES;
    typeModel.rowHeight = kZFAddressCellTipsErrorHeight;
    
    // occ测试数据
    [self updateTableIndexPaths:@[addressLine2IndexPath] typeModel:typeModel];
}

//获取选择数据模型
- (ZFAddressEditTypeModel *)editTypeModelIndexPath:(NSIndexPath *)indexPath {
    ZFAddressEditTypeModel *typeModel = [ZFAddressEditManager editTypeModelSource:self.dataArray indexPath:indexPath];
    return typeModel;
}

#pragma mark - 选择国家、城市

- (void)selectCountryStateCityVillage:(ZFAddressEditType)editType {
    
    ZFAddressCountryCitySelectVC *selectCtrl = [[ZFAddressCountryCitySelectVC alloc] init];
    
    ZFAddressLibraryCountryModel *countryModel = [[ZFAddressLibraryCountryModel alloc] init];
    countryModel.n = ZFToString(self.editModel.country_str);
    [countryModel handleSelfKey];

    ZFAddressLibraryStateModel *stateModel = [[ZFAddressLibraryStateModel alloc] init];
    stateModel.n = ZFToString(self.editModel.province);
    [stateModel handleSelfKey];
    
    ZFAddressLibraryCityModel *cityModel = [[ZFAddressLibraryCityModel alloc] init];
    cityModel.n = ZFToString(self.editModel.city);
    [cityModel handleSelfKey];
    
    ZFAddressLibraryTownModel *villageModel = [[ZFAddressLibraryTownModel alloc] init];
    villageModel.n = ZFToString(self.editModel.barangay);
    [villageModel handleSelfKey];
    
    selectCtrl.countryModel = countryModel;
    selectCtrl.stateModel = stateModel;
    selectCtrl.cityModel = cityModel;
    selectCtrl.townModel = villageModel;
    selectCtrl.isOrderUpdate = self.isOrderUpdate;

    if (editType == ZFAddressEditTypeCountry) {
        selectCtrl.selectIndex = 0;
    } else if (editType == ZFAddressEditTypeState) {
        selectCtrl.selectIndex = 1;
    } else if (editType == ZFAddressEditTypeCity) {
        selectCtrl.selectIndex = 2;
    } else if (editType == ZFAddressEditTypeVillage) {
        selectCtrl.selectIndex = 3;
    }
    
    @weakify(self)
    selectCtrl.addressCountrySelectCompletionHandler = ^(ZFAddressLibraryCountryModel *countryModel, ZFAddressLibraryStateModel *stateModel, ZFAddressLibraryCityModel *cityModel, ZFAddressLibraryTownModel *villageModel) {
        @strongify(self)
        
        self.hadEditCountryCity = YES;
        self.selectStateModel = [ZFAddressLibraryManager transformLibraryState:stateModel];
        self.editModel.province = self.selectStateModel.name;
        self.editModel.province_id = self.selectStateModel.stateId;
        self.selectCityModel = [ZFAddressLibraryManager transformLibraryCity:cityModel];
        self.editModel.city = self.selectCityModel.name;
        self.selectVillageModel = [ZFAddressLibraryManager transformLibraryTown:villageModel];
        
        // 只要选择了，就重置
        self.editModel.isSaveErrorFillZipTip = NO;
        if (!ZFIsEmptyString(self.editModel.barangay) && [self.editModel.barangay isEqualToString:self.selectVillageModel.barangay]) {
        } else {
            self.editModel.zipcode = @"";
        }
        self.editModel.barangay = self.selectVillageModel.barangay;
        
        self.hasProvince = countryModel.provinceList.count > 0 ? YES : NO;
        self.hasCity = stateModel.cityList.count > 0 ? YES : NO;
        self.hasVillage = cityModel.town_list.count > 0 ? YES : NO;
        
        // 不管是不是相同的，都用选择的
        self.selectCountryModel = [ZFAddressLibraryManager transformLibraryCountry:countryModel];
        self.selectCountryModel.ownState = self.hasProvince;
        self.selectCountryModel.ownCity = self.hasCity;
        self.selectCountryModel.showFourLevel = self.hasVillage;
        self.country_code = self.selectCountryModel.region_code;

        self.editModel.region_code = self.country_code;
        self.editModel.country_id = self.selectCountryModel.region_id;
        self.editModel.country_str = self.selectCountryModel.region_name;
        self.editModel.showFourLevel = self.selectCountryModel.showFourLevel;
        
        //判断当前是否为沙特国家，有的话需要更新NationalIDNumber 及电话号码类型以及清空省份城市选择。
        self.editModel.is_cod = self.selectCountryModel.is_cod;
        self.editModel.code = self.selectCountryModel.code;
        self.editModel.supplier_number_list = self.selectCountryModel.supplier_number_list;
        self.editModel.supplier_number = @"";
        self.editModel.supplier_number_spare = @"";
        // v5.4.0 一个时，默认填充
        if (ZFJudgeNSArray(self.selectCountryModel.supplier_number_list)) {
            if (self.selectCountryModel.supplier_number_list.count == 1) {
                self.editModel.supplier_number = ZFToString(self.selectCountryModel.supplier_number_list.firstObject);
                self.editModel.supplier_number_spare = ZFToString(self.selectCountryModel.supplier_number_list.firstObject);
            }
        }
        self.editModel.scut_number_list = self.selectCountryModel.scut_number_list;
        self.editModel.configured_number = self.selectCountryModel.configured_number;
        self.editModel.id_card = @"";
        self.editModel.whatsapp = @"";
        self.editModel.landmark = @"";
        
        [self resetAddressStateTip:NO message:@""];
        [self resetAddressCityTip:NO message:@""];
        [self resetAddressZipFourTip:NO message:@""];
        
        [self configAddressEditBookInfo];
        if (self.hasCity && self.selectCityModel && self.selectCountryModel.support_zip_code) {
            if ((self.hasVillage && !ZFIsEmptyString(self.editModel.barangay)) || !self.hasVillage) {
                [self requestCityZipAutoFill:YES];
            }
        }
    };
    [selectCtrl showParentController:self.navigationController topGapHeight:94];
}

- (void)selectCityZip:(ZFAddressEditTypeModel *)model {
    
    NSString *country_code = ZFToString(self.country_code);
    NSString *city_name = ZFToString(self.editModel.city);
    NSString *town_name = ZFToString(self.editModel.barangay);

    NSArray *cityZipArr;
    if (!ZFIsEmptyString(country_code) && !ZFIsEmptyString(city_name)) {
        NSString *countryCityKey = [NSString stringWithFormat:@"%@_%@_%@",country_code,city_name,town_name];
        if ([self isHoldCityZip:countryCityKey]) {
            cityZipArr = self.cityZipDic[countryCityKey];
            
            if (cityZipArr.count > 1) {
                [self.zipPickerView dismissView];
                self.zipPickerView = [ZFPickerView showPickerViewWithTitle:ZFLocalizedString(@"ModifyAddress_ZipCode_Placeholder", nil)
                                                               pickDataArr:@[cityZipArr]
                                                                 sureBlock:^(NSArray<ZFPickerViewSelectModel *> *selectContents) {
                                                                           ZFPickerViewSelectModel *firstSelectModel = selectContents.firstObject;
                                                                           if ([firstSelectModel isKindOfClass:[ZFPickerViewSelectModel class]]) {
                                                                               [self fillInCityZipContent:ZFToString(firstSelectModel.content)];
                                                                               YWLog(@"%@", ZFToString(firstSelectModel.content));
                                                                           }
                                                                       } cancelBlock:^{}];
                [self.zipPickerView selectPickerRowArray:@[ZFToString(self.editModel.zipcode)]];
            }
        }
    }
}

// 处理筛选城市选择结果
- (void)handleFilterSelectCity:(ZFAddressHintCityModel *)cityModel {
    [self.view endEditing:YES];
    self.cityFilterTable.hidden = YES;
    self.editModel.city = ZFToString(cityModel.city);
    self.editModel.isSaveErrorFillZipTip = NO;
    [self resetAddressCityTip:NO message:@""];
    if (!ZFIsEmptyString(cityModel.postcode)) {
        self.editModel.zipcode = cityModel.postcode;
        [self resetAddressZipFourTip:NO message:@""];
    }
    [self configAddressEditBookInfo];
}

// 是否已经持有该地区邮编
- (BOOL)isHoldCityZip:(NSString *)countryTownsKey {
    return [self.cityZipDic hasKey:countryTownsKey];
}

// 填充邮编
- (void)fillInCityZipContent:(NSString *)zipString {
    if (!ZFIsEmptyString(zipString) && self.zipIndexPath) {
        ZFAddressEditZipCodeTableViewCell *zipCell = [self.tableView cellForRowAtIndexPath:self.zipIndexPath];
        if (zipCell) {
            self.editModel.zipcode = zipString;
            [zipCell fillInZip:zipString];
        }
    }
}

/**
 * 进入谷歌智能地址
 */
#pragma mark - 进入谷歌智能地址

- (void)googleAddressSearch {
    
    ZFGoogleIntelligentizeAddressVC *googleVC = [[ZFGoogleIntelligentizeAddressVC alloc] init];
    self.googleVC = googleVC;
    googleVC.title = ZFLocalizedString(@"ModifyAddress_Edit_VC_title", nil);
    googleVC.country_code = self.country_code;
    googleVC.key = NullFilter(self.editModel.addressline1);
    googleVC.model = self.editModel;
    @weakify(self)
    @weakify(googleVC)
    [googleVC setSelectedAddressModel:^(ZFGoogleDetailAddressModel *detailAddressModel){
        @strongify(self)
        @strongify(googleVC)
        
        self.editModel.isSaveErrorFillZipTip = NO;
        if (!ZFIsEmptyString(detailAddressModel.address_components.addressline1)) {
            self.editModel.addressline1 = detailAddressModel.address_components.addressline1;
        } else if (!ZFIsEmptyString(detailAddressModel.formatted_address)) {//若addressline1为空时
            self.editModel.addressline1 = detailAddressModel.formatted_address;
        }
        
        if (!ZFIsEmptyString(detailAddressModel.address_components.addressline2)) {
            self.editModel.addressline2 = detailAddressModel.address_components.addressline2;
        }

        if (!ZFIsEmptyString(detailAddressModel.address_components.country_code) && !ZFIsEmptyString(detailAddressModel.address_components.country)) {
            
            self.country_code = detailAddressModel.address_components.country_code;
            self.editModel.region_code = self.country_code;
            self.editModel.country_id = ZFToString(detailAddressModel.address_components.country_id);
            
            self.editModel.country_str = ZFToString(detailAddressModel.address_components.country);
            self.editModel.province = ZFToString(detailAddressModel.address_components.state);
            self.editModel.city = ZFToString(detailAddressModel.address_components.city);
            self.editModel.zipcode = ZFToString(detailAddressModel.address_components.postcode);
            [self resetAddressStateTip:NO message:@""];
            [self resetAddressCityTip:NO message:@""];
            [self resetAddressZipFourTip:NO message:@""];
        }

        [self configAddressEditBookInfo];
        
        [googleVC googleIntelligentizeAddressHideCompletion:^(BOOL flag) {
            
        }];
    }];
    
    self.tableView.userInteractionEnabled = NO;
    [googleVC googleIntelligentizeAddressShowController:self completion:^(BOOL flag) {
        self.tableView.userInteractionEnabled = YES;
    }];
}


#pragma mark - 校验
///判断内容是否编辑
- (BOOL)isEditAddress {
    if (self.source_set_as_default_address != self.set_as_default_address) {
        return YES;//默认开关是否改变
    }
    return [ZFAddressEditManager isEditAddressSource:[self.sourceModel yy_modelToJSONObject] editModel:[self.editModel yy_modelToJSONObject]];
}

- (BOOL)isCheckEnterInfoSuccess {
    BOOL isOk = [ZFAddressEditManager isCheckEnterInfoSuccess:self.dataArray addressInfoModel:self.editModel village:self.hasVillage];
    return isOk;
}

- (void)orderAddressCanotEditMsg {
    
    NSString *msg = ZFLocalizedString(@"Address_cannot_change_tip", nil);
    if (self.addressNoPayOrder) {
        msg = ZFLocalizedString(@"Address_cannot_change_tip_no_pay", nil);
    }
    @weakify(self)
    [ZFAddressEditManager showOrderAddressContactCustomerMsg:msg completion:^(NSInteger buttonIndex) {
        @strongify(self)
        if (buttonIndex == 0) {//联系客服
            [self.navigationController popViewControllerAnimated:NO];
            [[ZFCustomerManager shareInstance] presentLiveChatWithGoodsInfo:@""];
        } else {
            [self goBackActionOrder];
        }
    }];
}

- (void)orderAddressGetEditInforError {//提示网络问题
    @weakify(self)
    [ZFAddressEditManager showOrderAddressChangedError:@"" completion:^(NSInteger buttonIndex) {
        @strongify(self)
        if (buttonIndex == 1) {
            [self requestOrderAddressData];
        } else {
            [self goBackActionOrder];
        }
    }];
}

- (void)orderAddressSaveError:(NSString *)msg {//保存失败提示客服
    
    NSString *tipMsg = ZFLocalizedString(@"Address_cannot_change_tip", nil);
    if (self.addressNoPayOrder) {
        tipMsg = ZFLocalizedString(@"Address_cannot_change_tip_no_pay", nil);
    }
    
    @weakify(self)
    [ZFAddressEditManager showOrderAddressContactCustomerMsg:tipMsg completion:^(NSInteger buttonIndex) {
        @strongify(self)
        if (buttonIndex == 0) {//联系客服
            ZFHelpViewController *helpCtrl = [[ZFHelpViewController alloc] init];
            [helpCtrl goBackUpperClassRelativeClass:NSStringFromClass(self.class)];
            [self.navigationController pushViewController:helpCtrl animated:YES];
        }
    }];
}

- (void)orderAddressChangedSuccess {
    
    if (self.addressNoPayOrder) {//未付款订单地址修改
        if (self.addressEditSuccessCompletionHandler) {
            self.addressEditSuccessCompletionHandler(AddressEditStateNoPayOrderSuccess);
            [self goBackActionOrder];
        }
        return;
    }
    
    @weakify(self)
    [ZFAddressEditManager showOrderAddressChangedSuccess:^(NSInteger buttonIndex) {
        @strongify(self)
        if (self.addressEditSuccessCompletionHandler) {
            self.addressEditSuccessCompletionHandler(AddressEditStatePayOrderSuccess);
            [self goBackActionOrder];
        }
    }];
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    if (!self.navigationItem.title) {
        self.navigationItem.title = ZFLocalizedString(@"Modify_Address_VC_Title",nil);
    }
    self.view.backgroundColor = ZFC0xF2F2F2();
    [self.view addSubview:self.tableView];
    [self.bottomBgView addSubview:self.bottomSaveView];
    self.tableView.tableFooterView = self.bottomBgView;
    
    //购物车下单无地址进来时
    if (self.sourceCart) {
        [self updateBottomTitle:AddressEditBottomTypeContinue];
    }
}

- (void)zfAutoLayoutView {
    [self.bottomSaveView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.mas_equalTo(self.bottomBgView);
        make.bottom.mas_equalTo(self.bottomBgView.mas_bottom);
        make.height.mas_equalTo(56);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view.mas_bottom);
    }];
}

- (void)showOrderTipView:(BOOL)show {
    
    if (!show) {
        UIView *tableView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 0.01)];
        self.tableView.tableHeaderView = tableView;
        
    } else {
        //刷新高度
        CGRect rect = CGRectZero;
        rect.size = [self.headerView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        self.headerView.frame = rect;
        self.tableView.tableHeaderView = self.headerView;
    }
}
- (void)updateBottomTitle:(AddressEditBottomType )type {
    self.bottomSaveView.bottomTitle = ZFLocalizedString(@"ModifyAddress_SAVE", nil);
    if (type == AddressEditBottomTypeContinue) {
        self.bottomSaveView.bottomTitle = ZFLocalizedString(@"ModifyAddress_Continue",nil);
    }
}

- (void)addNotification {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}


/**
 *  键盘弹出
 */
- (void)keyboardWillShow:(NSNotification *)aNotification {
    
    ZFUndeclaredSelectorLeakWarning( //忽略警告
                                    if ([WINDOW respondsToSelector:@selector(firstResponder)]) {
                                        UIView  *firstResponder = [WINDOW performSelector:@selector(firstResponder)];
                                        if ([firstResponder isKindOfClass:[UIView class]]) {
                                            UIViewController *viewCtrl = firstResponder.viewContainingController;
                                            if (![viewCtrl isKindOfClass:[ZFAddressEditViewController class]]) {
                                                YWLog(@"-------keyboardWillShow: %@",NSStringFromClass([viewCtrl class]));
                                                return;
                                            }
                                        }
                                    }
                                    );
    
    
    
    
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *endFrame = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardEndRect = [endFrame CGRectValue];
    CGFloat keyboardHeight = keyboardEndRect.size.height;
    
    /* 获取键盘的高度 */
    self.keyboardHeight = keyboardHeight > 200 ? keyboardHeight : 256;
    YWLog(@"---keyboardWillShow-- keyboardH: %f",keyboardHeight);
    
    if (self.currentIndexPath) {
        //防止网络请求成功时：self.currentIndexPath 设置成nil
        NSIndexPath *tempCurrentIndexPath = [self.currentIndexPath copy];
        ZFBaseEditAddressCell *baseCell = [self.tableView cellForRowAtIndexPath:tempCurrentIndexPath];
        if (!baseCell) {//indexPath无效时，
            [self showCityFilterView:NO];
            return;
        }
        
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight, 0);
        if ([baseCell isKindOfClass:ZFAddressEditCityTableViewCell.class]) {
            
            //需要延长，不然滚不上去
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:tempCurrentIndexPath.row - 1 inSection:tempCurrentIndexPath.section];
                CGRect currentRect = [self.tableView rectForRowAtIndexPath:lastIndexPath];
                
                [self.tableView setContentOffset:CGPointMake(0, CGRectGetMaxY(currentRect)) animated:YES];
                [self showCityFilterView:YES];
            });
            
        } else {
            [self showCityFilterView:NO];
            if ([baseCell isKindOfClass:ZFAddressEditNameTableViewCell.class]) {
                // 编辑 姓名，就不滚动处理了
                return;
            } else {
                //获取cell在tableView中的位置
                CGRect rectInTableView = [self.tableView rectForRowAtIndexPath:tempCurrentIndexPath];
                [self.tableView setContentOffset:CGPointMake(0, CGRectGetMinY(rectInTableView)) animated:NO];
            }
        }
    }
}

/**
 *  键盘退出
 */
- (void)keyboardWillHide:(NSNotification *)aNotification {
    YWLog(@"-------keyboardWillHide");
    
    ZFUndeclaredSelectorLeakWarning( //忽略警告
                                    if ([WINDOW respondsToSelector:@selector(firstResponder)]) {
                                        UIView  *firstResponder = [WINDOW performSelector:@selector(firstResponder)];
                                        if ([firstResponder isKindOfClass:[UIView class]]) {
                                            UIViewController *viewCtrl = firstResponder.viewContainingController;
                                            if (![viewCtrl isKindOfClass:[ZFAddressEditViewController class]]) {
                                                YWLog(@"-------keyboardWillHide: %@",NSStringFromClass([viewCtrl class]));
                                                return;
                                            }
                                        }
                                    }
                                    );
    
    self.keyboardHeight = 0;
    self.cityFilterTable.hidden = YES;
    self.tableView.contentInset =  UIEdgeInsetsMake(0, 0, 30, 0);;
}

#pragma mark - setter/getter

- (void)editOrderAddress:(ZFAddressInfoModel *)model checkPHAddress:(NSDictionary *)checkPHAddress {
    self.checkPHAddress = checkPHAddress;
    self.model = model;
}

- (NSMutableDictionary *)cityZipDic {
    if (!_cityZipDic) {
        _cityZipDic = [[NSMutableDictionary alloc] init];
    }
    return _cityZipDic;
}

- (void)setAddressOrderSn:(NSString *)addressOrderSn {
    _addressOrderSn = addressOrderSn;
    self.isOrderUpdate = YES;
}

- (void)setModel:(ZFAddressInfoModel *)model {
    _model = model;
    self.editModel = [model mutableCopy];
    //反正email为空
    self.editModel.email = self.editModel.email ?: [AccountManager sharedManager].account.email;
    self.country_code = ZFToString(self.editModel.region_code);
    self.hasCity = self.editModel.ownCity;
    self.hasProvince = self.editModel.ownState;
    self.hasVillage = self.editModel.ownBarangay;
    
    //手机用户
    if ([AccountManager sharedManager].account.is_emerging_country == 1) {
        self.editModel.is_emerging_country = 1;
        if (ZFIsEmptyString(self.editModel.tel)) {
            self.editModel.tel = [AccountManager sharedManager].account.phone;
        }
    }

    [self configAddressEditBookInfo];
    
    if (self.checkPHAddress) {
        NSDictionary *dic = @{@"data":self.checkPHAddress};
        [self handleAddressErrorClear:dic];
        self.checkPHAddress = nil;
    }
    
    self.set_as_default_address = self.editModel.is_default;
    self.source_set_as_default_address = self.set_as_default_address;
    self.sourceModel = [self.editModel mutableCopy];
    
    [self updateBottomTitle:AddressEditBottomTypeSave];
    
    if (model.support_zip_code) {
        [self requestCityZipAutoFill:NO];
    }
}

- (ZFAddressInfoModel *)editModel {
    if (!_editModel) {
        _editModel = [[ZFAddressInfoModel alloc] init];
    }
    return _editModel;
}

- (ZFAddressModifyViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[ZFAddressModifyViewModel alloc] init];
        _viewModel.controller = self;
    }
    return _viewModel;
}

- (NSMutableArray<ZFAddressEditTypeModel *> *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [ZFAddressEditManager configBaseTable:_tableView];
    }
    return _tableView;
}

- (UIView *)bottomBgView {
    if (!_bottomBgView) {
        _bottomBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 56)];
        _bottomBgView.backgroundColor = ZFCClearColor();
    }
    return _bottomBgView;
}
- (ZFBottomToolView *)bottomSaveView {
    if (!_bottomSaveView) {
        _bottomSaveView = [[ZFBottomToolView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 56)];
        _bottomSaveView.backgroundColor = ZFCClearColor();
        _bottomSaveView.bottomTitle = ZFLocalizedString(@"ModifyAddress_SAVE",nil);
        _bottomSaveView.showTopShadowline = NO;
        _bottomSaveView.topLine.hidden = YES;
        @weakify(self);
        _bottomSaveView.bottomButtonBlock = ^{
            @strongify(self);
            [self saveAddressButtonAction:nil];
        };
    }
    return _bottomSaveView;
}

- (ZFAddressCityTableView *)cityFilterTable {
    if (!_cityFilterTable) {
        _cityFilterTable = [[ZFAddressCityTableView alloc] initWithFrame:CGRectMake(0, 100, KScreenWidth, 10) style:UITableViewStyleGrouped];
        _cityFilterTable.backgroundColor = ZFC0xF2F2F2();
        _cityFilterTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        _cityFilterTable.hidden = YES;
        @weakify(self)
        _cityFilterTable.selectCityBlock = ^(ZFAddressHintCityModel *cityModel) {
            @strongify(self)
            [self handleFilterSelectCity:cityModel];
        };
    }
    return _cityFilterTable;
}

- (ZFAddressCheckView *)addressCheckView {
    if (!_addressCheckView) {
        _addressCheckView = [[ZFAddressCheckView alloc] initWithFrame:CGRectZero];
        @weakify(self)
        _addressCheckView.saveBlock = ^(ZFCheckShippingAddressModel *checkModel) {
            @strongify(self)
            [self saveAddressConfirm:checkModel];
        };
        _addressCheckView.editBlock = ^(ZFCheckShippingAddressModel *checkModel) {
            @strongify(self)
            [self checkEditSuggestAddress:checkModel];
        };
    }
    return _addressCheckView;
}

- (ZFAddressTableHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [[ZFAddressTableHeaderView alloc] initWithFrame:CGRectZero tip:ZFLocalizedString(@"Address_order_changed_notice", nil)];
        _headerView.backgroundColor = ZFC0xF1F1F1();
    }
    return _headerView;
}

@end
