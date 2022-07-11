//
//  OSSVOrderFinishsVC.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/24.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "STLBaseCtrl.h"
#import "OSSVOrderInfoeModel.h"
#import "RateModel.h"
#import "OSSVCreateOrderModel.h"
#import "OSSVCartOrderInfoViewModel.h"
#import "OSSVAccounteOrdersDetaileGoodsModel.h"

typedef void(^OrderFinishBlock)(void);

@interface OSSVOrderFinishsVC : STLBaseCtrl

///已废弃
//@property (nonatomic, copy) NSString *orderSn;
/////已废弃
//@property (nonatomic, strong) RateModel *rateModel;
/////已废弃
//@property (nonatomic, strong) OSSVOrderInfoeModel *OSSVOrderInfoeModel;


@property (nonatomic, copy) OrderFinishBlock block;
@property (nonatomic, assign) BOOL isCOD;   // 是否为COD支付

///因为拆单的缘故，所以后台可能返回多个订单
@property (nonatomic, strong) OSSVCreateOrderModel *createOrderModel;

@property (nonatomic, assign) BOOL isFromOrder;

@end
