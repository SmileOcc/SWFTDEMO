//
//  BoletoApi.h
//  ZZZZZ
//
//  Created by YW on 4/11/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "SYBaseRequest.h"

@interface BoletoApi : SYBaseRequest

-(instancetype)initWithOrderID:(NSString *)orderid;

@end
