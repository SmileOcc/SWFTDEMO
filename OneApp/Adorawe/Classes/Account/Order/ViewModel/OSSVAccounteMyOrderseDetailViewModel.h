//
//  OSSVAccounteMyOrderseDetailViewModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/20.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "BaseViewModel.h"
#import "OSSVOrdereInforeModel.h"

@interface OSSVAccounteMyOrderseDetailViewModel : BaseViewModel<DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (nonatomic,weak) UIViewController *controller;

//取消支付
- (void)requestCancelOrder:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure;

//在线支付
- (void)requestPayNowOrder:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure;

@end
