//
//  ZFGoogleAddressViewModel.m
//  ZZZZZ
//
//  Created by YW on 2018/7/10.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFGoogleAddressViewModel.h"
#import "ZFGoogleAddressModel.h"
#import "YWLocalHostManager.h"
#import "ZFThemeManager.h"
#import "NSStringUtils.h"
#import "ZFProgressHUD.h"
#import "YWCFunctionTool.h"
#import "ZFRequestModel.h"
#import <YYModel/YYModel.h>
#import "Constants.h"

@interface ZFGoogleAddressViewModel()
@property (nonatomic, strong) NSString              *inputText;
@property (nonatomic, strong) NSMutableArray        *addressDataArr;
@property (nonatomic, strong) NSString              *country_code;
@property (nonatomic, strong) NSURLSessionDataTask  *inputDataTask;
@end

@implementation ZFGoogleAddressViewModel

- (NSMutableArray *)addressDataArr {
    if (!_addressDataArr) {
        _addressDataArr = [[NSMutableArray alloc] init];
    }
    return _addressDataArr;
}
/**
 * 清空数据源
 */
- (void)clearTableDataSource
{
    [self.addressDataArr removeAllObjects];
}

/**
 * 查询输入的国家信息列地址表
 */
- (void)getInputGoogleAddressData:(NSString *)inputText
                     country_code:(NSString *)country_code
                       completion:(void (^)(NSArray *addressDataArr))completion
{
    if (ZFIsEmptyString(inputText)) return;
    
    //取消上次正在请求的
    BOOL hasCancel = NO;
    if (self.inputDataTask && self.inputDataTask.state == NSURLSessionTaskStateRunning) {
        hasCancel = YES;
        [self.inputDataTask cancel];
    }
 
    self.country_code = country_code;
    self.inputText = inputText;
    ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
    requestModel.url = API(Port_get_google_state);
    requestModel.parmaters = @{@"country_code" : ZFToString(country_code),
                               @"input" : ZFToString(inputText)};
    
    self.inputDataTask = [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        
        if (completion) {
            NSArray *dataArray = @[];
            NSDictionary *resultDic = responseObject[ZFResultKey];
            if (ZFJudgeNSDictionary(resultDic)) {
                NSArray *predictionsArr = resultDic[@"predictions"];
                if (ZFJudgeNSArray(predictionsArr)) {
                    dataArray = [NSArray arrayWithArray:[NSArray yy_modelArrayWithClass:[ZFGoogleAddressModel class] json:predictionsArr]];
                }
                [self updateTableDatas:dataArray];
            }
            completion(dataArray);
        }
        
    } failure:^(NSError *error) {
        if (!hasCancel) {
            //ShowToastToViewWithText(nil, error.domain);
        }
        [self updateTableDatas:@[]];
        if (completion) {
            completion(@[]);
        }
    }];
}

- (void)updateTableDatas:(NSArray *)dataArray {
    [self.addressDataArr removeAllObjects];

    if (self.inputText.length > 0) {
        ZFGoogleAddressModel *detailAddressModel = [[ZFGoogleAddressModel alloc] init];
        ZFGoogleHighlightModel *heighLightModel = [[ZFGoogleHighlightModel alloc] init];
        heighLightModel.offset = 0;
        heighLightModel.length = self.inputText.length;
        detailAddressModel.structured_formatting = [[ZFGoogleStructuredModel alloc] init];
        detailAddressModel.structured_formatting.main_text = self.inputText;
        detailAddressModel.highlight = @[heighLightModel];
        [self.addressDataArr addObject:detailAddressModel];
    }
    
    if (dataArray.count == 0) {
        
    } else {
        [self.addressDataArr addObjectsFromArray:dataArray];
    }
}

/**
 * 查询搜索地址详情
 */
- (void)getStateDetailData:(NSString *)place_id
{
    ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
    requestModel.url = API(Pro_get_state_detail);
    requestModel.parmaters = @{@"country_code" : ZFToString(self.country_code),
                               @"place_id" : ZFToString(place_id)
                               };
    ShowLoadingToView(nil);
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        HideLoadingFromView(nil);
        
        ZFGoogleDetailAddressModel *detailAddressModel = nil;
        NSDictionary *resultDic = responseObject[ZFResultKey];
        if (ZFJudgeNSDictionary(resultDic)) {
            
            NSDictionary *stateInfo = resultDic[@"state_info"];
            if (ZFJudgeNSDictionary(stateInfo)) {
                detailAddressModel = [ZFGoogleDetailAddressModel yy_modelWithJSON:stateInfo];
            } else {
                detailAddressModel = [ZFGoogleDetailAddressModel yy_modelWithJSON:resultDic];
            }
        }
        
        if (self.selectedAddressModel) {
            self.selectedAddressModel(detailAddressModel);
        }                                                        
    } failure:^(NSError *error) {
        HideLoadingFromView(nil);
        ShowToastToViewWithText(nil, error.domain);
    }];
}

#pragma mark - UItableVIewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.addressDataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    cell.textLabel.attributedText = nil;
    cell.detailTextLabel.attributedText = nil;
    
    ZFGoogleAddressModel *model = self.addressDataArr[indexPath.row];
    NSString *firstText = model.structured_formatting.main_text;
    cell.textLabel.attributedText = [self fetchCellAttrStr:model
                                                  withtext:firstText
                                                   topText:YES];
    
    NSString *secondText = model.structured_formatting.secondary_text;
    cell.detailTextLabel.attributedText = [self fetchCellAttrStr:model
                                                        withtext:secondText
                                                         topText:NO];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ZFGoogleAddressModel *model = self.addressDataArr[indexPath.row];
    if (![NSStringUtils isEmptyString:model.place_id]) {//请求地址详情
        [self getStateDetailData:model.place_id];
        
    } else {//自己输入的
        if (self.selectedAddressModel) {
            ZFGoogleDetailAddressModel *detailAddressModel = [[ZFGoogleDetailAddressModel alloc] init];
            detailAddressModel.address_components = [[ZFGoogleAddressComponentsModel alloc] init];
            detailAddressModel.address_components.addressline1 = model.structured_formatting.main_text;
            self.selectedAddressModel(detailAddressModel);
        }
    }
}

#pragma mark - 显示搜索地址

- (NSMutableAttributedString *)fetchCellAttrStr:(ZFGoogleAddressModel *)model
                                       withtext:(NSString *)main_text
                                        topText:(BOOL)isTopText
{
    UIFont *font = isTopText ? ZFFontSystemSize(14) : ZFFontSystemSize(12);
    UIColor *color = isTopText ? ZFCOLOR(34, 34, 34, 1) : ZFCOLOR(153, 153, 153, 1);
    
    NSMutableAttributedString *mainAttri= [[NSMutableAttributedString alloc] initWithString:ZFToString(main_text)];
    [mainAttri addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, main_text.length)];
    [mainAttri addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, main_text.length)];
    
    //忽略大小写
    main_text = [main_text lowercaseString];
    //NSString *inputText = [[self.inputText lowercaseString] replaceBrAndEnterChar];
    
    // occ v3.8.0 去掉 && [main_text containsString:inputText]
    if (model.highlight.count>0) {
        
        ZFGoogleHighlightModel *highlightModel = [model.highlight firstObject];
        if (highlightModel && main_text.length >= (highlightModel.length+highlightModel.offset)) {
            
            UIFont *boldFont = isTopText ? ZFFontBoldSize(14) : ZFFontBoldSize(12);
            [mainAttri addAttribute:NSFontAttributeName value:boldFont range:NSMakeRange(highlightModel.offset, highlightModel.length)];
        }
    }
    return mainAttri;
}

@end
