//
//  ZFCommunityAccountInfoModel.h
//  ZZZZZ
//
//  Created by YW on 2017/8/1.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZFCommunityAccountInfoModel : NSObject
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, assign) NSInteger state;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, assign) NSInteger followingCount;
@property (nonatomic, assign) NSInteger followersCount;
@property (nonatomic, assign) NSInteger likeCount;
@property (nonatomic, assign) BOOL isFollow;

//开通的用户affiliate_id是大于0的数字
@property (nonatomic, assign) NSInteger affiliate_id;
// 1官方账号, 2认证达人, 3ZMe之星
@property (nonatomic, copy) NSString *identify_type;
@property (nonatomic, copy) NSString *identify_icon;
@property (nonatomic, copy) NSString *identify_content;

@end
