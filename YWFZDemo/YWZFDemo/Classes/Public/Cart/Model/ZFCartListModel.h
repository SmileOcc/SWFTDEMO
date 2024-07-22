//
//  ZFCartListModel.h
//  ZZZZZ
//
//  Created by YW on 2017/9/16.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFCartListResultModel.h"

@interface ZFCartListModel : NSObject <YYModel>

@property (nonatomic, assign) NSInteger                 statusCode;
@property (nonatomic, strong) ZFCartListResultModel     *result;
@property (nonatomic, copy)   NSString                  *msg;


@end
