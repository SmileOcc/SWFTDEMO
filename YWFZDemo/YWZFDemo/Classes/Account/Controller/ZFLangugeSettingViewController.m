//
//  ZFLangugeSettingViewController.m
//  ZZZZZ
//
//  Created by YW on 2018/11/24.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFLangugeSettingViewController.h"
#import "AppDelegate.h"
#import "ZFNavigationController.h"
#import "AppDelegate+ZFThirdLibrary.h"
#import "ZFHomePageMenuModel.h"
#import <Firebase/Firebase.h>
#import "Growing.h"
#import <GGPaySDK/GGPaySDK.h>
#import "ZFSkinViewModel.h"
#import "ZFThemeManager.h"
#import "IQKeyboardManager.h"
#import "UIView+LayoutMethods.h"
#import "ZFLocalizationString.h"
#import "ZFFireBaseAnalytics.h"
#import "SystemConfigUtils.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "YWCFunctionTool.h"
#import "ZFCommonRequestManager.h"
#import "Constants.h"
#import "ZFAnalyticsExposureSet.h"
#import "ZFProgressHUD.h"
#import "UIImage+ZFExtended.h"
#import "ZFLangugeSettingCell.h"

static NSString * const kLangugeIdentifier = @"kLangugeIdentifier";

@interface ZFLangugeSettingViewController () <UITableViewDelegate, UITableViewDataSource> {
    NSInteger _selectedIndex;
    NSInteger _oldSelectedIndex;
}

@property (nonatomic, strong) NSArray <ZFSupportLangModel *>*languageArray;
@property (nonatomic, strong) UITableView *langugeTableView;
@property (nonatomic, strong) UIImageView *accesoryImageView;
@property (nonatomic, strong) UIButton *saveButton;
@end

@implementation ZFLangugeSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self setupView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)setupView {
    [self.view addSubview:self.langugeTableView];
}

- (void)initData {
    self.title = ZFLocalizedString(@"Setting_Cell_Languege", nil);
    self.view.backgroundColor = ZFCOLOR(245.0, 245.0, 245.0, 1.0);
    // 从我的模块进来
    NSArray <ZFSupportLangModel *>*countrySupportLang = [ZFLocalizationString shareLocalizable].languageArray;
    if (self.supportLangList) {
        countrySupportLang = self.supportLangList;
    }
    self.languageArray = countrySupportLang;
    [self selectIndex];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.saveButton];
    self.saveButton.enabled = NO;
}

/**
 * 标记选中标签
 */
- (void)selectIndex {
    // 默认选中的语言
    NSString *selecteLang = [ZFLocalizationString shareLocalizable].nomarLocalizable;
    
    // 从启动引导进来只返回引导页
    if (self.comeFromType == LangugeSettingComeFrom_GuideSettingVC) {
        if (!ZFIsEmptyString(self.shouldSelectedShortenedLang)) {
            selecteLang = self.shouldSelectedShortenedLang;
        }
    }

    _selectedIndex = 0;
    for (NSInteger i = 0; i < self.languageArray.count; i++) {
        ZFSupportLangModel *model = self.languageArray[i];
        NSString *languegeCode = model.code;
        if ([languegeCode isEqualToString:selecteLang]) {
            _selectedIndex = i;
            break;
        }
    }
    _oldSelectedIndex = _selectedIndex;
}

#pragma mark - UITableViewDelegate/UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.languageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZFLangugeSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:kLangugeIdentifier];
    cell.contentLabel.text = self.languageArray[indexPath.row].name;
    cell.link.hidden = (indexPath.row == self.languageArray.count - 1) ? YES : NO;
    cell.accesoryImageView.hidden = (indexPath.row == _selectedIndex) ? NO : YES;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == _selectedIndex) {
        return;
    }
    _selectedIndex = indexPath.row;
    [tableView reloadData];
    
    //选择不同的才可以点击
    if (_oldSelectedIndex == _selectedIndex) {
        self.saveButton.enabled = NO;
    } else {
        self.saveButton.enabled = YES;
    }
}

#pragma mark - privte method
/**
 * 保存切换语言
 */
- (void)saveButtonAction {
    
    __block NSString *oldLanguage = [ZFLocalizationString shareLocalizable].nomarLocalizable;
    //只有用户手动选择了语言，才保存
    ZFSupportLangModel *supportModel = self.languageArray[_selectedIndex];
    NSString *selectLanguage = supportModel.code;
    [[ZFLocalizationString shareLocalizable] saveUserSelectLanguage:selectLanguage];
    
    // 从启动引导进来只返回引导页面
    if (self.comeFromType == LangugeSettingComeFrom_GuideSettingVC) {
        if (self.convertLangugeBlock) {
            NSString *selectedLanguge = supportModel.name;//全称
            NSString *shortenedLang = supportModel.code;//简称:两个字母
            self.convertLangugeBlock(selectedLanguge, shortenedLang);
        }
        [self goBackAction];
        
    } else { // 从我的模块进来
        // 更换语言
        NSString *selectedLanguge = supportModel.code;
        [ZFLocalizationString shareLocalizable].nomarLocalizable = selectedLanguge;
        [[ZFLocalizationString shareLocalizable] saveNomarLocalizableLanguage:selectLanguage];
        
        //切换语言后切换系统UI布局方式
        [UIViewController convertAppUILayoutDirection];
        
        // 切换语言统计
        [ZFLangugeSettingViewController convertLangugeAnalytic];
        
        // 重新初始化AppTabbr
        [ZFLangugeSettingViewController initAppTabBarVCFromChangeLanguge:TabBarIndexAccount completion:^(BOOL success) {
            if (!success) {
                //回滚语言切换
                [ZFLocalizationString shareLocalizable].nomarLocalizable = oldLanguage;
                [[ZFLocalizationString shareLocalizable] saveNomarLocalizableLanguage:oldLanguage];
            }
        }];
    }
    [IQKeyboardManager sharedManager].toolbarDoneBarButtonItemText = ZFLocalizedString(@"GoodsPage_VC_Done", nil);
}

/**
 * 切换语言,切换国家时 重新初始化AppTabbr, 刷新国家运营数据
 */
+ (void)initAppTabBarVCFromChangeLanguge:(NSInteger)tabBarIndex
{
    // 清除启动页广告,首页半透明弹框数据
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kHomeFloatModelKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLaunchAdvertDataDictiontryKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // 切换语言后, 恢复全局导航换肤到初始状态
    [AccountManager sharedManager].needChangeAppSkin = NO;
    
    // 切换语言后需要刷新inital接口
    ShowLoadingToView(nil);
    [ZFCommonRequestManager requestInitializeData:^(BOOL success) {
        [ZFCommonRequestManager requestExchangeData:^(BOOL success) {
            HideLoadingFromView(nil);
            // 请求用户信息定位接口 （这个接口默认是在Home首页viewDidLoad里获取，防止切换国家时，直接进入其他社区模块)
            [ZFCommonRequestManager requestLocationInfo];
            
            // 请求换肤
            [ZFCommonRequestManager requestZFSkin];
            
            // 重新刷新首页统计的数据
            [[ZFAnalyticsExposureSet sharedInstance] removeAllObjects];
            
            //切换语言后切换系统UI布局方式
            [UIViewController convertAppUILayoutDirection];
            
            // 切换语言统计
            [ZFLangugeSettingViewController convertLangugeAnalytic];
            
            // 切换语言后重新初始化Tabbar
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [appDelegate initAppRootVC];
            appDelegate.tabBarVC.selectedIndex = tabBarIndex;
        }];
    }];
}

+ (void)initAppTabBarVCFromChangeLanguge:(NSInteger)tabBarIndex completion:(void(^)(BOOL success))completion
{
    // 清除启动页广告,首页半透明弹框数据
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kHomeFloatModelKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLaunchAdvertDataDictiontryKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // 切换语言后, 恢复全局导航换肤到初始状态
    [AccountManager sharedManager].needChangeAppSkin = NO;
    
    // 切换语言后需要刷新inital接口
    ShowLoadingToView(nil);
    [ZFCommonRequestManager requestInitializeData:^(BOOL success) {
        if (!success) {
            if (completion) {
                completion(NO);
            }
            return;
        }
        
        // 这个接口一定要放在切主页之前的CMS接口拿到定位国家,不然首页拉不到相应国家的频道
        // 请求用户信息定位接口 （这个接口默认是在Home首页viewDidLoad里获取，防止切换国家时，直接进入其他社区模块)
        [ZFCommonRequestManager requestLocationInfo];
        
        [ZFCommonRequestManager requestExchangeData:^(BOOL success) {
            HideLoadingFromView(nil);
            
            // 请求换肤
            [ZFCommonRequestManager requestZFSkin];
            
            // 重新刷新首页统计的数据
            [[ZFAnalyticsExposureSet sharedInstance] removeAllObjects];
            
            //切换语言后切换系统UI布局方式
            [UIViewController convertAppUILayoutDirection];
            
            // 切换语言统计
            [ZFLangugeSettingViewController convertLangugeAnalytic];
            
            // 切换语言后重新初始化Tabbar
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [appDelegate initAppRootVC];
            appDelegate.tabBarVC.selectedIndex = tabBarIndex;
            if (completion) {
                completion(success);
            }
        }];
    }];
}

/**
 * 切换语言统计
 */
+ (void)convertLangugeAnalytic {
    [ZFFireBaseAnalytics selectContentWithItemId:[NSString stringWithFormat:@"Language_%@", [ZFLocalizationString shareLocalizable].nomarLocalizable]
                                        itemName:@"Language_Change"
                                     ContentType:@"Language"
                                    itemCategory:@"UITableCell"];
    
    //Growing统计传一个语言标识
    NSString *lang = [ZFLocalizationString shareLocalizable].nomarLocalizable;
    [Growing setPeopleVariableWithKey:@"language" andStringValue:ZFToString(lang)];
    [AccountManager saveLeandCloudData];
    
    // 配置GA统计
    [APPDELEGATE configurGAI];
}

#pragma mark - getter/setter
- (UITableView *)langugeTableView {
    if (!_langugeTableView) {
        _langugeTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _langugeTableView.delegate = self;
        _langugeTableView.dataSource = self;
        _langugeTableView.backgroundColor = [UIColor clearColor];
        _langugeTableView.rowHeight = UITableViewAutomaticDimension;
        _langugeTableView.estimatedRowHeight = 44;
        _langugeTableView.tableFooterView = [UIView new];
        _langugeTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _langugeTableView.contentInset = UIEdgeInsetsMake(12, 0, 0, 0);
        [_langugeTableView registerClass:[ZFLangugeSettingCell class] forCellReuseIdentifier:kLangugeIdentifier];
    }
    return _langugeTableView;
}

- (UIImageView *)accesoryImageView {
    if (!_accesoryImageView) {
        UIImage *image = [[UIImage imageNamed:@"refine_select"] imageWithColor:ZFC0xFE5269()];
        _accesoryImageView = [[UIImageView alloc] initWithImage:image];
        _accesoryImageView.backgroundColor = [UIColor clearColor];
        _accesoryImageView.frame = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
    }
    return _accesoryImageView;
}

- (UIButton *)saveButton {
    if (!_saveButton) {
        _saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _saveButton.backgroundColor = [UIColor clearColor];
        _saveButton.enabled = NO;
        _saveButton.titleLabel.font = ZFFontSystemSize(16);
        [_saveButton setTitleColor:ZFCOLOR(51.0, 51.0, 51.0, 1.0) forState:UIControlStateNormal];
        [_saveButton setTitleColor:ZFCOLOR(221.0, 221.0, 221.0, 1.0) forState:UIControlStateDisabled];
        [_saveButton addTarget:self action:@selector(saveButtonAction) forControlEvents:UIControlEventTouchUpInside];
        
        NSString *title = ZFLocalizedString(@"Profile_Save_Button", nil);
        CGSize titleSize = [title sizeWithAttributes:@{NSFontAttributeName: [UIFont fontWithName:_saveButton.titleLabel.font.fontName size:_saveButton.titleLabel.font.pointSize]}];
        _saveButton.frame = CGRectMake(0.0, 0.0, titleSize.width, self.navigationController.navigationBar.height);
        [_saveButton setTitle:title forState:UIControlStateNormal];
    }
    return _saveButton;
}

@end
