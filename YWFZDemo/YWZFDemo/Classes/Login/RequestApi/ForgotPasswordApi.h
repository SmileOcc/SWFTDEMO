//
//  ForgotPasswordApi.h
//  ZZZZZ
//
//  Created by ZJ1620 on 16/9/22.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "SYBaseRequest.h"

@interface ForgotPasswordApi : SYBaseRequest

-(instancetype)initWithEmail:(NSString *)email;

@end
