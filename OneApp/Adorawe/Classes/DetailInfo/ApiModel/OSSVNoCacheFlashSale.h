//
//  OSSVNoCacheFlashSale.h
// XStarlinkProject
//
//  Created by fan wang on 2021/9/2.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OSSVNoCacheFlashSale : NSObject
@property (nonatomic,copy) NSString *active_id;
@property (nonatomic,copy) NSString *active_stock;
@property (nonatomic,copy) NSString *sold_num;
@property (nonatomic,copy) NSString *active_limit;
@property (nonatomic,copy) NSString *active_price;
@property (nonatomic,copy) NSString *active_price_converted;
@property (nonatomic,copy) NSString *discount;
@property (nonatomic,copy) NSString *active_discount;
@property (nonatomic,copy) NSString *save;
@property (nonatomic,copy) NSString *save_converted;
@property (nonatomic,copy) NSString *expire_time;
@property (nonatomic,copy) NSString *active_status;
@property (nonatomic,copy) NSString *label;
@property (nonatomic,copy) NSString *channel_id;
@property (nonatomic,copy) NSString *follow_num;
@property (nonatomic,copy) NSString *sold_out;
@property (nonatomic,copy) NSString *flash_start_time;
@property (nonatomic,copy) NSString *flash_end_time;
@property (nonatomic,copy) NSString *is_can_buy;
@property (nonatomic,copy) NSString *buy_notice;
@end

NS_ASSUME_NONNULL_END
