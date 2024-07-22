//
//  ZFAddressLocationModel.h
//  ZZZZZ
//
//  Created by YW on 2017/12/29.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ZFLocationInfoModel;

@interface ZFAddressLocationModel : NSObject

@property (nonatomic, copy) NSString                                    *hash_key;
@property (nonatomic, assign) BOOL                                      is_open;
@property (nonatomic, strong) NSArray<ZFLocationInfoModel *>            *data;

@end
