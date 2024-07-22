//
//  ZFOrderManager.m
//  ZZZZZ
//
//  Created by YW on 27/10/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFOrderManager.h"
#import "FilterManager.h"
#import "ZFOrderAmountDetailModel.h"
#import "RateModel.h"
#import "ZFVATCell.h"
#import "ZFOrderAmountDetailCell.h"
#import "NSArrayUtils.h"
#import "NSStringUtils.h"
#import "ZFLocalizationString.h"
#import "ZFAnalytics.h"
#import "YWCFunctionTool.h"
#import "ZFRequestModel.h"
#import "AccountManager.h"
#import "ZFBTSManager.h"
#import "ZFThemeManager.h"

@interface ZFOrderManager ()
@property (nonatomic, copy) NSString                    *codDiscountTitle;
@property (nonatomic, copy) NSString                    *taxRate;
@property (nonatomic, weak) ZFOrderCheckInfoDetailModel *checkOutModel;
@end

@implementation ZFOrderManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        //后台设置的默认占位符
        self.codReplaceHold = @"$cod_fee";
    }
    return self;
}

#pragma mark - Public method
- (void)adapterManagerWithModel:(ZFOrderCheckInfoDetailModel *)checkOutModel {
    
    _checkOutModel = checkOutModel;

    //判断是否支持货到付款，把当前国家对应的货币存储到本地临时变量
    NSString *currency = [FilterManager isSupportCOD:checkOutModel.address_info.country_id];
    if (![NSStringUtils isEmptyString:currency]) {
        [FilterManager saveTempFilter:currency];
    }

    self.shippingListArray = [NSMutableArray array];
    [checkOutModel.shipping_list enumerateObjectsUsingBlock:^(ShippingListModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.shippingListArray addObject:model];
    }];
    
    //设置一个默认积分
    self.currentPoint   = checkOutModel.point.use_point_max;
    self.pointSavePrice = [NSString stringWithFormat:@"%.2f",[checkOutModel.point.use_point_max doubleValue] * 0.02];
    
    // 如果当前已经输入过积分,则以这个为准
    if (!ZFIsEmptyString(self.currentInputPoint)) {
        self.currentPoint = self.currentInputPoint;
        if (checkOutModel.point.use_point_max.integerValue < self.currentPoint.integerValue) {
            self.currentPoint = checkOutModel.point.use_point_max;
        }
        self.pointSavePrice = [NSString stringWithFormat:@"%.2f",[self.currentPoint doubleValue] * 0.02];
    }
    
    self.couponCode             = checkOutModel.total.coupon_code;
    self.addressId              = checkOutModel.address_info.address_id;
    self.addressCode            = checkOutModel.address_info.code;
    self.supplierNumber         = checkOutModel.address_info.supplier_number;
    self.tel                    = checkOutModel.address_info.tel;
    self.need_traking_number    = checkOutModel.total.need_traking_number;
    self.insurance              = checkOutModel.ifNeedInsurance ? checkOutModel.total.insure_fee : @"0.00";
    self.goods_price            = checkOutModel.total.goods_price;
    self.couponAmount           = checkOutModel.total.coupon_amount;
    self.countryID              = checkOutModel.address_info.country_id;
    self.activities_amount      = checkOutModel.total.activities_amount;
    self.student_discount_amount= checkOutModel.total.student_discount_amount;
    //用于快速支付
    self.payertoken             = checkOutModel.payertoken;
    self.payerId                = checkOutModel.payerId;
    self.codDiscountTitle       = ZFLocalizedString(@"TotalPrice_Cell_CODDiscount",nil);
    self.taxRate                = checkOutModel.VATModel.taxRate;
    
    if (self.couponAmount.doubleValue > 0) {
        self.isSelectCoupon = YES;
    }
}

- (void)queryAmountDetailArray:(void(^)(NSArray *amountDetailModelArray, NSArray *detailCellList))complation
{
    NSString *studentDiscountTitle = nil;
    NSInteger studentLevel = [AccountManager sharedManager].account.student_level;
    if (studentLevel == 1) {
        studentDiscountTitle = ZFLocalizedString(@"OrderInfo_priceList_student_discount", nil);
    }else if (studentLevel == 2) {
        studentDiscountTitle = ZFLocalizedString(@"OrderInfo_priceList_supermeStudent_discount", nil);
    }
    
    NSString *codDiscount = [self queryCodDiscount];

    NSString *productTotalkey = ZFLocalizedString(@"OrderInfo_priceList_subtotal_total",nil);
    NSString *items = ZFLocalizedString(@"CartOrderInfo_Goods_Items", nil);
    if (self.checkOutModel.totalGoodsNum == 1) {
        items = ZFLocalizedString(@"CartOrderInfo_Goods_Item", nil);
    }
    productTotalkey = [NSString stringWithFormat:@"%@ (%ld %@)", productTotalkey, self.checkOutModel.totalGoodsNum, items];
    
    NSMutableArray *amountKeyArray = [NSMutableArray arrayWithObjects:
                                      productTotalkey,
                                      ZFLocalizedString(@"OrderInfo_priceList_deliver",nil),
                                      ZFLocalizedString(@"OrderInfo_priceList_cod_fee", nil),
                                      ZFLocalizedString(@"OrderInfo_priceList_insurance",nil),
                                      ZFLocalizedString(@"OrderInfo_priceList_event_discount",nil),
                                      ZFLocalizedString(@"OrderInfo_priceList_coupon_discount",nil),
                                      ZFToString(studentDiscountTitle),
                                      ZFLocalizedString(@"OrderInfo_priceList_zpoints",nil),
                                      self.codDiscountTitle,
                                      ZFLocalizedString(@"OrderInfo_priceList_grandTotal",nil),
                                      nil];
    
    NSMutableDictionary *amountDict = [[NSMutableDictionary alloc] init];

    //商品总价格
    NSString *totalKey = productTotalkey;
    amountDict[totalKey] = [self querySubtotal];
    
    //物流价格
    NSString *shippingKey = ZFLocalizedString(@"OrderInfo_priceList_deliver",nil);
    amountDict[shippingKey] = [self queryShippingCost];
    if (self.shippingPrice.doubleValue <= 0) {
        amountDict[shippingKey] = ZFLocalizedString(@"OrderInfo_page_free", nil);
    }
    
    //商品结算总价格
    NSString *key = ZFLocalizedString(@"OrderInfo_priceList_grandTotal",nil);
    if (self.currentPaymentType == CurrentPaymentTypeCOD) {
        amountDict[key] = [self queryTotalPayable];
    } else {
        amountDict[key] = [self queryGrandTotal];
    }
    
    //以下是可选显示
    
    //优惠券
    if ([self.couponAmount doubleValue] > 0) {
        NSString *key = ZFLocalizedString(@"OrderInfo_priceList_coupon_discount",nil);
        amountDict[key] = [self queryCoupon];
    }
    
    //物流保险费
    if ([self.insurance doubleValue] > 0) {
        NSString *key = ZFLocalizedString(@"OrderInfo_priceList_insurance",nil);
        amountDict[key] = [self queryShippingInsurance];
    }
    
    //COD费用
    if (self.currentPaymentType == CurrentPaymentTypeCOD) {
        NSString *key = ZFLocalizedString(@"OrderInfo_priceList_cod_fee",nil);
        amountDict[key] = [self queryCodCost];
    }
    
    //活动优惠价格
    if ([self.activities_amount doubleValue] > 0) {
        NSString *key = ZFLocalizedString(@"OrderInfo_priceList_event_discount", nil);
        amountDict[key] = [self queryEventDiscount];
    }
    
    //积分价格
    if ([self.pointSavePrice doubleValue] > 0 && self.isUsePoint) {
        NSString *key = ZFLocalizedString(@"OrderInfo_priceList_zpoints",nil);
        amountDict[key] = [self queryZPointsSaving];
    }
    
    //当选择的COD，并且COD取整值不为0的时候
    if (self.currentPaymentType == CurrentPaymentTypeCOD && ![NSStringUtils isEmptyString:codDiscount]) {
        NSString *codkey = self.codDiscountTitle;
        amountDict[codkey] = codDiscount;
    }
    
    //学生卡
    if (studentDiscountTitle && self.student_discount_amount.doubleValue > 0) {
        NSString *studentDiscount = [self queryStudentEventDiscount];
        amountDict[studentDiscountTitle] = studentDiscount;
    }

    NSMutableArray *detailCellList = [NSMutableArray arrayWithCapacity:amountDict.count];
    NSMutableArray *modelArray = [NSMutableArray arrayWithCapacity:amountDict.count];
    for (int i = 0; i < [amountKeyArray count]; i++) {
        NSString *key = amountKeyArray[i];
        NSString *value = amountDict[key];
        if (value) {
            ZFOrderAmountDetailModel *model = [[ZFOrderAmountDetailModel alloc] init];
            model.name = key;
            model.value = value;
            model.isShowTipsButton = NO;
            [modelArray addObject:model];
            [detailCellList addObject:[ZFOrderAmountDetailCell class]];
            if ([self valueShowThemeColor:key]) {
                //减免项目需要变成主题色
                NSDictionary *attribtDic = @{NSForegroundColorAttributeName: ZFC0xFE5269()};
                NSMutableAttributedString *attribtStr = [[NSMutableAttributedString alloc] initWithString:model.value attributes:attribtDic];
                model.attriValue = attribtStr;
            } else if ([key isEqualToString:self.codDiscountTitle]) {
                ///COD取整需要增加一个提示按钮
                model.isShowTipsButton = YES;
            } else if ([key isEqualToString:ZFLocalizedString(@"OrderInfo_priceList_grandTotal",nil)]) {
                NSDictionary *attribtDic = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:14]};
                NSMutableAttributedString *attribtStr = [[NSMutableAttributedString alloc] initWithString:model.value attributes:attribtDic];
                NSMutableAttributedString *attriName = [[NSMutableAttributedString alloc] initWithString:model.name attributes:attribtDic];
                model.attriValue = attribtStr;
                model.attriName = attriName;
            } else if ([value isEqualToString:ZFLocalizedString(@"OrderInfo_page_free",nil)]) {
                ////当费用为FREE时，字体加粗
                model.value = ZFLocalizedString(@"OrderInfo_page_free", nil);
                NSDictionary *attribtDic = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:14]};
                NSMutableAttributedString *attribtStr = [[NSMutableAttributedString alloc] initWithString:model.value attributes:attribtDic];
                model.attriValue = attribtStr;
            }
        }
    }
    if (complation) {
        complation(modelArray, detailCellList);
    }
}

- (BOOL)valueShowThemeColor:(NSString *)name
{
    if ([name isEqualToString:ZFLocalizedString(@"OrderInfo_priceList_coupon_discount",nil)] ||
        [name isEqualToString:ZFLocalizedString(@"OrderInfo_priceList_zpoints",nil)] ||
        [name isEqualToString:ZFLocalizedString(@"OrderInfo_priceList_student_discount", nil)] ||
        [name isEqualToString:ZFLocalizedString(@"OrderInfo_priceList_supermeStudent_discount", nil)] ||
        [name isEqualToString:ZFLocalizedString(@"OrderInfo_priceList_event_discount", nil)] ||
        [name isEqualToString:ZFLocalizedString(@"OrderInfo_priceList_cod", nil)]) {
        return YES;
    }
    return NO;
}

- (NSString *)queryAmountNumber {
    /// SOA 要先取整，再计算
    NSString *currency = [self gainCurrency];
    NSString *goodsPrice = [NSString stringWithFormat:@"%.2f", [self gainTotalPrice]];
    
    NSDecimalNumber *numberTotal = nil;
    NSDecimalNumber *numberPirce = [NSDecimalNumber decimalNumberWithString:goodsPrice];
    NSDecimalNumber *numberShipping = [ExchangeManager transDecimalNumberPurePriceforPrice:self.shippingPrice currency:currency priceType:PriceType_ShippingCost];
    NSDecimalNumber *numberCod = [ExchangeManager transDecimalNumberPurePriceforPrice:self.codFreight currency:currency priceType:PriceType_ShippingCost];
    NSDecimalNumber *numberInsurance = [ExchangeManager transDecimalNumberPurePriceforPrice:self.insurance currency:currency priceType:PriceType_Insurance];
    NSDecimalNumber *numberCoupon = [ExchangeManager transDecimalNumberPurePriceforPrice:self.couponAmount currency:currency priceType:PriceType_Coupon];
    NSDecimalNumber *numberPoint = [ExchangeManager transDecimalNumberPurePriceforPrice:self.pointSavePrice currency:currency priceType:PriceType_Point];
    NSDecimalNumber *numberactivities = [ExchangeManager transDecimalNumberPurePriceforPrice:self.activities_amount currency:currency priceType:PriceType_Activity];
    NSDecimalNumber *numberStudent = [ExchangeManager transDecimalNumberPurePriceforPrice:self.student_discount_amount currency:currency priceType:PriceType_Off];
    
    numberTotal = [numberPirce decimalNumberByAdding:numberShipping];
    if (!self.checkOutModel.is_cod_service) {
        numberTotal = [numberTotal decimalNumberByAdding:numberCod];
    }
    numberTotal = [numberTotal decimalNumberByAdding:numberInsurance];
    numberTotal = [numberTotal decimalNumberBySubtracting:numberCoupon];
    if (self.isUsePoint) {
        numberTotal = [numberTotal decimalNumberBySubtracting:numberPoint];
    }
    numberTotal = [numberTotal decimalNumberBySubtracting:numberactivities];
    numberTotal = [numberTotal decimalNumberBySubtracting:numberStudent];
    
    return [NSString stringWithFormat:@"%.2f", numberTotal.doubleValue];
}

- (NSString *)querySubtotal {
    NSString *currency = [self gainCurrency];
    NSString *totalPrice = [NSString stringWithFormat:@"%.2f", [self gainTotalPrice]];
    NSString *price = [ExchangeManager transAppendPrice:totalPrice currency:currency];
    return price;
}

- (NSString *)queryShippingCost {
    return [FilterManager adapterCodWithAmount:self.shippingPrice andCod:self.currentPaymentType == CurrentPaymentTypeCOD priceType:PriceType_ShippingCost];
}

- (NSString *)queryShippingInsurance {
    return [FilterManager adapterCodWithAmount:self.insurance andCod:self.currentPaymentType == CurrentPaymentTypeCOD priceType:PriceType_Insurance];
}

- (NSString *)queryCodCost {
    if (self.codFreight.doubleValue <= 0.0) {
        return ZFLocalizedString(@"OrderInfo_page_free", nil);
    }
    return [FilterManager adapterCodWithAmount:self.codFreight andCod:self.currentPaymentType == CurrentPaymentTypeCOD priceType:PriceType_Insurance];
}

- (NSString *)queryEventDiscount {
    NSString *result = [FilterManager adapterCodWithAmount:self.activities_amount andCod:self.currentPaymentType == CurrentPaymentTypeCOD priceType:PriceType_Off];
    return [NSString stringWithFormat:@"- %@",result];
}

- (NSString *)queryStudentEventDiscount
{
    NSString *result = [FilterManager adapterCodWithAmount:self.student_discount_amount andCod:self.currentPaymentType == CurrentPaymentTypeCOD priceType:PriceType_Off];
    return [NSString stringWithFormat:@"- %@",result];
}

- (NSString *)queryCoupon {
    if (!self.isSelectCoupon) {
        self.couponAmount = @"0.00";
    }
    NSString *result = [FilterManager adapterCodWithAmount:self.couponAmount andCod:self.currentPaymentType == CurrentPaymentTypeCOD priceType:PriceType_Coupon];
    return [NSString stringWithFormat:@"- %@",result];
}

- (NSString *)queryZPointsSaving {
    NSString *result = [FilterManager adapterCodWithAmount:self.pointSavePrice andCod:self.currentPaymentType == CurrentPaymentTypeCOD priceType:PriceType_Point];
    return [NSString stringWithFormat:@"- %@",result];
}

- (NSString *)queryGrandTotal {
    NSString *currency = [self gainCurrency];
    NSString *total = [self queryAmountNumber];
    if (total.doubleValue <= 0.01) {
        //应付金额小于或等于0.01的时候,强制等于0.01,产品需求
        total = [NSString stringWithFormat:@"0.01"];
    }
    NSString *price = [ExchangeManager transAppendPrice:total currency:currency];
    return price;
}

- (NSString *)queryCodDiscount {
    NSString *result;
    NSInteger index = [FilterManager cashOnDeliveryTruncType:self.countryID];
    NSString *amount = [self queryAmountNumber];
    NSArray *pointEndNumList = [amount componentsSeparatedByString:@"."];
    NSInteger digits = [FilterManager cashOnDeliveryTruncNumberOfDigits:self.countryID];
    if (ZFJudgeNSArray(pointEndNumList)) {
        if ([pointEndNumList count] > 1) {
            NSString *pointEnd = pointEndNumList[1];
            if (pointEnd.doubleValue == 0 && digits <= 0) {
                //当价格是整数时，不需要显示上下取整的提示
                index = CashOnDeliveryTruncTypeDefault;
            }
        }
    }

    NSString *codDiscount = @"";
    switch (index) {
        case CashOnDeliveryTruncTypeUp:
        {
            self.codDiscountTitle = ZFLocalizedString(@"OrderInfo_priceList_insurance_discount",nil);
            codDiscount = [ExchangeManager transforCeilOrFloorDifferencePrice:amount currency:[FilterManager tempCurrency] numberOfdigits:digits upDownType:UpDownFetchType_Up];
            result = [NSString stringWithFormat:@"+ %@",codDiscount];
        }
            break;
        case CashOnDeliveryTruncTypeDown:
        {
            self.codDiscountTitle = ZFLocalizedString(@"OrderInfo_priceList_cod",nil);
            codDiscount = [ExchangeManager transforCeilOrFloorDifferencePrice:amount currency:[FilterManager tempCurrency] numberOfdigits:digits upDownType:UpDownFetchType_Down];
            result = [NSString stringWithFormat:@"- %@",codDiscount];
        }
            break;
        case CashOnDeliveryTruncTypeDefault:
        {
            self.codDiscountTitle = ZFLocalizedString(@"OrderInfo_priceList_cod",nil);
            result = @"";
        }
            break;
    }
    
    return result;
}

- (NSString *)queryTotalPayable {
    NSString *result;
    NSInteger index = [FilterManager cashOnDeliveryTruncType:self.countryID];
    NSInteger digits = [FilterManager cashOnDeliveryTruncNumberOfDigits:self.countryID];
    NSString *amount = [self queryAmountNumber];
    switch (index) {
        case CashOnDeliveryTruncTypeUp:
        {
            result = [ExchangeManager transforCeilOrFloorPrice:amount currency:[FilterManager tempCurrency] numberOfdigits:digits upDownType:UpDownFetchType_Up];
        }
            break;
        case CashOnDeliveryTruncTypeDown:
        {
            result = [ExchangeManager transforCeilOrFloorPrice:amount currency:[FilterManager tempCurrency] numberOfdigits:digits upDownType:UpDownFetchType_Down];
        }
            break;
        case CashOnDeliveryTruncTypeDefault:
        {
            NSString *price = [ExchangeManager transAppendPrice:amount currency:[FilterManager tempCurrency]];
            result = price;
        }
            break;
    }
    
    return result;
}

- (NSString *)queryTaxPrice {
    double vat = 0.0;
    if (self.currentPaymentType == CurrentPaymentTypeCOD) {
        NSInteger index = [FilterManager cashOnDeliveryTruncType:self.countryID];
        switch (index) {
            case CashOnDeliveryTruncTypeUp:
            {
                vat = ceil([[self queryAmountNumber] doubleValue]) * [self.taxRate doubleValue];
            }
                break;
            case CashOnDeliveryTruncTypeDown:
            {
                vat = floor([[self queryAmountNumber] doubleValue]) * [self.taxRate doubleValue];
            }
                break;
            case CashOnDeliveryTruncTypeDefault:
            {
                vat = 0;
            }
                break;
        }
    }else{
        vat = [[self queryAmountNumber] doubleValue] * [self.taxRate doubleValue];
    }
    
    self.vat = [NSString stringWithFormat:@"%.2f",vat];
    return  [FilterManager adapterCodWithAmount:[NSString stringWithFormat:@"%lf",vat] andCod:self.currentPaymentType == CurrentPaymentTypeCOD priceType:PriceType_ProductPrice];
}

- (NSString *)queryCashOnDelivery {
    NSString *amount = [self queryAmountNumber];
    NSString *title;
    NSInteger digits = [FilterManager cashOnDeliveryTruncNumberOfDigits:self.countryID];
    switch ([FilterManager cashOnDeliveryTruncType:self.countryID]) {
        case CashOnDeliveryTruncTypeUp:
        {
            title = [ExchangeManager transforCeilOrFloorPrice:amount currency:[FilterManager tempCurrency] numberOfdigits:digits upDownType:UpDownFetchType_Up];
//            title = [NSString stringWithFormat:@"%@",[ExchangeManager transforCeilPrice:[NSString stringWithFormat:@"%lf",num] currency:[FilterManager tempCurrency] numberOfdigits:digits]];
        }
            break;
        case CashOnDeliveryTruncTypeDefault:
        {
            title = [ExchangeManager transforCeilOrFloorPrice:amount currency:[FilterManager tempCurrency] numberOfdigits:digits upDownType:UpDownFetchType_Down];
//            title = [NSString stringWithFormat:@"%@",[ExchangeManager transforPrice:[NSString stringWithFormat:@"%lf",num] currency:[FilterManager tempCurrency]]];
        }
            break;
        case CashOnDeliveryTruncTypeDown:
        {
            title = [ExchangeManager transforCeilOrFloorPrice:amount currency:[FilterManager tempCurrency] numberOfdigits:digits upDownType:UpDownFetchType_Up];
//            title = [NSString stringWithFormat:@"%@",[ExchangeManager transforFloorPrice:amount currency:[FilterManager tempCurrency] numberOfdigits:digits]];
        }
            break;
        default:
            break;
    }
    return title;
}

- (void)queryCurrentOrderCurrency {
    NSString *str;
    if ( ([FilterManager isSupportCOD:self.countryID] && [self.paymentCode isEqualToString:@"Cod"])) {
        if ([NSStringUtils isEmptyString:[FilterManager isSupportCOD:self.countryID]]) {
            str = [ExchangeManager localCurrencyName];
        }else{
            str = [FilterManager isSupportCOD:self.countryID];
            NSArray<RateModel *> *array = [ExchangeManager currencyList];
            for (RateModel *model in array) {
                if ([model.symbol isEqualToString:str]) {
                    str = model.code;
                }
            }
        }
    } else {
        str = [ExchangeManager localCurrencyName];
    }
    self.bizhong = str;
}

- (BOOL)isShowCODGoodsAmountLimit:(NSString *)payCode checkoutModel:(ZFOrderCheckInfoDetailModel *)checkoutModel {
    if ([payCode isEqualToString:@"Cod"] &&
        ([self.goods_price doubleValue] < [checkoutModel.cod.totalMin doubleValue]
         || [self.goods_price doubleValue] > [checkoutModel.cod.totalMax doubleValue]))
    {
        return YES;
    }else{
        return NO;
    }
}

- (NSString *)appendGoodsSN:(ZFOrderCheckInfoDetailModel *)model {
    NSMutableString *goodsStr = [NSMutableString string];
    for (int i = 0; i < model.cart_goods.goods_list.count; i++) {
        CheckOutGoodListModel *goodsModel = model.cart_goods.goods_list[i];
        if ([goodsModel.goods_sn length] > 0) {
            [goodsStr appendString:goodsModel.goods_sn];
            if (model.cart_goods.goods_list.count != 1 && i != model.cart_goods.goods_list.count - 1) {
                [goodsStr appendString:@","];
            }
        }else{
            //Appsflyer Debug 统计事件
            ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
            NSDictionary *params = @{@"af_json_data" : ZFToString([model yy_modelToJSONObject]),
                                     @"af_content_type" : @"cart/checkout_info",
                                     @"af_quest_param" : requestModel.parmaters
                                     };
            [ZFAnalytics appsFlyerTrackEvent:@"af_upload_api_data" withValues:params];
        }
    }
    return [goodsStr copy];
}

- (NSString *)appendGoodsPrice:(ZFOrderCheckInfoDetailModel *)model {
    NSMutableString *goodsPrices = [NSMutableString string];
    for (int i = 0; i < model.cart_goods.goods_list.count; i++) {
        CheckOutGoodListModel *goodsModel = model.cart_goods.goods_list[i];
        if ([goodsModel.hacker_point.goods_real_pay_amount length] > 0) {
            [goodsPrices appendString:goodsModel.hacker_point.goods_real_pay_amount];
            if (model.cart_goods.goods_list.count != 1 && i != model.cart_goods.goods_list.count - 1) {
                [goodsPrices appendString:@","];
            }
        }
    }
    return [goodsPrices copy];
}

- (NSString *)appendGoodsQuantity:(ZFOrderCheckInfoDetailModel *)model {
    NSMutableString *goodsQuantity = [NSMutableString string];
    for (int i = 0; i < model.cart_goods.goods_list.count; i++) {
        CheckOutGoodListModel *goodsModel = model.cart_goods.goods_list[i];
        if ([goodsModel.goods_number length] > 0) {
            [goodsQuantity appendString:goodsModel.goods_number];
            if (model.cart_goods.goods_list.count != 1 && i != model.cart_goods.goods_list.count - 1) {
                [goodsQuantity appendString:@","];
            }
        }
    }
    return [goodsQuantity copy];
}

- (void)analyticsClickButton:(NSString *)payMethod state:(NSInteger)state {
    dispatch_async(dispatch_queue_create([[[NSDate date] description] UTF8String], NULL), ^{
        //增加支付方式统计
        if (![NSStringUtils isEmptyString:payMethod]) {
            if(state == FastPaypalOrderTypeSuccess ||  state == FastPaypalOrderTypeFail) {
                [ZFAnalytics clickButtonWithCategory:@"Payment Method" actionName:@"FastPayment" label:@"FastPayment"];
            } else {
                [ZFAnalytics clickButtonWithCategory:@"Payment Method" actionName:payMethod label:payMethod];
            }
        }
    });
}

- (NSString *)orderTypeNameWithPayCode:(NSInteger)payCode {
    NSString *screenName = @"Generate Order";
    switch (payCode) {
        case PayCodeTypeCOD: {
            screenName = @"COD Order";
            break;
        }
        case PayCodeTypeOnline: {
            screenName = @"Online Order";
            break;
        }
        default: {
            if (self.currentPaymentType == CurrentPaymentTypeCOD) {
                screenName = @"Generate Order - COD";
            } else {
                screenName = @"Generate Order - Online";
            }
            break;
        }
    }
    return screenName;
}

- (void)configureABTest {
    self.isSelectInsurance = NO;
    self.isShowShippingInfo = YES;
    self.autoCoupon = @"1";
}

///获取货币符号
- (NSString *)gainCurrency
{
    NSString *currency = nil;
    if (self.currentPaymentType == CurrentPaymentTypeCOD && ![NSStringUtils isEmptyString:[FilterManager tempCurrency]]) {
        ///如果是COD
        currency = [FilterManager tempCurrency];
        return currency;
    }
    currency = [ExchangeManager localTypeCurrency];
    return currency;
}

///SOA 商品分批计算价格
- (double)gainTotalPrice
{
    __block double goodsPrice = 0.0;
    NSString *goodsCurrency = [self gainCurrency];
    [_checkOutModel.cart_goods.goods_list enumerateObjectsUsingBlock:^(CheckOutGoodListModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        goodsPrice += [ExchangeManager transPurePriceforPrice:obj.goods_price currency:goodsCurrency priceType:PriceType_ProductPrice].doubleValue * obj.goods_number.integerValue;
    }];
    return goodsPrice;
}

/**
 *  商品总数量
 */
- (NSString *)gainBuyProductTotalNumbers
{
    __block NSInteger total = 0.0;
//    NSString *goodsCurrency = [self gainCurrency];
    [_checkOutModel.cart_goods.goods_list enumerateObjectsUsingBlock:^(CheckOutGoodListModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        total += obj.goods_number.integerValue;
    }];
    return [NSString stringWithFormat:@"%ld", total];
}

- (NSString *)pccNum
{
    if ([self.checkOutModel.taxVerify.is_pcc isEqualToString:@"1"]) {
        return _pccNum;
    }
    return @"";
}

- (NSString *)taxString
{
    if ([self.checkOutModel.taxVerify.is_pcc isEqualToString:@"1"]) {
        return _pccNum;
    }
    return _taxString;
}

@end
