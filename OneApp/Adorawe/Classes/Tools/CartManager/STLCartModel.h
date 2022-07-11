//
//  STLCartModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/13.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STLCatrActivityModel.h"
#import "STLCartLikeGoodsModel.h"
#import "CartModel.h"
#import "OSSVCartFreeShippingModel.h"
#import "OSSVVivaiaCartFreeShippingModel.h"
@class CartInfoModel;
@class CodConfModel;
@class CartNeedBuyModel;

typedef NS_ENUM(NSInteger,CartGroupModelType) {
    /**普通商品*/
    CartGroupModelTypeNormal = 1,
    /**满减活动*/
    CartGroupModelTypeActivity,
    /**新人免费*/
//    CartGroupModelTypeFree,
    /**失效商品*/
    CartGroupModelTypeFailure,
    /**同类推荐*/
    CartGroupModelTypeRecommend,
    /**空视图*/
    CartGroupModelTypeEmpty
};


@interface STLCartModel : NSObject

/**活动集合*/
@property (nonatomic, strong) NSArray <STLCatrActivityModel*>   *bundGoodsList;
/**其他商品*/
@property (nonatomic, strong) NSArray <CartModel*>             *otherGoodsList;
/**失效商品*/
@property (nonatomic, strong) NSArray <CartModel*>             *failureGoodsList;
/**新人商品 v1.2.0没用到*/
//@property (nonatomic, strong) NSArray <CartModel*>             *freeGiftList;
/**推荐商品*/
@property (nonatomic, strong) STLCartLikeGoodsModel             *likeGoods;
/**购物车广告集*/
@property (nonatomic, strong) NSArray                          *cartTips;
/**购物车金额*/
@property (nonatomic, strong) CartInfoModel                    *cartInfo;
/**Cod提示*/
@property (nonatomic, strong) CodConfModel                     *codConf;

@property (nonatomic, strong) CartNeedBuyModel                 *needBuy;

@property (nonatomic, copy) NSString                           *userid;

@property (nonatomic, copy) NSString                           *positionSort;

@property (nonatomic, copy) NSString                           *discountMsg; //底部文案
@property (nonatomic, copy) NSString                           *discountValue; //底部文案的值
@property (nonatomic, strong) OSSVCartFreeShippingModel        *freeShippingTip; //顶部免邮文案
@property (nonatomic, strong) OSSVVivaiaCartFreeShippingModel  *vivaiaFreeShipping; //用于V 站的顶部免邮文案
////顶部信息
@property (nonatomic, copy) NSString                           *top_notice;

/**推荐商品 二维数组*/
@property (nonatomic, strong) NSArray                          *likeGoodsArray;

//自定义组集合
@property (nonatomic, strong) NSArray                          *groupList;


- (NSMutableArray<CartModel*> *)allValidGoods;
- (NSMutableArray<CartModel*> *)allSelectGoods;

//处理数据
- (void)handleGroupData;

- (void)handleCartGoodsCount;
@end


///////////////////=== 表示集合Model ===//////////////////////

@interface STLCartGroupModel : NSObject

@property (nonatomic, assign) CartGroupModelType    type;
@property (nonatomic, strong) id                    data;

//同类推荐
@property (nonatomic, strong) id                    titleModel;

@end









// ============================== 购物车金额 =========================== //
@interface   CartInfoModel : NSObject

/**节省金额*/
@property (nonatomic, copy) NSString      *save;
/**支付金额*/
@property (nonatomic, copy) NSString      *total;

@property (nonatomic, copy) NSString      *save_converted;

@property (nonatomic, copy) NSString      *total_converted;

@end



// ============================== 限制金额提示 =========================== //
@interface   CodConfModel : NSObject
/**限制金额提示*/
/**最小*/
@property (nonatomic, copy) NSString      *minAmount;
/**最大*/
@property (nonatomic, copy) NSString      *maxAmount;
@end

// ============================== 凑单提示 =========================== //
@interface   CartNeedBuyModel : NSObject
@property (nonatomic, copy) NSString      *content;
/**专题ID*/
@property (nonatomic, copy) NSString      *idx;
/**专题标题*/
@property (nonatomic, copy) NSString      *title;
@end
