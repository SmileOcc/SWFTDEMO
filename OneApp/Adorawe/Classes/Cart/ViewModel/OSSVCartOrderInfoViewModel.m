//
//  OSSVCartOrderInfoViewModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/27.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCartOrderInfoViewModel.h"

#import "OSSVCartCheckAip.h"

#import "OSSVOrderCreateAip.h"

#import "OSSVSMSVerifysAip.h"

#import "OSSVCreateOrderModel.h"

#import "OSSVAdvsEventsManager.h"

#import "OSSVCommonnRequestsManager.h"
@interface OSSVCartOrderInfoViewModel ()

@property (nonatomic, strong) NSMutableArray *apiList;
@property (nonatomic, copy)   NSString *idCardStr;
@end

@implementation OSSVCartOrderInfoViewModel

-(void)dealloc
{
    NSLog(@"OSSVCartOrderInfoViewModel dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*========================================分割线======================================*/

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveTextFieldText:) name:kNotif_orderCreateWithIdCard object:nil];
        _idCardStr = @"";
        _coinPayType = @"1"; //默认选中金币
    }
    return self;
}

//创建订单
- (void)requestNetwork:(id)parmaters completion:(void (^)(id))completion failure:(void (^)(id))failure {
    @weakify(self)
    [[STLNetworkStateManager sharedManager] networkState:^{
        @strongify(self)
        @weakify(self)
        OSSVOrderCreateAip *api = nil;
        if ([parmaters isKindOfClass:[OSSVCartOrderInfoViewModel class]]) {
            NSDictionary *params = [self handleCreateOrderApiPamras:parmaters];
            api = [[OSSVOrderCreateAip alloc] initWithDict:params];
        }else{
            api = [[OSSVOrderCreateAip alloc] initWithDict:parmaters];
        }
        [api.accessoryArray addObject:[[STLRequestAccessory alloc] initWithApperOnView:nil]];
        [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            @strongify(self)
            id requestJSON = [OSSVNSStringTool desEncrypt:request];
            id result = [self dataAnalysisFromJson: requestJSON request:api];
            if (result != nil) {
                if (completion) {
                    completion(result);
                }
            }
         //创建订单成功，更新用户信息，目的是为了订单列表中，whatsApp的号码的填充
            [OSSVCommonnRequestsManager checkUpdateUserInfo:nil];
        } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
            if (failure) {
                failure(error);
            }
        }];
    } exception:^{
        if (failure) {
            failure(nil);
        }
    }];
}

/*========================================分割线======================================*/

//请求订单页面数据
- (void)requestCartCheckNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
    @weakify(self)
    [[STLNetworkStateManager sharedManager] networkState:^{
        @strongify(self)
        OSSVCartCheckAip *api = nil;
        if ([parmaters isKindOfClass:[OSSVCartOrderInfoViewModel class]]) {
            NSDictionary *params = [self handleCheckOutRequestApiParams:parmaters];
            api = [[OSSVCartCheckAip alloc] initWithDict:params];
        }else{
            api = [[OSSVCartCheckAip alloc] initWithDict:parmaters];
        }
        @weakify(self)
        [api.accessoryArray addObject:[[STLRequestAccessory alloc] initWithApperOnView:self.controller.view]];
        [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            @strongify(self)
            id requestJSON = [OSSVNSStringTool desEncrypt:request];
            id result = [self dataAnalysisFromJson: requestJSON request:api];
            if (completion) {
                completion(result);
            }
        } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
            if (failure) {
                failure(error);
            }
        }];
        [self.apiList addObject:api];
    } exception:^{
        if (failure) {
            failure(nil);
        }
    }];
}

/*========================================分割线======================================*/

- (void)requestSMSVerifyNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
    @weakify(self)
    [[STLNetworkStateManager sharedManager] networkState:^{
        @strongify(self)
        OSSVSMSVerifysAip *api = [[OSSVSMSVerifysAip alloc] initWithOrderID:parmaters];
        @weakify(self)
        [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            @strongify(self)
            id requestJSON = [OSSVNSStringTool desEncrypt:request];
            id result = [self dataAnalysisFromJson: requestJSON request:api];
            if (completion) {
                completion(result);
            }
        } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
            if (failure) {
                failure(error);
            }
        }];
        [self.apiList addObject:api];
    } exception:^{
        if (failure) {
            failure(nil);
        }
    }];
}

/*========================================分割线======================================*/

- (id)dataAnalysisFromJson:(id)json request:(OSSVBasesRequests *)request{
    if ([request isKindOfClass:[OSSVCartCheckAip class]]) {
        //进行数据处理
//        if ([json[kStatusCode] integerValue] == kStatusCode_200) {
            //进行数据解析
        OSSVCartCheckModel *checkModel = [OSSVCartCheckModel yy_modelWithJSON:json[kResult]];
            if (!checkModel) {
                checkModel = [[OSSVCartCheckModel alloc] init];
            }
            checkModel.flag = [json[@"flag"] integerValue];
            checkModel.statusCode = [json[kStatusCode] integerValue];
            checkModel.message = json[@"message"];
            return checkModel;
//            if ([json[@"flag"] integerValue] == CartCheckOutResultEnumTypeSuccess) {
//                OSSVCartCheckModel *checkModel = [OSSVCartCheckModel yy_modelWithJSON:json[kResult]];
//                return @[@(CartCheckOutResultEnumTypeSuccess),checkModel];
//            }else if ([json[@"flag"] integerValue] == CartCheckOutResultEnumTypeNoAddress) {
//                return @[@(CartCheckOutResultEnumTypeNoAddress),json[@"message"]];
//            } else if ([json[@"flag"] integerValue] == CartCheckOutResultEnumTypeNoGoods) {
//                return @[@(CartCheckOutResultEnumTypeNoGoods),json[@"message"]];
//            }else if ([json[@"flag"] integerValue] == CartCheckOutResultEnumTypeNoShipping) {
//                return @[@(CartCheckOutResultEnumTypeNoShipping),json[@"message"]];
//            }else if ([json[@"flag"] integerValue] == CartCheckOutResultEnumTypeNoPayment) {
//                return @[@(CartCheckOutResultEnumTypeNoPayment),json[@"message"]];
//            }else if ([json[@"flag"] integerValue] == CartCheckOutResultEnumTypeShelvesed) {
//                return @[@(CartCheckOutResultEnumTypeShelvesed),json[@"message"]];
//            }else if ([json[@"flag"] integerValue] == CartCheckOutResultEnumTypeNoStock) {
//                return @[@(CartCheckOutResultEnumTypeNoStock),json[@"message"]];
//            }
//        } else {
//            [self alertMessage:json[@"message"]];
//        }
    } else if ([request isKindOfClass:[OSSVOrderCreateAip class]]) {
        //分仓后台把返回的数据包装成了数组
        OSSVCreateOrderModel *createModel = [OSSVCreateOrderModel yy_modelWithJSON:json];
        return createModel;
    } else if ([request isKindOfClass:[OSSVSMSVerifysAip class]]) {
        if ([json[kStatusCode] integerValue] == kStatusCode_200) {
            return json[kResult];
        } else {
            [self alertMessage:json[@"message"]];
        }
    }
    return nil;
}

/*========================================分割线======================================*/

#pragma mark - public method

-(void)freesource
{
    for (int i = 0; i < self.apiList.count; i++) {
        OSSVBasesRequests *request = self.apiList[i];
        [request stop];
    }
    [self.apiList removeAllObjects];
}

#pragma mark - private method
//请求订单页面传参
-(NSDictionary *)handleCheckOutRequestApiParams:(OSSVCartOrderInfoViewModel *)cartOrderInfoModel
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"address_id"] = STLToString(cartOrderInfoModel.addressModel.addressId);
    dict[@"coupon_code"] = STLToString(cartOrderInfoModel.couponModel.code);
    dict[@"buy_now"] = @(NO);
    dict[@"use_point"] = [OSSVNSStringTool isEmptyString:cartOrderInfoModel.ypointModel.points] ? @"0" : @"1";
    dict[@"payToken"] = @"";
    dict[@"isPaypalFast"] = @(NO);
    dict[@"pay_code"] = STLToString(cartOrderInfoModel.paymentModel.payCode);   //选择支付方式时候，新增该参数
    dict[@"is_use_coin"] = STLToString(self.coinPayType);  //是否使用金币
    //运费险
    dict[@"is_shipping_insurance"] = STLToString(self.shippingInsurance);

    return dict;
}

///创建订单的传参
-(NSDictionary *)handleCreateOrderApiPamras:(OSSVCartOrderInfoViewModel *)cartOrderInfoModel
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict[@"wid"] = @"";
    NSMutableString *selectGoods = [[NSMutableString alloc] init];
    [cartOrderInfoModel.effectiveProductList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        OSSVCartGoodsModel *goods = obj;
        [selectGoods appendString:goods.goodsId];
        if (idx != cartOrderInfoModel.effectiveProductList.count - 1) {
            [selectGoods appendString:@","];
        }
    }];
    dict[@"select_goods"] = selectGoods;
    dict[@"address_id"] = STLToString(cartOrderInfoModel.addressModel.addressId);
    dict[@"shipping_id"] = STLToString(cartOrderInfoModel.shippingModel.sid);
//    dict[@"pay_id"] = cartOrderInfoModel.paymentModel.payid;
    dict[@"pay_code"] = STLToString(cartOrderInfoModel.paymentModel.payCode);
    
    //发票
    dict[@"invoice"] = @(NO);
    dict[@"tracking"] = @"0";
    //运费险
    dict[@"is_shipping_insurance"] = STLToString(self.shippingInsurance);
    dict[@"remark"] = @"";
    if (cartOrderInfoModel.couponModel != nil && cartOrderInfoModel.couponModel.code != nil) {
        dict[@"coupon_code"] = STLToString(cartOrderInfoModel.couponModel.code);
    } else {
        dict[@"coupon_code"] = @"";
    }
    
    /*是否使用积分*/
    NSString *userPoint = @"0";
    if (cartOrderInfoModel.ypointModel) {
        userPoint = @"1";
    }
    dict[@"use_point"] = userPoint;
    
    /*阿根廷订单税费问题解决需求*/
    dict[@"tax_id"] = @"";
    
    dict[@"payToken"] = self.payToken == nil ? @"" : self.payToken;
    dict[@"isPaypalFast"] = @(self.isPaypalFast);
    dict[@"PayerID"] = @"";
    dict[@"code"] = self.verifyCode == nil ? @"" : self.verifyCode;
    if (cartOrderInfoModel.checkOutModel.currencyInfo) {
        dict[@"currency"] = STLToString(cartOrderInfoModel.checkOutModel.currencyInfo.code);
    }
    //新增身份证号码
    if (self.idCardStr.length) {
        dict[@"IdCard"] = self.idCardStr;

    } else {
        dict[@"IdCard"] = STLToString(cartOrderInfoModel.addressModel.idCard);

    }
    //新增支付优惠ID和优惠金额
    dict[@"pay_discount_id"] = STLToString(cartOrderInfoModel.paymentModel.payDiscountId);
    dict[@"pay_discount"] = STLToString(cartOrderInfoModel.paymentModel.payDiscount);
  
    //使用金币
    dict[@"is_use_coin"] = STLToString(self.coinPayType);
    return dict;
}
//接收到通知
- (void)receiveTextFieldText:(NSNotification *)notification {
    self.idCardStr = STLToString([[notification userInfo] valueForKey:@"idCard"]);

}
#pragma mark - setter and getter

-(NSMutableArray *)effectiveProductList
{
    ///OSSVCartGoodsModel
    if (!_effectiveProductList) {
        _effectiveProductList = [[NSMutableArray alloc] init];
    }
    return _effectiveProductList;
}

-(OSSVCouponModel *)couponModel
{
    if (!_couponModel) {
        _couponModel = [[OSSVCouponModel alloc] init];
    }
    return _couponModel;
}

-(NSMutableArray *)totalPriceCellStatusList
{
    if (!_totalPriceCellStatusList) {
        _totalPriceCellStatusList = [[NSMutableArray alloc] init];
    }
    return _totalPriceCellStatusList;
}

-(NSMutableArray *)paymentList
{
    if (!_paymentList) {
        _paymentList = [[NSMutableArray alloc] init];
    }
    return _paymentList;
}

-(NSMutableArray *)apiList
{
    if (!_apiList) {
        _apiList = [[NSMutableArray alloc] init];
    }
    return _apiList;
}

@end
