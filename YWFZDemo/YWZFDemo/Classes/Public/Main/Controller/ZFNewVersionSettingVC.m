//
//  ZFNewVersionSettingVC.m
//  ZZZZZ
//
//  Created by YW on 2018/7/24.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFNewVersionSettingVC.h"
#import "ZFTableViewManager.h"
#import "ZFAccountCountryViewController.h"
#import "ZFCurrencyViewController.h"
#import "ZFLangugeSettingViewController.h"
#import "ZFThemeManager.h"
#import "ZFProgressHUD.h"
#import "ZFLocalizationString.h"
#import "ExchangeManager.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "ZFCommonRequestManager.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFSettingTableViewCell.h"

@interface ZFNewVersionSettingVC ()
@property (nonatomic, strong) UITableView           *tableView;
@property (nonatomic, strong) ZFTableViewManager    *tableViewManager;
@property (nonatomic, strong) NSArray               *tableTitleDataArr;
@property (nonatomic, strong) NSArray               *tableImageDataArr;
@property (nonatomic, strong) UIButton              *colseButton;
@property (nonatomic, strong) UIButton              *saveButton;
@property (nonatomic, strong) NSString              *regionName;
@property (nonatomic, strong) NSString              *exchangeSignAndName;
@property (nonatomic, strong) NSString              *selectedLanguge;//语言全称
@property (nonatomic, strong) NSString              *selectedShortenedLanguge;//语言简称:2个字母
@property (nonatomic, strong) NSString              *selectedCurrency;
@property (nonatomic, strong) ZFAddressCountryModel *selectedCountryModel;
@end

@implementation ZFNewVersionSettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = ZFLocalizedString(@"Setting_VC_Title",nil);
    [self zfInitView];
    [self zfAutoLayoutView];
    [self setupNavRightBtn];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)zfInitView {
    [self.view addSubview:self.tableView];
}

- (void)zfAutoLayoutView {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
}

#pragma mark -===========导航栏操作===========

- (void)setupNavRightBtn {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.colseButton];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.saveButton];
}

- (void)colseButtonAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -===========切换, 保存数据===========

/**
 * 保存更改
 */
- (void)saveButtonAction {
    if (ZFIsEmptyString(self.selectedShortenedLanguge)) {
        // 保存所有更改的数据
        [self saveAllChangeData];
    } else {
        NSString *oldLanguge = [ZFLocalizationString shareLocalizable].nomarLocalizable;
        [ZFLocalizationString shareLocalizable].nomarLocalizable = self.selectedShortenedLanguge;
        
        if (self.selectedCountryModel) {
            ZFInitCountryInfoModel *countryInfo = [AccountManager sharedManager].initializeModel.countryInfo;
            countryInfo.region_id = self.selectedCountryModel.region_id;
            countryInfo.region_code = self.selectedCountryModel.region_code;
            countryInfo.support_lang = self.selectedCountryModel.support_lang;
            countryInfo.is_emerging_country = self.selectedCountryModel.is_emerging_country;
            [AccountManager sharedManager].initializeModel.countryInfo = countryInfo;
            //这个参数，在接口的公共参数里面取到了，不赋值的话，init接口获取不到最新的国家参数
            [AccountManager sharedManager].accountCountryModel = self.selectedCountryModel;
        }
        
        @weakify(self)
        ShowLoadingToView(self.view);//有切换语言需要重新请求init接口
        [ZFCommonRequestManager requestInitializeData:^(BOOL success){
            @strongify(self)
            HideLoadingFromView(self.view);
            
            if (success) {
                // 保存所有更改的数据
                [self saveAllChangeData];
                [ZFCommonRequestManager requestLocationInfo];
            } else {
                // 恢复语言
                [ZFLocalizationString shareLocalizable].nomarLocalizable = oldLanguge;
                ShowToastToViewWithText(nil, ZFLocalizedString(@"EmptyCustomViewManager_titleLabel",nil));
            }
        }];
    }
}

/**
 *  保存所有更改的设置数据
 */
- (void)saveAllChangeData
{
    // 保存更改国家信息
    if ([self.selectedCountryModel isKindOfClass:[ZFAddressCountryModel class]]) {
        SaveUserDefault(kHasChangeCurrencyKey, @(NO));
        [AccountManager sharedManager].accountCountryModel = self.selectedCountryModel;
        [AccountManager saveLeandCloudData];
        
        ZFInitCountryInfoModel *countryInfo = [AccountManager sharedManager].initializeModel.countryInfo;
        
        // 切换国家后, 需要更新init接口的国家信息
        countryInfo.region_code = self.selectedCountryModel.region_code;
        countryInfo.region_id = self.selectedCountryModel.region_id;
        countryInfo.region_name = self.selectedCountryModel.region_name;
        countryInfo.is_emerging_country = self.selectedCountryModel.is_emerging_country;
        [AccountManager sharedManager].initializeModel.countryInfo = countryInfo;
        
        // 切换国家后, 需要更新init接口的汇率信息
        ZFInitExchangeModel *exchange = [AccountManager sharedManager].initializeModel.exchange;
        exchange.name = self.selectedCountryModel.exchange.name;
        exchange.rate = self.selectedCountryModel.exchange.rate;
        exchange.sign = self.selectedCountryModel.exchange.sign;
        [AccountManager sharedManager].initializeModel.exchange = exchange;
        
        // 如果没有手动选择汇率,则需要更新汇率
        NSString *sign = self.selectedCountryModel.exchange.sign;
        NSString *name = self.selectedCountryModel.exchange.name;
        NSString *allCurrency = [NSString stringWithFormat:@"%@ %@", sign, name];
        [ExchangeManager updateLocalCurrency:allCurrency];
        
        [ZFLocalizationString shareLocalizable].languageArray = self.selectedCountryModel.support_lang;
    }
    
    // 保存更改切换的汇率
    if (!ZFIsEmptyString(self.selectedCurrency)) {
        SaveUserDefault(kHasChangeCurrencyKey, @(YES));
        [ExchangeManager updateLocalCurrency:self.selectedCurrency];
        
        // 更新init接口的汇率信息
        ZFInitExchangeModel *exchange = [AccountManager sharedManager].initializeModel.exchange;
        exchange.name = [ExchangeManager localCurrencyName];
        exchange.rate = [NSString stringWithFormat:@"%f",[ExchangeManager localRate]];
        exchange.sign = [ExchangeManager localTypeCurrency];
        [AccountManager sharedManager].initializeModel.exchange = exchange;
    }
    
    // 保存更改切换的语言
    if (!ZFIsEmptyString(self.selectedShortenedLanguge)) {
        [ZFLocalizationString shareLocalizable].nomarLocalizable = self.selectedShortenedLanguge;
        [[ZFLocalizationString shareLocalizable] saveUserSelectLanguage:self.selectedShortenedLanguge];
        [[ZFLocalizationString shareLocalizable] saveNomarLocalizableLanguage:self.selectedShortenedLanguge];
        
        // 切换语言后切换系统UI布局方式
        [UIViewController convertAppUILayoutDirection];
        
        // 切换语言统计
        [ZFLangugeSettingViewController convertLangugeAnalytic];
    }
    
    if (self.saveInfoBlock) {
        self.saveInfoBlock(self.regionName, self.exchangeSignAndName, self.selectedShortenedLanguge);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -===========表格数据===========

- (NSArray *)tableTitleDataArr {
    if(!_tableTitleDataArr){
        ZFInitCountryInfoModel *model = [AccountManager sharedManager].initializeModel.countryInfo;
        if (model.support_lang.count > 1) {
            _tableTitleDataArr = @[ZFLocalizedString(@"Account_Cell_Country", nil),
                                   ZFLocalizedString(@"Currency_VC_Title",nil),
                                   ZFLocalizedString(@"Setting_Cell_Languege", nil)];
        } else {
            _tableTitleDataArr = @[ZFLocalizedString(@"Account_Cell_Country", nil),
                                   ZFLocalizedString(@"Currency_VC_Title",nil),];
        }
    }
    return _tableTitleDataArr;
}

- (NSArray *)tableImageDataArr {
    if(!_tableImageDataArr){
        _tableImageDataArr = @[@"account_home_country",
                               @"account_home_currency",
                               @"account_home_language"];
    }
    return _tableImageDataArr;
}

- (ZFTableViewManager *)tableViewManager {
    if(!_tableViewManager){
        @weakify(self)
        _tableViewManager = [ZFTableViewManager createWithCellClass:[ZFSettingTableViewCell class]];
        
        _tableViewManager.cellForRowBlock = ^(UITableViewCell *customeCell, id rowData, NSIndexPath *indexPath) {
            @strongify(self)
            ZFSettingTableViewCell *cell = (ZFSettingTableViewCell *)customeCell;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.iconImage = ZFImageWithName(self.tableImageDataArr[indexPath.row]);
            cell.title = ZFToString(self.tableTitleDataArr[indexPath.row]);
            cell.detailTitle = [self getSubTextWithIndexPath:indexPath];
            cell.detailTextColor = ZFCOLOR(153, 153, 153, 1);
            cell.arrowImage = [UIImage imageNamed:@"account_arrow_right"];
            if (indexPath.row == self.tableTitleDataArr.count - 1) {
                cell.bottomLine.hidden = YES;
            }
        };
        
        [_tableViewManager setPlainTabDataArrBlcok:^NSArray *{
            @strongify(self)
            return self.tableTitleDataArr;
        }];
        
        [_tableViewManager setHeightForRowBlcok:^CGFloat(id rowData, NSIndexPath *indexPath) {
            return 56;
        }];
        
        //点击cell
        [_tableViewManager setDidSelectRowBlcok:^(NSDictionary *rowDataDic, NSIndexPath *indexPath) {
            @strongify(self)
            [self pushToTagetVC:indexPath];
        }];
    }
    return _tableViewManager;
}

#pragma mark -===========表格Cell方法===========

- (NSString *)getSubTextWithIndexPath:(NSIndexPath *)indexPath {
    NSString *subText = @"";
    switch (indexPath.row) {
        case 0:
        {
            if (self.selectedCountryModel) {
                subText = self.selectedCountryModel.region_name;
            } else {
                subText = [AccountManager sharedManager].initializeModel.countryInfo.region_name;
            }
            if (!subText || subText.length==0) {
                subText = @"United States";
            }
            self.regionName = subText;
        }
            break;
        case 1:
        {
            subText = [self fetchShowCurrency];
        }
            break;
        case 2:
        {
            if (!ZFIsEmptyString(self.selectedLanguge)) {
                subText = self.selectedLanguge;
            } else {
                subText = [[ZFLocalizationString shareLocalizable] currentLanguageName];
            }
            if (!subText || subText.length==0) {
                subText = @"en";
            }
        }
            break;
        default:
            break;
    }
    return subText;
}

- (NSString *)fetchShowCurrency
{
    NSString *subText = @"USD";
    if (self.selectedCurrency) {
        NSArray *sginArr = [self.selectedCurrency componentsSeparatedByString:@" "];
        if (sginArr.count>1) {
            subText = [sginArr lastObject];
            self.exchangeSignAndName = self.selectedCurrency;
        } else {
            self.exchangeSignAndName = @"$ USD";
        }
        
    } else {
        if (self.selectedCountryModel) {
            subText = self.selectedCountryModel.exchange.name;
            self.exchangeSignAndName = [NSString stringWithFormat:@"%@ %@",self.selectedCountryModel.exchange.sign, self.selectedCountryModel.exchange.name];
            
        } else {
            ZFInitExchangeModel *exchange = [AccountManager sharedManager].initializeModel.exchange;
            subText = exchange.name;
            self.exchangeSignAndName = [NSString stringWithFormat:@"%@ %@",exchange.sign, exchange.name];
        }
    }
    if (!subText || subText.length==0) {
        subText = @"USD";
    }
    return subText;
}

#pragma mark -===========页面跳转===========

- (void)pushToTagetVC:(NSIndexPath *)indexpath {
    switch (indexpath.row) {
        case 0:
        {
            ZFAccountCountryViewController *vc = [[ZFAccountCountryViewController alloc] init];
            vc.comeFromType = CountryVCComeFrom_GuideCountry;
            if (self.selectedCountryModel) {
                vc.shouldSelectedModel = self.selectedCountryModel;
                
            } else {
                ZFInitCountryInfoModel *countryInfo = [AccountManager sharedManager].initializeModel.countryInfo;
                
                ZFAddressCountryModel *tempCountryModel = [ZFAddressCountryModel new];
                tempCountryModel.region_id = countryInfo.region_id;
                tempCountryModel.region_name = countryInfo.region_name;
                tempCountryModel.region_code = countryInfo.region_code;
                tempCountryModel.is_emerging_country = countryInfo.is_emerging_country;
                vc.shouldSelectedModel = tempCountryModel;
            }
            
            @weakify(self)
            vc.selectCountryBlcok = ^(ZFAddressCountryModel *model) {
                @strongify(self)
                self.selectedCountryModel = model;
                if ([model.support_lang count] == 1) {
                    //只有一个国家，要隐藏语言设置
                    self.tableTitleDataArr = @[ZFLocalizedString(@"Account_Cell_Country", nil),
                                               ZFLocalizedString(@"Currency_VC_Title",nil)];
                } else {
                    self.tableTitleDataArr = @[ZFLocalizedString(@"Account_Cell_Country", nil),
                                               ZFLocalizedString(@"Currency_VC_Title",nil),
                                               ZFLocalizedString(@"Setting_Cell_Languege", nil)];
                }
                self.selectedLanguge = self.selectedCountryModel.supportLanguage;
                self.selectedShortenedLanguge = self.selectedCountryModel.code;
                self.selectedCurrency = nil;
                [self.tableView reloadData];
            };
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 1:
        {
            ZFCurrencyViewController *vc = [[ZFCurrencyViewController alloc] init];
            vc.comeFromType = CurrencyComeFrom_GuideSetting;
            vc.shouldSelectedCurrency = [self fetchShowCurrency];
            @weakify(self)
            vc.convertCurrencyBlock = ^(NSString *selectedCurrency){
                @strongify(self)
                self.selectedCurrency = selectedCurrency;
            };
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 2:
        {
            ZFLangugeSettingViewController *vc = [[ZFLangugeSettingViewController alloc] init];
            vc.comeFromType = LangugeSettingComeFrom_GuideSettingVC;
            vc.shouldSelectedShortenedLang = self.selectedShortenedLanguge;
            vc.supportLangList = self.selectedCountryModel.support_lang;
            @weakify(self)
            //selectedLanguge: 全称, shortenedLang:简称(两个字母)
            vc.convertLangugeBlock = ^(NSString *selectedLanguge, NSString *selectedShortenedLang){
                @strongify(self)
                self.selectedLanguge = selectedLanguge;
                self.selectedShortenedLanguge = selectedShortenedLang;
            };
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        default:
            break;
    }
}

#pragma mark -===========初始化UI===========

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = ZFCOLOR(245, 245, 245, 1.0);
        _tableView.delegate = self.tableViewManager;
        _tableView.dataSource = self.tableViewManager;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.tableFooterView = [UIView new];
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 12)];
        _tableView.tableHeaderView = view;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.rowHeight = 56;
    }
    return _tableView;
}

- (UIButton *)colseButton {
    if (!_colseButton) {
        _colseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _colseButton.frame = CGRectMake(0.0, 0.0, 60, NAVBARHEIGHT);
        [_colseButton addTarget:self action:@selector(colseButtonAction) forControlEvents:UIControlEventTouchUpInside];
//        UIImage *backImage = [UIImage imageNamed:([SystemConfigUtils isRightToLeftShow] ? @"nav_arrow_right" : @"nav_arrow_left")];
        [_colseButton setImage:ZFImageWithName(@"login_dismiss") forState:UIControlStateNormal];
        _colseButton.imageEdgeInsets = UIEdgeInsetsMake(0, -40, 0, 0);
    }
    return _colseButton;
}

- (UIButton *)saveButton {
    if (!_saveButton) {
        _saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _saveButton.frame = CGRectMake(0.0, 0.0, 80, NAVBARHEIGHT);
        [_saveButton setTitleColor:ZFCOLOR(51.0, 51.0, 51.0, 1.0) forState:UIControlStateNormal];
        [_saveButton setTitleColor:ZFCOLOR(51.0, 51.0, 51.0, 0.5) forState:UIControlStateDisabled];
        [_saveButton addTarget:self action:@selector(saveButtonAction) forControlEvents:UIControlEventTouchUpInside];
        NSString *title = ZFLocalizedString(@"Profile_Save_Button", nil);
        [_saveButton setTitle:title forState:UIControlStateNormal];
        _saveButton.titleLabel.font = ZFFontSystemSize(16);
        _saveButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    }
    return _saveButton;
}
@end
