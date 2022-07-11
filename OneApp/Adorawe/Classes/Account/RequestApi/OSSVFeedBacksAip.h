//
//  OSSVFeedBacksAip.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/7.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVBasesRequests.h"

@interface OSSVFeedBacksAip : OSSVBasesRequests

- (instancetype)initWithFeedBackType:(NSString *)type email:(NSString *)email content:(NSString *)content images:(NSArray *)images;

@end
