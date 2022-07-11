//
//  OSSVHomeGoodsListModel.h
// OSSVHomeGoodsListModel
//
//  Created by 10010 on 20/7/31.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STLGoodsBaseModel.h"

@interface OSSVHomeGoodsListModel : STLGoodsBaseModel

@property (nonatomic, copy) NSString *cutOffRate; // 折扣率
@property (nonatomic, copy) NSString *goodsImageUrl; // 图片URL
@property (nonatomic, copy) NSString *warehouseCode; // 仓库编号
@property (nonatomic, copy) NSString *wid; // 仓库ID
@property (nonatomic, assign) BOOL isDailyDeal; // 是否是优惠产品，就是是否有计时器  (是否设置DailyDeal 1是 0否)
@property (nonatomic, assign) NSInteger leftTime; // 定时器的剩余时间  秒
@property (nonatomic, copy) NSString   *markImgUrl; //水印图片URL
@property (nonatomic, assign) NSInteger   is_collect; //水印图片URL
////自定义 首页底部信息
@property (nonatomic, copy) NSString   *categoryId;

//****************闪购商品************************//
@property (nonatomic, copy) NSString   *activePrice;
@property (nonatomic, copy) NSString   *activeId;
@property (nonatomic, copy) NSString   *active_price_converted;


///自定义
@property (nonatomic, copy) NSMutableAttributedString *lineMarketPrice;

@end
