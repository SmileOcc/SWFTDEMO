//
//  CartModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/1.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CartModel : STLGoodsBaseModel<BCORMEntityProtocol>

/** 数据库ID*/
@property (nonatomic,copy) NSString *rowid;
/** 商品名称*/
@property (nonatomic,copy) NSString *goodsName;
/** 商品数量*/
@property (nonatomic,assign) NSInteger goodsNumber;
/** 商品价格*/
@property (nonatomic,copy) NSString *goodsPrice;
/** 商品属性*/
@property (nonatomic,copy) NSString *goodsAttr;
/** 商品价格*/
@property (nonatomic,copy) NSString *marketPrice; /////
/** 商品缩略图*/
@property (nonatomic,copy) NSString *goodsThumb;
/** 是否收藏0：否，1：是*/
@property (nonatomic,assign) BOOL isFavorite;
/** 修改时间*/
@property (nonatomic,copy) NSString *modify;
/** 店铺名称*/
@property (nonatomic,copy) NSString *store;
/** 仓库编码*/
//@property (nonatomic,copy) NSString *warehouseCode;
/** 仓库名称*/
@property (nonatomic,copy) NSString *warehouseName;
/** 仓库*/
@property (nonatomic,copy) NSString *wid;
/**用户ID*/
//@property (nonatomic,copy) NSString *userid;
/**是否选择*/
@property (nonatomic,assign) NSInteger isChecked;
@property (nonatomic,assign) NSInteger stateType;
@property (nonatomic,copy) NSString *totalPrice;

//** 是否在售*/
@property (nonatomic,assign) BOOL isOnSale;
/** 商品库存数量*/
@property (nonatomic,copy) NSString *goodsStock;

/** 新人免费商品 1  v1.2.0干掉*/
//@property (nonatomic,copy) NSString *freeGiftType;

/**活动id*/
@property (nonatomic, copy) NSString *specialId;

/**0 元新人*/
@property (nonatomic, copy) NSString *is_exchange;
/**活动id*/
@property (nonatomic, copy) NSString *exchange_label;
//闪购活动ID
@property (nonatomic, copy) NSString *activeId;
/** 来源*/
@property (nonatomic, assign) STLAppsflyerGoodsSourceType mediasource;
@property (nonatomic, copy) NSString *reviewsId;

@property (nonatomic, copy) NSString *flash_sale_active_id;
@property (nonatomic, copy) NSString *is_flash_sale;


@property (nonatomic, copy) NSString *shield_status;

@property (nonatomic,assign) NSInteger cart_exits;// 0元商品是否存在
@property (nonatomic, assign) BOOL isFirstRow;
@end
