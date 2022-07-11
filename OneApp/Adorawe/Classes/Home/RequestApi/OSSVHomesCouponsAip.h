//
//  STLHomeCouponApi.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/29.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVBasesRequests.h"

@interface OSSVHomesCouponsAip : OSSVBasesRequests

-(instancetype)initWithCouponCode:(NSString *)code specialID:(NSString *)specialId;

@end
