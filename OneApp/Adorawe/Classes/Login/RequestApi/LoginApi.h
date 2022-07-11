//
//  LoginApi.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/1.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVBasesRequests.h"

@interface LoginApi : OSSVBasesRequests

- (instancetype)initWithEmail:(NSString *)email password:(NSString *)password;

@end
