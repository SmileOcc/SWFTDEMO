//
//  OSSVCartShippingMethodVC.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/8.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "STLBaseCtrl.h"

@class OSSVCartShippingModel;

@interface OSSVCartShippingMethodVC : STLBaseCtrl

/*接收OSSVCartShippingModel模型数据*/
@property (nonatomic,strong) OSSVCartShippingModel *shippingModel;

/*接收列表数据*/
@property (nonatomic,strong) NSArray *shippingList;

//CK页当前币种
@property (nonatomic, strong) RateModel *curRate;

/*点击返回到Oeder Information -> Block ->OSSVCartShippingModel模型数据*/
@property (nonatomic,copy) void (^callBackBlock)(OSSVCartShippingModel *model);

/*支付ID,用来判断物流列表内COD支付绑定的物流方式不可选*/
@property (nonatomic, assign) BOOL isOptional;

@end
