//
//  ZFTestCMSViewController.m
//  ZZZZZ
//
//  Created by YW on 2018/12/19.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import "ZFTestCMSViewController.h"
#import "ZFTableViewManager.h"
#import "ZFAccountCountryViewController.h"
#import "ZFLangugeSettingViewController.h"
#import "ZFActionSheetView.h"
#import "DLChooseDateView.h"
#import "NSDate+ZFExtension.h"
#import "YWLocalHostManager.h"
#import "ZFThemeManager.h"
#import "ZFTabBarController.h"
#import "ZFLocalizationString.h"
#import "SystemConfigUtils.h"
#import "ExchangeManager.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Constants.h"
#import "UIView+LayoutMethods.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "YSAlertView.h"
#import "YWLocalHostManager.h"
#import "ZFProgressHUD.h"
#import "ZFSettingTableViewCell.h"
#import "NSString+Extended.h"

@interface ZFTestCMSViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSArray               *tableDataArr;
@property (nonatomic, strong) UITableView           *tableView;
@property (nonatomic, strong) ZFTableViewManager    *tableViewManager;
@property (nonatomic, strong) ZFAddressCountryModel *selectedCountryModel;
@property (nonatomic, strong) NSString              *selectedShortenedLanguge;//语言简称:2个字母
@property (nonatomic, strong) NSString              *selectedLanguge;//语言全称
@property (nonatomic, strong) NSString              *selectedDate;//语言全称
@property (nonatomic, assign) NSInteger             isNewUser;//新老客
@end

@implementation ZFTestCMSViewController

/**
 * 清除历史选择的筛选条件
 */
- (void)clearCMSParmaterSift {
    self.selectedShortenedLanguge = nil;
    self.selectedLanguge = nil;
    self.selectedDate = nil;
    self.isNewUser = -1;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kTestCMSParmaterSiftKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"kTestCMSTime"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = ZFCOLOR(245, 245, 245, 1.0);
    
    NSDictionary *siftDict = GetUserDefault(kTestCMSParmaterSiftKey);
    if (ZFJudgeNSDictionary(siftDict) && siftDict.count >0) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"清除筛选" style:(UIBarButtonItemStylePlain) target:self action:@selector(clearCMSParmaterSift)];
    }
    
    if (![YWLocalHostManager isOnlineRelease]){ //⚠️警告: 当前类只供测试时使用
        self.selectedDate = ZFToString(GetUserDefault(@"kTestCMSTime"));
        
        self.isNewUser = -1;
        NSMutableDictionary *testDict = GetUserDefault(kTestCMSParmaterSiftKey);
        if (ZFJudgeNSDictionary(testDict)) {
            NSString *customer = testDict[@"is_new_customer"];
            if (!ZFIsEmptyString(customer)) {
                self.isNewUser = customer.integerValue;
            }
        }
        [self.view addSubview:self.tableView];
        [self addFooterView];
    } else {
        UILabel *tipLabel = [[UILabel alloc] initWithFrame:self.view.bounds];
        tipLabel.text = @"此功能只能在测试环境中使用";
        tipLabel.font = ZFFontSystemSize(25);
        tipLabel.y -= 88;
        tipLabel.textAlignment = NSTextAlignmentCenter;
        tipLabel.textColor = [UIColor grayColor];
        [self.view addSubview:tipLabel];
    }
}

- (NSArray *)tableDataArr {
    if(!_tableDataArr){
        _tableDataArr = [[NSArray alloc] initWithObjects:@"国家", @"语言", @"时间",
                         @"人群", @"切换分支", @"切换主页数据", nil];
    }
    return _tableDataArr;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.tableDataArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 12)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ZFSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ZFSettingTableViewCell class])];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.hideBottomLine = YES;
    cell.title = self.tableDataArr[indexPath.section];
    cell.detailTextColor = ColorHex_Alpha(0x999999, 1.0);
    cell.arrowImage = [UIImage imageNamed:@"account_arrow_right"];
    
    NSString *subText = @"";
    switch (indexPath.section) {
        case 0://国家
        {
            if (self.selectedCountryModel) {
                subText = self.selectedCountryModel.region_name;
            } else {
                subText = [AccountManager sharedManager].accountCountryModel.region_name;
            }
        }
            break;
        case 1://语言
        {
            if (self.selectedLanguge) {
                subText = self.selectedLanguge;
            } else {
                subText = [[ZFLocalizationString shareLocalizable] currentLanguageName];
            }
        }
            break;
        case 2://时间
        {
            subText = ZFToString(self.selectedDate);
        }
            break;
        case 3: //人群
        {
            if (self.isNewUser == 1) {
                subText =  @"新客";
            } else if (self.isNewUser == 0) {
                subText =  @"老客";
            }
        }
            break;
        case 4: //切分支
        {
            NSString *currentCMSBranch = GetUserDefault(kInputCMSBranchKey);
            if (ZFIsEmptyString(currentCMSBranch)) {
                subText = @"默认分支: release";
            } else {
                subText = [NSString stringWithFormat:@"当前分支: %@", currentCMSBranch];
            }
        }
            break;
        case 5: //切换主页数据
        {
            NSArray *CMSTitles = nil;
            if (![AccountManager sharedManager].homeDateIsCMSType) {
                CMSTitles = @[@"恢复到CMS正常数据\n", @"(目前主页为CMS备份数据)"];
            } else {
                CMSTitles = @[@"切换至CMS备份数据"];
            }
            //以高亮颜色提示 主页显示的是cms还是非cms数据
            NSArray *CMSColors = @[ColorHex_Alpha(0x999999, 1.0), [UIColor redColor]];
            NSArray *CMSFonts = @[ZFFontSystemSize(14), ZFFontSystemSize(10)];
            cell.attributedDetailTitle = [NSString getAttriStrByTextArray:CMSTitles
                                                                  fontArr:CMSFonts
                                                                 colorArr:CMSColors
                                                              lineSpacing:0
                                                                alignment:1];
            return cell;
        }
            break;
        default:
            break;
    }
    cell.detailTitle = subText;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0:
        {
            ZFAccountCountryViewController *vc = [[ZFAccountCountryViewController alloc] init];
            vc.comeFromType = CountryVCComeFrom_GuideCountry;            
            @weakify(self)
            vc.selectCountryBlcok = ^(ZFAddressCountryModel *model) {
                @strongify(self)
                self.selectedCountryModel = model;
                [self.tableView reloadData];
            };
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 1:
        {
            ZFLangugeSettingViewController *vc = [[ZFLangugeSettingViewController alloc] init];
            vc.comeFromType = LangugeSettingComeFrom_GuideSettingVC;
            @weakify(self)
            //selectedLanguge: 全称, shortenedLang:简称(两个字母)
            vc.convertLangugeBlock = ^(NSString *selectedLanguge, NSString *selectedShortenedLang){
                @strongify(self)
                self.selectedLanguge = selectedLanguge;
                self.selectedShortenedLanguge = selectedShortenedLang;
                [self.tableView reloadData];
            };
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 2:
        {
            // 选择时间
            DLChooseDateView *chooseDate = [DLChooseDateView showDateView:@"请选择时间" cancelBlock:nil confirmBlock:^(NSString *date) {
                self.selectedDate = date;
                [self.tableView reloadData];
            }];
            chooseDate.isSlide = NO;
        }
            break;
        case 3:
        {
            [ZFActionSheetView actionSheetByBottomCornerRadius:^(NSInteger buttonIndex, id title) {
                self.isNewUser = buttonIndex;
                [self.tableView reloadData];
            } cancelButtonBlock:nil sheetTitle:nil cancelButtonTitle:@"取消" otherButtonTitleArr:@[@"老客", @"新客"]];
        }
            break;
        case 4: //切CMS分支
        {
            if ([YWLocalHostManager isPreRelease]) {
                ShowToastToViewWithText(nil, @"请先切换到测试环境再操作");
                return;
            }
            
            NSString *currentCMSBranch = GetUserDefault(kInputCMSBranchKey);
            if (ZFIsEmptyString(currentCMSBranch)) {
                currentCMSBranch = @"develop";
            }
            NSString *message = [NSString stringWithFormat:@"\n当前CMS分支: %@ \n注意: 切换会立即重启App", currentCMSBranch];
            [YSAlertView inputAlertWithTitle:@"👉切换CMS测试分支👈"
                                     message:message
                                        text:nil
                                 placeholder:@"请输入CMS分支名称"
                                 cancelTitle:@"取消"
                                  otherTitle:@"确认"
                                keyboardType:0
                                 buttonBlock:^(NSString *inputText) {
                                     
                                     if (ZFIsEmptyString(inputText)) {
                                         inputText = @"release";
                                     }
                                     SaveUserDefault(kInputCMSBranchKey, ZFToString(inputText));
                                     ShowToastToViewWithText(nil, [NSString stringWithFormat:@"切换%@成功, ,退出后请手动启动Appp", inputText]);
                                     [YWLocalHostManager clearZFNetworkCache];
                
                                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                        [YWLocalHostManager logOutApplication];
                                    });
                                     
            } cancelBlock:nil];
        }
            break;
        case 5:
        {
            if ([YWLocalHostManager isOnlineRelease]) {
                ShowAlertSingleBtnView(@"温馨提示", @"CMS条件筛选功能在线上环境中禁止操作", @"好的");
            } else {
                BOOL isMainCMSType = NO;
                if (![AccountManager sharedManager].homeDateIsCMSType) {
                    isMainCMSType = YES;
                }
                ZFPostNotification(kConvertToBackupsDataNotification, @(isMainCMSType));
                ShowToastToViewWithText(nil, @"主页切换至备份数据成功");
                [self goBackAction];
            }
        }
            break;
        default:
            break;
    }
}

/**
 *  保存所有更改的 测试 设置数据
 */
- (void)saveTestChangeData {
    // 包装测试参数
    NSMutableDictionary *testDict = [NSMutableDictionary dictionary];
    if (!ZFIsEmptyString(self.selectedDate)) {
        testDict[@"time"] = @([NSDate timeSwitchTimestamp:self.selectedDate andFormatter:@"yyyy-MM-dd HH:mm:ss"]);
        SaveUserDefault(@"kTestCMSTime", ZFToString(self.selectedDate));
    }
    if (self.isNewUser != -1) {
        testDict[@"is_new_customer"] = (self.isNewUser==1) ? @"1" : @"0";
    }
    SaveUserDefault(kTestCMSParmaterSiftKey, testDict);
    
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
    }

    // 保存更改切换的语言
    if (!ZFIsEmptyString(self.selectedShortenedLanguge)) {
        [ZFLocalizationString shareLocalizable].nomarLocalizable = self.selectedShortenedLanguge;
        // 切换语言后切换系统UI布局方式
        [UIViewController convertAppUILayoutDirection];
        // 切换语言统计
        [ZFLangugeSettingViewController convertLangugeAnalytic];
        
        // 重新初始化AppTabbr
        [ZFLangugeSettingViewController initAppTabBarVCFromChangeLanguge:TabBarIndexHome];
    } else {
        // 返回前通知刷新页面
        ZFPostNotification(kCMSTestSiftDataNotification, nil);
        [super goBackAction];
    }
}

#pragma mark -===========初始化UI===========

- (UITableView *)tableView {
    if (!_tableView) {
        CGRect rect = CGRectMake(0, 0, KScreenWidth, KScreenHeight - (STATUSHEIGHT + NAVBARHEIGHT + 45 + (IPHONE_X_5_15 ? 34 : 10)));
        _tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
        _tableView.backgroundColor = ZFCOLOR(245, 245, 245, 1.0);
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 44;
        _tableView.sectionHeaderHeight = 12;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.tableFooterView = [UIView new];
        [_tableView registerClass:[ZFSettingTableViewCell class] forCellReuseIdentifier:NSStringFromClass([ZFSettingTableViewCell class])];
    }
    return _tableView;
}

- (void)addFooterView {
    UIButton *okButton = [UIButton buttonWithType:UIButtonTypeCustom];
    okButton.frame = CGRectMake(16, CGRectGetMaxY(self.tableView.frame)- (IPHONE_X_5_15 ? 34 : 10), KScreenWidth-32, 45);
    [okButton setBackgroundColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
    [okButton setBackgroundColor:ZFC0x2D2D2D_08() forState:UIControlStateHighlighted];
    okButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [okButton setTitleColor:ZFCOLOR_WHITE forState:UIControlStateNormal];
    [okButton setTitle:@"确  定" forState:UIControlStateNormal];
    okButton.layer.cornerRadius = 3;
    okButton.layer.masksToBounds = YES;
    [okButton addTarget:self action:@selector(okButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:okButton];
}

- (void)okButtonAction:(UIButton *)buttom {
    [self saveTestChangeData];
}

@end

