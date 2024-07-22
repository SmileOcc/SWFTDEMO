//
//  ZFCouponListItemAOP.m
//  ZZZZZ
//
//  Created by 602600 on 2019/12/18.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCouponListItemAOP.h"
#import <UIKit/UIKit.h>
#import "ZFAccountProductCell.h"
#import "YWCFunctionTool.h"
#import "ZFGrowingIOAnalytics.h"
#import "ZFAppsflyerAnalytics.h"
#import "AccountManager.h"

@interface ZFCouponListItemAOP ()

@property (nonatomic, strong) NSMutableArray *analyticsSet;

@end

@implementation ZFCouponListItemAOP

- (void)after_requestCouponItemPageData:(BOOL)isFirstPage
                             completion:(void (^)(NSDictionary *pageInfo))completion {
    if (isFirstPage) {
        [self.analyticsSet removeAllObjects];
    }
}

- (void)after_tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[ZFAccountProductCell class]]) {
        ZFAccountProductCell *productCell = (ZFAccountProductCell *)cell;
        [productCell.goodsList enumerateObjectsUsingBlock:^(ZFGoodsModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![self.analyticsSet containsObject:ZFToString(obj.goods_id)]) {
                [self.analyticsSet addObject:ZFToString(obj.goods_id)];
                obj.af_rank = (idx + 1) + (indexPath.row * productCell.goodsList.count);
                [ZFAppsflyerAnalytics trackGoodsList:@[obj] inSourceType:ZFAppsflyerInSourceTypeMyCouponListRecommend AFparams:nil];
                [ZFGrowingIOAnalytics ZFGrowingIOProductShow:obj page:GIOSourceAccountRecommend];
            }
        }];
    }
}

- (void)after_ZFAccountProductCellDidSelectProduct:(ZFGoodsModel *)goodsModel {
    // appflyer统计
    NSDictionary *appsflyerParams = @{@"af_content_id" : ZFToString(goodsModel.goods_sn),
                                      @"af_spu_id" : ZFToString(goodsModel.goods_spu),
                                      @"af_recommend_name" : @"recommend_couponlist",
                                      @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type), //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                      @"af_page_name" : @"mycoupon_page",    // 当前页面名称
                                      @"af_second_entrance" : @"recommend_couponlist"
                                      };
    [ZFAppsflyerAnalytics zfTrackEvent:@"af_recommend_click" withValues:appsflyerParams];
    
    [ZFGrowingIOAnalytics ZFGrowingIOProductClick:goodsModel page:GIOSourceCouponRecommend sourceParams:@{
        GIOGoodsTypeEvar : GIOGoodsTypeRecommend,
        GIOGoodsNameEvar : @"recommend_couponlist",
        GIOFistEvar : GIOSourceAccount,
        GIOSndNameEvar : GIOSourceCouponRecommend
    }];
}

///after 注入事件
-(NSDictionary *)injectMenthodParams
{
    return @{
    NSStringFromSelector(@selector(tableView:willDisplayCell:forRowAtIndexPath:)) : @"after_tableView:willDisplayCell:forRowAtIndexPath:",
    @"requestCouponItemPageData:completion:" : @"after_requestCouponItemPageData:completion:",
    @"ZFAccountProductCellDidSelectProduct:" : @"after_ZFAccountProductCellDidSelectProduct:"
    };;
}

- (NSMutableArray *)analyticsSet {
    if (!_analyticsSet) {
        _analyticsSet = [NSMutableArray array];
    }
    return _analyticsSet;
}

@end
