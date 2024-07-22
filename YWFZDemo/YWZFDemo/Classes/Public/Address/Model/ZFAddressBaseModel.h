//
//  ZFAddressBaseModel.h
//  ZZZZZ
//
//  Created by YW on 2019/1/9.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ZFAddressBaseModel : NSObject

@property (nonatomic, assign) NSUInteger    hashCost; // 排序用

@property (nonatomic, copy) NSString        *idx;

@property (nonatomic, copy) NSString        *n;

/** 分组key*/
@property (nonatomic, copy) NSString        *k;

@end

