//
//  OSSVHelpsdViewModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/2.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVHelpsdViewModel.h"
#import "GBSettingItem.h"
#import "GBSettingGroup.h"
#import "GBSettingCell.h"

#import "STLWKWebCtrl.h"
#import "YYText.h"

@interface OSSVHelpsdViewModel ()
@property (nonatomic, strong) NSMutableArray *dataArray;
@end

@implementation OSSVHelpsdViewModel

#pragma mark - UITableViewDelegate UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    GBSettingGroup *group = self.dataArray[section];
    return group.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 1.创建cell
    GBSettingCell *cell = [GBSettingCell cellWithTableView:tableView];
    
    // 2.给cell传递模型数据
    GBSettingGroup *group = self.dataArray[indexPath.section];
    cell.item = group.items[indexPath.row];
    cell.lastRowInSection =  (group.items.count - 1 == indexPath.row);
    
    // 3.返回cell
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    // 1.取消选中这行
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    
//    // 2.模型数据
//    GBSettingGroup *group = self.dataArray[indexPath.section];
//    GBSettingItem *item = group.items[indexPath.row];
//    
//    //根据item.tag判断h5界面跳转
//    STLWKWebCtrl *webVc = [[STLWKWebCtrl alloc]init];
//    webVc.urlType = item.tag;
//    if ([item.title isKindOfClass:[NSString class]]) {
//        webVc.title = item.title;
//    } else if(item.tag == SystemURLTypeContractUs) {
//        webVc.title = STLLocalizedString_(@"ContactUs", nil);
//    }
//    webVc.isNoNeedsWebTitile = YES;
//    [self.controller.navigationController pushViewController:webVc animated:YES];
}

#pragma mark - Load data
- (NSMutableArray *)dataArray {
    
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
        [self setupGroupOneSection];
    }
    return _dataArray;
}


- (void)setupGroupOneSection {
    
//    GBSettingItem *aboutUs = [GBSettingItem itemWithTitle:STLLocalizedString_(@"AboutUs", nil)];
//    aboutUs.tag = SystemURLTypeAboutUs;
//    
//    GBSettingItem *terms = [GBSettingItem itemWithTitle:STLLocalizedString_(@"Term", nil)];
//    terms.tag = SystemURLTypeTermsOfUs;
//    
//    GBSettingItem *privacyPolicy = [GBSettingItem itemWithTitle:STLLocalizedString_(@"PrivacyPolicy", nil)];
//    privacyPolicy.tag = SystemURLTypePrivacyPolicy;
//    
//    GBSettingItem *securePayment = [GBSettingItem itemWithTitle:STLLocalizedString_(@"SecurePaymentMethod", nil)];
//    securePayment.tag = SystemURLTypeSecurePaymentMethods;
//    
//    GBSettingItem *shipping = [GBSettingItem itemWithTitle:STLLocalizedString_(@"ShippingHandling", nil)];
//    shipping.tag = SystemURLTypeShippingAndHandling;
//    
//    GBSettingItem *returnPolicy = [GBSettingItem itemWithTitle:STLLocalizedString_(@"ReturnPolicy", nil)];
//    returnPolicy.tag = SystemURLTypeWarrantyAndReturn;
//    
//    NSString *contactUs = STLLocalizedString_(@"ContactUs", nil);
//    NSString *conatchEmail = @"(service@adorawe.net)";
//    NSString *contentString = [NSString stringWithFormat:@"%@%@",contactUs,conatchEmail];
//    
//    NSMutableAttributedString *contactUsAtt = [[NSMutableAttributedString alloc] initWithString:contentString];
//    
//    NSRange conatchEmailRange = [contactUsAtt.string rangeOfString:conatchEmail];
//    
//    
//    if (conatchEmailRange.location != NSNotFound) {
//        [contactUsAtt yy_setTextHighlightRange:conatchEmailRange
//                                         color:[OSSVThemesColors col_FF5875]
//                               backgroundColor:[UIColor clearColor]
//                                     tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
//                                         
//                                     }];
//        
//    }
//    
//    GBSettingItem *contactUsitem = [GBSettingItem itemWithTitle:contactUsAtt];
//    contactUsitem.tag = SystemURLTypeContractUs;
//    
//    GBSettingGroup *group = [[GBSettingGroup alloc] init];
//    group.items = @[aboutUs, terms, privacyPolicy, securePayment,shipping,returnPolicy, contactUsitem];
//    [self.dataArray addObject:group];
}


@end
