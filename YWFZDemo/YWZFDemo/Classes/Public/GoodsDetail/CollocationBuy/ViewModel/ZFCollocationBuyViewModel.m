//
//  ZFCollocationBuyViewModel.m
//  ZZZZZ
//
//  Created by YW on 2019/8/13.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCollocationBuyViewModel.h"
#import "ZFCollocationBuyModel.h"
#import "ZFPiecingOrderPriceModel.h"
#import "YWLocalHostManager.h"
#import "ZFProgressHUD.h"
#import "NSDictionary+SafeAccess.h"
#import "YWCFunctionTool.h"
#import "ZFRequestModel.h"
#import "AccountManager.h"
#import "Constants.h"
#import "ZFGoodsModel.h"
#import "ZFCollocationBuyModel.h"
#import "ZFLocalizationString.h"
#import "ExchangeManager.h"

@implementation ZFCollocationBuyViewModel

/**
 * 请求商品搭配购数据
 */
+ (NSURLSessionDataTask *)requestCollocationBuy:(NSString *)goods_sn
                                  showFirstPage:(BOOL)showFirstPage
                                     completion:(void (^)(ZFCollocationBuyModel *))completion
{
    ZFRequestModel *requestModel = [ZFRequestModel new];
    requestModel.url = API(Port_collocationBuy);
    requestModel.parmaters = @{
                               @"goods_sn" : ZFToString(goods_sn),
                               @"is_first" : showFirstPage ? @"1" : @"0"
                               };
//    requestModel.eventName = @"goods_collocation_buy";
//    requestModel.taget = self.actionProtocol;
    
    return [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        NSArray *resultArray = responseObject[ZFResultKey];
        if (!ZFJudgeNSArray(resultArray) || resultArray.count == 0)  {
            if (completion) {
                completion(nil);
            }
            return;
        }        
        NSMutableArray *modelArray = [NSMutableArray array];
        NSMutableArray *titleArray = [NSMutableArray array];
        CGFloat shopPrice = 0;
        CGFloat marketPrice = 0;
        
        for (NSInteger i=0; i<resultArray.count; i++) {
            NSArray *subResultArray = resultArray[i];
            if (!ZFJudgeNSArray(subResultArray)) {
                if (completion) {
                    completion(nil);
                }
                return;
            }
            NSString *tagetTitle = [NSString stringWithFormat:@"%@%ld",ZFLocalizedString(@"Cart_Match",nil) ,i+1];
            [titleArray addObject:tagetTitle];
            
            NSMutableArray *subModelArray = [NSMutableArray array];
            for (NSDictionary *modelDict in subResultArray) {
                ZFCollocationGoodsModel *collocationModel = [ZFCollocationGoodsModel yy_modelWithJSON:modelDict];
                collocationModel.tagetTitle = tagetTitle;
                CGFloat temShopPrice = [ExchangeManager transPurePriceforPrice:collocationModel.shop_price].floatValue;
                CGFloat tempMarketPrice = [ExchangeManager transPurePriceforPrice:collocationModel.market_price].floatValue;
                shopPrice += temShopPrice;
                marketPrice += tempMarketPrice;
                [subModelArray addObject:collocationModel];
            }
            [modelArray addObject:subModelArray];
        }
        ZFCollocationBuyModel *collocationBuyModel = [[ZFCollocationBuyModel alloc] init];
        collocationBuyModel.collocationGoodsArr = modelArray;
        collocationBuyModel.collocationTitleArr = titleArray;
        collocationBuyModel.shopPrice = [NSString stringWithFormat:@"%.2f", shopPrice];
        collocationBuyModel.marketPrice = [NSString stringWithFormat:@"%.2f", marketPrice];
        
        if (completion) {
            completion(collocationBuyModel);
        }
    } failure:^(NSError *error) {
        if (completion) {
            completion(nil);
        }
        YWLog(@"GoodsShows error: %@", error);
    }];
}
@end
