//
//  ZFCommunitySearchResultModel.h
//  ZZZZZ
//
//  Created by YW on 2017/7/31.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZFCommunitySearchResultModel : NSObject
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, assign) BOOL isFollow;
@property (nonatomic, copy) NSString *likes_total;
@property (nonatomic, copy) NSString *nick_name;
@property (nonatomic, copy) NSString *review_total;
@property (nonatomic, copy) NSString *user_id;

// 1官方账号, 2认证达人, 3ZMe之星
@property (nonatomic, copy) NSString *identify_type;
@property (nonatomic, copy) NSString *identify_icon;
@end
