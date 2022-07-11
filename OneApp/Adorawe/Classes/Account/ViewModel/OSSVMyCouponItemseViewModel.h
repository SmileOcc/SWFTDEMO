//
//  OSSVMyCouponItemseViewModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/24.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "BaseViewModel.h"

@interface OSSVMyCouponItemseViewModel : BaseViewModel<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, weak) UIViewController *controller;

@property (nonatomic, strong) NSMutableArray *dataArray;

@end
