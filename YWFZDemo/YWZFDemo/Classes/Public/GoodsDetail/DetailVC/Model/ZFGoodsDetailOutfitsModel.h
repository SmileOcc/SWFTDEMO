//
//  ZFGoodsDetailOutfitsModel.h
//  ZZZZZ
//
//  Created by YW on 2019/9/17.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ZFGoodsModel;

NS_ASSUME_NONNULL_BEGIN

@interface ZFDetailOutfitsPicModel : NSObject
@property (nonatomic, copy) NSString *height;
@property (nonatomic, copy) NSString *review_id;
@property (nonatomic, copy) NSString *small_pic;
@property (nonatomic, copy) NSString *width;
@property (nonatomic, copy) NSString *big_pic;
@property (nonatomic, copy) NSString *origin_pic;
@property (nonatomic, copy) NSString *is_first_pic;
@end


@interface ZFGoodsDetailOutfitsModel : NSObject

@property (nonatomic, copy) NSString *outfitsId;
@property (nonatomic, copy) NSString *liked;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *user_id;
@property (nonatomic, copy) NSString *property;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *sort;
@property (nonatomic, copy) NSString *like_count;
@property (nonatomic, copy) NSString *followed;
@property (nonatomic, copy) NSString *reply_count;
@property (nonatomic, copy) NSString *identify_icon;
@property (nonatomic, copy) NSString *is_top;
@property (nonatomic, copy) NSString *review_type;
@property (nonatomic, copy) NSString *add_time;
@property (nonatomic, copy) NSString *view_num;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *identify_type;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *site_version;
@property (nonatomic, strong) ZFDetailOutfitsPicModel *picModel;

/** 此商品关联的穿搭接口数据 */
@property (nonatomic, strong) NSArray<ZFGoodsModel *> *goodsModelArray;
/** 是否已统计过曝光 */
@property (nonatomic, assign) BOOL hasStatisticsShowGoods;


@end

NS_ASSUME_NONNULL_END
