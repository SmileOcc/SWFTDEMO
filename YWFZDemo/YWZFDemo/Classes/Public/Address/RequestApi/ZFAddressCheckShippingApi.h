//
//  ZFAddressCheckShippingApi.h
//  ZZZZZ
//
//  Created by YW on 2018/12/21.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import "SYBaseRequest.h"

//地址纠错
@interface ZFAddressCheckShippingApi : SYBaseRequest
- (instancetype)initWithDic:(NSDictionary *)addressDic;
@end
