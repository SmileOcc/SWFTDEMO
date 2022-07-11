//
//  OSSVCountryeViewModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/8.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCountryeViewModel.h"
#import "CountryModel.h"
#import "CountryListModel.h"
#import "CountryManager.h"
#import "OSSVAddresseCountryeHeaderView.h"
#import "CountryApi.h"
#import "OSSVCountryeViewCell.h"

@interface OSSVCountryeViewModel ()
@property (nonatomic, strong) NSMutableArray            *dataSource;
@property (nonatomic, strong) NSMutableArray            *keysDic;

@end

@implementation OSSVCountryeViewModel

//v1.4.0occ移除
//- (void)requestNetwork:(id)parmaters completion:(void (^)(id))completion failure:(void (^)(id))failure {
//    [[STLNetworkStateManager sharedManager] networkState:^{
//        CountryApi *api = [[CountryApi alloc] init];
//        [api.accessoryArray addObject:[[STLRequestAccessory alloc] initWithApperOnView:self.controller.view]];
//        [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
//            id requestJSON = [OSSVNSStringTool desEncrypt:request];
//            NSArray *result = [self dataAnalysisFromJson: requestJSON request:api];
//            [OSSVAccountsManager sharedManager].countryList = result;
//            if (completion) {
//                completion(result);
//            }
//        } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
//            STLLog(@"failure");
//        }];
//    } exception:^{
//        if (failure) {
//            failure(nil);
//        }
//    }];
//}

- (id)dataAnalysisFromJson:(id)json request:(OSSVBasesRequests *)request {
    if ([request isKindOfClass:[CountryApi class]]) {
        if ([json[kStatusCode] integerValue] == kStatusCode_200) {
            NSArray *array = [NSArray yy_modelArrayWithClass:[CountryListModel class] json:json[kResult]]; //NSArray *countries = countryDict[kResult][@"countries"];
//            [CountryManager saveLocalCountry:array];
            return array;
        } else {
            [self alertMessage:json[@"message"]];
        }
    }
    return nil;
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.keysDic.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *countrys = _dataSource[section][_keysDic[section]];
    return countrys.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    // 这里实际上是进行 复用了哦
    OSSVAddresseCountryeHeaderView *headerView = [OSSVAddresseCountryeHeaderView addressCountryHeaderViewWithTableView:tableView section:section];
    headerView.titleText = self.keysDic[section];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 28; // wei 确认
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OSSVCountryeViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(OSSVCountryeViewCell.class)];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    CountryModel *model = _dataSource[indexPath.section][_keysDic[indexPath.section]][indexPath.row];
//    [cell.imageView yy_setImageWithURL:[NSURL URLWithString:model.picture] placeholder:[UIImage imageNamed:@"placeholder_pdf"] options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation completion:nil];
    cell.textLabel.text = model.countryName;
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.textLabel.textColor = OSSVThemesColors.col_333333;
    if ([self.countryName isEqualToString:model.countryName]) {
        cell.textLabel.textColor = OSSVThemesColors.col_FF9522;
    } else {
        cell.textLabel.textColor = OSSVThemesColors.col_333333;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CountryModel *model = _dataSource[indexPath.section][_keysDic[indexPath.section]][indexPath.row];
    self.countrySelect(model);
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // 分割线补全
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
    {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)])
    {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

//添加索引列
-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {

    return self.keysDic;
}

//索引列点击事件
-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index] atScrollPosition:UITableViewScrollPositionTop animated:YES];

    return index;
}

#pragma mark - InitData
- (void)initDataSources {
    
//    self.keysDic = [NSMutableArray array];
//    self.dataSource = [NSMutableArray array];
//    for (CountryListModel *obj in [OSSVAccountsManager sharedManager].countryList) {
//        if (obj.key.length > 1) {obj.key = @"*";}
//        NSString *key = obj.key;
//        [self.keysDic addObject:key];
//        NSArray <CountryModel *>*countrys = obj.countryList;
//        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//        [dic setObject:countrys forKey:key];
//        [self.dataSource addObject:dic];
//    }
    //    STLLog(@"keyDic === %@,dataSorce == %@",self.keysDic,self.dataSource);
}

@end
