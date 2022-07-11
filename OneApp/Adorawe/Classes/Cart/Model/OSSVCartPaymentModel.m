
//
//  OSSVCartPaymentModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/13.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCartPaymentModel.h"

@implementation OSSVCartPaymentModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"payCode"     : @"pay_code",
             @"payid"       : @"pay_id",
             @"payDesc"     : @"pay_desc",
             @"payName"     : @"pay_name",
             @"payDiscount" : @"pay_discount",
             @"isOptional"  : @"isOptional",
             @"payHelp"     : @"pay_help",
             @"fractions_type" : @"fractions_type",
             @"payIconUrlStr": @"pay_img",
             @"payDiscountId": @"pay_discount_id",
             @"poundage"     : @"poundage",
             @"payVoucherNumberDesc"   : @"pay_voucher_number_desc",
             @"payVoucherDiscountDesc" : @"pay_voucher_discount_desc",
             @"payVoucherDiscountAmount" : @"pay_voucher_discount_amount"
             };
}

// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    return @[
             @"payCode",
             @"payid",
             @"payDesc",
             @"payDiscount",
             @"payName",
             @"isOptional",
             @"poundage",
             @"payHelp",
             @"fractions_type",
             @"payIconUrlStr",
             @"payDiscountId",
             @"payVoucherNumberDesc",
             @"payVoucherDiscountDesc",
             @"payVoucherDiscountAmount",
             @"dialog_tip_text",
             @"payment_discount_desc"
             ];
}

-(BOOL)isCodPayment
{
    if ([self.payCode isEqualToString:@"Cod"]) {
        return YES;
    }
    return NO;
}

-(BOOL)isInfluencerPayment {
    if ([self.payCode isEqual:@"Influencer"]) {
        return YES;
    }
    return NO;
}

@end
