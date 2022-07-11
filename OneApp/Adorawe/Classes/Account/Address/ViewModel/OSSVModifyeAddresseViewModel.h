//
//  OSSVModifyeAddresseViewModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/6.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "BaseViewModel.h"

@interface OSSVModifyeAddresseViewModel : BaseViewModel

@property (nonatomic, weak) UIViewController    *controller;
- (void)requestEditAddressNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure;

- (void)requestAddressPhoneCheckNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure;

@end
