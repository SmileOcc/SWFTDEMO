//
//  CouponItemApi.h
//  ZZZZZ
//
//  Created by YW on 2017/6/12.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "SYBaseRequest.h"

@interface CouponItemApi : SYBaseRequest
-(instancetype)initWithKind:(NSString *)kind page:(NSInteger)page pageSize:(NSInteger)pageSize;
@end
