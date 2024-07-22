//
//  FastSettleApi.h
//  ZZZZZ
//
//  Created by YW on 2017/4/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "SYBaseRequest.h"

@interface FastSettleApi : SYBaseRequest
-(instancetype)initWithPayertoken:(NSString *)payertoken payerId:(NSString *)payerId;
@end
