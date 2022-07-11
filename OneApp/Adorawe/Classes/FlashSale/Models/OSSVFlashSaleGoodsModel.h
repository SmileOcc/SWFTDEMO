//
//  OSSVFlashSaleGoodsModel.h
// XStarlinkProject
//
//  Created by Kevin on 2020/11/5.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OSSVFlashSaleGoodsModel : STLGoodsBaseModel<YYModel>
@property (nonatomic, copy) NSString *goodId;
@property (nonatomic, copy) NSString *wid;
@property (nonatomic, copy) NSString *goodsImgUrl;
@property (nonatomic, copy) NSString *activeId;
@property (nonatomic, copy) NSString *activeStock;
@property (nonatomic, copy) NSString *soldNum;
@property (nonatomic, copy) NSString *activePrice;
@property (nonatomic, copy) NSString *marketPrice;
@property (nonatomic, copy) NSString *soldOut;
@property (nonatomic, copy) NSString *userWant;
@property (nonatomic, copy) NSString *activeStatus;
@property (nonatomic, copy) NSString *isCollect;

@property (nonatomic,copy) NSString *active_price_converted;//商品价格带货币

///自定义
@property (nonatomic, copy) NSMutableAttributedString *lineMarketPrice;

///1.3.8
@property (nonatomic, copy) NSString *followNum;
@property (nonatomic, assign) NSInteger followId;
@property (nonatomic, assign) BOOL isFollow;
@end

@interface STLFlashTotalModel : NSObject<YYModel>

@property (nonatomic, strong) NSArray<OSSVFlashSaleGoodsModel *> *goodsList;
@property (nonatomic, copy)   NSString *totalCount;
@property (nonatomic, copy)   NSString *pageCount;
@end

NS_ASSUME_NONNULL_END
