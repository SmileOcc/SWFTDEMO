//
//  OSSVAddresesOfOrdereEnterViewModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/25.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "BaseViewModel.h"

// 地址页面，1： 是直接返回  2： 编辑状态
typedef NS_ENUM(NSUInteger, AddressEidtOrRebackType) {
    AddressRebackType = 0,
    AddressEidtType = 1
};

@class OSSVAddresseBookeModel;
// 执行删除操作（delete）
typedef void (^CompleteExecuteBlock)();

// 更新 列表（当进入到编辑页面返回的时候）
typedef void (^UpdateAddressList)();
// 默认操作
typedef void (^DefaultAddressBlock)();
// 返回选中的model ,为了Order 页面的
typedef void (^GetSelectDefalutModelBlock)(OSSVAddresseBookeModel *model);
// 返回直接修改的model ,为了Order 页面的
typedef void (^GetModifyAddressModelBlock)(OSSVAddresseBookeModel *model);

@interface OSSVAddresesOfOrdereEnterViewModel : BaseViewModel<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, weak) UIViewController             *controller;
@property (nonatomic, copy) CompleteExecuteBlock         completeExecuteBlock;
@property (nonatomic, assign) AddressEidtOrRebackType    editOrRebackType;
@property (nonatomic, copy) UpdateAddressList            updateBlock;
@property (nonatomic, copy) DefaultAddressBlock          defaultBlock;
@property (nonatomic, copy) GetSelectDefalutModelBlock   getDefalutModelBlock;
@property (nonatomic, copy) GetModifyAddressModelBlock   getModifyAddressModelBlock;
@property (nonatomic, copy) NSString                     *selectedAddressId;
//删除按钮
- (void)requestAddressDeleteNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure;
@end
