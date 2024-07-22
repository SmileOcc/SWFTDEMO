//
//  ZFAddressViewModel.h
//  ZZZZZ
//
//  Created by YW on 2017/8/29.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "BaseViewModel.h"

@interface ZFAddressViewModel : BaseViewModel
/**
 * 请求地址列表
 */
- (void)requestAddressListNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure;

/**
 * 删除地址
 */
- (void)requestDeleteAddressNetwork:(id)parmaters completion:(void (^)(BOOL isOK))completion;

/**
 * 选择默认地址
 */
- (void)requestsetDefaultAddressNetwork:(id)parmaters completion:(void (^)(BOOL isOK))completion;


- (void)requestAddressLocationInfoNetwork:(id)parmaters completion:(void (^)(id obj))completion;
@end
