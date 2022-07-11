//
//  OSSVCartGoodsModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/13.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OSSVCartGoodsModel : STLGoodsBaseModel
@property (nonatomic, copy) NSString *goodsSn;
@property (nonatomic, copy) NSString *wid;
@property (nonatomic, copy) NSString *goodsAttr;
@property (nonatomic, copy) NSString *goodsName;
@property (nonatomic, copy) NSString *goodsThumb;
@property (nonatomic, copy) NSString *goodsPrice;
@property (nonatomic, assign) NSInteger goodsNumber;
@property (nonatomic, copy) NSString *warehouseName;                                   ///<所属仓库名称

@property (nonatomic,copy) NSString *goods_discount_price;


@property (nonatomic,copy) NSString *cart_id;

@property (nonatomic,copy) NSString *is_clearance;

@property (nonatomic,copy) NSString *is_promote_price;

//新增两个为了闪购商品不能使用优惠券
@property (nonatomic,copy) NSString *flashSaleId; //闪购ID
@property (nonatomic,copy) NSString *isFlashSale; //是否为闪购商品

@property (nonatomic,copy) NSString *shield_status; //是否为闪购商品

//零元购模型
@property (nonatomic,copy) NSString *is_exchange;
@property (nonatomic,copy) NSString *exchange_label;

@end



