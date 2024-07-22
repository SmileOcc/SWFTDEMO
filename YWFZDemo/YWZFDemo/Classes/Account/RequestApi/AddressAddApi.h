//
//  AddressAddApi.h
//  Yoshop
//
//  Created by YW on 16/6/7.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import "SYBaseRequest.h"

@class AddressBookModel;

@interface AddressAddApi : SYBaseRequest

- (instancetype)initWithDic:(NSDictionary *)addressDic;
@end
