//
//  CouponItemModel.h
//  ZZZZZ
//
//  Created by YW on 2017/6/12.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CouponItemModel : NSObject
@property (nonatomic, copy) NSString *cat_id;

@property (nonatomic, copy) NSString *cishu;

@property (nonatomic, copy) NSString *code;

@property (nonatomic, copy) NSString *code_type;

@property (nonatomic, copy) NSString *create_time;

@property (nonatomic, copy) NSString *end_date;

@property (nonatomic, copy) NSString *exp_time;

@property (nonatomic, copy) NSString *fangshi;

@property (nonatomic, copy) NSString *goods;

@property (nonatomic, copy) NSString *note;

@property (nonatomic, copy) NSString *start_date;

@property (nonatomic, copy) NSString *status;

@property (nonatomic, copy) NSString *youhui;

@property (nonatomic, copy) NSString *youhuilv;

@property (nonatomic, copy) NSString *expire; //  优惠券是否过期

@property (nonatomic, copy) NSString *preferential_head;

@property (nonatomic, copy) NSString *preferential_first;

@property (nonatomic, copy) NSString *deeplink_uri;

@property (nonatomic, assign) BOOL is_72_expiring;

@property (nonatomic, assign) BOOL isShowAll;

@property (nonatomic, assign) BOOL no_mail;
@end
