//
//  OSSVCartOrderInfoViewModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/27.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "BaseViewModel.h"
#import "OSSVAddresseBookeModel.h"
#import "OSSVCouponModel.h"
#import "OSSVCartWareHouseModel.h"
#import "OSSVCartPaymentModel.h"
#import "OSSVPointsModel.h"
#import "OSSVCartShippingModel.h"
#import "OSSVCartCheckModel.h"

///<CartCheck接口网络请求类型
typedef NS_ENUM(NSInteger) {
    CartCheckType_Coupon,           ///<优惠券
    CartCheckType_Point,            ///<积分
    CartCheckType_Normal            ///<普通
}CartCheckType;

@interface OSSVCartOrderInfoViewModel : BaseViewModel

@property (nonatomic,weak) UIViewController *controller;

//Create Order
- (void)requestCartCheckNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure;

// 发送SMS到用户手机
- (void)requestSMSVerifyNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure;

@property (nonatomic, assign) CartCheckType cartCheckType;
#pragma mark - 作为视图模型保存视图的一些参数

@property (nonatomic, copy) NSString *payToken;
@property (nonatomic, assign) BOOL isPaypalFast;
@property (nonatomic, copy) NSString *verifyCode;
@property (nonatomic, copy) NSString *coinPayType;
///<保存后台的支付方式容器
@property (nonatomic, strong) NSMutableArray *paymentList;
///<后台返回的数据模型
@property (nonatomic, strong) OSSVCartCheckModel *checkOutModel;
///<选择的地址模型
@property (nonatomic, strong) OSSVAddresseBookeModel *addressModel;
///<物流方式模型
@property (nonatomic, strong) OSSVCartShippingModel *shippingModel;
///<选择的优惠券模型
@property (nonatomic, strong) OSSVCouponModel *couponModel;
///<用户的商品列表模型 <OSSVCartWareHouseModel *>
@property (nonatomic, strong) NSArray *wareHouseModelList;
///<用户有效的商品列表 用于获取优惠券信息的时候传参 <OSSVCartGoodsModel>
@property (nonatomic, strong) NSMutableArray *effectiveProductList;
///<用户选择的支付模型
@property (nonatomic, strong) OSSVCartPaymentModel *paymentModel;
///<用户选择的积分
@property (nonatomic, strong) OSSVPointsModel *ypointModel;
///<物流保险  --打开为1， 关闭为0
@property (nonatomic, copy) NSString *shippingInsurance;
///<最终总价格
//@property (nonatomic, assign) CGFloat totalPrice;
///<保存页面仓库totalPrice行的状态列表
@property (nonatomic, strong) NSMutableArray *totalPriceCellStatusList;


@end
