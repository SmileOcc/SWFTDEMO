//
//  STLThemeCouponsModel.h
// XStarlinkProject
//
//  Created by Starlinke on 2021/7/5.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Btn_multi :NSObject
@property (nonatomic , copy) NSString              * theme;
@property (nonatomic , copy) NSString              * toast_en;
@property (nonatomic , copy) NSString              * toast_ar;

@end


@interface Btn :NSObject
@property (nonatomic , copy) NSString              * theme;
@property (nonatomic , copy) NSString              * toast_en;
@property (nonatomic , copy) NSString              * toast_ar;

@end


@interface Coupon_itemModel :NSObject
@property (nonatomic , copy)   NSString              * coupon_id;
@property (nonatomic , copy)   NSString              * coupon_code;
@property (nonatomic , copy)   NSString              * type;
@property (nonatomic , copy)   NSString              * type_name;
@property (nonatomic , copy)   NSString              * day_time;
@property (nonatomic , copy)   NSString              * title;
@property (nonatomic , strong) NSArray <NSString *>  * content;
@property (nonatomic , copy)   NSString              * expiry_date_str;
@property (nonatomic , assign) NSInteger              is_received;

@end


@interface OSSVThemesCouponssModel :NSObject
@property (nonatomic , copy) NSString                               * sort;
@property (nonatomic , copy) NSString                               * get_type;
@property (nonatomic , copy) NSString                               * coupon_str;
@property (nonatomic , copy) NSString                               * theme;
@property (nonatomic , copy) NSString                               * bg_image;
@property (nonatomic , copy) NSString                               * bg_color_val;
@property (nonatomic , strong) Btn_multi                            * btn_multi;
@property (nonatomic , strong) Btn                                  * btn;
@property (nonatomic , copy) NSString                               * type;
@property (nonatomic , copy) NSString                               * bg_color;
@property (nonatomic , strong) NSArray <Coupon_itemModel *>              * coupon_items;

@end
NS_ASSUME_NONNULL_END
