//
//  CartOperationViewModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/7.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "BaseViewModel.h"
@class CartModel;
@interface CartOperationViewModel : BaseViewModel
- (void)requestCartAddNetwork:(CartModel *)cartModel completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure;
//- (void)requestCartEditNetwork:(CartModel *)cartModel completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure;
//- (void)requestCartDelNetwork:(CartModel *)cartModel completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure;


- (void)requestCartUploadNetwork:(id)parmaters showView:(UIView *)showView completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure;

- (void)requestCartUncheckNetwork:(id)parmaters showView:(UIView *)showView completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure;
@end
