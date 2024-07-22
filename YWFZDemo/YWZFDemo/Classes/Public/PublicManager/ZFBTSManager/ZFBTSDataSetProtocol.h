//
//  ZFBTSDataSetProtocol.h
//  ZZZZZ
//
//  Created by YW on 2019/6/18.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//  包含有BTS数据的模型必须遵循这个协议

#import <Foundation/Foundation.h>
#import "ZFBTSModel.h"

@protocol ZFBTSDataSetProtocol <NSObject>

- (NSArray <ZFBTSModel *> *)gainDataSetBTSModelList;

@end

