//
//  GoodsReductionModel.m
//  ZZZZZ
//
//  Created by YW on 20/9/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "GoodsReductionModel.h"
#import "YWCFunctionTool.h"
#import "ExchangeManager.h"
#import <objc/message.h>

@implementation GoodsReductionModel

- (NSArray<NSAttributedString *> *)showAttrTextArray {
    if (!_showAttrTextArray) {
        NSString *allShowText = self.msg;
        
        NSString *localCurrencyName = [ExchangeManager localCurrencyName];
        if ([self.currency isEqualToString:localCurrencyName]) { // 相同时不需要转换价格,直接拼接货币符号
            for (NSString *key in self.org_price_list.allKeys) {
                NSString *value = self.org_price_list[key];
                // 不计算价格, 只拼接货币符号
                NSString *originPrice = [ExchangeManager transAppendPrice:value currency:nil];
                allShowText = [allShowText stringByReplacingOccurrencesOfString:key withString:originPrice];
            }
        } else { // 非本地货币时,需要转换成本地价格
            for (NSString *key in self.price_list.allKeys) {
                NSString *value = self.price_list[key];
                //计算价格(向下取整)
                PriceType zfPriceType = (self.is_up_round==1) ? PriceType_ProductPrice : PriceType_Off;
                NSString *convertPrice = [ExchangeManager transPurePriceforPrice:value currency:nil priceType:zfPriceType];
                // 拼接货币符号
                convertPrice = [ExchangeManager transAppendPrice:convertPrice currency:localCurrencyName];
                allShowText = [allShowText stringByReplacingOccurrencesOfString:key withString:convertPrice];
            }
        }
        
        NSDictionary *htmlAttrDict = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)};
        NSArray *titleArray = [allShowText componentsSeparatedByString:@"||"];
        
        NSMutableArray *showArray = [NSMutableArray array];
        for (NSString *string in titleArray) {
            if (ZFIsEmptyString(string)) continue;
            
            NSString *showString = [string stringByAppendingString:[NSString stringWithFormat:@"<style>body{font-family: '%@'; font-size:%dpx;}</style>", @".SFUIText", 14]];
            
            NSData *htmlData = [showString dataUsingEncoding:NSUnicodeStringEncoding];
            
            NSAttributedString *stringAttributed = [[NSAttributedString alloc] initWithData:htmlData
                                                                                    options:htmlAttrDict
                                                                         documentAttributes:nil
                                                                                      error:nil];
            if (stringAttributed) {
                [showArray addObject:stringAttributed];
            }
        }
        _showAttrTextArray = showArray;
    }
    return _showAttrTextArray;
}


@end
