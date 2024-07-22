//
//  ZFBaseGoodsModel.m
//  ZZZZZ
//
//  Created by YW on 14/9/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFBaseGoodsModel.h"
#import "ExchangeManager.h"
#import "ZFThemeManager.h"
#import "AccountManager.h"
#import "YWCFunctionTool.h"

@interface ZFBaseGoodsModel ()

@end

@implementation ZFBaseGoodsModel

- (void)setShopPrice:(NSString *)shopPrice
{
    _shopPrice = shopPrice;
}

- (void)setMarketPrice:(NSString *)marketPrice
{
    _marketPrice = marketPrice;
}

- (BOOL)showMarketPrice
{
    if (self.price_type == 1 || self.price_type == 2 || self.price_type == 3 || self.price_type == 4 || self.price_type == 5) {
        return YES;
    }
    return NO;
}

@end
