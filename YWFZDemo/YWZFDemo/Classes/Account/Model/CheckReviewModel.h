//
//  CheckReviewModel.h
//  ZZZZZ
//
//  Created by DBP on 16/12/27.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CheckReviewModel : NSObject

@property (nonatomic, copy) NSString *review_id;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *add_time;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *nick_name;
@property (nonatomic, copy) NSString *order_id;
@property (nonatomic, copy) NSString *rate_overall;

@property (nonatomic, strong) NSArray *review_pic;

@end
