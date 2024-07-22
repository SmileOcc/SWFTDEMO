//
//  ZFNewUserBoardGoodsModel.h
//  ZZZZZ
//
//  Created by mac on 2019/1/18.
//  Copyright © 2019年 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ZFNewUserBoardGoodsSeckillInfo;
@class ZFNewUserBoardGoodsCatLevelColumn;

NS_ASSUME_NONNULL_BEGIN

@interface ZFNewUserBoardGoodsModel : NSObject

@property (nonatomic, strong) NSArray *board_list;
@property (nonatomic, strong) NSMutableArray *goods_list;

@end


@interface ZFNewUserBoardGoodsBoardList : NSObject

@property (nonatomic, assign) double status;
@property (nonatomic, strong) NSString *date;
@property (nonatomic, strong) NSString *sekill_start_desc;
@property (nonatomic, assign) double board_id;
@property (nonatomic, assign) double over_time;

@end


@interface ZFNewUserBoardGoodsGoodsList : NSObject

@property (nonatomic, strong) NSString *goods_thumb;
@property (nonatomic, assign) double is_collect;
@property (nonatomic, strong) NSString *goods_title;
@property (nonatomic, strong) ZFNewUserBoardGoodsSeckillInfo *seckill_info;
@property (nonatomic, strong) NSString *goods_number;
@property (nonatomic, strong) NSString *activityIcon;
@property (nonatomic, strong) NSArray *tags;
@property (nonatomic, strong) NSString *is_on_sale;
@property (nonatomic, strong) NSString *cat_name;
@property (nonatomic, strong) NSString *market_price;
@property (nonatomic, strong) NSString *goods_sn;
@property (nonatomic, strong) NSString *goods_id;
@property (nonatomic, strong) ZFNewUserBoardGoodsCatLevelColumn *cat_level_column;
@property (nonatomic, strong) NSString *wp_image;
@property (nonatomic, strong) NSString *shop_price;

@end


@interface ZFNewUserBoardGoodsSeckillInfo : NSObject

@property (nonatomic, assign) double diff_time;
@property (nonatomic, assign) double seckill_status;
@property (nonatomic, assign) double left_percent;
@property (nonatomic, strong) NSString *goods_left_desc;
@property (nonatomic, assign) double left;
@property (nonatomic, assign) double zhekou;

@end


@interface ZFNewUserBoardGoodsCatLevelColumn : NSObject

@property (nonatomic, strong) NSString *third_cat_name;
@property (nonatomic, strong) NSString *first_cat_name;
@property (nonatomic, strong) NSString *snd_cat_name;

@end

NS_ASSUME_NONNULL_END
