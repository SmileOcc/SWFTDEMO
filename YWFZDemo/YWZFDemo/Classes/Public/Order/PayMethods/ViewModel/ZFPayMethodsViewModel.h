//
//  ZFPayMethodsViewModel.h
//  Zaful
//
//  Created by liuxi on 2017/10/12.
//  Copyright © 2017年 Y001. All rights reserved.
//

#import "BaseViewModel.h"
@class ZFOrderCheckInfoModel;
@interface ZFPayMethodsViewModel : BaseViewModel
/*
 * 请求支付方式列表
 */
- (void)requestNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id))failure;

/*
 * 确认支付方式请求
 */
- (void)requestDoneNetwork:(id)parmaters completion:(void (^)(NSArray<ZFOrderCheckInfoModel *>* dataArray))completion failure:(void (^)(id))failure;
@end
