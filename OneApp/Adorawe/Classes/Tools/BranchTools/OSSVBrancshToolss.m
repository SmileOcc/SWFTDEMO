//
//  OSSVBrancshToolss.m
// XStarlinkProject
//
//  Created by fan wang on 2021/6/4.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVBrancshToolss.h"
#import "STLPreference.h"

@implementation OSSVBrancshToolss
///浏览商品详情
+(void)logViewItem:(NSDictionary *)product{
    
    BranchUniversalObject *branchUniversalObject = [BranchUniversalObject new];
    branchUniversalObject.contentMetadata.sku = product[@"goods_sn"];
    branchUniversalObject.contentMetadata.contentSchema     = BranchContentSchemaCommerceProduct;
    branchUniversalObject.contentMetadata.price             = product[@"present_price"];
    branchUniversalObject.contentMetadata.currency          = BNCCurrencyUSD;
    branchUniversalObject.contentMetadata.productName       = product[@"goods_name"];
    branchUniversalObject.contentMetadata.productVariant    = product[@"goods_attr"];
    branchUniversalObject.contentMetadata.productBrand      = OSSVLocaslHosstManager.appName;
    
    BranchEvent *event = [BranchEvent standardEvent:BranchStandardEventViewItem];
    event.contentItems = @[branchUniversalObject];
    event.eventDescription = @"Product View Item";
    event.currency = BNCCurrencyUSD;
    event.customData = [self appendUtmSource:product];
    [event logEvent];
}
///加入购物车
+(void)logAddToCart:(NSDictionary *)product{
    BranchUniversalObject *branchUniversalObject = [BranchUniversalObject new];
    branchUniversalObject.contentMetadata.sku = product[@"goods_sn"];
    branchUniversalObject.contentMetadata.contentSchema     = BranchContentSchemaCommerceProduct;
    branchUniversalObject.contentMetadata.quantity          = [product[@"goods_quantity"] integerValue];
    branchUniversalObject.contentMetadata.price             = product[@"present_price"];
    branchUniversalObject.contentMetadata.currency          = BNCCurrencyUSD;
    branchUniversalObject.contentMetadata.productName       = product[@"goods_name"];
    branchUniversalObject.contentMetadata.productVariant    = product[@"goods_attr"];
    branchUniversalObject.contentMetadata.productBrand      = OSSVLocaslHosstManager.appName;

    BranchEvent *event = [BranchEvent standardEvent:BranchStandardEventAddToCart];
    event.contentItems = @[branchUniversalObject];
    event.customData = [self appendUtmSource:product];
    [event logEvent];
}

///开始结账
+(void)logInitPurchase:(NSDictionary *)product{
    NSArray *items = product[kFIRParameterItems];
    NSMutableArray *contentItem =  [[NSMutableArray alloc] init];
    for (NSDictionary *item in items) {
        if (STLJudgeNSDictionary(item)) {
            BranchUniversalObject *branchUniversalObject = [BranchUniversalObject new];
            branchUniversalObject.contentMetadata.sku = item[kFIRParameterItemID];
            branchUniversalObject.contentMetadata.contentSchema     = BranchContentSchemaCommerceProduct;
            branchUniversalObject.contentMetadata.quantity          = [item[kFIRParameterQuantity] integerValue];
            branchUniversalObject.contentMetadata.price             = item[kFIRParameterPrice];
            branchUniversalObject.contentMetadata.currency          = BNCCurrencyUSD;
            branchUniversalObject.contentMetadata.productName       = item[kFIRParameterItemName];
            branchUniversalObject.contentMetadata.productVariant    = item[kFIRParameterItemVariant];
            branchUniversalObject.contentMetadata.productBrand      = OSSVLocaslHosstManager.appName;
            [contentItem addObject:branchUniversalObject];
        }
    }
    
    BranchEvent *event = [BranchEvent standardEvent:BranchStandardEventInitiatePurchase];
    event.contentItems = [contentItem copy];
    event.eventDescription = @"User init purchase.";
    NSMutableDictionary *dict = [product mutableCopy];
    dict[kFIRParameterItems] = STLToString([items yy_modelToJSONString]);
    event.customData = [self appendUtmSource:dict];
    [event logEvent];
}
///生成订单
+(void)logAddPaymentInfo:(NSDictionary *)product{
    NSArray *items = product[kFIRParameterItems];
    NSMutableArray *contentItem =  [[NSMutableArray alloc] init];
    for (NSDictionary *item in items) {
        if (STLJudgeNSDictionary(item)) {
            BranchUniversalObject *branchUniversalObject = [BranchUniversalObject new];
            branchUniversalObject.contentMetadata.sku = item[kFIRParameterItemID];
            branchUniversalObject.contentMetadata.contentSchema     = BranchContentSchemaCommerceProduct;
            branchUniversalObject.contentMetadata.quantity          = [item[kFIRParameterQuantity] integerValue];
            branchUniversalObject.contentMetadata.price             = item[kFIRParameterPrice];
            branchUniversalObject.contentMetadata.currency          = BNCCurrencyUSD;
            branchUniversalObject.contentMetadata.productName       = item[kFIRParameterItemName];
            branchUniversalObject.contentMetadata.productVariant    = item[kFIRParameterItemVariant];
            branchUniversalObject.contentMetadata.productBrand      = OSSVLocaslHosstManager.appName;
            [contentItem addObject:branchUniversalObject];
        }
    }
    
    BranchEvent *event = [BranchEvent standardEvent:BranchStandardEventAddPaymentInfo];
    event.contentItems = [contentItem copy];
    event.eventDescription = @"User placed order.";
    NSMutableDictionary *dict = [product mutableCopy];
    dict[kFIRParameterItems] = STLToString([items yy_modelToJSONString]);
    event.customData = [self appendUtmSource:dict];
    [event logEvent];
}
///计入GMV
+(void)logPurchaseGMV:(NSDictionary *)product{
    NSArray *items = product[kFIRParameterItems];
    
    
    NSMutableArray *contentItem =  [[NSMutableArray alloc] init];
    for (NSDictionary *item in items) {
        if (STLJudgeNSDictionary(item)) {
            BranchUniversalObject *branchUniversalObject = [BranchUniversalObject new];
            branchUniversalObject.contentMetadata.sku = item[kFIRParameterItemID];
            branchUniversalObject.contentMetadata.contentSchema     = BranchContentSchemaCommerceProduct;
            branchUniversalObject.contentMetadata.quantity          = [item[kFIRParameterQuantity] integerValue];
            branchUniversalObject.contentMetadata.price             = item[kFIRParameterPrice];
            branchUniversalObject.contentMetadata.currency          = BNCCurrencyUSD;
            branchUniversalObject.contentMetadata.productName       = item[kFIRParameterItemName];
            branchUniversalObject.contentMetadata.productVariant    = item[kFIRParameterItemVariant];
            branchUniversalObject.contentMetadata.productBrand      = OSSVLocaslHosstManager.appName;
            [contentItem addObject:branchUniversalObject];
        }
    }
    
    
    BranchEvent *event = [BranchEvent standardEvent:BranchStandardEventPurchase];
    event.contentItems = [contentItem copy];
    event.eventDescription = @"User completed purchase.";
    event.currency = BNCCurrencyUSD;
    event.coupon = product[@"coupon"];
    event.transactionID = product[@"transaction_id"];
    event.revenue = product[@"value"];
    event.customData = [self appendUtmSource:@{}];
    [event logEvent];
}

/// 统计Push
+(void)logPush:(NSDictionary *)pushInfo{
    BranchEvent *event = [BranchEvent standardEvent:@"af_push"];
    event.eventDescription = @"User received Push.";
    event.customData = [self appendUtmSource:pushInfo];
    [event logEvent];
}

///注册
+(void)logCompleteRegistration:(NSDictionary *)registerInfo{
    BranchEvent *event = [BranchEvent standardEvent:BranchStandardEventCompleteRegistration];
    event.eventDescription = @"User login completed.";
    event.customData = [self appendUtmSource:registerInfo];
    [event logEvent];
}

+(NSDictionary *)appendUtmSource:(NSDictionary *)dictionary{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:dictionary];
    NSDictionary *utmSource = [STLPreference objectForKey:kBranchUtmSource];
    [dic addEntriesFromDictionary:utmSource];
    return [dic copy];
}

@end
