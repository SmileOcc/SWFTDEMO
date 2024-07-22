//
//  ZFOrderCheckInfoModel.m
//  ZZZZZ
//
//  Created by YW on 23/10/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFOrderCheckInfoModel.h"
#import "YWCFunctionTool.h"
#import "ZFThemeManager.h"
#import "NSString+Extended.h"

@implementation ZFOrderCheckInfoModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"order_info" : [ZFOrderCheckInfoDetailModel class],
             @"goods_list"    : [CheckOutGoodListModel class],
             @"shipping_list" : [ShippingListModel class],
             @"payment_list"  : [PaymentListModel class],
             @"footer"        : [ZFOrderInfoFooterModel class],
             @"available": [ZFMyCouponModel class],
             @"disabled": [ZFMyCouponModel class]
             };
}

- (void)setOrder_info:(ZFOrderCheckInfoDetailModel *)order_info
{
    _order_info = order_info;

//    NSArray *iconList = @[
//                          [UIImage imageNamed:@"ic_pay_adn_idacs"],
//                          [UIImage imageNamed:@"ic_pay_wp_p24"],
//                          [UIImage imageNamed:@"ic_pay_visaelectron"],
//                          [UIImage imageNamed:@"ic_pay_visa"],
//                          [UIImage imageNamed:@"ic_pay_visa_debit"],
//                          [UIImage imageNamed:@"ic_pay_sofort"],
//                          [UIImage imageNamed:@"ic_pay_poli"],
//                          [UIImage imageNamed:@"ic_pay_oxxo"],
//                          [UIImage imageNamed:@"ic_pay_mastercarddebit"],
//                          ];
    ///计算paymetList中的icon位置
    for (int i = 0; i < _order_info.payment_list.count; i++) {
        PaymentListModel *model = _order_info.payment_list[i];
        
        NSInteger count = model.pay_desc_list.count;
        NSMutableArray *iconList = [[NSMutableArray alloc] init];
        NSMutableArray *labelList = [[NSMutableArray alloc] init];
        CGFloat height = 25.0;
        for (int j = 0; j < count; j++) {
            PaymentIconModel *iconModel = model.pay_desc_list[j];
            NSString *imgName = iconModel.app_code;
            if (!ZFToString(imgName).length) {
                imgName = iconModel.pay_name;
            }
            UIImage *image = [UIImage imageNamed:imgName];
            
            if (!image && !ZFToString(iconModel.app_code).length) {
                UILabel *label = [[UILabel alloc] init];
                label.font = [UIFont systemFontOfSize:14];
                label.textColor = ZFC0x999999();
                label.text = iconModel.pay_name;
                label.textAlignment = NSTextAlignmentCenter;
                [labelList addObject:label];
                
                CGFloat width = [label.text textSizeWithFont:label.font constrainedToSize:CGSizeMake(MAXFLOAT, height) lineBreakMode:label.lineBreakMode].width + 5;
                CGSize size = CGSizeMake(width, height);
                [model.iconSizeList addObject:[NSValue valueWithCGSize:size]];
                continue;
            }
            
            if (image) {
                [model.iconSizeList addObject:[NSValue valueWithCGSize:CGSizeMake(iconModel.width, iconModel.height)]];
                [iconList addObject:image];
            }
        }
  
        NSMutableArray *totalList = [[NSMutableArray alloc] init];
        [totalList addObjectsFromArray:iconList];
        [totalList addObjectsFromArray:labelList];
        model.payIconImageList = totalList.copy;
    }
}

@end
