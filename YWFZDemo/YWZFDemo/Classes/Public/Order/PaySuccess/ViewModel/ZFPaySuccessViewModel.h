//
//  ZFPaySuccessViewModel.h
//  ZZZZZ
//
//  Created by YW on 7/6/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseViewModel.h"

@interface ZFPaySuccessViewModel : BaseViewModel

/**
 * 支付成功后请求验证是否需要引导评论
 */
- (void)requestPaySuccessNetwork:(NSString *)orderSN completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure;

@end
