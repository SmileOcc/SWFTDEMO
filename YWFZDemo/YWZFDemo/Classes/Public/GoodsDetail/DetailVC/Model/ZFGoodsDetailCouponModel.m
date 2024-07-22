//
//  ZFDetailCouponListModel.m
//  ZZZZZ
//
//  Created by YW on 2018/8/18.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFGoodsDetailCouponModel.h"
#import "ExchangeManager.h"
#import "YWCFunctionTool.h"
#import "ZFLocalizationString.h"

@implementation ZFGoodsDetailCouponModel
@end


@implementation ZFCouponMsgModel

/**
 *  计算优惠券价格
 */
- (NSString *)showCouponText {
    if (!_showCouponText) {
        
        if (!ZFIsEmptyString(self.msg)) {
            
            NSString *showCouponText = self.msg;
            if (!ZFIsEmptyString(self.replace)
                && !ZFIsEmptyString(self.amount)
                && [self.msg containsString:self.replace]) {                
                // (向下取整)
                NSString *replaceAmount = [ExchangeManager transPurePriceforPrice:self.amount currency:nil priceType:PriceType_Off];
                
                if (!ZFIsEmptyString(replaceAmount)) {
                    NSString *convertPrice = [ExchangeManager transAppendPrice:replaceAmount currency:nil];
                    showCouponText = [self.msg stringByReplacingOccurrencesOfString:self.replace withString:convertPrice];
                }
            }
            _showCouponText = ZFToString(showCouponText);
            
        } else {
            _showCouponText = ZFLocalizedString(@"Detail_Product_Coupons_Tips",nil);
        }
    }
    return _showCouponText;
}

@end



