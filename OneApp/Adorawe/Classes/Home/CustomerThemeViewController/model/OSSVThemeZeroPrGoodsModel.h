//
//  OSSVThemeZeroPrGoodsModel.h
// OSSVThemeZeroPrGoodsModel
//
//  Created by odd on 2020/9/14.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OSSVThemeZeroPrGoodsModel : STLGoodsBaseModel

//@property (nonatomic,copy) NSString *market_price_converted;
@property (nonatomic,copy) NSString *goods_id;
@property (nonatomic,copy) NSString *goods_img;
@property (nonatomic,copy) NSString *goodsSn;
@property (nonatomic,copy) NSString *exchange_price;
@property (nonatomic,copy) NSString *exchange_price_converted;
@property (nonatomic,copy) NSString *exchange_active_goods;
@property (nonatomic,copy) NSString *pageType;
@property (nonatomic,copy) NSString *wid;
@property (nonatomic,copy) NSString *url;
@property (nonatomic,copy) NSString *specialId;
@property (nonatomic,copy) NSString *mark_img;
@property (nonatomic,copy) NSString *tips_reduction;
@property (nonatomic,copy) NSString *shop_price;
@property (nonatomic,copy) NSString *shop_price_converted;
@property (nonatomic,assign) NSInteger sold_out;
@property (nonatomic,assign) NSInteger goods_number;
@property (nonatomic,copy) NSString *goods_title;
@property (nonatomic,assign) NSInteger cart_exists;
///自定义
@property (nonatomic, copy) NSMutableAttributedString *lineMarketPrice;
@property (nonatomic,assign) NSInteger type;

@end

NS_ASSUME_NONNULL_END
