//
//  OSSVTrackingeInformationeAip.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/6.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVBasesRequests.h"

@interface OSSVTrackingeInformationeAip : OSSVBasesRequests

//- (instancetype)initWithOrderNumber:(NSString *)orderNumber;
- (instancetype)initWithTrackVal:(NSString *)trackVal trackType:(NSString *)trackType;
@end
