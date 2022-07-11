//
//  OSSVAccounteMyOrderseDetailModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/20.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSSVOrdereMoneyeInfoModel.h"

@class OSSVAccounteOrderseDetailShippingeModel;
@class OSSVAccounteOrdereDetailExtraeModel;
@class AddressGoodsShieldInfoModel;

@interface OSSVAccounteMyOrderseDetailModel : NSObject

@property (nonatomic,copy) NSString *orderId;//订单ID
@property (nonatomic,copy) NSString *orderSn;//订单SKU
@property (nonatomic,assign) NSInteger orderStatus;//订单状态
@property (nonatomic,copy) NSString *orderStatusValue;//订单状态字符串
@property (nonatomic,copy) NSString *firstName;//姓
@property (nonatomic,copy) NSString *lastName;//名
@property (nonatomic,copy) NSString *street;//街
@property (nonatomic,copy) NSString *streetMore;//详细地址
@property (nonatomic,copy) NSString *country;//国家
@property (nonatomic,copy) NSString *province;//省
@property (nonatomic,copy) NSString *city;//市
@property (nonatomic,copy) NSString *phone;//手机
@property (nonatomic,copy) NSString *zip;//邮编
@property (nonatomic,copy) NSString *district;
@property (nonatomic,strong) NSArray *goodsList;//商品信息列表
@property (nonatomic,copy) NSString *shippingName;//物流方式
@property (nonatomic,copy) NSString *payName;//支付方式
@property (nonatomic,copy) NSString *payCode;//支付方式编码    ------->新增
@property (nonatomic,assign) NSInteger orderaddTime; //下单时间的时间戳
@property (nonatomic,copy) NSString *addTime;//订单下单时间
@property (nonatomic,copy) NSString *orderDate; //订单下单时间格式化的

@property (nonatomic,copy) NSString *wid;//仓库   ------->新增
@property (nonatomic,strong) OSSVAccounteOrderseDetailShippingeModel *shipping;//物流配送信息
@property (nonatomic,copy) NSString *paydesc; //一小时支付获取五倍积分说明

@property (nonatomic,copy) NSString *pointMoney;
@property (nonatomic, copy) NSString *codFractionsType;             ///<cod 折扣类型 0不变 1向上取整 2向下取整
@property (nonatomic, copy) NSString *expiresTime;
@property (nonatomic, copy) NSString *is_split;         //是否拆单---1是 0否
@property (nonatomic, copy) NSString *split_text;       //拆单文案
/// 物流包裹数
@property (nonatomic, assign) NSInteger parcel_num;

@property (nonatomic, copy) NSString *order_flow_switch;        ///0 默认流程A流程需要发送短信 1 B流程 需要多次确认
@property (nonatomic, copy) NSString *order_remark;        ///订单取消/设为已付款说明

@property (nonatomic, copy) NSString *coupon_code;

@property (nonatomic, copy) NSString *insurance_cost; //物流运险费
@property (nonatomic, strong) OSSVOrdereMoneyeInfoModel *money_info;

///是否为挽回订单 1是 0否
@property (nonatomic, assign) BOOL               is_retrieve;
///订单挽回文案
@property (nonatomic, copy) NSString             *retrieve_tips;

///自定义
@property (nonatomic, strong) OSSVAddresseBookeModel   *selAddressModel;


@end

///orderstatus
//0    未付款
//1    已付款
//2    备货
//3    完全发货
//4    已收到货
//6    付款中
//7    已授权
//8    部分付款
//10    退款
//11    取消
//12    扣款失败
//13    待审核
//14    审核不通过
//15    部分配货
//16    完全配货
//17    出库
//18    缺货
//19    待取消
//20    部分发货




