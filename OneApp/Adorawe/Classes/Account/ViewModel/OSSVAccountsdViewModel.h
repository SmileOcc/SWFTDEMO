//
//  OSSVAccountsdViewModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/31.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "BaseViewModel.h"

@interface OSSVAccountsdViewModel : BaseViewModel<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) UIViewController *controller;

- (void)messageRequest:(id)parmaters
            completion:(void (^)(id))completion
               failure:(void (^)(id))failure;

- (void)updateCouponCount:(NSInteger)count;

@end
