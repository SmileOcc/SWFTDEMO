//
//  ZFOrderCheckInfoDetailModel.m
//  ZZZZZ
//
//  Created by YW on 26/10/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFOrderCheckInfoDetailModel.h"
#import "YWCFunctionTool.h"
@implementation ZFOrderCheckInfoDetailModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.totalGoodsNum = -1;
    }
    return self;
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"VATModel" : @"vattax"
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass{
    return @{
             @"goods_list"    : [CheckOutGoodListModel class],
             @"shipping_list" : [ShippingListModel class],
             @"payment_list"  : [PaymentListModel class],
             @"footer"        : [ZFOrderInfoFooterModel class],
             @"available": [ZFMyCouponModel class],
             @"disabled": [ZFMyCouponModel class],
             @"change_coutry" : [ZFInitCountryInfoModel class],
             @"first_order_bts_result" : [AFparams class],
             @"taxVerify": [ZFTaxVerifyModel class],
             };
}

-(NSInteger)totalGoodsNum
{
    if (_totalGoodsNum > 0) {
        return _totalGoodsNum;
    }
    //计算总的商品数量
    NSInteger totalGoodsNum = 0;
    for (int i = 0; i < self.cart_goods.goods_list.count; i++) {
        CheckOutGoodListModel *goodListModel = self.cart_goods.goods_list[i];
        totalGoodsNum += goodListModel.goods_number.integerValue;
    }
    _totalGoodsNum = totalGoodsNum;
    return _totalGoodsNum;
}

@end


@implementation ZFTaxVerifyModel


- (void)handleHtml {
    
//    UIFont *font =  [UIFont systemFontOfSize:13];
//    [self configNoteHtmlAttr:font.fontName fontSize:font.pointSize];
//    [self configNoteHtmlAttr:font.fontName fontSize:font.pointSize];
}
- (NSAttributedString *)configNameHtmlAttr:(NSString *)fontName
fontSize:(CGFloat)fontSize {
    
    if (self.namehtmlAttr) {
        return self.namehtmlAttr;
    }
    NSDictionary *htmlAttrDict = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)};
    
    NSString *showString = [ZFToString(self.pcc_name) stringByAppendingString:[NSString stringWithFormat:@"<style>body{font-family: '%@'; font-size:%fpx;}</style>", fontName, fontSize]];
    
    NSData *htmlData = [showString dataUsingEncoding:NSUnicodeStringEncoding];
    
    NSAttributedString *htmlAttr = [[NSAttributedString alloc] initWithData:htmlData
                                                                    options:htmlAttrDict
                                                         documentAttributes:nil
                                                                      error:nil];
    self.namehtmlAttr = htmlAttr;
    return htmlAttr;
}

- (NSAttributedString *)configNoteHtmlAttr:(NSString *)fontName
                                  fontSize:(CGFloat)fontSize {
    if (self.notehtmlAttr) {
        return self.notehtmlAttr;
    }
    NSDictionary *htmlAttrDict = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)};
    
    NSString *showString = [ZFToString(self.note) stringByAppendingString:[NSString stringWithFormat:@"<style>body{font-family: '%@'; font-size:%fpx;}</style>", fontName, fontSize]];
    
    NSData *htmlData = [showString dataUsingEncoding:NSUnicodeStringEncoding];
    
    NSAttributedString *htmlAttr = [[NSAttributedString alloc] initWithData:htmlData
                                                                    options:htmlAttrDict
                                                         documentAttributes:nil
                                                                      error:nil];
    self.notehtmlAttr = htmlAttr;
    return htmlAttr;
}

@end
