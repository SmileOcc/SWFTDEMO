//
//  AddressStateModel.h
//  ZZZZZ
//
//  Created by YW on 2017/4/27.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AddressStateModel : NSObject
@property (nonatomic, copy) NSString *provinceName;
@property (nonatomic, copy) NSString *provinceId;
@property (nonatomic, assign) BOOL is_city;
@end
