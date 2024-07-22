//
//  ZFCommunityPostOrderListApi.h
//  ZZZZZ
//
//  Created by YW on 2017/7/25.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "SYBaseRequest.h"

@interface ZFCommunityPostOrderListApi : SYBaseRequest

- (instancetype)initWithOrderWithPage:(NSInteger)page pageSize:(NSInteger)pageSize;

@end
