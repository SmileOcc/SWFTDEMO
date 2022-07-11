//
//  OSSVCartShippingMethodViewModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/8.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "BaseViewModel.h"

@class OSSVCartShippingModel;

@interface OSSVCartShippingMethodViewModel : BaseViewModel<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic,weak) UIViewController *controller;

@property (nonatomic,weak) OSSVCartShippingModel *shippingModel;

@property (nonatomic,strong) NSArray *shippingList;
//CK页当前币种
@property (nonatomic, strong) RateModel *curRate;

@property (nonatomic, assign) BOOL isOptional;

@property (nonatomic,copy) void (^selectedBlock)(NSInteger index);

@end
