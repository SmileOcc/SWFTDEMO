//
//  ZFCommunityGoodsInfosModel.h
//  Yoshop
//
//  Created by YW on 16/7/19.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZFCommuitySameGoodsCatModel : NSObject
@property (nonatomic, copy) NSString *catId;
@property (nonatomic, copy) NSString *catName;
@end

@interface ZFCommunityGoodsInfosModel : NSObject

@property (nonatomic, copy) NSString *goodsImg;//商品图片
@property (nonatomic, copy) NSString *goodsTitle;//商品名称
@property (nonatomic, copy) NSString *shopPrice;//商品价格
@property (nonatomic, copy) NSString *goodsId;//商品ID
@property (nonatomic, copy) NSString *goods_sn;
@property (nonatomic, assign) BOOL isSame;
@property (nonatomic, copy) NSString *wid;

//自定义选择次数
@property (nonatomic, assign) NSInteger selectSkuCount;

@end
