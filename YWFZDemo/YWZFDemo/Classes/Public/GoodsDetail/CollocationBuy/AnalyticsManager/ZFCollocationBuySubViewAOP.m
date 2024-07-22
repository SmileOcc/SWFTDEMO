//
//  ZFCollocationBuySubViewAOP.m
//  ZZZZZ
//
//  Created by YW on 2019/8/30.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCollocationBuySubViewAOP.h"
#import "YWCFunctionTool.h"
#import "ZFAppsflyerAnalytics.h"
#import "ZFCollocationGoodsCell.h"
#import "ZFCollocationBuyModel.h"
#import "ZFGoodsModel.h"
#import "AccountManager.h"

@interface ZFCollocationBuySubViewAOP ()

@property (nonatomic, strong) NSMutableArray *analyticsSet;

@end

@implementation ZFCollocationBuySubViewAOP

- (void)after_tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[ZFCollocationGoodsCell class]]) {
        ZFCollocationGoodsCell *productCell = (ZFCollocationGoodsCell *)cell;
        if ([productCell.goodsModel isKindOfClass:[ZFCollocationGoodsModel class]]) {
            ZFCollocationGoodsModel *goodsModel = (ZFCollocationGoodsModel *)productCell.goodsModel;
            if ([self.analyticsSet containsObject:ZFToString(goodsModel.goods_id)]) {
                return;
            }
            [self.analyticsSet addObject:ZFToString(goodsModel.goods_id)];
            ZFGoodsModel *model = [ZFGoodsModel new];
            model.goods_id = goodsModel.goods_id;
            model.goods_sn = goodsModel.goods_sn;
            [ZFAppsflyerAnalytics trackGoodsList:@[model] inSourceType:ZFAppsflyerInSourceTypeCollocation AFparams:nil];
        }
    }
}

- (void)after_tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[ZFCollocationGoodsCell class]]) {
        ZFCollocationGoodsCell *collocationCell = (ZFCollocationGoodsCell *)cell;
        ZFCollocationGoodsModel *goodsModel = (ZFCollocationGoodsModel *)collocationCell.goodsModel;
        // appflyer统计
        NSString *goodsSN = goodsModel.goods_sn;
        NSString *spu = nil;
        if (goodsSN.length > 7) {
            spu = [goodsSN substringWithRange:NSMakeRange(0, 7)];
        }else{
            spu = goodsSN;
        }
        NSDictionary *appsflyerParams = @{@"af_content_id" : ZFToString(goodsModel.goods_sn),
                                          @"af_spu_id" : ZFToString(spu),
                                          @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type), //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                          @"af_page_name" : @"goods_page", // 当前页面名称
                                          };
        [ZFAppsflyerAnalytics zfTrackEvent:@"af_sku_click" withValues:appsflyerParams];
    }
}

- (NSDictionary *)injectMenthodParams {
    NSDictionary *params = @{
                             NSStringFromSelector(@selector(tableView:willDisplayCell:forRowAtIndexPath:)) :
                                 @"after_tableView:willDisplayCell:forRowAtIndexPath:",
                             NSStringFromSelector(@selector(tableView:didSelectRowAtIndexPath:)) :
                                 NSStringFromSelector(@selector(after_tableView:didSelectRowAtIndexPath:)),
                             };
    
    return params;
}

- (NSMutableArray *)analyticsSet {
    if (!_analyticsSet) {
        _analyticsSet = [NSMutableArray array];
    }
    return _analyticsSet;
}

@end
