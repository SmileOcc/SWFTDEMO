//
//  RegisterApi.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/1.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVBasesRequests.h"

@interface RegisterApi : OSSVBasesRequests

@property (copy,nonatomic) NSString *subscribe;

- (instancetype)initWithEmail:(NSString *)email password:(NSString *)password sex:(NSString *)sex;

@end
