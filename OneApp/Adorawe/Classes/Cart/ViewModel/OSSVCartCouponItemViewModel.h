//
//  OSSVCartCouponItemViewModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/28.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "BaseViewModel.h"
#import "RadioButton.h"

@class OSSVMyCouponsListsModel;

@interface OSSVCartCouponItemViewModel : BaseViewModel<UITableViewDelegate,UITableViewDataSource,DZNEmptyDataSetSource, DZNEmptyDataSetDelegate,RadioButtonDelegate>

@property (nonatomic,weak) UIViewController *controller;

@property (nonatomic,copy) void (^selectedBlock)(OSSVMyCouponsListsModel *model);

@property (nonatomic,copy) NSString *couponCode;

@property (nonatomic, strong) NSArray *available;

@property (nonatomic, strong) NSArray *unavailable;

@property (weak,nonatomic) NSString *noCouponTitle;

@end
