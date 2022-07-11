//
//  OSSVChangesPasswordsAip.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/3.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVBasesRequests.h"

@interface OSSVChangesPasswordsAip : OSSVBasesRequests

- (instancetype)initWithChangeNewPassword:(NSString *)nowPassword oldPassword:(NSString *)oldPassword;

@end
