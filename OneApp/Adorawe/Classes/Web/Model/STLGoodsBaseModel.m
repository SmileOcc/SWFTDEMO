//
//  STLGoodsBaseModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/27.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "STLGoodsBaseModel.h"

@implementation STLGoodsBaseModel

- (CGFloat)goodsListPriceHeight {
    if (_goodsListPriceHeight < kHomeCellBottomViewHeight) {
        _goodsListPriceHeight = kHomeCellBottomViewHeight;
    }
    return _goodsListPriceHeight;
}

- (BOOL)isShowGoodDetailFlash {
    //不是0元活动， 闪购状态 0、1显示
    if (STLIsEmptyString(self.specialId) && self.flash_sale
        && ([STLToString(self.flash_sale.active_status) isEqualToString:@"0"]
            || [STLToString(self.flash_sale.active_status) isEqualToString:@"1"])) {
        return YES;
    }
    return NO;
}

- (BOOL)isShowGoodDetailNew {
    BOOL isShowNew = self.is_new == 1;

    // 0元>闪购>折扣>新品
    
    if (!STLIsEmptyString(self.specialId) || (self.flash_sale
        && ([STLToString(self.flash_sale.active_status) isEqualToString:@"0"]
            || [STLToString(self.flash_sale.active_status) isEqualToString:@"1"])) || ([self.show_discount_icon integerValue] && STLToString(self.discount) > 0)) {
        isShowNew = NO;
    }
    return isShowNew;
}
@end



@implementation STLFlashSaleModel


- (BOOL)isOnlyFlashActivity {
    if (!STLIsEmptyString(self.active_discount) && [self.active_discount floatValue] > 0) {
        return YES;
    }
    return NO;
}

- (BOOL)isFlashActiving {
    return [STLToString(self.active_status) isEqualToString:@"1"]  ? YES : NO;
}

- (BOOL)isCanBuyFlashSaleStateing {
    if ([STLToString(self.active_status) isEqualToString:@"1"] && !STLIsEmptyString(self.active_discount) && [self.active_discount floatValue] > 0 && [self.active_stock integerValue] > 0 && [self.active_limit integerValue] > 0 && [self.sold_out integerValue] == 0) {
        return YES;
    }
    return NO;
}

- (BOOL)isCanBuyFlashSaleStateingBuyNumber:(NSInteger)number {
    if ([self isCanBuyFlashSaleStateing]) {
        if ([self.active_stock integerValue] >= number && [self.sold_out integerValue] == 0) {
            return YES;
        }
    }
    return NO;
}

@end
