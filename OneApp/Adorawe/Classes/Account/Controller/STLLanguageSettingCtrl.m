//
//  OSSVLanguageSettingVC.m
// XStarlinkProject
//
//  Created by odd on 2020/7/10.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVLanguageSettingVC.h"
#import "STLLanguageSettingCell.h"
#import "AppDelegate+STLCategory.h"
#import "RateModel.h"
#import "STLGetAppCopywritingApi.h"
#import "STLCommonRequestManager.h"
static NSString * const kLangugeIdentifier = @"kLangugeIdentifier";

@interface OSSVLanguageSettingVC () <UITableViewDelegate, UITableViewDataSource> {
    NSInteger _selectedIndex;
    NSInteger _oldSelectedIndex;
}

@property (nonatomic, strong) NSArray <STLSupportLangModel *>*languageArray;
@property (nonatomic, strong) UITableView                   *langugeTableView;
@property (nonatomic, strong) UIImageView                   *accesoryImageView;
@property (nonatomic, strong) UIButton                      *saveButton;
@end


@implementation OSSVLanguageSettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self setupView];
}

- (void)setupView {
    [self.view addSubview:self.langugeTableView];
}

- (void)initData {
    self.title = STLLocalizedString_(@"Setting_Cell_Languege", nil);
    self.view.backgroundColor = STLThemeColor.col_F5F5F5;
    // 从我的模块进来
    NSArray <STLSupportLangModel *>*countrySupportLang = [STLLocalizationString shareLocalizable].languageArray;
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
    NSString *selecteLang = [STLLocalizationString shareLocalizable].nomarLocalizable;
    
    // 从启动引导进来只返回引导页
    if (self.comeFromType == LangugeSettingComeFrom_GuideSettingVC) {
        if (!STLIsEmptyString(self.shouldSelectedShortenedLang)) {
            selecteLang = self.shouldSelectedShortenedLang;
        }
    }

    _selectedIndex = 0;
    for (NSInteger i = 0; i < self.languageArray.count; i++) {
        STLSupportLangModel *model = self.languageArray[i];
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
    STLLanguageSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:kLangugeIdentifier];
    cell.contentLabel.text = self.languageArray[indexPath.row].name;
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
    [STLCommonRequestManager getAppCopywriting];
    __block NSString *oldLanguage = [STLLocalizationString shareLocalizable].nomarLocalizable;
    //只有用户手动选择了语言，才保存
    STLSupportLangModel *supportModel = self.languageArray[_selectedIndex];
    NSString *selectLanguage = supportModel.code;
    [STLLocalizationString shareLocalizable].nomarLocalizable = selectLanguage;
    [[STLLocalizationString shareLocalizable] saveUserSelectLanguage:selectLanguage];
    [[STLLocalizationString shareLocalizable] saveNomarLocalizableLanguage:selectLanguage];

    [STLAnalytics sensorsDynamicConfigure];

    
//    [self changeCurrency:selectLanguage];
    
    // 从启动引导进来只返回引导页面
    if (self.comeFromType == LangugeSettingComeFrom_GuideSettingVC) {
        if (self.convertLangugeBlock) {
            NSString *selectedLanguge = supportModel.name;//全称
            NSString *shortenedLang = supportModel.code;//简称:两个字母
            self.convertLangugeBlock(selectedLanguge, shortenedLang);
        }
        [self goBackAction];
        
    } else { // 从我的模块进来
           
        //切换语言后切换系统UI布局方式
        [UIViewController convertAppUILayoutDirection];
        
        // 重新初始化AppTabbr
        [OSSVLanguageSettingVC initAppTabBarVCFromChangeLanguge:STLMainMoudleAccount completion:^(BOOL success) {
            if (!success) {
                //回滚语言切换
                [STLLocalizationString shareLocalizable].nomarLocalizable = oldLanguage;
                [[STLLocalizationString shareLocalizable] saveNomarLocalizableLanguage:oldLanguage];
                
//                [self changeCurrency:oldLanguage];
            }
        }];
    }
    [IQKeyboardManager sharedManager].toolbarDoneBarButtonItemText = STLLocalizedString_(@"keyboard_Done", nil);
    [STLNavigationController initialize];
}

#pragma mark ----切换语言 从新获取一下文案的接口
- (void)getAppCopywriting {
    
    [[STLNetworkStateManager sharedManager] networkState:^{
        STLGetAppCopywritingApi *api = [[STLGetAppCopywritingApi alloc] init];
        [api startWithBlockSuccess:^(__kindof STLBaseRequest *request) {
            NSString *reg_page_text = @"";
            NSString *user_page_text = @"";
            NSString *taxText = @"";  //税务文案
        id requestJSON = [NSStringTool desEncrypt:request];
            if ([requestJSON isKindOfClass:[NSDictionary class]]) {
                if ([requestJSON[kStatusCode] integerValue] == kStatusCode_200) {
                    NSDictionary *resultDic = requestJSON[@"result"];
                    if (STLJudgeNSDictionary(resultDic)) {
                        taxText = STLToString(resultDic[@"order_tax_text"]);
                        STLUserDefaultsSet(@"tax", taxText);
                        [[NSUserDefaults standardUserDefaults] synchronize];

                        reg_page_text = STLToString(resultDic[@"reg_page_text"]);
                        user_page_text = STLToString(resultDic[@"user_page_text"]);
                    }

                }
            }
            [STLPushManager sharedInstance].tip_reg_page_text = reg_page_text;
            [STLPushManager sharedInstance].tip_user_page_text = user_page_text;

        } failure:^(__kindof STLBaseRequest *request, NSError *error) {
        
        }];
        
    } exception:^{
        
    }];
}
#pragma mark ---改变货币  -----1.2.4版本去掉这个
- (void)changeCurrency:(NSString *)lanage {
    
    //需求定的，不是阿语，都是美元货币
    NSString *specialCountryCoude = @"USD";
    if ([lanage isEqualToString:@"ar"]) {
        specialCountryCoude = @"SAR";
    }
    
    
    NSArray *array = [ExchangeManager currencyList];
    [array enumerateObjectsUsingBlock:^(RateModel   * _Nonnull  model, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([specialCountryCoude isEqualToString:model.code]) {
            [ExchangeManager updateLocalCurrencyWithRteModel:model];
            *stop = YES;
        }
    }];
}

/**
 * 切换语言,切换国家时 重新初始化AppTabbr, 刷新国家运营数据
 */
+ (void)initAppTabBarVCFromChangeLanguge:(NSInteger)tabBarIndex
{
    //切换语言后切换系统UI布局方式
    [UIViewController convertAppUILayoutDirection];
    
    
    // 切换语言后重新初始化Tabbar
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate initAppRootVC];
    appDelegate.tabBarVC.selectedIndex = tabBarIndex;
    
    // 保存LeandCloud数据
    [AccountManager saveLeandCloudData];

}

+ (void)initAppTabBarVCFromChangeLanguge:(NSInteger)tabBarIndex completion:(void(^)(BOOL success))completion
{
    // 切换语言后重新初始化Tabbar
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate initAppRootVC];
    
    // 保存LeandCloud数据
    [AccountManager saveLeandCloudData];
            
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
        _langugeTableView.contentInset = UIEdgeInsetsMake(12, 0, 0, 0);
        [_langugeTableView registerClass:[STLLanguageSettingCell class] forCellReuseIdentifier:kLangugeIdentifier];
    }
    return _langugeTableView;
}

- (UIImageView *)accesoryImageView {
    if (!_accesoryImageView) {
        UIImage *image = [UIImage imageNamed:@"refine_select"];
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
        _saveButton.titleLabel.font = FontWithSize(16);
        [_saveButton setTitleColor:STLThemeColor.col_333333 forState:UIControlStateNormal];
        [_saveButton setTitleColor:STLThemeColor.col_DDDDDD forState:UIControlStateDisabled];
        [_saveButton addTarget:self action:@selector(saveButtonAction) forControlEvents:UIControlEventTouchUpInside];
        
        NSString *title = STLLocalizedString_(@"english_save", nil);
        CGSize titleSize = [title sizeWithAttributes:@{NSFontAttributeName: [UIFont fontWithName:_saveButton.titleLabel.font.fontName size:_saveButton.titleLabel.font.pointSize]}];
        _saveButton.frame = CGRectMake(0.0, 0.0, titleSize.width, self.navigationController.navigationBar.height);
        [_saveButton setTitle:title forState:UIControlStateNormal];
    }
    return _saveButton;
}

@end
