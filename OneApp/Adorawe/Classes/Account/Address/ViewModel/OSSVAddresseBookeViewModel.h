//
//  OSSVAddresseBookeViewModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/2.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "BaseViewModel.h"
#import "MGSwipeTableCell.h"
@class OSSVAddresseBookeModel;

// 执行删除操作（delete）
typedef void (^CompleteExecuteBlock)();
// 恢复删除操作 （resume）
typedef void (^ResumeDeleteActionBlock)();
// 更新 列表（当进入到编辑页面返回的时候）
typedef void (^UpdateAddressList)();
// 返回选中的model ,为了Order 页面的
typedef void (^GetSelectDefalutModelBlock)(OSSVAddresseBookeModel *model);
// 默认操作
typedef void (^DefaultAddressBlock)();

@interface OSSVAddresseBookeViewModel : BaseViewModel<MGSwipeTableCellDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, weak) UIViewController *controller;

@property (nonatomic, assign) BOOL                      isEdit;
@property (nonatomic, copy) CompleteExecuteBlock        completeExecuteBlock;
@property (nonatomic, copy) ResumeDeleteActionBlock     resumeDeleteActionBlock;
@property (nonatomic, copy) UpdateAddressList           updateBlock;
@property (nonatomic, copy) DefaultAddressBlock         defaultBlock;
@property (nonatomic, copy) GetSelectDefalutModelBlock  getDefalutModelBlock;


- (void)requestAddressDeleteNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure;

@end
