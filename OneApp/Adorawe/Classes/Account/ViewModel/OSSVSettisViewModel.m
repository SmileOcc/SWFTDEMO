//
//  OSSVSettisViewModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/2.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVSettisViewModel.h"
#import "OSSVSettingsTablesCell.h"

#import "GBSettingItem.h"
#import "GBSettingArrowItem.h"
#import "GBSettingLabelItem.h"
#import "GBSettingGroup.h"
#import "GBSettingCell.h"
#import "OSSVNotificationSettingsVC.h"
#import "OSSVLanguageSettingVC.h"
#import "OSSVChecksUpadtesAip.h"
#import "OSSVUpdatesContentsModel.h"
#import "OSSVCheckUpdatesModel.h"


#import "ExchangeManager.h"
#import "RateModel.h"
#import "CacheFileManager.h"

typedef NS_OPTIONS(NSUInteger, SettingEnumIndex) {
    SettingEnumCurrencyIndex = 0,
    SettingEnumLanguageIndex,
    SettingEnumClearIndex,
    SettingEnumRateIndex,
    SettingEnumVersionIndex
};

@interface OSSVSettisViewModel ()

@property (nonatomic, strong) NSMutableArray    *dataArray;
@property (nonatomic, strong) NSArray           *pickerArray;
@property (nonatomic, weak) GBSettingItem       *currency;

@end

@implementation OSSVSettisViewModel

#pragma mark - Requset
- (void)requestNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
    
}

- (void)requestCheckUpdateNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
    @weakify(self)
    [[STLNetworkStateManager sharedManager] networkState:^{
        @strongify(self)
        @weakify(self)
        OSSVChecksUpadtesAip *api = [[OSSVChecksUpadtesAip alloc] init];
        [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            @strongify(self)
            id requestJSON = [OSSVNSStringTool desEncrypt:request];
            OSSVCheckUpdatesModel *model = [self dataAnalysisFromJson:requestJSON request:api];
            if (completion) {
                completion(model);
            }
            
        } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
            if (failure) {
                failure(nil);
            }
        }];
    } exception:^{
        if (failure) {
            failure(nil);
        }
    }];
}

- (id)dataAnalysisFromJson:(id)json request:(OSSVBasesRequests *)request {
    if ([request isKindOfClass:[OSSVChecksUpadtesAip class]]) {
        if ([json[kStatusCode] integerValue] == kStatusCode_200) {
            return [OSSVCheckUpdatesModel yy_modelWithJSON:json[kResult]];
        } else {
            [self alertMessage:json[@"message"]];
        }
    }
    return nil;
}

#pragma mark - TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    GBSettingGroup *group = self.dataArray[section];
    return group.items.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 1.创建cell
    GBSettingCell *cell = [GBSettingCell cellWithTableView:tableView];
    
    // 2.给cell传递模型数据
    GBSettingGroup *group = self.dataArray[indexPath.section];
    cell.item = group.items[indexPath.row];
    cell.lastRowInSection =  (group.items.count - 1 == indexPath.row);
    
    // 3.返回cell
    return cell;

}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // 分割线补全
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (self.dataArray.count - 1 == section) {
        return 0;
    }
    return 12;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *fotterView = [[UIView alloc] initWithFrame:CGRectZero];
    fotterView.backgroundColor = [OSSVThemesColors col_F5F5F5];
    return fotterView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // 1.取消选中这行
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // 2.模型数据
    GBSettingGroup *group = self.dataArray[indexPath.section];
    GBSettingItem *item = group.items[indexPath.row];
    
    
    if (item.option) { // block有值(点击这个cell,.有特定的操作需要执行)
        item.option();
    } else if ([item isKindOfClass:[GBSettingArrowItem class]]) { // 箭头
        GBSettingArrowItem *arrowItem = (GBSettingArrowItem *)item;
        STLLog(@"selectIndex == %lu",indexPath.row);
        // 如果没有需要跳转的控制器
        if (arrowItem.destVcClass == nil)  return;
        
        UIViewController *nextVC = [[arrowItem.destVcClass alloc] init];
        nextVC.title = arrowItem.title;
        [self.controller.navigationController pushViewController:nextVC animated:YES];
    }
}

- (void)updateCurrentCurrency {
    RateModel *curRateModel = [ExchangeManager localCurrency];
    self.currency.content = [NSString stringWithFormat:@"%@ %@", curRateModel.code, curRateModel.symbol];
}

#pragma mark 这里就是选择了PickerView返回的值
- (void)pickerViewDidSelected:(UIPickerView *)pickerView {
    NSInteger index = [pickerView selectedRowInComponent:0];
//    STLLog(@"selectPickerValue ======== %@",self.pickerArray[index]);
    // 获取到返回的值后，如何来刷新 tableView
    if (![self.pickerArray isKindOfClass:[NSArray class]] && !self.pickerArray.count) {
        return;
    }
    if (self.pickerArray[index]) {
        self.currency.content = self.pickerArray[index];
        NSArray *rateArr = [ExchangeManager currencyList];
        if (rateArr.count > index) {
            RateModel *curRateModel = rateArr[index];
            [ExchangeManager updateLocalCurrencyWithRteModel:curRateModel];
        }
        
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        [user setBool:YES forKey:kIsSettingCurrentKey];
        [user synchronize];
        /**
         *  发送改变货币类型通知
         */
//        [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_Currency object:nil];
        
//        // 保存LeandCloud数据
//        [OSSVAccountsManager saveLeandCloudData];
        [OSSVLanguageSettingVC initAppTabBarVCFromChangeLanguge:STLMainMoudleAccount completion:^(BOOL success) {
            
        }];

    }
}

#pragma mark - UIPickerViewDataSource
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [self.pickerArray count];
}

-(NSString*) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [self.pickerArray objectAtIndex:row];
}


#pragma mark - LoadData
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
        [self setupGroupSection];
        
    }
    return _dataArray;
}

- (void)setupGroupSection {
    
    RateModel *curRateModel = [ExchangeManager localCurrency];
    NSString *currencyString = [NSString stringWithFormat:@"%@ %@", curRateModel.code, curRateModel.symbol];
    if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
        currencyString = [NSString stringWithFormat:@"%@ %@", curRateModel.symbol,curRateModel.code];
    }
    GBSettingItem *currencyItem = [GBSettingLabelItem itemWithTitle:STLLocalizedString_(@"Currency", nil) content:currencyString];
    @weakify(self)
    currencyItem.option = ^{
        @strongify(self)
        if (self.showPickerBlock) {
            self.showPickerBlock();
        }
    };
    self.currency = currencyItem;
    
    NSString *currentLanagure = [STLLocalizationString shareLocalizable].currentLanguageName;
    
    GBSettingItem *langageItem = [GBSettingLabelItem itemWithTitle:STLLocalizedString_(@"Setting_Cell_Languege", nil) content:[NSString stringWithFormat:@"%@", currentLanagure]];
    langageItem.option = ^{
        @strongify(self)
        if (self.langageBlock) {
            self.langageBlock();
        }
    };
    
    GBSettingItem *clearItem  = [GBSettingLabelItem itemWithTitle:STLLocalizedString_(@"Clear_Cache", nil) content:[NSString stringWithFormat:@"%.1lf M",[CacheFileManager folderSizeAtPath:STL_PATH_CACHE]]];
    @weakify(clearItem)
    clearItem.option = ^{
        @strongify(clearItem)
        [CacheFileManager clearCache:STL_PATH_CACHE];
        clearItem.content = [NSString stringWithFormat:@"%.1lf M",[CacheFileManager folderSizeAtPath:STL_PATH_CACHE]];
        //////预发布不清楚cookie
        if (![OSSVConfigDomainsManager isPreRelease]) {
            NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
            for (NSHTTPCookie *cookie in [storage cookies])
            {
                [storage deleteCookie:cookie];
            }
        }
        [self alertMessage:STLLocalizedString_(@"clearCache_Tip", nil)];
    };
    
    GBSettingItem *goToAppStoreItem = [GBSettingArrowItem itemWithTitle:STLLocalizedString_(@"RateUs", nil)  destVcClass:nil];
    goToAppStoreItem.option = ^{
        [SHAREDAPP openURL:[NSURL URLWithString:REMOVE_URLENCODING([OSSVLocaslHosstManager appStoreReviewUrl])] options:@{} completionHandler:nil];
    };
    GBSettingItem *versionItem = [GBSettingLabelItem itemWithTitle:STLLocalizedString_(@"Version", nil)  content:kAppVersion];
  
    versionItem.option = ^{
        // 检测是否是最新版本
        @strongify(self)
        @weakify(self)
        [self requestCheckUpdateNetwork:nil completion:^(id obj) {  //这里请求后台，返回当前版本号
            @strongify(self)
            OSSVCheckUpdatesModel *checkModel = (OSSVCheckUpdatesModel *)obj;
            if (checkModel.isNeedUpdate){
                
                OSSVUpdatesContentsModel *contentmodel = [OSSVUpdatesContentsModel yy_modelWithDictionary:checkModel.updateContent];
                STLAlertViewController *alertController =  [STLAlertViewController
                                                       alertControllerWithTitle: STLLocalizedString_(@"updatesInformation",nil)
                                                       message:contentmodel.content
                                                       preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:STLLocalizedString_(@"updateRemindMeLater", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                    
                }];
                
                UIAlertAction * doneAction = [UIAlertAction actionWithTitle:STLLocalizedString_(@"updateNow", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        
                    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:contentmodel.url]]) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:contentmodel.url] options:@{} completionHandler:nil];

                    }
                   
                }];
                [alertController addAction:cancelAction];
                [alertController addAction:doneAction];
                [self.controller presentViewController:alertController animated:YES completion:nil];
            } else {
                 [self alertMessage:STLLocalizedString_(@"versionNotNeedUpdate", nil)];
            }
        } failure:^(id obj) {
            
        }];
        
    };

    GBSettingItem *notificationItem = [GBSettingArrowItem itemWithTitle:STLLocalizedString_(@"notification", nil) destVcClass:[OSSVNotificationSettingsVC class]];

    GBSettingGroup *group = [[GBSettingGroup alloc] init];
//    group.items = @[currencyItem,clearItem,goToAppStoreItem,versionItem,notificationItem];
    group.items = @[currencyItem,langageItem,clearItem,goToAppStoreItem,versionItem,notificationItem];
    
    
    GBSettingItem *aboutUsItem = [GBSettingArrowItem itemWithTitle:STLLocalizedString_(@"AboutUs", nil)  destVcClass:nil];
    aboutUsItem.option = ^{
        @strongify(self)
        STLWKWebCtrl *aboutUsWebCtrl = [[STLWKWebCtrl alloc] init];
        aboutUsWebCtrl.urlType = SystemURLTypeAboutUs;
        aboutUsWebCtrl.title = STLLocalizedString_(@"AboutUs", nil);
        aboutUsWebCtrl.isNoNeedsWebTitile = YES;
        [self.controller.navigationController pushViewController:aboutUsWebCtrl animated:YES];
    };
    GBSettingItem *privacyItem = [GBSettingArrowItem itemWithTitle:STLLocalizedString_(@"PrivacyPolicy", nil)  destVcClass:nil];
    privacyItem.option = ^{
        @strongify(self)
        STLWKWebCtrl *privacyWebCtrl = [[STLWKWebCtrl alloc] init];
        privacyWebCtrl.urlType = SystemURLTypePrivacyPolicy;
        privacyWebCtrl.title = STLLocalizedString_(@"PrivacyPolicy", nil);
        privacyWebCtrl.isNoNeedsWebTitile = YES;
        [self.controller.navigationController pushViewController:privacyWebCtrl animated:YES];

    };
    GBSettingItem *termsItem = [GBSettingArrowItem itemWithTitle:STLLocalizedString_(@"Term_of_Usage", nil)  destVcClass:nil];
    termsItem.option = ^{
        @strongify(self)
        STLWKWebCtrl *termsWebCtrl = [[STLWKWebCtrl alloc] init];
        termsWebCtrl.urlType = SystemURLTypeTermsOfUs;
        termsWebCtrl.title = STLLocalizedString_(@"Term_of_Usage", nil);
        termsWebCtrl.isNoNeedsWebTitile = YES;
        [self.controller.navigationController pushViewController:termsWebCtrl animated:YES];

    };
    GBSettingGroup *secondGroup = [[GBSettingGroup alloc] init];
    secondGroup.items = @[aboutUsItem,privacyItem,termsItem];

    [self.dataArray addObject:group];
    [self.dataArray addObject:secondGroup];

}


- (NSArray *)pickerArray {
    
    if (!_pickerArray) {
        _pickerArray = [self getTheExchangeCurrencyList];
    }
    return _pickerArray;
}

#pragma mark 获取不同汇率
- (NSArray *)getTheExchangeCurrencyList {
    
    NSArray *array = [ExchangeManager currencyList];
    NSMutableArray * currencyListArray = [NSMutableArray arrayWithCapacity:4];
    for (RateModel *model in array) {
        NSString *needString = [NSString stringWithFormat:@"%@ %@",model.code,model.symbol];
        [currencyListArray addObject:needString];
    }
    return currencyListArray.copy;
}

@end
