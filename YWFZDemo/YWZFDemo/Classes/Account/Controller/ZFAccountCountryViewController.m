//
//  ZFAccountCountryViewController.m
//  ZZZZZ
//
//  Created by YW on 2018/6/19.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFAccountCountryViewController.h"
#import "ZFInitViewProtocol.h"
#import "ZFAddressCountryViewModel.h"
#import "ZFAddressCountryModel.h"
#import "ZFAddressCountrySearchResultView.h"
#import "UIImage+YYWebImage.h"
#import "ZFCommuntityGestureTableView.h"
#import "ZFLangugeSettingViewController.h"
#import "ZFThemeManager.h"
#import "IQKeyboardManager.h"
#import "ZFProgressHUD.h"
#import "UIView+ZFViewCategorySet.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "ZFLocalizationString.h"
#import "NSObject+Swizzling.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "YSAlertView.h"
#import "ZFRefreshHeader.h"
#import "ZFRefreshFooter.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFBTSManager.h"
#import "ZFCellHeightManager.h"
#import "UIImage+ZFExtended.h"
#import "NSStringUtils.h"
//当前国家标识
#define kCurrentCountryIndexKey     @"#"
#define KCurrentCountryText         ZFLocalizedString(@"AccountCountry_VC_SelectedCountry", nil)

@interface ZFAccountCountryViewController () <ZFInitViewProtocol, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) ZFCountryTableView                                *tableView;
@property (nonatomic, strong) ZFAddressCountrySearchResultView                  *searchResultView;
@property (nonatomic, strong) UISearchBar                                       *searchBar;
@property (nonatomic, strong) ZFAddressCountryViewModel                         *viewModel;
@property (nonatomic, strong) NSArray<ZFAddressCountryModel *>                  *countryArray;
@property (nonatomic, strong) NSMutableArray                                    *keysArray;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray *> *countryList;
@property (nonatomic, strong) NSIndexPath                                       *seletedIndexPath;
@property (nonatomic, strong) NSString                                          *currentRegion_id;
@property (nonatomic, assign) BOOL                                              hasAlreadySeleted;
@end

@implementation ZFAccountCountryViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self zfInitView];
    [self zfAutoLayoutView];
    [self.tableView.mj_header beginRefreshing];
}

#pragma mark - action methods
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)doneButtonAction:(UIButton *)sender {
    [self.view endEditing:YES];
}

#pragma mark - private methods

- (void)scrollToSeletedIndexPath {
    
    if (self.comeFromType == CountryVCComeFrom_GuideCountry) {
        
        // 从启动引导进来滚动到之前选择的行
        if (!self.shouldSelectedModel) return;
        
        for (NSInteger i=0; i < self.keysArray.count; i++) {
            NSInteger rowCount = self.countryList[self.keysArray[i]].count;
            NSString *key = self.keysArray[i];
            for (NSInteger j=0; j<rowCount; j++) {
                ZFAddressCountryModel *model = self.countryList[key][j];
                if ([self.shouldSelectedModel.region_id isEqualToString:model.region_id]) {
                    self.seletedIndexPath = [NSIndexPath indexPathForRow:j inSection:i];
                    [self.tableView scrollToRowAtIndexPath:self.seletedIndexPath atScrollPosition:(UITableViewScrollPositionTop) animated:NO];
                }
            }
        }
        
    } else {
        if (self.seletedIndexPath) {
            [self.tableView scrollToRowAtIndexPath:self.seletedIndexPath atScrollPosition:(UITableViewScrollPositionTop) animated:NO];
        }
    }
}

- (void)dealWithCountryInfoData {
    [self.countryList removeAllObjects];
    [self.keysArray removeAllObjects];
    ZFAddressCountryModel *accountCountryModel = [AccountManager sharedManager].accountCountryModel;
    
    [self.countryArray enumerateObjectsUsingBlock:^(ZFAddressCountryModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.region_name.length > 0) {
            
            NSString *key = [obj.region_name substringWithRange:NSMakeRange(0, 1)];
            key = [NSStringUtils firstCharactersCapitalized:key];
            
            if ([self.countryList objectForKey:key]) {
                NSMutableArray *values = [self.countryList objectForKey:key];
                [values addObject:obj];
                [self.countryList setObject:values forKey:key];
                
                if (accountCountryModel && [self.currentRegion_id isEqualToString:obj.region_id]) {
                    if ([self.keysArray containsObject:key]) {
                        NSInteger section = [self.keysArray indexOfObject:key];
                        self.seletedIndexPath = [NSIndexPath indexPathForRow:values.count-1 inSection:section];
                    }
                }
                
            } else {
                [self.keysArray addObject:key];
                
                //需要特殊处理显示当前国家 例如: #USA
                if ([key isEqualToString:kCurrentCountryIndexKey]){
                    obj.region_name = [obj.region_name substringWithRange:NSMakeRange(1, obj.region_name.length-1)];
                    if (accountCountryModel && ZFToString(accountCountryModel.region_id).length) {
                        self.currentRegion_id = accountCountryModel.region_id;
                    } else {
                        self.currentRegion_id = obj.region_id;
                    }
                }
                
                //只有当已经切换过国家才显示打钩
                if (accountCountryModel && [self.currentRegion_id isEqualToString:obj.region_id]) {
                    if ([self.keysArray containsObject:key]) {
                        NSInteger section = [self.keysArray indexOfObject:key];
                        self.seletedIndexPath = [NSIndexPath indexPathForRow:0 inSection:section];
                    }
                }
                
                NSMutableArray *values = [NSMutableArray array];
                [values addObject:obj];
                [self.countryList setObject:values forKey:key];
            }
        }
    }];
}

- (NSMutableArray *)smartMatchSearchResultWithKey:(NSString *)key {
    NSMutableArray<ZFAddressCountryModel *> *searchResult = [NSMutableArray array];
    [self.countryArray enumerateObjectsUsingBlock:^(ZFAddressCountryModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSUInteger first = 0, second = 0, hash = 0; //hash记录权值， INF为不匹配状态，否则为匹配状态，使用二进制按位标记。权值小排前面，权值相同采用字典序。
        while (first < obj.region_name.length && second < key.length) {
            NSString *first_str = [[obj.region_name substringWithRange:NSMakeRange(first, 1)] lowercaseString];
            NSString *second_str = [[key substringWithRange:NSMakeRange(second, 1)] lowercaseString];
            if ([first_str isEqualToString:second_str]) {   //匹配到对应位置，
                hash |= (1 << first);
                ++first;
                ++second;
            } else {
                ++first;
            }
        }
        //判断当前second是不是已经匹配完key, 如果匹配完，更新权值，并将匹配到的model加入到搜索结果数组中。
        if (second == key.length) { //匹配完状态
            obj.hashCost = hash;
            [searchResult addObject:obj];
        }
    }];
    NSMutableArray<ZFAddressCountryModel *> *sortSearchArray = [NSMutableArray arrayWithArray:[searchResult sortedArrayUsingComparator:^NSComparisonResult(ZFAddressCountryModel *  _Nonnull obj1, ZFAddressCountryModel *  _Nonnull obj2) {
        return obj1.hashCost > obj2.hashCost ? NSOrderedDescending : obj1.hashCost < obj2.hashCost ? NSOrderedAscending: NSOrderedSame;
    }]];
    return sortSearchArray;
}

#pragma mark - <UISearchBarDelegate>
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length == 0 || self.countryArray.count == 0) {
        self.searchResultView.hidden = YES;
        return ;
    }
    //筛选处理数据源
    self.searchResultView.dataArray = [self smartMatchSearchResultWithKey:searchText];
    self.searchResultView.hidden = NO;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.searchResultView.dataArray removeAllObjects];
    self.searchResultView.hidden = YES;
    searchBar.text = @"";
}

#pragma mark - <UITableViewDelegate, UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.keysArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.countryList[self.keysArray[section]].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"addressCountryCell"];
    [cell.textLabel convertTextAlignmentWithARLanguage];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryView = nil;
    if ([self.seletedIndexPath isEqual:indexPath]) {
        cell.accessoryView = [[UIImageView alloc] initWithImage:[ZFImageWithName(@"refine_select") imageWithColor:ZFC0xFE5269()]];
    }
    NSString *key = self.keysArray[indexPath.section];
    ZFAddressCountryModel *model = self.countryList[key][indexPath.row];
    cell.textLabel.text = model.region_name;
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"addressContryHeaderIdentifer"];
    NSString *key = self.keysArray[section];
    
    //这里自定义:系统的textLabel改不了字体
    UILabel *keyLabel = [[UILabel alloc] init];
    //需要特殊处理显示当前国家 例如: #USA
    if ([key isEqualToString:kCurrentCountryIndexKey]) {
        key = KCurrentCountryText;
    }
    keyLabel.font = ZFFontSystemSize(14);
    keyLabel.textColor = ColorHex_Alpha(0x999999, 1);
    keyLabel.text = key;
    [keyLabel convertTextAlignmentWithARLanguage];
    keyLabel.frame = CGRectMake(18, 0, KScreenWidth-18*2, 24);
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 24)];
    bgView.backgroundColor = ZFC0xF2F2F2();
    [bgView addSubview:keyLabel];
    header.backgroundView = bgView;
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 24;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 48;
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.keysArray;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    [self.tableView refreshFloatIndexView:title index:index];
    return index;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSArray *visallCell = self.tableView.visibleCells;
    UITableViewCell *firstCell = visallCell.firstObject;
    if (firstCell) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:firstCell];
        if (indexPath && self.keysArray.count > indexPath.section) {
            NSString *title = self.keysArray[indexPath.section];
            
            if (title && ![self.tableView.currentTitle isEqualToString:title]) {
                [self.tableView refreshFloatIndexView:title index:indexPath.section];
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.seletedIndexPath == indexPath) {
        return;
    }
    if (self.hasAlreadySeleted) return; //禁止多次点击
    
    //引导页不弹
    if (self.comeFromType == CountryVCComeFrom_GuideCountry) {
        
        self.hasAlreadySeleted = YES;
        
        NSString *sectionKey = self.keysArray[indexPath.section];
        ZFAddressCountryModel *accountCountryModel = self.countryList[sectionKey][indexPath.row];
        
        // 刷新Cell选中状态
        NSIndexPath *oldSelectedPath = self.seletedIndexPath ? : indexPath;
        self.seletedIndexPath = indexPath;
        [tableView reloadRowsAtIndexPaths:@[self.seletedIndexPath,oldSelectedPath] withRowAnimation:(UITableViewRowAnimationNone)];
        
        // 更新选择国家信息
        [self saveSelectedCountryData:accountCountryModel];
        
    } else { //内部每次都弹
        
        // 刷新Cell选中状态
        NSIndexPath *oldSelectedPath = self.seletedIndexPath ? : indexPath;
        self.seletedIndexPath = indexPath;
        [tableView reloadRowsAtIndexPaths:@[indexPath,oldSelectedPath] withRowAnimation:(UITableViewRowAnimationNone)];
        
        NSString *message = ZFLocalizedString(@"first_change_country_tip",nil);
        NSString *noTitle = ZFLocalizedString(@"first_change_country_CANCEL",nil);
        NSString *yesTitle = ZFLocalizedString(@"first_change_country_CONTINUE",nil);
        
        ShowAlertView(nil, message, @[yesTitle], ^(NSInteger buttonIndex, id buttonTitle) {
            
            self.hasAlreadySeleted = YES;
            NSString *sectionKey = self.keysArray[indexPath.section];
            ZFAddressCountryModel *accountCountryModel = self.countryList[sectionKey][indexPath.row];
            [self saveSelectedCountryData:accountCountryModel];
            
        }, noTitle, ^(id cancelTitle) {
            //取消还原设置
            self.hasAlreadySeleted = NO;
            self.seletedIndexPath = oldSelectedPath;
            [tableView reloadRowsAtIndexPaths:@[indexPath,oldSelectedPath] withRowAnimation:(UITableViewRowAnimationNone)];
        });
    }
}

#pragma mark -===========更新选择国家信息===========

/**
 * 更新选择国家信息
 */
- (void)saveSelectedCountryData:(ZFAddressCountryModel *)accountCountryModel
{
    __block NSString *countryCode = nil;
    __block NSString *countryLanauge = nil;
    __block ZFAddressCountryModel *oldAccountModel = [AccountManager sharedManager].accountCountryModel;

    //从启动引导设置国家信息进来要到引导页保存国家信息
    ZFSupportLangModel *supporModel = [[ZFLocalizationString shareLocalizable] filterSupporlang:accountCountryModel.support_lang];
    countryCode = supporModel.code;
    countryLanauge = supporModel.name;
    [ZFLocalizationString shareLocalizable].nomarLocalizable = supporModel.code;
    
    if (ZFToString(countryCode).length) {
        accountCountryModel.code = countryCode;
        accountCountryModel.supportLanguage = countryLanauge;
    }
    
    if (self.comeFromType != CountryVCComeFrom_GuideCountry) {
        SaveUserDefault(kHasChangeCurrencyKey, @(NO));
        [AccountManager sharedManager].accountCountryModel = accountCountryModel;
        
        [[ZFLocalizationString shareLocalizable] saveNomarLocalizableLanguage:supporModel.code];
        [ZFLocalizationString shareLocalizable].languageArray = accountCountryModel.support_lang;
        ShowToastToViewWithText(self.view, ZFLocalizedString(@"Success",nil));
    }

    if (self.selectCountryBlcok) {
        //从引导页进入的时候，不需要保存语言，因为外部有一个保存按钮，点击那个保存按钮才需要保存
        self.selectCountryBlcok(accountCountryModel);
    }

    /** 业务需求:
     * 1. 切换国家, 更新汇率
     * 2. 发送改变货币类型通知刷新所有页面数据
     * 3. 首页banner接口需要根据选中的国家传标识来返回banner数据
     */
    //[[NSNotificationCenter defaultCenter] postNotificationName:kCurrencyNotification object:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.comeFromType == CountryVCComeFrom_GuideCountry) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            // 切换语言,切换国家时 重新初始化AppTabbr, 刷新国家运营数据
            [ZFLangugeSettingViewController initAppTabBarVCFromChangeLanguge:TabBarIndexAccount completion:^(BOOL success) {
                if (success) {
                    // 清除所有bts
                    [ZFBTSManager clearBTSWithPlancodeArray:nil];
                    [[ZFCellHeightManager shareManager] clearCaches];
                } else {
                    //回滚数据
                    [AccountManager sharedManager].accountCountryModel = oldAccountModel;
                    [[ZFLocalizationString shareLocalizable] saveNomarLocalizableLanguage:oldAccountModel.code];
                    [ZFLocalizationString shareLocalizable].languageArray = oldAccountModel.support_lang;
                }
            }];
        }
    });
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.title = ZFLocalizedString(@"modifyAddress_countryCity_country", nil);
    self.view.backgroundColor = ZFCOLOR_WHITE;
    [self.view addSubview:self.searchBar];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.searchResultView];
}

- (void)zfAutoLayoutView {
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.mas_equalTo(self.view);
        make.height.mas_equalTo(@50);
    }];

    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(self.view);
        make.top.mas_equalTo(self.searchBar.mas_bottom);
    }];
    
    [self.searchResultView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(self.view);
        make.top.mas_equalTo(self.searchBar.mas_bottom);
    }];
}

#pragma mark - getter

/**
 * 请求个人中心获取国家地址接口
 */
- (void)requestCountryData {
    @weakify(self)
    [ZFAddressCountryViewModel getMemberCountryListData:^(NSArray *countryDataArr) {
        @strongify(self)
        self.countryArray = countryDataArr;
        [self dealWithCountryInfoData];
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
        self.searchBar.userInteractionEnabled = YES;
        [self scrollToSeletedIndexPath];
        
    } failure:^(NSString *tipStr) {
        @strongify(self)
        self.tableView.emptyDataImage = [UIImage imageNamed:@"blankPage_noAddress"];
        self.tableView.emptyDataTitle = ZFLocalizedString(@"EmptyCustomViewHasNoData_titleLabel",nil);
        [self.tableView reloadData];
        [self.tableView showRequestTip:nil];
    }];
}

- (ZFAddressCountrySearchResultView *)searchResultView {
    if (!_searchResultView) {
        _searchResultView = [[ZFAddressCountrySearchResultView alloc] initWithFrame:CGRectZero];
        _searchResultView.hidden = YES;
        
        @weakify(self);
        _searchResultView.addressCountryResultSelectCompletionHandler = ^(ZFAddressCountryModel *accountCountryModel) {
            @strongify(self);
            
            //引导页不弹
             if (self.comeFromType == CountryVCComeFrom_GuideCountry) {
                 [self saveSelectedCountryData:accountCountryModel];

             } else { //内部每次都弹
                 NSString *message = ZFLocalizedString(@"first_change_country_tip",nil);
                 NSString *noTitle = ZFLocalizedString(@"first_change_country_CANCEL",nil);
                 NSString *yesTitle = ZFLocalizedString(@"first_change_country_CONTINUE",nil);
                 
                 ShowAlertView(nil, message, @[yesTitle], ^(NSInteger buttonIndex, id buttonTitle) {
                     [self saveSelectedCountryData:accountCountryModel];
                 }, noTitle, ^(id cancelTitle) {
                     [self.searchResultView cancelSelect];
                 });
             }
        };
    }
    return _searchResultView;
}

- (ZFCountryTableView *)tableView {
    if (!_tableView) {
        _tableView = [[ZFCountryTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        _tableView.sectionIndexColor = ZFC0x999999();
        _tableView.sectionIndexTrackingBackgroundColor = [UIColor clearColor];
        _tableView.sectionIndexBackgroundColor = [UIColor clearColor];
        _tableView.tableFooterView = [UIView new];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"addressCountryCell"];
        [_tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"addressContryHeaderIdentifer"];
        
        @weakify(self);
        _tableView.mj_header = [ZFRefreshHeader headerWithRefreshingBlock:^{
            @strongify(self)
            [self requestCountryData];
        }];
    }
    return _tableView;
}

- (UISearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
        _searchBar.backgroundImage =  [UIImage yy_imageWithColor:[UIColor whiteColor] size:CGSizeMake(KScreenWidth, 52)];
        _searchBar.tintColor = [UIColor blackColor];
        UIImage *searchFieldImage = [UIImage yy_imageWithColor:ColorHex_Alpha(0xF7F7F7, 1) size:CGSizeMake(KScreenWidth-8*2, 36)];
        [_searchBar setSearchFieldBackgroundImage:searchFieldImage forState:(UIControlStateNormal)];
        NSString *placeholder = [NSString stringWithFormat:@" %@", ZFLocalizedString(@"Search_PlaceHolder_Search", nil)];
        _searchBar.placeholder = placeholder;
        [_searchBar setImage:ZFImageWithName(@"account_country_searchIcon") forSearchBarIcon:(UISearchBarIconSearch) state:0];
        _searchBar.delegate = self;
        _searchBar.userInteractionEnabled = NO;
        [_searchBar addDoneOnKeyboardWithTarget:self action:@selector(doneButtonAction:)];
        
        // 修改search字体大小
        if ([UISearchBar zf_hasVarName:@"searchField"]) {
            UITextField *searchField = [self.searchBar valueForKey:@"searchField"];
            if ([searchField isKindOfClass:[UITextField class]]) {
                searchField.font = ZFFontSystemSize(14);
                
                NSString *searchStr = [NSString stringWithFormat:@" %@", ZFLocalizedString(@"Search_PlaceHolder_Search", nil)];
                NSMutableAttributedString *placeholderStr = [[NSMutableAttributedString alloc] initWithString:searchStr];
                [placeholderStr addAttribute:NSForegroundColorAttributeName value:ColorHex_Alpha(0x999999, 1) range:NSMakeRange(0, searchStr.length)];
                searchField.attributedPlaceholder = placeholderStr;
            }
        }
    }
    return _searchBar;
}

- (NSMutableArray *)keysArray {
    if (!_keysArray) {
        _keysArray = [NSMutableArray array];
    }
    return _keysArray;
}

- (NSMutableDictionary<NSString *,NSMutableArray *> *)countryList {
    if (!_countryList) {
        _countryList = [NSMutableDictionary dictionary];
    }
    return _countryList;
}
@end
