//
//  ZFCommunityVideoLiveGoodsModel.h
//  ZZZZZ
//
//  Created by YW on 2019/7/25.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZFCommunityVideoLiveGoodsModel : NSObject

@property (nonatomic, copy) NSString *goods_id;

@property (nonatomic, copy) NSString *goods_sn;

@property (nonatomic, copy) NSString *cat_id;

@property (nonatomic, copy) NSString *cat_name;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *price;

@property (nonatomic, copy) NSString *shop_price;

@property (nonatomic, copy) NSString *url;

@property (nonatomic, copy) NSString *pic_url;

@property (nonatomic, copy) NSString *goods_is_on_sale;

/// 时间唯一标识
@property (nonatomic, copy) NSString *time;


@property (nonatomic,assign) NSTimeInterval   timerInterval;





@end

NS_ASSUME_NONNULL_END
