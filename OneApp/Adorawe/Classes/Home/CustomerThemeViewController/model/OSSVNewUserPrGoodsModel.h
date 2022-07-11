//
//  OSSVNewUserPrGoodsModel.h
// OSSVNewUserPrGoodsModel
//
//  Created by 10010 on 20/7/27.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OSSVNewUserPrGoodsModel : STLGoodsBaseModel

@property (nonatomic,copy) NSString *shopPrice;
@property (nonatomic,copy) NSString *goodsNumber;
@property (nonatomic,copy) NSString *isOnSale;
@property (nonatomic,copy) NSString *marketPrice;
@property (nonatomic,copy) NSString *goodsImg;
@property (nonatomic,copy) NSString *wid;
@property (nonatomic,assign) BOOL isCollect;
// 多属性数组
@property (nonatomic,strong) NSArray<OSSVSpecsModel*>        *goodsSpecs;

///自定义
@property (nonatomic, copy) NSMutableAttributedString *lineMarketPrice;
@end
