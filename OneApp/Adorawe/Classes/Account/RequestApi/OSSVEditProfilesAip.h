//
//  OSSVEditProfilesAip.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/3.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVBasesRequests.h"

@interface OSSVEditProfilesAip : OSSVBasesRequests

- (instancetype)initWithNickName:(NSString *)nickName sex:(NSString *)sex birthday:(NSString *)birthday avatar:(NSString *)avatar;

@end
