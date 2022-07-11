//
//  GoodsDetailsBaseInfoModel.h
//  Yoshop
//
//  Created by huangxieyue on 16/6/2.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GoodsDetailsBaseInfoModel : NSObject

@property (nonatomic,copy) NSString *goodsId;
@property (nonatomic,copy) NSString *goodsSku;
@property (nonatomic,copy) NSString *goodsSmallImg;
@property (nonatomic,copy) NSString *goodsImg;
@property (nonatomic,copy) NSString *goodsBigImg;
@property (nonatomic,copy) NSString *goodsUrlTitle;
@property (nonatomic,copy) NSString *goodsBrand;
@property (nonatomic,copy) NSString *goodsGroupId;
@property (nonatomic,copy) NSString *goodsTitle;
@property (nonatomic,copy) NSString *goodsWeight;
@property (nonatomic,copy) NSString *goodsVolumeWeight;
@property (nonatomic,copy) NSString *goodsDeliveryTime;
@property (nonatomic,copy) NSString *goodsImgType;
@property (nonatomic,copy) NSString *goodsImgWidth;
@property (nonatomic,copy) NSString *goodsImgHeight;
@property (nonatomic,copy) NSString *goodsDeliveryLevel;
@property (nonatomic,copy) NSString *goodsSupplierCode;
@property (nonatomic,copy) NSString *goodsDiscount;
@property (nonatomic,copy) NSString *goodsWid;
@property (nonatomic,copy) NSString *goodsMarketPrice;
@property (nonatomic,copy) NSString *goodsShopPrice;
@property (nonatomic,copy) NSString *goodsNumber;

@property (nonatomic,copy) NSString *promoteLv;
@property (nonatomic,copy) NSString *promotePrice;
@property (nonatomic,copy) NSString *promoteStartDate;
@property (nonatomic,copy) NSString *promoteEndDate;
@property (nonatomic,copy) NSString *promoteRemark;

@property (nonatomic,copy) NSString *catName;
@property (nonatomic,copy) NSString *catId;

@property (nonatomic,copy) NSString *isPromote;
@property (nonatomic,copy) NSString *isDelete;
@property (nonatomic,copy) NSString *isOnSale;
@property (nonatomic,copy) NSString *isFreeShipping;

@end