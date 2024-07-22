//
//  CurrencyViewModel.m
//  ZZZZZ
//
//  Created by DBP on 17/2/14.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "CurrencyViewModel.h"
#import "RateModel.h"
#import "ZFProgressHUD.h"
#import "UIView+ZFViewCategorySet.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "ZFLocalizationString.h"
#import "ExchangeManager.h"
#import "YWCFunctionTool.h"
#import "ZFCommonRequestManager.h"
#import "Constants.h"
#import "ZFThemeManager.h"
#import "UIImage+ZFExtended.h"

@interface CurrencyViewModel ()
@property (nonatomic, strong) NSArray                  *dataArray;
@property (nonatomic, copy) NSString                   *currencyString;
@property (nonatomic, assign) ZFCurrencyVCComeFromType comeFromType;
@end

@implementation CurrencyViewModel

- (void)requestData:(ZFCurrencyVCComeFromType)comeFromType {
    self.comeFromType = comeFromType;
//    self.dataArray = [self getTheExchangeCurrencyList];
    
//    if (_dataArray.count == 0) {
        // 如果没有汇率则重新请求
        [self requestExchangeData];
//    } else {
        //滚动到选择的位置
//        [self scrollToSelectedPosition];
//    }
}

/**
 * 滚动到选择的位置
 */
- (void)scrollToSelectedPosition
{
    NSIndexPath *indexPath = nil;
    if (self.comeFromType == CurrencyComeFrom_GuideSetting) {
        if (!ZFIsEmptyString(self.shouldSelectedCurrency)) {
            self.currencyString = self.shouldSelectedCurrency;
        }
    } else {
        self.currencyString = [ExchangeManager localCurrency];
    }
    
    for (int i = 0; i<self.dataArray.count; i++) {
        NSString *showText = self.dataArray[i];
        if ([showText containsString:self.currencyString]) {
            indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            break;
        }
    }
    
    if (indexPath) {
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:(UITableViewScrollPositionTop) animated:NO];
    }
}

/**
 * 如果没有汇率则重新请求
 */
- (void)requestExchangeData {
    @weakify(self)
    ShowLoadingToView(self.tableView.superview);
    [ZFCommonRequestManager requestExchangeData:^(BOOL success) {
        @strongify(self)
        HideLoadingFromView(self.tableView.superview);
        
        if (success) {
            self.dataArray = [self getTheExchangeCurrencyList];
            [self.tableView reloadData];
            //滚动到选择的位置
            [self scrollToSelectedPosition];
            
        } else {
            self.tableView.emptyDataBtnTitle = ZFLocalizedString(@"EmptyCustomViewManager_refreshButton",nil);
            
            @weakify(self)
            [self.tableView setBlankPageViewActionBlcok:^(ZFBlankPageViewStatus status) {
                @strongify(self)
                [self requestExchangeData];
            }];
            [self.tableView showRequestTip:nil];
        }
    }];
}

#pragma mark 获取不同汇率
- (NSArray *)getTheExchangeCurrencyList {
    NSArray *array = [ExchangeManager currencyList];
    NSMutableArray * currencyListArray = [NSMutableArray arrayWithCapacity:4];
    for (RateModel *model in array) {
        NSString *needString = [NSString stringWithFormat:@"%@ %@",model.symbol,model.code];
        [currencyListArray addObject:needString];
    }
    return currencyListArray.copy;
}

#pragma mark - UITableviewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.dataArray.count > indexPath.row) {
        NSString *seleectCurrency = ZFToString(self.dataArray[indexPath.row]);
        if ([seleectCurrency isEqualToString:ZFToString(self.currencyString)]) {
            return;
        }
        if (self.comeFromType == CurrencyComeFrom_GuideSetting) {
            if (self.selectCurrencyBlock) {
                NSString *selectText = self.dataArray[indexPath.row];
                self.selectCurrencyBlock(selectText);
            }
            
        } else {
            SaveUserDefault(kHasChangeCurrencyKey, @(YES));
            [ExchangeManager updateLocalCurrency:_dataArray[indexPath.row]];
            if (self.selectCurrencyBlock) {
                self.selectCurrencyBlock([ExchangeManager localCurrency]);
            }
        }
        [_tableView reloadData];
        
        //发送改变货币类型通知
        [[NSNotificationCenter defaultCenter] postNotificationName:kCurrencyNotification object:nil];
        [self.controller.navigationController popViewControllerAnimated:YES];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 0.001;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.001;
} 

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"currencyCell" forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"currencyCell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    NSString *showText = self.dataArray[indexPath.row];
    cell.textLabel.text = showText;
    cell.accessoryView = nil;
    [cell.textLabel convertTextAlignmentWithARLanguage];
    
    if (self.comeFromType == CurrencyComeFrom_GuideSetting) {
        if (!ZFIsEmptyString(self.shouldSelectedCurrency) &&
            [showText containsString:self.shouldSelectedCurrency]) {
            cell.accessoryView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"refine_select"] imageWithColor:ZFC0xFE5269()]];
        }
    } else {
        if ([showText isEqualToString:[ExchangeManager localCurrency]]) {
            cell.accessoryView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"refine_select"] imageWithColor:ZFC0xFE5269()]];
        }
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}
@end
