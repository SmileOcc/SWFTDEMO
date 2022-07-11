//
//  OSSVAccounteOrdersDetaileGoodsModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/20.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSSVOrdereMoneyeInfoModel.h"

@interface OSSVAccounteOrdersDetaileGoodsModel : STLGoodsBaseModel

@property (nonatomic,copy) NSString *goods_price;//商品价格
@property (nonatomic,copy) NSString *goodsName;//商品名称
@property (nonatomic,copy) NSString *goodsAttr;//商品规格
@property (nonatomic,copy) NSString *wid;//仓库
@property (nonatomic,copy) NSString *goodsThumb;//商品图片
@property (nonatomic,copy) NSString *goodsNumber;//商品数
@property (nonatomic,assign) NSInteger isReview;//是否评论

@property (nonatomic, copy) NSString *wareHouseName; //仓库名称


@property (nonatomic, copy) NSString *orderId;


@property (nonatomic, strong) OSSVOrdereMoneyeInfoModel *money_info;

@end

