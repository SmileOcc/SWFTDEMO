//
//  ZFCollocationBuyModel.h
//  ZZZZZ
//
//  Created by YW on 2019/8/13.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZFCollocationBuyTabModel : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *channel_id;
@end


@interface ZFUnfloatPriceInfo : NSObject
@property (nonatomic, strong)   NSArray *tags;
@property (nonatomic, assign) BOOL is_specil_goods;
@property (nonatomic, copy)   NSString *price;
@property (nonatomic, assign) NSInteger type;
@end


@interface ZFCollocationGoodsModel : NSObject
@property (nonatomic, copy)   NSString *goods_title;
@property (nonatomic, copy)   NSString *shop_price_backup;
@property (nonatomic, copy)   NSString *cat_id;
@property (nonatomic, copy)   NSString *goods_number;
@property (nonatomic, copy)   NSString *delivery_level;
@property (nonatomic, strong) NSArray *tags;
@property (nonatomic, assign) NSInteger priceType;
@property (nonatomic, copy)   NSString *goods_sn;
@property (nonatomic, copy)   NSString *real_time_number;
@property (nonatomic, copy)   NSString *shop_price;
@property (nonatomic, copy)   NSString *market_price;
@property (nonatomic, copy)   NSString *is_on_sale;
@property (nonatomic, strong) ZFUnfloatPriceInfo *unfloatPriceInfo;
@property (nonatomic, copy)   NSString *goods_id;
@property (nonatomic, copy)   NSString *shelf_down_type;
@property (nonatomic, copy)   NSString *is_lang_show_cur;
@property (nonatomic, copy)   NSString *goods_grid_app;
/** 标签栏 */
@property (nonatomic, copy)   NSString *tagetTitle;
@property (nonatomic, assign) BOOL shouldSelected;
@end


@interface ZFCollocationBuyModel : NSObject
@property (nonatomic, strong)  NSArray<NSArray <ZFCollocationGoodsModel *> *> *collocationGoodsArr;
@property (nonatomic, strong)  NSArray<NSString *> *collocationTitleArr;
@property (nonatomic, copy)  NSString *shopPrice;
@property (nonatomic, copy)  NSString *marketPrice;
@end


NS_ASSUME_NONNULL_END
