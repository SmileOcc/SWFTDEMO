//
//  OSSVAccountMysWishsModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/6.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STLProductsDetailStoreBaseInfoModel;

@interface OSSVAccountMysWishsModel : STLGoodsBaseModel

@property (nonatomic,copy) NSString *goodsThumb;
@property (nonatomic,copy) NSString *goodsMarketPrice;
@property (nonatomic,copy) NSString *goodsAttr;
@property (nonatomic,strong) STLProductsDetailStoreBaseInfoModel *store;
@property (nonatomic,copy) NSString *wid;
@property (nonatomic,copy) NSString *warehouseCode;
@property (nonatomic,copy) NSString *warehouseName;
@property (nonatomic,strong) NSArray *goodsNowAttr;
@property (nonatomic,copy) NSString *collectId;
@property (nonatomic,assign) BOOL isOnSale;
@property (nonatomic,copy) NSString *goodsNum;
@property (nonatomic,copy) NSString *cutoff;


@end
