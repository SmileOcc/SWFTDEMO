//
//  OSSVCategoriyDetailsGoodListsModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/4.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STLGoodsBaseModel.h"

@interface OSSVCategoriyDetailsGoodListsModel : STLGoodsBaseModel

@property (nonatomic, copy) NSString *count; 
@property (nonatomic, copy) NSString *cutOffRate; // 折扣率
@property (nonatomic, copy) NSString *goodsImageUrl; // 图片标准图 URL
@property (nonatomic, copy) NSString *groupBy;
@property (nonatomic, copy) NSString *originalMarketPrice; //商品原来的价格 --market_price
@property (nonatomic, copy) NSString *warehouseCode; //(仓库编号)
@property (nonatomic, copy) NSString *wid; // 仓库ID -- wid
//@property (nonatomic, assign) BOOL isDailyDeal; // 是否是优惠产品，就是是否有计时器  (是否设置DailyDeal 1是 0否)
@property (nonatomic, assign) NSInteger leftTime; // 定时器的剩余时间  秒
//@property (nonatomic, strong) NSIndexPath *countDownIndexPath; // 对应定时器的index
@property (nonatomic, copy) NSString *markImgUrl;//商品水印图片URL
@property (nonatomic, assign) NSInteger is_collect;// 收藏

@end
