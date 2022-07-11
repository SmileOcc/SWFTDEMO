//
//  OSSVTransporteSpliteGoodsModel.h
// XStarlinkProject
//
//  Created by Kevin on 2020/11/27.
//  Copyright © 2020 starlink. All rights reserved.
//  -----拆单商品sku Model------

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OSSVTransporteSpliteGoodsModel : NSObject
@property (nonatomic, copy) NSString *goodPrice;
@property (nonatomic, copy) NSString *goodDiscountPrice;
@property (nonatomic, copy) NSString *goodName;
@property (nonatomic, copy) NSString *goodAttr;
@property (nonatomic, copy) NSString *wid;
@property (nonatomic, copy) NSString *goodImgUrl;
@property (nonatomic, copy) NSString *goodId;
@property (nonatomic, copy) NSString *goodSn;
@property (nonatomic, copy) NSString *goodNumber;
@property (nonatomic, copy) NSString *isReview;
@property (nonatomic, copy) NSString *warehouseName;
@property (nonatomic, copy) NSString *formated_goods_price;
@property (nonatomic, copy) NSString *formated_subtotal;
@property (nonatomic, copy) NSString *subtotal;
@property (nonatomic, copy) NSString *catId;
@property (nonatomic, copy) NSString *catName;
@property (nonatomic, copy) NSString *show_in_goods_list;
@property (nonatomic, copy) NSString *isDelete;

@end

NS_ASSUME_NONNULL_END
