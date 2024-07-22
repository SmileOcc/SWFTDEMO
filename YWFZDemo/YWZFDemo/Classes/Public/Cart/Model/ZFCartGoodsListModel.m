
//
//  ZFCartGoodsListModel.m
//  ZZZZZ
//
//  Created by YW on 2017/9/16.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCartGoodsListModel.h"
#import "ZFCartGoodsModel.h"
#import "ZFColorDefiner.h"
#import "NSString+Extended.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "ExchangeManager.h"

@implementation ZFCartGoodsListModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"cartList" : [ZFCartGoodsModel class],
             };
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"url" : @"url",
             @"msg" : @"msg",
             @"goodsModuleType" : @"goods_module_type",
             @"cartList" : @"cart_list",
             };
}

- (NSAttributedString *)freeGiftHeaderAttrText {
    if (!_freeGiftHeaderAttrText) {
        NSArray *colorArray = @[ZFCOLOR_BLACK, ZFCOLOR(183, 96, 42, 1)];
        NSArray *fontArr = @[[UIFont systemFontOfSize:14]];
        NSString *title1 = ZFLocalizedString(@"FreeGift", nil);
        NSString *title2 = @"";
        
        if (!ZFIsEmptyString(self.diff_msg) && !ZFIsEmptyString(self.diff_amount)) {
            NSString *replaceStr = @"$diff_amount";
            if ([self.diff_msg containsString:replaceStr]) {
                NSString *locationPrice = [ExchangeManager transforPrice:self.diff_amount];
                NSString *convertPrice = [self.diff_msg stringByReplacingOccurrencesOfString:replaceStr withString:locationPrice];
                title2 = ZFToString(convertPrice);
            }
        }
        NSArray *titleArr = @[title1, title2];
        _freeGiftHeaderAttrText = [NSString getAttriStrByTextArray:titleArr
                                                           fontArr:fontArr
                                                          colorArr:colorArray
                                                       lineSpacing:0
                                                         alignment:0];
    }
    return _freeGiftHeaderAttrText;
}

- (NSAttributedString *)configHeaderHtmlAttr:(NSString *)fontName
                                    fontSize:(CGFloat)fontSize
{
    NSString *allShowText = self.msg;
    
    NSString *localCurrencyName = [ExchangeManager localCurrencyName];
    if ([self.currency isEqualToString:localCurrencyName]) { // 相同时不需要转换价格,直接拼接货币符号
        for (NSString *key in self.org_price_list.allKeys) {
            NSString *value =  ZFToString(self.org_price_list[key]);
            // 不计算价格, 只拼接货币符号
            NSString *originPrice = [ExchangeManager transAppendPrice:value currency:nil];
            allShowText = [allShowText stringByReplacingOccurrencesOfString:key withString:originPrice];
        }
    } else { // 非本地货币时,需要转换成本地价格
        for (NSString *key in self.price_list.allKeys) {
            NSString *value = ZFToString(self.price_list[key]);
            //计算价格(向下取整)
            PriceType zfPriceType = (self.is_up_round==1) ? PriceType_ProductPrice : PriceType_Off;
            NSString *convertPrice = [ExchangeManager transPurePriceforPrice:value currency:nil priceType:zfPriceType];
            
            // 拼接货币符号
            convertPrice = [ExchangeManager transAppendPrice:convertPrice currency:localCurrencyName];
            
            allShowText = [allShowText stringByReplacingOccurrencesOfString:key withString:convertPrice];
        }
    }
    
    NSDictionary *htmlAttrDict = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)};
    
    NSString *showString = [allShowText stringByAppendingString:[NSString stringWithFormat:@"<style>body{font-family: '%@'; font-size:%fpx;}</style>", fontName, fontSize]];
    
    NSData *htmlData = [showString dataUsingEncoding:NSUnicodeStringEncoding];
    
    NSAttributedString *htmlAttr = [[NSAttributedString alloc] initWithData:htmlData
                                                                    options:htmlAttrDict
                                                         documentAttributes:nil
                                                                      error:nil];
    self.headerHtmlAttr = htmlAttr;
    return htmlAttr;
}

@end
