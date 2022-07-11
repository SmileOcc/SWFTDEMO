//
//  STLCartLikeGoodsModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/18.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CartLikeGoodsTitleModel;
@class CartLikeGoodsItemsModel;
@interface STLCartLikeGoodsModel : NSObject

@property (nonatomic, strong) CartLikeGoodsTitleModel                        *title;
/**推荐商品*/
@property (nonatomic, strong) NSArray <CartLikeGoodsItemsModel*>             *goods;
@end


// ==============================  =========================== //
@interface CartLikeGoodsTitleModel: NSObject

@property (nonatomic, copy) NSString      *titleName;
@property (nonatomic, copy) NSString      *titleImage;
@end


// ==============================  =========================== //
@interface CartLikeGoodsItemsModel: STLGoodsBaseModel

@property (nonatomic, copy) NSString      *wid;
@property (nonatomic, copy) NSString      *goodsPrice;
@property (nonatomic, copy) NSString      *marketPrice;
@property (nonatomic, copy) NSString      *goodsThumb;

@end
