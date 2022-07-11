//
//  OSSVGoodsListModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/3.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STLGoodsBaseModel.h"

@class GoodsDetailsImageSizeModel;

@interface OSSVGoodsListModel : STLGoodsBaseModel

@property (nonatomic,copy) NSString     *wid; //仓库   ////
//@property (nonatomic,copy) NSString     *warehouseCode; // 仓库编码
@property (nonatomic,copy) NSString     *goodsImg; // 图片URL
@property (nonatomic,copy) NSString     *goodsMarketPrice; // 原价
@property (nonatomic,copy) NSString     *goodsCount; // 推荐商品个数
@property (nonatomic,copy) NSString     *cutOffRate; // 折扣
@property (nonatomic,copy) NSString     *markImgUrlString; //水印图片链接
@property (nonatomic,copy) NSString     *isCollect;  //是否收藏
@end
