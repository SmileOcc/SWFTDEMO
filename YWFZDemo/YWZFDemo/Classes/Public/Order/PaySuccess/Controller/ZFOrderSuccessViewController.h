//
//  YSOrderFinishViewController.h
//  Yoshop
//
//  Created by 7F-shigm on 16/6/24.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import "ZFBaseViewController.h"
#import "ZFFiveThModel.h"
#import "ZFBaseOrderModel.h"
#import "ZFOrderPayResultModel.h"
#import "ZFOrderPayResultHandler.h"

typedef void(^OrderFinishBlock)(BOOL isAccount);

@interface ZFOrderSuccessViewController : ZFBaseViewController

@property (nonatomic, assign) ZFOrderPayResultSource fromType;

//@property (nonatomic, copy) NSString             *orderSN;
@property (nonatomic, copy) OrderFinishBlock     toAccountOrHomeblock;
/**只有结算页进来的，才会显示*/
@property (nonatomic, assign) BOOL               isShowNotictionView;

///各种下单场景中的商品模型列表，用于统计数据
@property (nonatomic, strong) ZFBaseOrderModel *baseOrderModel;

@property (nonatomic, strong) ZFOrderPayResultModel *orderPayResultModel;

@end
