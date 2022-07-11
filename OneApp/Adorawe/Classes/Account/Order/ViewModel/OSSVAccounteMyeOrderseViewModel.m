//
//  OSSVAccounteMyeOrderseViewModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/7.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVAccounteMyeOrderseViewModel.h"
#import "AppDelegate.h"
#import "OSSVCreditsCardsView.h"
#import "OSSVWorldsPaysView.h"
#import "OSSVAccounteMyOrdersAip.h"
#import "OSSVAccounteMyeOrdersModel.h"

#import "OSSVAccountePayeMyOrdersAip.h"
#import "OSSVCodCancelAddAip.h"
#import "OSSVOrdereAddresseInfoAip.h"
#import "OSSVOrdereCodeConfirmAip.h"
#import "OSSVOrdereCodChangeeStatusAip.h"

#import "OSSVAccounteMyeOrdersListeModel.h"
#import "OSSVOrderFinishsVC.h"
#import "OSSVCartVC.h"

#import "OSSVAccounteCanceleMyOrdersAip.h"
#import "OSSVOrdereBuyeAgainAip.h"

#import "OSSVAccounteMyeOrderseHeadereView.h"
#import "OSSVAccounteMyOrderseGoodseModel.h"
#import "STLActivityWWebCtrl.h"
#import "OSSVAccountOrdersPageVC.h"
#import "OSSVAccountsOrderDetailVC.h"
#import "OSSVAccounteMyOrderseCell.h"
#import "STLNewTrackingListViewController.h"
#import "STLTransportSplitViewController.h"
#import "OSSVOrderInfoeModel.h"

#import "OSSVOrdersReviewVC.h"

#import "OSSVSMSVerifysView.h"
#import "OSSVCheckOutCodMsgAlertView.h"
#import "OSSVOrdereCodeSuccessView.h"
#import "OSSVOrdereCodeConfirmView.h"
#import "OSSVCartOrderInfoViewModel.h"

#import "OSSVWesternsUnionsView.h"
#import "ZJJTimeCountDown.h"
#import "OSSVConfigDomainsManager.h"
#import "OSSVAccounteMyOrderseDetailViewModel.h"
#import "OSSVPayPalModule.h"

#import "YYText.h"

#import "Adorawe-Swift.h"

@import RangersAppLog;

#define TAG_ORDERALERT_PAYFAILED  1008

@interface OSSVAccounteMyeOrderseViewModel ()<AccountMyOrdersCellDelegate,ZJJTimeCountDownDelegate>

@property (nonatomic,strong) NSMutableArray                         *dataArray;
@property (nonatomic,strong) OSSVAccounteMyeOrdersModel                   *myOrdersModel;
@property (nonatomic,assign) NSInteger                              orderListCount;
@property (nonatomic,strong) OSSVOrderInfoeModel                         *OSSVOrderInfoeModel;
@property (nonatomic,strong) ZJJTimeCountDown                       *countDown;
@property (nonatomic, strong) OSSVAccounteMyOrderseDetailViewModel        *viewModel;
@property (nonatomic, strong) OSSVPayPalModule                       *payModule;
@property (nonatomic, strong) OSSVSMSVerifysView                      *smsVerifyView;
@property (nonatomic, strong) OSSVCheckOutCodMsgAlertView            *codMsgAlertView;
@property (nonatomic, strong) OSSVOrdereCodeSuccessView                *codSuccessView;
@property (nonatomic, strong) OSSVAccounteMyeOrdersListeModel              *selectCodOrderModel;
@property (nonatomic, strong) OSSVCartOrderInfoViewModel                *infoViewModel;

@property (nonatomic, strong) OSSVAccounteMyeOrdersListeModel              *cancelAddCartOrderModel;

@property (nonatomic, copy) NSString                                *tempDownRefreshOrderID;

@property (nonatomic, copy) NSString *endTimeText;

@property (nonatomic, assign) BOOL   isRefreshing;
@property (nonatomic, assign) BOOL   isTimeDownStart;
@property (nonatomic, assign) BOOL  testTime;

@property (nonatomic,copy) NSString *confirmMethod;
@end

@implementation OSSVAccounteMyeOrderseViewModel

#pragma mark Requset
- (void)requestNetwork:(id)parmaters completion:(void (^)(id))completion failure:(void (^)(id))failure {
    if (!STLJudgeNSDictionary(parmaters)) {
        if (failure) {
            failure(nil);
        }
        return;
    }
    NSInteger page = 1;
    if ([parmaters[@"isRfersh"] integerValue] == 0) {
        // 假如最后一页的时候
        if (self.myOrdersModel.page == self.myOrdersModel.totalPage) {
            if (completion) {
                completion(STLNoMoreToLoad);
            }
            return;
        }
        page = self.myOrdersModel.page  + 1;
    } else {
        self.isRefreshing = YES;
    }
    
    @weakify(self)
    [[STLNetworkStateManager sharedManager] networkState:^{
        @strongify(self)
        //status参数:默认为0)[0-未付款，1-已支付，2-备货，3-已完全发货，4-已取消]
        OSSVAccounteMyOrdersAip *api = [[OSSVAccounteMyOrdersAip alloc] initWithPage:page pageSize:[PageSize integerValue] Status:parmaters[@"status"]];
        // 取缓存数据
        {
//            if (api.cacheJSONObject) {
//                id requestJSON = api.cacheJSONObject;
//                self.myOrdersModel = [self dataAnalysisFromJson: requestJSON request:api];
//                if (page == 1) {
//                    self.dataArray = [NSMutableArray arrayWithArray:self.myOrdersModel.orderList];
//                    [self handleEndTime:self.dataArray];
//                }
//                self.emptyViewShowType = self.dataArray.count > 0 ? EmptyViewShowTypeHide : EmptyViewShowTypeNoData;
//                if (completion) {
//                    completion(nil);
//                }
//            }
        }
        
//        @weakify(self)
//        [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
//            @strongify(self)
//            id requestJSON = [OSSVNSStringTool desEncrypt:request];
//            self.myOrdersModel = [self dataAnalysisFromJson: requestJSON request:api];
//            
//            if (page == 1) {
//                self.dataArray = [NSMutableArray arrayWithArray:self.myOrdersModel.orderList];
//            } else {
//                [self.dataArray addObjectsFromArray:self.myOrdersModel.orderList];
//            }
        @weakify(self)
        [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            @strongify(self)
            id requestJSON = [OSSVNSStringTool desEncrypt:request];
            self.myOrdersModel = [self dataAnalysisFromJson: requestJSON request:api];
            ///国家站 拿到数据后 设置隐藏展示顶部视图
//            self.myOrdersModel.show_ip_change_tips = @"1";//测试代码
            if ([self.myOrdersModel.show_ip_change_tips isEqualToString:@"1"]) {
                self.ipChangedView.hidden = NO;
            }else{
                self.ipChangedView.hidden = YES;
            }
            [self.ipChangedView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.equalTo(self.ipChangedView.hidden ? 0 : 44);
            }];
            
            if (page == 1) {
                self.isRefreshing = NO;
                self.dataArray = [NSMutableArray arrayWithArray:self.myOrdersModel.orderList];
                [self handleEndTime:self.dataArray];
            } else {
                NSInteger oldCount = self.dataArray.count; // 记录上一个
                if (self.myOrdersModel.orderList.count > 0) {
                    [self.dataArray addObjectsFromArray:self.myOrdersModel.orderList];
                    [self handleEndTime:self.dataArray];
                    NSMutableArray *indexPaths = [NSMutableArray array];
                    for(NSInteger i = oldCount;i < self.dataArray.count; i++){
                        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                    }
                    if (completion) {
                        completion(indexPaths.copy);
                    }
                    return;
                }
            }

            self.emptyViewShowType = self.dataArray.count > 0 ? EmptyViewShowTypeHide : EmptyViewShowTypeNoData;
            if (completion) {
                completion(nil);
            }
            self.isTimeDownStart = NO;
            
        } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
            @strongify(self)
            if ([parmaters[@"isRfersh"] integerValue] == 1) {//加载更多的状态
                self.emptyViewShowType = EmptyViewShowTypeHide;
                self.isRefreshing = NO;
            }else if ([parmaters[@"isRfersh"] integerValue] == 0 && ![self.dataArray count]){//下拉刷新，首次进入页面
                self.emptyViewShowType = EmptyViewShowTypeNoNet;
            }
            if (failure) {
                failure(nil);
            }
            self.isTimeDownStart = NO;
        }];
        [self.queueList addObject:api];
    } exception:^{
        @strongify(self)
        self.emptyViewShowType = EmptyViewShowTypeNoNet;
        if (failure) {
            failure(nil);
        }
        self.isTimeDownStart = NO;
    }];
}

- (void)requestCancelOrder:(id)parmaters completion:(void (^)(id))completion failure:(void (^)(id))failure {
    
    [[STLNetworkStateManager sharedManager] networkState:^{
        OSSVAccounteCanceleMyOrdersAip *api = [[OSSVAccounteCanceleMyOrdersAip alloc] initWithOrderId:parmaters];
        [api.accessoryArray addObject:[[STLRequestAccessory alloc] initWithApperOnView:self.controller.view]];
        [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            if (completion) {
                completion(nil);
            }
        } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
            STLLog(@"failure");
        }];
        [self.queueList addObject:api];
    } exception:^{
        if (failure) {
            failure(nil);
        }
    }];
}

- (void)requestPayOrder:(id)parmaters completion:(void (^)(id))completion failure:(void (^)(id))failure {
    
    [[STLNetworkStateManager sharedManager] networkState:^{
        OSSVAccountePayeMyOrdersAip *api = [[OSSVAccountePayeMyOrdersAip alloc] initWithOrderId:parmaters];
        ///这里必须要加到window上面
        [api.accessoryArray addObject:[[STLRequestAccessory alloc] initWithApperOnView:nil]];
        [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            //            NSArray *result = [self dataAnalysisFromJson: request.responseJSONObject request:api];
            id requestJSON = [OSSVNSStringTool desEncrypt:request];
            NSArray *result = [self dataAnalysisFromJson: requestJSON request:api];
            if (completion) {
                completion(result);
            }
        } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
            STLLog(@"failure");
        }];
        [self.queueList addObject:api];
    } exception:^{
        if (failure) {
            failure(nil);
        }
    }];
}

- (void)requestOrderAddress:(NSDictionary *)parmaters completion:(void (^)(NSDictionary *reuslt))completion failure:(void (^)(id))failure {
    
    [[STLNetworkStateManager sharedManager] networkState:^{
        OSSVOrdereAddresseInfoAip *api = [[OSSVOrdereAddresseInfoAip alloc] initWithOrderId:parmaters[@"order_id"]];
        [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            //            NSArray *result = [self dataAnalysisFromJson: request.responseJSONObject request:api];
            id requestJSON = [OSSVNSStringTool desEncrypt:request];
            NSDictionary *result = [self dataAnalysisFromJson: requestJSON request:api];
            if (completion) {
                completion(result);
            }
        } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
            STLLog(@"failure");
        }];
        [self.queueList addObject:api];
    } exception:^{
        if (failure) {
            failure(nil);
        }
    }];
}

- (void)requestCodOrderConfirm:(NSDictionary *)parmaters completion:(void (^)(BOOL flag))completion failure:(void (^)(id))failure {
    
    [[STLNetworkStateManager sharedManager] networkState:^{
        
        OSSVOrdereCodeConfirmAip *api = [[OSSVOrdereCodeConfirmAip alloc] initWithOrderId:parmaters[@"order_id"] code:parmaters[@"code"] addressId:parmaters[@"address_id"]];
        [api.accessoryArray addObject:[[STLRequestAccessory alloc] initWithApperOnView:nil]];
        [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            id requestJSON = [OSSVNSStringTool desEncrypt:request];
            id state = [self dataAnalysisFromJson: requestJSON request:api];
            if (completion) {
                completion([state boolValue]);
            }
        } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
            STLLog(@"failure");
            if (failure) {
                failure(nil);
            }
        }];
        [self.queueList addObject:api];
    } exception:^{
        if (failure) {
            failure(nil);
        }
    }];
}

- (void)requestCodOrderChangeStatusConfirm:(NSDictionary *)parmaters completion:(void (^)(BOOL flag))completion failure:(void (^)(id))failure {
    
    [[STLNetworkStateManager sharedManager] networkState:^{
        
        OSSVOrdereCodChangeeStatusAip *api = [[OSSVOrdereCodChangeeStatusAip alloc] initWithOrderId:parmaters[@"order_id"]];
        [api.accessoryArray addObject:[[STLRequestAccessory alloc] initWithApperOnView:nil]];
        [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            id requestJSON = [OSSVNSStringTool desEncrypt:request];
            id state = [self dataAnalysisFromJson: requestJSON request:api];
            if (completion) {
                completion([state boolValue]);
            }
        } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
            STLLog(@"failure");
            if (failure) {
                failure(nil);
            }
        }];
        [self.queueList addObject:api];
    } exception:^{
        if (failure) {
            failure(nil);
        }
    }];
}


- (id)dataAnalysisFromJson:(id)json request:(OSSVBasesRequests *)request {
    if ([request isKindOfClass:[OSSVAccounteMyOrdersAip class]]) {
        if ([json[kStatusCode] integerValue] == kStatusCode_200) {
            return [OSSVAccounteMyeOrdersModel yy_modelWithJSON:json[kResult]];
        } else {
            [self alertMessage:json[@"message"]];
        }
    }else if ([request isKindOfClass:[OSSVAccounteCanceleMyOrdersAip class]]) {
        if ([json[kStatusCode] integerValue] == kStatusCode_200) {
            [self alertMessage:json[@"message"]];
        } else {
            [self alertMessage:@"Cancel the failure!"];
        }
    }else if ([request isKindOfClass:[OSSVAccountePayeMyOrdersAip class]]) {
        if ([json[kStatusCode] integerValue] == kStatusCode_200) {
            //进行数据解析，如果订单生成成功，此处应该返回一个支付链接
            self.OSSVOrderInfoeModel = [OSSVOrderInfoeModel yy_modelWithJSON:json[kResult][@"order_info"]];
            if (self.OSSVOrderInfoeModel) {
                return @[@(YES),json[kResult][@"url"],json[kResult][@"data"],self.OSSVOrderInfoeModel];
            }else{
                return @[@(YES),json[kResult][@"url"],json[kResult][@"data"]];
            }
        } else {
            [self alertMessage:json[@"message"]];
            return @[@(NO)];
        }
    }else if([request isKindOfClass:[OSSVOrdereAddresseInfoAip class]]) {
        
        if ([json[kStatusCode] integerValue] == kStatusCode_200) {
            return json[kResult];
        } else {
            [self alertMessage:STLLocalizedString_(@"Order_Address_Get_Error", nil)];
            return nil;
        }

    } else if([request isKindOfClass:[OSSVOrdereCodeConfirmAip class]]) {
        
        if ([json[kStatusCode] integerValue] == kStatusCode_200) {
            return @"1";
        } else {
            [self alertMessage:json[@"message"]];
            return @"0";
        }

    } else if([request isKindOfClass:[OSSVOrdereCodChangeeStatusAip class]]) {
        if ([json[kStatusCode] integerValue] == kStatusCode_200) {
            return @"1";
        } else {
            [self alertMessage:json[@"message"]];
            return @"0";
        }
    } else {
        [self alertMessage:json[@"message"]];
        return @[@(NO)];
    }
    return nil;
}

-(void)handleEndTime:(NSArray *)list
{
    NSDate *date = [NSDate date];
    NSTimeInterval nowTime = [date timeIntervalSince1970];
    [list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[OSSVAccounteMyeOrdersListeModel class]]) {
            OSSVAccounteMyeOrdersListeModel *model = (OSSVAccounteMyeOrdersListeModel *)obj;
            
            if (model.expiresTime.integerValue > 0 && !model.isAddTime) {
                model.isAddTime = YES;
                model.expiresTime = [NSString stringWithFormat:@"%ld", (long)(model.expiresTime.integerValue + (NSInteger)nowTime)];
            }
            
        }
    }];
    
    if (_countDown) {
        [_countDown destoryTimer];
        _countDown = nil;
    }
}
//     倒计时
//     if (idx == 0) {
//         model.orderStatus = @"0";
//         model.isAddTime = YES;
//         model.expiresTime = [NSString stringWithFormat:@"%ld", (long)(5 + (NSInteger)nowTime)];
//
//     }
     
#pragma mark - Action
#pragma mark 订单挽留
- (void)cancelOrderAndAddCart:(OSSVAccounteMyOrderseCell *)cell {
    
    self.cancelAddCartOrderModel = cell.orderListModel;

    [OSSVAnalyticsTool analyticsGAEventWithName:@"repurchase_order" parameters:@{
            @"screen_group":@"MyOrder",
            @"action":[NSString stringWithFormat:@"%@_Cancel_Repurchase",STLToString(self.cancelAddCartOrderModel.orderStatus)]}];
    
    if ([self.cancelAddCartOrderModel.payCode isEqualToString:@"Cod"]) {
        self.selectCodOrderModel = cell.orderListModel;

        @weakify(self)
        [self codCancelRequest:@"0" cancelResult:@"" completion:^(id obj) {
            @strongify(self)
            [self buyAgainOrder:nil orderModel:self.cancelAddCartOrderModel isNeedRefresh:YES];
        } failure:^(id obj) {
            @strongify(self)
            [self repurchaseAnalytics:self.cancelAddCartOrderModel success:NO];
        }];
       
    } else {
        
        @weakify(self)
        [self requestCancelOrder:self.cancelAddCartOrderModel.orderId completion:^(id obj) {
            @strongify(self)
            [self orderCancelSuccess:self.cancelAddCartOrderModel normal:NO success:YES cancelReason:@""];
            [self buyAgainOrder:nil orderModel:self.cancelAddCartOrderModel isNeedRefresh:YES];
            
        } failure:^(id obj) {
            @strongify(self)
            [self orderCancelSuccess:self.cancelAddCartOrderModel normal:NO success:NO cancelReason:@""];
            [self repurchaseAnalytics:self.cancelAddCartOrderModel success:NO];
        }];
    }
}

#pragma mark 取消

- (void)showCancelCodAlterView:(OSSVAccounteMyeOrdersListeModel *)orderModel {
    
    OSSVAccounteMyeOrdersListeModel *model = self.dataArray.firstObject;

    if (orderModel && [orderModel.orderId isEqualToString:model.orderId] && orderModel.selAddressModel) {
        if (model && [model.payCode isEqualToString:@"Cod"] && ([model.orderStatus integerValue] == OrderStateTypeWaitingForPayment || [model.orderStatus integerValue] == OrderStateTypeWaitConfirm)) {
            model.selAddressModel = orderModel.selAddressModel;
            [self payOrderCOD:model];
        }
    }
}

- (void)cancelOrderCOD:(OSSVAccounteMyeOrdersListeModel *)model{
    
    if (!model.selAddressModel) {
        @weakify(self)
        [self requestOrderAddress:@{@"order_id":STLToString(model.orderId)} completion:^(NSDictionary *reuslt) {
            @strongify(self)
            if (STLJudgeNSDictionary(reuslt)) {
                OSSVAddresseBookeModel *addressModel = [OSSVAddresseBookeModel yy_modelWithJSON:reuslt];
                model.selAddressModel = addressModel;
                [self cancelOrderCOD:model];
            }
            
        } failure:^(id error) {
            
        }];
        return;
    }
    
    self.selectCodOrderModel = model;
    self.codMsgAlertView.order_flow_switch = @"0";
    if ([model.orderStatus integerValue] == OrderStateTypeWaitConfirm) {
        self.codMsgAlertView.order_flow_switch = self.myOrdersModel.order_flow_switch;
    }
    [self.codMsgAlertView show];

}
- (void)cancelOrder:(OSSVAccounteMyOrderseCell *)cell {
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (self.dataArray.count > indexPath.row) {
        OSSVAccounteMyeOrdersListeModel *ordersModel = self.dataArray[indexPath.row];
        
        NSArray *upperTitle = @[STLLocalizedString_(@"no",nil).uppercaseString,STLLocalizedString_(@"yes", nil).uppercaseString];
        NSArray *lowserTitle = @[STLLocalizedString_(@"no",nil),STLLocalizedString_(@"yes", nil)];

        @weakify(self)
        [OSSVAlertsViewNew showAlertWithAlertType:STLAlertTypeButton isVertical:YES messageAlignment:NSTextAlignmentCenter isAr:NO showHeightIndex:1 title:@"" message:STLLocalizedString_(@"cancelOreder", nil) buttonTitles:APP_TYPE == 3 ? lowserTitle : upperTitle buttonBlock:^(NSInteger index, NSString * _Nonnull title) {
            @strongify(self)
            if (index == 1) {
                
                    
                 [OSSVAnalyticsTool analyticsGAEventWithName:@"cancel_order" parameters:@{
                        @"screen_group":@"MyOrder",
                        @"action":@"Cancel_Yes"}];
                
                [self requestCancelOrder:ordersModel.orderId completion:^(id obj) {
                    [self orderCancelSuccess:ordersModel normal:YES success:YES cancelReason:@""];
                    if (self.reloadDataBlock) {
                        self.reloadDataBlock();
                    }
                } failure:^(id obj) {
                    [self orderCancelSuccess:ordersModel normal:YES success:NO cancelReason:@""];

                }];
            } else {
                    
                [OSSVAnalyticsTool analyticsGAEventWithName:@"cancel_order" parameters:@{
                       @"screen_group":@"MyOrder",
                       @"action":@"Cancel_No"}];
            }
            
        }];
    }
}

#pragma mark 购买付款

- (void)payOrderCOD:(OSSVAccounteMyeOrdersListeModel *)model {

    if (!model.selAddressModel) {
        @weakify(self)
        [self requestOrderAddress:@{@"order_id":STLToString(model.orderId)} completion:^(NSDictionary *reuslt) {
            @strongify(self)
            if (STLJudgeNSDictionary(reuslt)) {
                OSSVAddresseBookeModel *addressModel = [OSSVAddresseBookeModel yy_modelWithJSON:reuslt];
                model.selAddressModel = addressModel;
                [self payOrderCOD:model];
            }
            
        } failure:^(id error) {
            
        }];
        return;
    }
//    if (model.checkOutModel.cod_black_list_tip.length) {
//        [STLAlertControllerView showCtrl:self alertTitle:nil message:model.checkOutModel.cod_black_list_tip oneMsg:STLLocalizedString_(@"sure", nil) twoMsg:nil completionHandler:nil];
//        return;
//    }
    
    self.selectCodOrderModel = model;

    ///弹出输入验证码框
    UIWindow *keyWindow = [SHAREDAPP keyWindow];
    CGRect rect = CGRectMake(0, kSCREEN_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-kSCREEN_BAR_HEIGHT);
    self.smsVerifyView = [[OSSVSMSVerifysView alloc] initWithFrame:rect];
    NSString *userPhoneNum = [NSString stringWithFormat:@"+%@ %@%@",STLToString(model.selAddressModel.countryCode),STLToString(model.selAddressModel.phoneHead),STLToString(model.selAddressModel.phone) ];
    NSString *paymentAmount = model.money_info.payable_amount_converted_symbol;
    
    
    BOOL codISAB = [self.myOrdersModel.order_flow_switch integerValue];
    if (codISAB && [model.orderStatus integerValue] == OrderStateTypeWaitConfirm) {

        ///1.4.6 根据配置与AB流量配置
        BOOL is_cod_sms_opend = [[BDAutoTrack ABTestConfigValueForKey:@"is_cod_sms_opend" defaultValue:@(YES)] boolValue];
        BOOL goWithNewProcess = OSSVAccountsManager.sharedManager.sysIniModel.cod_confirm_sms_open && OSSVAccountsManager.sharedManager.sysIniModel.cod_confirm_sms_abtest && is_cod_sms_opend;
        if (goWithNewProcess) {
            [self confirmCODWithOutSMSNew:model titleMsg:paymentAmount phoneMsg:userPhoneNum];
            return;
        }
        
        [self confirmCODWithOutSMS:model titleMsg:paymentAmount phoneMsg:userPhoneNum];
        return;
    }
    
//
//    if (model.checkOutModel.currencyInfo) {
//        paymentAmount = [NSString stringWithFormat:@"%@%.4f",model.checkOutModel.currencyInfo.symbol,model.totalPrice];
//        paymentAmount = [paymentAmount substringToIndex:(paymentAmount.length - 2)];
//    } else {
//        paymentAmount = [NSString stringWithFormat:@"%@%.4f",[ExchangeManager localCurrency].symbol,model.totalPrice];
//        paymentAmount = [paymentAmount substringToIndex:(paymentAmount.length - 2)];
//    }

    
    NSDictionary *sensorsDic = @{@"order_sn":STLToString(model.orderSn),
    };
    [OSSVAnalyticsTool analyticsSensorsEventWithName:@"CodPaymentPopup" parameters:sensorsDic];
    
    [self.smsVerifyView setUserPhoneNum:userPhoneNum paymentAmount:paymentAmount];
    @weakify(self)
    self.smsVerifyView.sendSMSRequestBlock = ^{
        @strongify(self)
        [self.infoViewModel requestSMSVerifyNetwork:STLToString(model.orderId) completion:^(id obj) {
            if (obj) {
                [[NSNotificationCenter defaultCenter] postNotificationName:SEND_SMS_SUCCESS object:obj];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_RefrshUserInfo object:nil];
            } else {
                STLLog(@"❌❌❌Send SMS验证出错.手机号码错误或者PHP接口出错.");
                [[NSNotificationCenter defaultCenter] postNotificationName:SEND_SMS_FAIL object:nil];
            }
        } failure:^(id obj) {
            [[NSNotificationCenter defaultCenter] postNotificationName:SEND_SMS_FAIL object:nil];
        }];
    };
    
    self.smsVerifyView.verifyCodeAnalyticBlock = ^(BOOL hasCode) {
        @strongify(self)
        [self conConfirmAnalytics:hasCode];
    };
    
    self.smsVerifyView.verifyCodeRequestBlock = ^(NSString *code){
        @strongify(self)
        
        @weakify(self)
        [self requestCodOrderConfirm:@{@"order_id":STLToString(model.orderId),
                                       @"code":STLToString(code),
                                       @"address_id":STLToString(model.selAddressModel.addressId)
        } completion:^(BOOL flag) {
            @strongify(self)
            if (flag) {
                [self.smsVerifyView coolse];
                [self.codSuccessView show];
                
                if (self.reloadDataBlock) {
                    self.reloadDataBlock();
                }
            }
            [self paySuccesWithProductCodAnalytics:flag];
        } failure:^(id error) {
            [self paySuccesWithProductCodAnalytics:NO];
        }];
    };

    self.smsVerifyView.closeSMSBlock = ^{
        @strongify(self)
        @weakify(self)

        NSMutableAttributedString *codAttr = [[NSMutableAttributedString alloc] initWithString:STLLocalizedString_(@"Cod_Cancel_OverTime_Tip", nil)];
        
        NSRange conatchEmailRange = [codAttr.string rangeOfString:STLLocalizedString_(@"Cod_Tip_24_hour", nil)];
        
        
        if (conatchEmailRange.location != NSNotFound) {
            [codAttr yy_setTextHighlightRange:conatchEmailRange
                                             color:[OSSVThemesColors col_FF5875]
                                   backgroundColor:[UIColor clearColor]
                                         tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
                                             
                                         }];
            
        }

        [OSSVAlertsViewNew showAlertWithAlertType:STLAlertTypeButton isVertical:YES messageAlignment:NSTextAlignmentCenter isAr:NO showHeightIndex:1 title:@"" message:codAttr buttonTitles:@[STLLocalizedString_(@"Continue_Cancel",nil).uppercaseString,STLLocalizedString_(@"Continue_To_Verify",nil).uppercaseString] buttonBlock:^(NSInteger index, NSString * _Nonnull title) {
            @strongify(self)
            if (index == 1) {
                [self payOrderCOD:model];
            }
            
        }];
    };
    [keyWindow addSubview:self.smsVerifyView];
}

-(void)confirmCODWithSMS:(OSSVAccounteMyeOrdersListeModel *)model titleMsg:(NSString *)paymentAmount phoneMsg:(NSString*)userPhoneNum{
    OSSVCODVierifyVC *vc = [[OSSVCODVierifyVC alloc] init];
    NSArray* phoneArr = [userPhoneNum componentsSeparatedByString:@" "];
    vc.phoneCode = phoneArr.firstObject;
    vc.orderId = STLToString(model.orderId);
    vc.orderSn = STLToString(model.orderSn);
    vc.phone = phoneArr.lastObject;
    vc.amountStr = paymentAmount;
    
    vc.success = ^(BOOL success,NSString* confirm_method) {
        if (self.reloadDataBlock) {
            self.reloadDataBlock();
        }
        self.confirmMethod = confirm_method;
        if (success) {
            [self paySuccesWithProductCodAnalytics:success];
            [NSNotificationCenter.defaultCenter postNotificationName:@"SwitchToAllOrdertab" object:nil];
        }
        
    };
    [self.controller presentViewController:vc animated:true completion:nil];
}


-(void)confirmCODWithOutSMSNew:(OSSVAccounteMyeOrdersListeModel *)model titleMsg:(NSString *)paymentAmount phoneMsg:(NSString*)userPhoneNum{
    OSSVCODConfirmWithoutSmsNewVC *vc = [[OSSVCODConfirmWithoutSmsNewVC alloc] init];
    NSArray* phoneArr = [userPhoneNum componentsSeparatedByString:@" "];
    vc.phoneCode = phoneArr.firstObject;
    vc.orderId = STLToString(model.orderId);
    vc.orderSn = STLToString(model.orderSn);
    vc.phone = phoneArr.lastObject;
    vc.amountStr = paymentAmount;
    
    vc.success = ^(BOOL success,NSString* confirm_method) {
        if (self.reloadDataBlock) {
            self.reloadDataBlock();
        }
        self.confirmMethod = confirm_method;
        if (success) {
            [NSNotificationCenter.defaultCenter postNotificationName:@"SwitchToAllOrdertab" object:nil];
            [self paySuccesWithProductCodAnalytics:success];
        }
    };
    
    
    vc.jumpToSMS = ^(NSString * _Nonnull paymentAmount, NSString * _Nonnull userPhoneNum) {
        [self confirmCODWithSMS:model titleMsg:paymentAmount phoneMsg:userPhoneNum];
    };
    
    [self.controller presentViewController:vc animated:true completion:nil];
    
    NSDictionary *sensorsDic = @{@"order_sn":STLToString(model.orderSn),
    };
    [OSSVAnalyticsTool analyticsSensorsEventWithName:@"CodPaymentPopup" parameters:sensorsDic];
}


-(void)confirmCODWithOutSMS:(OSSVAccounteMyeOrdersListeModel *)model titleMsg:(NSString *)paymentAmount phoneMsg:(NSString*)userPhoneNum{
    OSSVOrdereCodeConfirmView *codConfirmView = [[OSSVOrdereCodeConfirmView alloc] initWithFrame:CGRectZero titleMsg:paymentAmount phoneMsg:userPhoneNum];
    [codConfirmView show];
    
    NSDictionary *sensorsDic = @{@"order_sn":STLToString(model.orderSn),
    };
    [OSSVAnalyticsTool analyticsSensorsEventWithName:@"CodPaymentPopup" parameters:sensorsDic];
    
    
    @weakify(self)
    @weakify(codConfirmView)
    codConfirmView.confirmRequestBlock = ^{
        @strongify(self)
        @strongify(codConfirmView)
        
        [self conConfirmAnalytics:YES];
        @weakify(self)
        @weakify(codConfirmView)
        [self requestCodOrderChangeStatusConfirm:@{@"order_id":STLToString(model.orderId)} completion:^(BOOL flag) {
            @strongify(self)
            @strongify(codConfirmView)
            
            if (flag) {
                [codConfirmView dismiss];
                
                if (self.reloadDataBlock) {
                    self.reloadDataBlock();
                }
                [NSNotificationCenter.defaultCenter postNotificationName:@"SwitchToAllOrdertab" object:nil];
            }
            [self paySuccesWithProductCodAnalytics:flag];
            
        } failure:^(id error) {
            [self paySuccesWithProductCodAnalytics:NO];

        }];
    };
}
#pragma mark ---支付
- (void)payOrder:(OSSVAccounteMyOrderseCell *)cell {
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (self.dataArray.count > indexPath.row) {
        OSSVAccounteMyeOrdersListeModel *ordersModel = self.dataArray[indexPath.row];
        
        [self.viewModel requestPayNowOrder:ordersModel.orderId completion:^(OSSVOrdereInforeModel *obj) {
            if (obj) {
                OSSVPayPalModule *module = [[OSSVPayPalModule alloc] init];
                OSSVCreateOrderModel *creatOrderModel = [[OSSVCreateOrderModel alloc] init];
                creatOrderModel.goodsList = ordersModel.ordersGoodsList;
                creatOrderModel.shippingFee = STLToString(ordersModel.money_info.shipping_fee);
                creatOrderModel.couponCode = STLToString(ordersModel.coupon_code);
                creatOrderModel.payCode = ordersModel.payCode;
                
                STLOrderModel *orderModel = [[STLOrderModel alloc] init];
                orderModel.order_sn = ordersModel.orderSn;
                orderModel.order_amount = STLToString(ordersModel.money_info.payable_amount);

                orderModel.cod_order_amount = ordersModel.orderAmount;
                orderModel.url = obj.url;
                orderModel.pay_code = STLToString(ordersModel.payCode);
                
                creatOrderModel.orderList = @[orderModel];
                module.OSSVOrderInfoeModel = creatOrderModel;
                module.payModuleCase = ^(STLOrderPayStatus status){
                    [self orderOnlePayResultAnalytics:ordersModel state:status == STLOrderPayStatusDone];
                    switch (status) {
                        case STLOrderPayStatusUnknown:
                        case STLOrderPayStatusCancel:
                        {
                            [self showAlertViewWithTitle:STLLocalizedString_(@"payCancel", nil) Message:STLLocalizedString_(@"paymentCancel", nil)];
                            [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_RefrshUserInfo object:nil];
                        }
                            break;
                        case STLOrderPayStatusDone:
                        {
                            OSSVOrderFinishsVC *orderFinishVC = [OSSVOrderFinishsVC new];
                            orderFinishVC.createOrderModel = creatOrderModel;
                            orderFinishVC.isFromOrder = YES;
                            orderFinishVC.block = ^{
                                _reloadDataBlock();
                            };
                            [self.controller.navigationController pushViewController:orderFinishVC animated:YES];
                        }
                            break;
                        case STLOrderPayStatusFailed:
                        {
                            [self showAlertViewWithTitle:STLLocalizedString_(@"failedPay", nil) Message:STLLocalizedString_(@"paymentFailed", nil)];
                        }
                            break;
                    default:
                        break;
                    }
                };
                [module handlePay];
                self.payModule = module;
            } else {
                [self orderOnlePayResultAnalytics:ordersModel state:NO];
            }
        } failure:^(id obj) {
            
        }];
    }
}

#pragma mark 再次购买
- (void)buyAgainOrder:(OSSVAccounteMyOrderseCell *)cell orderModel:(OSSVAccounteMyeOrdersListeModel *)model isNeedRefresh:(BOOL)isNeed{
    
    
    OSSVAccounteMyeOrdersListeModel *orderListModel = model;
    if (!orderListModel) {
        orderListModel = cell.orderListModel;
    }
    
    OSSVOrdereBuyeAgainAip *buyAgainApi = [[OSSVOrdereBuyeAgainAip alloc] initWithOrderId:STLToString(orderListModel.orderId)];

    [HUDManager showHUD:MBProgressHUDModeIndeterminate hide:NO afterDelay:0 enabled:NO message:nil];
    
    @weakify(self)
    [buyAgainApi startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
        @strongify(self)

        [HUDManager hiddenHUD];
        NSDictionary *buyAgainDic = [OSSVNSStringTool desEncrypt:request];
        

        BOOL state = NO;
        if ([buyAgainDic[kStatusCode] integerValue] == kStatusCode_200) {
            state = YES;
            NSDictionary *resultDic = buyAgainDic[kResult];
            OSSVCartVC *ctrl = [[OSSVCartVC alloc] init];
            ctrl.buyAgainAlert = [resultDic[@"needAppAlert"] boolValue];
            [self.controller.navigationController pushViewController:ctrl animated:YES];
        }else{
            NSString *message = buyAgainDic[kMessagKey];
            if (message.length > 0) {
                [HUDManager showHUDWithMessage:message];
            }
        }
        
        [OSSVAnalyticsTool analyticsSensorsEventWithName:@"AddToCartOrder" parameters:@{@"is_success":@(state),@"order_sn":STLToString(orderListModel.orderSn)}];
        [self analyticsAddToCart:orderListModel isSuccess:state];
        [self repurchaseAnalytics:orderListModel success:state];

        if (isNeed) {
            if (self.reloadDataBlock) {
                self.reloadDataBlock();
            }
        }

    } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
        @strongify(self)
        
        [HUDManager hiddenHUD];
        [self repurchaseAnalytics:orderListModel success:NO];
        if (isNeed) {
            if (self.reloadDataBlock) {
                self.reloadDataBlock();
            }
        }
    }];
}

- (void)analyticsAddToCart:(OSSVAccounteMyeOrdersListeModel *)ordersListModel isSuccess:(BOOL)isSuccess{
    
    if (ordersListModel) {
        [ordersListModel.ordersGoodsList enumerateObjectsUsingBlock:^(OSSVAccounteMyOrderseGoodseModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSDictionary *sensorsDic = @{@"referrer":[UIViewController currentTopViewControllerPageName],
                                         @"goods_sn":STLToString(obj.goods_sn),
                                         @"goods_name":STLToString(obj.goods_name),
                                         @"cat_id":STLToString(obj.cat_id),
                                         @"cat_name":STLToString(obj.cat_name),
                                         @"item_type":@"normal",
                                         @"original_price":@([STLToString(obj.market_price) floatValue]),
                                         @"present_price":@([STLToString(obj.goods_price) floatValue]),
                                         @"goods_quantity":@([STLToString(obj.goods_number) integerValue]),
                                         @"currency":@"USD",
                                         @"shoppingcart_entrance":@"repurchase",
                                         @"is_success"     : @(isSuccess)
            };
                                         
            [OSSVAnalyticsTool analyticsSensorsEventWithName:@"AddToCart" parameters:sensorsDic];
            [OSSVAnalyticsTool analyticsSensorsEventFlush];
            
            [DotApi addToCart];
            
        }];
    }
}

#pragma mark 订单评论
- (void)reviewOrder:(OSSVAccounteMyOrderseCell *)cell {
    
    OSSVAccounteMyeOrdersListeModel *orderListModel = cell.orderListModel;

    OSSVOrdersReviewVC *reviewCtrl = [[OSSVOrdersReviewVC alloc] init];
    reviewCtrl.orderId = orderListModel.orderId;
    [self.controller.navigationController pushViewController:reviewCtrl animated:YES];
}

#pragma mark --查询物流
- (void)checkTracking:(OSSVAccounteMyOrderseCell *)cell {
    OSSVAccounteMyeOrdersListeModel *orderListModel = cell.orderListModel;
    // 1：拆单   0：非拆单
    if ([STLToString(orderListModel.isSplit) isEqualToString:@"1"]) {
        STLTransportSplitViewController *splitVc = [[STLTransportSplitViewController alloc] init];
        splitVc.orderNumber = STLToString(orderListModel.orderSn);
        [self.controller.navigationController pushViewController:splitVc animated:YES];

    } else {
        STLNewTrackingListViewController *trackingVC = [[STLNewTrackingListViewController alloc] init];
        trackingVC.trackVal = STLToString(orderListModel.orderSn);
        trackingVC.trackType = @"1";
        [self.controller.navigationController pushViewController:trackingVC animated:YES];
    }
}
#pragma mark - UITableView


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.dataArray.count < 5) {
        tableView.mj_footer.hidden = YES;
    } else {
        tableView.mj_footer.hidden = NO;
    }
    return self.dataArray.count;
}

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    OSSVAccounteMyeOrdersListeModel *ordersModel = self.dataArray[indexPath.row];
//    OSSVAccounteMyOrderseCell *orderCell = (OSSVAccounteMyOrderseCell *)cell;
//    [orderCell.countDownLabel setupCellWithModel:ordersModel indexPath:indexPath];
//    orderCell.countDownLabel.attributedText = [self.countDown countDownWithTimeLabel:orderCell.countDownLabel];
//}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OSSVAccounteMyeOrdersListeModel *ordersModel = self.dataArray[indexPath.row];
    ordersModel.order_flow_switch = self.myOrdersModel.order_flow_switch;
    
    OSSVAccounteMyOrderseCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(OSSVAccounteMyOrderseCell.class)];
    if (!cell) {
        cell = [[OSSVAccounteMyOrderseCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass(OSSVAccounteMyOrderseCell.class)];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.indexPath = indexPath;
    cell.countDown = self.countDown;
    cell.orderListModel = ordersModel;
    cell.delegate = self;
     return cell;
}

#pragma mark - 历史账单入口
- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    OSSVAccounteMyeOrderseHeadereView *headerView = [OSSVAccounteMyeOrderseHeadereView accountMyOrdersHeaderViewWithTableView:tableView];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.dataArray.count > section) {
        return 4;
    }
    return 0.001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (self.dataArray.count > section) {
        return 12;
    }
    return 0.001;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    CGFloat sectionHeaderHeight = 40;
//    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
//        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
//    }
//    else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
//        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
//    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView fd_heightForCellWithIdentifier:NSStringFromClass(OSSVAccounteMyOrderseCell.class) cacheByIndexPath:indexPath configuration:^(OSSVAccounteMyOrderseCell *cell) {
        cell.orderListModel = self.dataArray[indexPath.row];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    OSSVAccounteMyeOrdersListeModel *ordersModel = self.dataArray[indexPath.row];
    
    [OSSVAnalyticsTool analyticsGAEventWithName:@"order_action" parameters:@{
           @"screen_group":@"MyOrder",
           @"action":[NSString stringWithFormat:@"Detail_%@",STLToString(ordersModel.orderSn)]}];
    
    OSSVAccountsOrderDetailVC *orderDetailVC = [[OSSVAccountsOrderDetailVC alloc] initWithOrderId:ordersModel.orderId];
    orderDetailVC.callback = ^{
        if (self.reloadDataBlock) {
            self.reloadDataBlock();
        }
    };
    [self.controller.navigationController pushViewController:orderDetailVC animated:YES];
}

- (void)showAlertViewWithTitle:(NSString *)title Message:(NSString *)message {
    STLAlertViewController *alertController = [STLAlertViewController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:APP_TYPE == 3 ? STLLocalizedString_(@"ok", nil) : STLLocalizedString_(@"ok", nil).uppercaseString style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [self.controller presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - AccountMyOrdersCellDelegate
- (void)OSSVAccounteMyOrderseCell:(OSSVAccounteMyOrderseCell *)cell sender:(UIButton *)sender event:(OrderOperateType)operateType {
    
    OSSVAccounteMyeOrdersListeModel *model = cell.orderListModel;
    
    [OSSVAnalyticsTool analyticsGAEventWithName:@"order_action" parameters:@{
           @"screen_group":@"MyOrder",
           @"action":[NSString stringWithFormat:@"%@_%@",STLToString(model.orderStatus),STLToString(sender.titleLabel.text)]}];
    
    if (operateType == OrderOperateTypeBuyAgain) {
        [self buyAgainOrder:cell orderModel:model isNeedRefresh:NO];
        return;
    }
    
    if (operateType == OrderOperateTypeBuyAddCart) {
        
        @weakify(self)
        [OSSVAlertsViewNew showAlertWithFrame:[UIScreen mainScreen].bounds alertType:STLAlertTypeButtonColumn isVertical:YES messageAlignment:NSTextAlignmentCenter isAr:NO showHeightIndex:0 title:@"" message:STLLocalizedString_(@"order_cancel_buy_msg", nil) buttonTitles:@[STLLocalizedString_(@"order_cancel_buy_btn", nil)] buttonBlock:^(NSInteger index , NSString * _Nonnull title) {
            @strongify(self)
            [self cancelOrderAndAddCart:cell];
        } closeBlock:^{
            
        }];
        
//        STLAlertTempView *orderCancelAddToCart = [[STLAlertTempView alloc] initWithFrame:CGRectZero message:STLLocalizedString_(@"order_cancel_buy_msg", nil) buttonTitle:STLLocalizedString_(@"order_cancel_buy_btn", nil)];
//
//        [orderCancelAddToCart showAlert];
        
//        @weakify(self)
//        orderCancelAddToCart.confirmBlock = ^{
//            @strongify(self)
//            [self cancelOrderAndAddCart:cell];
//        };
        return;
    }
    
    if (operateType == OrderOperateTypeCancel) {
        if ([model.payCode isEqualToString:@"Cod"]) {
            [self cancelOrderCOD:model];
        } else {
            [self cancelOrder:cell];
        }
        return;
    }
    
    if (operateType == OrderOperateTypePaying) {
        if ([model.payCode isEqualToString:@"Cod"]) {
            [self payOrderCOD:model];
        } else {
            [self payOrder:cell];
        }
        return;
    }
    
    if (operateType == OrderOperateTypeReview) {
        [self reviewOrder:cell];
        return;
    }
    
    if (operateType == OrderOperateTypeShipment) {
        [self checkTracking:cell];
        return;
    }
}

- (NSString *)currentButtonName:(OrderOperateType)operateType {
    return @"";
}



#pragma mark - ZJJTimeCountDownDelegate
- (void)outDateTimeLabel:(ZJJTimeCountDownLabel *)timeLabel timeCountDown:(ZJJTimeCountDown *)timeCountDown {
    // 当时怎么没用这个判断呢，挠头
    //STLLog(@"---- out 倒计时结束 %@",timeLabel.text);
}

- (void)dateWithTimeLabel:(ZJJTimeCountDownLabel *)timeLabel timeCountDown:(ZJJTimeCountDown *)timeCountDown {
    //STLLog(@"----date %@",timeLabel.text);
    
    BOOL isEnd = NO;
    if ([timeLabel.text isEqualToString:timeLabel.jj_description] || [timeLabel.text isEqualToString:STLToString(self.endTimeText)]) {
        isEnd = YES;
    }
    if (isEnd && !self.isTimeDownStart) {
        OSSVAccounteMyeOrdersListeModel *timeModel = (OSSVAccounteMyeOrdersListeModel *)timeLabel.model;

        if (!STLIsEmptyString(self.tempDownRefreshOrderID) && [self.tempDownRefreshOrderID isEqualToString:STLToString(timeModel.orderId)]) {
            self.tempDownRefreshOrderID = @"";
            return;
        }
        
        if (!self.isRefreshing && ([timeModel.orderStatus integerValue] == OrderStateTypeWaitingForPayment || [timeModel.orderStatus integerValue] == OrderStateTypeWaitConfirm) && timeModel.isAddTime) {
            
            [self.dataArray enumerateObjectsUsingBlock:^(OSSVAccounteMyeOrdersListeModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([timeModel.orderId isEqualToString:obj.orderId]) {
                    obj.orderStatus = [NSString stringWithFormat:@"%lu",(unsigned long)OrderStateTypeCancelled];
                    *stop = YES;
                }
            }];
            
            self.isTimeDownStart = YES;
            self.tempDownRefreshOrderID = STLToString(timeModel.orderId);
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.tableView.mj_header beginRefreshing];
            });
        }
    }
}

//样式改成用文字单位区分天/时/分/秒（英语区分单复数），注意转换后阿语倒计时规则
//---英语区分单复数（如：1day，2days），阿语倒计时规则优化
//---阿语倒计时规则：
//（1单数，2双数，3-10复数，11以上用单数）——阿语翻译
- (NSAttributedString *)customTextWithTimeLabel:(ZJJTimeCountDownLabel *)timeLabel timeCountDown:(ZJJTimeCountDown *)timeCountDown {
    
    NSString *days = STLLocalizedString_(@"day", nil);
    NSString *hours = STLLocalizedString_(@"hour", nil);
    NSString *min = STLLocalizedString_(@"minute", nil);
    NSString *seco = STLLocalizedString_(@"second", nil);

    if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
        if(timeLabel.days == 2) {
            days = STLLocalizedString_(@"days_Even", nil);
        } if (timeLabel.days >=3 && timeLabel.days <= 10) {
            days = STLLocalizedString_(@"days", nil);
        }
        
        if(timeLabel.hours == 2) {
            hours = STLLocalizedString_(@"hours_Even", nil);
        } if (timeLabel.hours >=3 && timeLabel.hours <= 10) {
            hours = STLLocalizedString_(@"hours", nil);
        }
        
        if(timeLabel.minutes == 2) {
            min = STLLocalizedString_(@"minutes_Even", nil);
        } if (timeLabel.minutes >=3 && timeLabel.minutes <= 10) {
            min = STLLocalizedString_(@"minutes", nil);
        }
        
        if(timeLabel.seconds == 2) {
            seco = STLLocalizedString_(@"seconds_Even", nil);
        } if (timeLabel.seconds >=3 && timeLabel.seconds <= 10) {
            seco = STLLocalizedString_(@"seconds", nil);
        }
    }  else {
        if (timeLabel.days  > 1) {
            days = STLLocalizedString_(@"days", nil);
        }
        
        if (timeLabel.hours > 1) {
            hours = STLLocalizedString_(@"hours", nil);
        }
        
        if (timeLabel.minutes > 1) {
            min = STLLocalizedString_(@"minutes", nil);
        }
        
        if (timeLabel.seconds > 1) {
            seco = STLLocalizedString_(@"seconds", nil);
        }
    }
    
    if (timeLabel.days > 0) {
        return [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.2ld%@ %.2ld%@ %.2ld%@ %.2ld%@",(long)timeLabel.days,days,(long)timeLabel.hours,hours, (long)timeLabel.minutes,min,(long)timeLabel.seconds,seco].uppercaseString];

    }
    if (STLIsEmptyString(self.endTimeText)) {
        self.endTimeText = [NSString stringWithFormat:@"%.2d%@ %.2d%@ %.2d%@",0,hours, 0,min,0,seco].uppercaseString;
    }
    return [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.2ld%@ %.2ld%@ %.2ld%@",(long)timeLabel.hours,hours, (long)timeLabel.minutes,min,(long)timeLabel.seconds,seco].uppercaseString];
}


#pragma mark - public method

-(void)stopCellTimer
{
    [self.countDown destoryTimer];
    _countDown = nil;
}

-(void)dealloc
{
    NSLog(@"orders dealloc");
}

#pragma mark - setter and getter

-(ZJJTimeCountDown *)countDown
{
    if (!_countDown) {
        _countDown = [[ZJJTimeCountDown alloc] initWithScrollView:self.tableView dataList:self.dataArray];
        _countDown.timeStyle = ZJJCountDownTimeStyleTamp;
        _countDown.labelInContentView = NO;
        _countDown.delegate = self;
    }
    return _countDown;
}

-(OSSVAccounteMyOrderseDetailViewModel *)viewModel
{
    if (!_viewModel) {
        _viewModel = [[OSSVAccounteMyOrderseDetailViewModel alloc] init];
        _viewModel.controller = self.controller;
    }
    return _viewModel;
}

- (OSSVCheckOutCodMsgAlertView *)codMsgAlertView {
    if (!_codMsgAlertView) {
        _codMsgAlertView = [[OSSVCheckOutCodMsgAlertView alloc] initWithFrame:CGRectZero];
        @weakify(self);
        _codMsgAlertView.codAlertBlock = ^(NSString *resultId, NSString *resultStr) {
            @strongify(self);
            @weakify(self);
            
            [OSSVAnalyticsTool analyticsGAEventWithName:@"cancel_order" parameters:@{
                   @"screen_group":@"MyOrder",
                   @"action":@"Cancel_Yes"}];
            
            [self codCancelRequest:resultId cancelResult:resultStr completion:^(id obj) {
                @strongify(self);
                if (self.reloadDataBlock) {
                    self.reloadDataBlock();
                }
            } failure:nil];
        };
        _codMsgAlertView.closeBlock = ^{
            
            [OSSVAnalyticsTool analyticsGAEventWithName:@"cancel_order" parameters:@{
                   @"screen_group":@"MyOrder",
                   @"action":@"Cancel_No"}];
        };
    }
    return _codMsgAlertView;
}


- (void)codCancelRequest:(NSString *)type cancelResult:(NSString *)resultString completion:(void (^)(id))completion failure:(void (^)(id))failure{
    
    NSDictionary *params = @{@"cancel_type"  :STLToString(type),
                             @"order_id"      :STLToString(self.selectCodOrderModel.orderId),
                             };

    @weakify(self)
    OSSVCodCancelAddAip *codCancelApi = [[OSSVCodCancelAddAip alloc] initWithDict:params];
    [codCancelApi startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
        NSLog(@"----- codCancell Success");
        @strongify(self)
        
        [self orderCancelSuccess:self.selectCodOrderModel normal:YES success:YES cancelReason:resultString];

        if (completion) {
            completion(nil);
        }
        
    } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
        NSLog(@"----- codCancell failure: %@",error.debugDescription);
        if (failure) {
            failure(nil);
        }
        [self orderCancelSuccess:self.selectCodOrderModel normal:YES success:NO cancelReason:resultString];

    }];
}

- (OSSVOrdereCodeSuccessView *)codSuccessView {
    if (!_codSuccessView) {
        _codSuccessView = [[OSSVOrdereCodeSuccessView alloc] initWithFrame:CGRectZero];
    }
    return _codSuccessView;
}


-(OSSVCartOrderInfoViewModel *)infoViewModel
{
    if (!_infoViewModel) {
        _infoViewModel = [[OSSVCartOrderInfoViewModel alloc] init];
    }
    return _infoViewModel;
}

- (void)conConfirmAnalytics:(BOOL)state {
    
    if (!self.selectCodOrderModel) {
        return;
    }
    
    ////
    NSString *contacts = [NSString stringWithFormat:@"%@ %@",
                          STLToString(self.selectCodOrderModel.receiver_info.first_name),
                          STLToString(self.selectCodOrderModel.receiver_info.last_name)];
    
    NSArray *counrty = [self.selectCodOrderModel.receiver_info.country_name componentsSeparatedByString:@"/"];
    NSArray *province = [self.selectCodOrderModel.province componentsSeparatedByString:@"/"];
    NSArray *city = [self.selectCodOrderModel.city componentsSeparatedByString:@"/"];
    NSArray *street = [self.selectCodOrderModel.district componentsSeparatedByString:@"/"];

    NSString *countryString = counrty.firstObject;
    NSString *stateString = province.firstObject;
    NSString *cityString = city.firstObject;
    NSString *streetString = street.firstObject;

    NSArray *addressArray = @[streetString,cityString,stateString,countryString];
    NSString *addressString = [addressArray componentsJoinedByString:@","];
    
    
    NSDictionary *sensorsDic = @{@"order_sn":STLToString(self.selectCodOrderModel.orderSn),
                                 @"order_actual_amount"        :   @([STLToString(self.selectCodOrderModel.money_info.payable_amount) floatValue]),
                                 @"total_price_of_goods"        :   @([STLToString(self.selectCodOrderModel.money_info.goods_amount) floatValue]),
                                 @"payment_method"        :   STLToString(self.selectCodOrderModel.payCode),
                                 @"currency":@"USD",
                                 @"receiver_name"      :   STLToString(contacts),
                                 @"receiver_country"      :   STLToString(countryString),
                                 @"receiver_province"        :   STLToString(stateString),
                                @"receiver_city"           :   STLToString(cityString),
                                 @"receiver_district"   :   STLToString(streetString),
                                 @"receiver_address"   :   STLToString(addressString),
                                 @"shipping_fee"        :   @([STLToString(self.selectCodOrderModel.money_info.shipping_fee) floatValue]),
                                 @"discount_id":STLToString(self.selectCodOrderModel.coupon_code),
                                 @"discount_amount":@([STLToString(self.selectCodOrderModel.money_info.coupon_save) floatValue]),
                                 @"is_use_discount":(STLIsEmptyString(self.selectCodOrderModel.coupon_code) ? @(0) : @(1)),
                                 @"is_success": @(state),

    };
    [OSSVAnalyticsTool analyticsSensorsEventWithName:@"ClickConfirmCod" parameters:sensorsDic];
    
}


- (void)paySuccesWithProductCodAnalytics:(BOOL)state {
    
    if (!self.selectCodOrderModel) {
        return;
    }

    ////
    NSString *contacts = [NSString stringWithFormat:@"%@ %@",
                          STLToString(self.selectCodOrderModel.receiver_info.first_name),
                          STLToString(self.selectCodOrderModel.receiver_info.last_name)];
    
    NSArray *counrty = [self.selectCodOrderModel.receiver_info.country_name componentsSeparatedByString:@"/"];
    NSArray *province = [self.selectCodOrderModel.province componentsSeparatedByString:@"/"];
    NSArray *city = [self.selectCodOrderModel.city componentsSeparatedByString:@"/"];
    NSArray *street = [self.selectCodOrderModel.district componentsSeparatedByString:@"/"];

    NSString *countryString = counrty.firstObject;
    NSString *stateString = province.firstObject;
    NSString *cityString = city.firstObject;
    NSString *streetString = street.firstObject;

    NSArray *addressArray = @[streetString,cityString,stateString,countryString];
    NSString *addressString = [addressArray componentsJoinedByString:@","];
    

    BOOL isfirstOrder = [OSSVAccountsManager sharedManager].account.is_first_order_time;
    NSString *payType = @"normal";
    [OSSVAnalyticsTool sharedManager].analytics_uuid = [OSSVAnalyticsTool appsAnalyticUUID];
    NSString *analyticsUUID = [OSSVAnalyticsTool sharedManager].analytics_uuid;
    NSString *goodsSkuCount = [NSString stringWithFormat:@"%lu",(unsigned long)self.selectCodOrderModel.ordersGoodsList.count];
    NSDictionary *sensorsDic = @{@"is_first_time":(isfirstOrder ? @(1) : @(0)),
                                 @"order_type":payType,
                                 @"order_sn":STLToString(self.selectCodOrderModel.orderSn),
                                 @"order_actual_amount"        :   @([STLToString(self.selectCodOrderModel.money_info.payable_amount) floatValue]),
                                 @"total_price_of_goods"        :   @([STLToString(self.selectCodOrderModel.money_info.goods_amount) floatValue]),
                                 @"payment_method"        :   STLToString(self.selectCodOrderModel.payCode),
                                 @"currency":@"USD",
                                 @"receiver_name"      :   STLToString(contacts),
                                 @"receiver_country"      :   STLToString(countryString),
                                 @"receiver_province"        :   STLToString(stateString),
                                 @"receiver_city"           :   STLToString(cityString),
                                 @"receiver_district"   :   STLToString(streetString),
                                 @"receiver_address"   :   STLToString(addressString),
                                 @"shipping_fee"        :   @([STLToString(self.selectCodOrderModel.money_info.shipping_fee) floatValue]),
                                 @"discount_id":STLToString(self.selectCodOrderModel.coupon_code),
                                 @"discount_amount":@([STLToString(self.selectCodOrderModel.money_info.coupon_save) floatValue]),
                                 @"is_use_discount":(STLIsEmptyString(self.selectCodOrderModel.coupon_code) ? @(0) : @(1)),
                                 @"is_success": @(state),
                                 @"uu_id":analyticsUUID,
                                 @"goods_sn_count":goodsSkuCount,

    };
    [OSSVAnalyticsTool analyticsSensorsEventWithName:@"ConfirmCod" parameters:sensorsDic];
    
    if (state) {//只埋成功
        //AB ConfirmCod
        [ABTestTools.shared confirmCodWithOrderSn:STLToString(self.selectCodOrderModel.orderSn)
                                orderActureAmount:[STLToString(self.selectCodOrderModel.money_info.payable_amount) floatValue]
                                totalPriceOfGoods:[STLToString(self.selectCodOrderModel.money_info.goods_amount) floatValue]
                                     goodsSnCount:self.selectCodOrderModel.ordersGoodsList.count
                                    paymentMethod:STLToString(self.selectCodOrderModel.payCode)
                                    isUseDiscount:(STLIsEmptyString(self.selectCodOrderModel.coupon_code) ? @"0" : @"1")
                                    confirmMethod:self.confirmMethod
        ];
    }
    
    
    
    NSMutableArray *goodsSnArray = [[NSMutableArray alloc]initWithCapacity: 1];
    NSMutableArray *priceArray = [[NSMutableArray alloc]initWithCapacity: 1];
    NSMutableArray *qtyArray = [[NSMutableArray alloc]initWithCapacity: 1];
    NSMutableArray *itemsGoods = [[NSMutableArray alloc] init];

    CGFloat allAmount = 0;
    for (NSInteger i = 0; i < self.selectCodOrderModel.ordersGoodsList.count; i ++) {
        OSSVAccounteMyOrderseGoodseModel *goodsModel = (OSSVAccounteMyOrderseGoodseModel*)self.selectCodOrderModel.ordersGoodsList[i];
        [goodsSnArray addObject:STLToString(goodsModel.goods_sn)];
        [priceArray addObject:STLToString(goodsModel.money_info.goods_price)];
        [qtyArray addObject:STLToString(goodsModel.goods_number)];
        
        CGFloat price = [goodsModel.money_info.goods_price floatValue];
        
        NSDictionary *items = @{
            kFIRParameterItemID: STLToString(goodsModel.goods_sn),
            kFIRParameterItemName: STLToString(goodsModel.goods_name),
            kFIRParameterItemCategory: STLToString(goodsModel.cat_name),
            kFIRParameterPrice: @(price),
            kFIRParameterQuantity: @([STLToString(goodsModel.goods_number) floatValue]),
            kFIRParameterItemVariant:STLToString(goodsModel.goods_attr),
            kFIRParameterItemBrand:@"",
        };
        
        [itemsGoods addObject:items];
        
        BOOL isfirstOrder = [OSSVAccountsManager sharedManager].account.is_first_order_time;
        NSString *payType = @"normal";
        NSDictionary *sensorsDic = @{@"is_first_time":(isfirstOrder ? @(1) : @(0)),
                                     @"order_type":payType,
                                     @"order_sn":STLToString(self.selectCodOrderModel.orderSn),
                                     @"goods_sn"        :   STLToString(goodsModel.goods_sn),
                                     @"goods_name"        :   STLToString(goodsModel.goods_name),
                                     @"cat_id"        :   STLToString(goodsModel.cat_id),
                                     @"cat_name"      :   STLToString(goodsModel.cat_name),
                                     @"currency":@"USD",
                                     @"original_price"      :   @([goodsModel.money_info.market_price floatValue]),
                                     @"present_price"        :   @([goodsModel.money_info.goods_price floatValue]),
                                     @"goods_color"           :   @"",
                                     @"goods_size" :@"",
                                     @"goods_quantity"   :   @([STLToString(goodsModel.goods_number) integerValue]),
                                     @"is_success": @(state),
                                     @"uu_id":analyticsUUID,
                                          
        };
        [OSSVAnalyticsTool analyticsSensorsEventWithName:@"ConfirmCodDetail" parameters:sensorsDic];
    }

    allAmount += [self.selectCodOrderModel.money_info.payable_amount floatValue];

    
    NSString *goodsSnStrings = [(NSArray *)goodsSnArray componentsJoinedByString:@","];
    NSString *priceStrings = [(NSArray *)priceArray componentsJoinedByString:@","];
    NSString *qtyStrings = [(NSArray *)qtyArray componentsJoinedByString:@","];
    
    
    if (state) {
        
        NSDictionary *dic = @{
            @"af_content_id":goodsSnStrings,
            @"af_order_id":STLToString(self.selectCodOrderModel.orderSn),
            @"af_price":priceStrings,
            @"af_quantity":qtyStrings,
            @"af_currency":@"USD",
            @"af_revenue":[NSString stringWithFormat:@"%@",self.selectCodOrderModel.money_info.payable_amount],
        };
        [OSSVAnalyticsTool appsFlyerOrderPaySuccess:dic];
        
        //数据GA埋点曝光 支付成功事件
        //GA
        NSDictionary *itemsDic = @{kFIRParameterItems:itemsGoods,
                                   kFIRParameterCurrency: @"USD",
                                   kFIRParameterValue: @(allAmount),
                                   kFIRParameterCoupon:STLToString(self.selectCodOrderModel.coupon_code),
                                   kFIRParameterPaymentType:STLToString(self.selectCodOrderModel.payCode),
                                   kFIRParameterShipping:STLToString(self.selectCodOrderModel.orderSn),
                                   @"shipping":STLToString(self.selectCodOrderModel.money_info.shipping_fee),
                                   kFIRParameterDiscount:@"",
                                   kFIRParameterTax:@"",
                                   @"cod_cost": STLToString(self.selectCodOrderModel.money_info.cod_cost),
                                   @"cod_discount":STLToString(self.selectCodOrderModel.money_info.cod_discount),
                                   @"screen_group":@"PaymentSuccess",
        };
        
        [OSSVAnalyticsTool analyticsGAEventWithName:kFIREventPurchase parameters:itemsDic];
        ///Branch
        [OSSVBrancshToolss logPurchaseGMV:itemsDic];
        
        [DotApi payOrder];
    }
    
}

- (void)orderCancelSuccess:(OSSVAccounteMyeOrdersListeModel *)model normal:(BOOL)isNormal success:(BOOL)isSuccess cancelReason:(NSString *)cancelReason {
    
    if (!model) {
        return;
    }

    if (isSuccess) {
        
        NSMutableArray *snArray = [[NSMutableArray alloc]initWithCapacity: 1];
        NSMutableArray *priceArray = [[NSMutableArray alloc]initWithCapacity: 1];
        NSMutableArray *qtyArray = [[NSMutableArray alloc]initWithCapacity: 1];
        
        
        for (NSInteger i = 0; i < model.ordersGoodsList.count; i ++) {
            OSSVAccounteMyOrderseGoodseModel *goodsModel = (OSSVAccounteMyOrderseGoodseModel*)model.ordersGoodsList[i];
            [snArray addObject:STLToString(goodsModel.goods_sn)];
            [priceArray addObject:STLToString(goodsModel.money_info.goods_price)];
            [qtyArray addObject:STLToString(goodsModel.goods_number)];
        }
        
        
        NSString *snStrings = [(NSArray *)snArray componentsJoinedByString:@","];
        NSString *priceStrings = [(NSArray *)priceArray componentsJoinedByString:@","];
        NSString *qtyStrings = [(NSArray *)qtyArray componentsJoinedByString:@","];
        
        
        NSDictionary *dic = @{
            @"af_content_id":snStrings,
            @"af_order_id":STLToString(model.orderSn),
            @"af_price":priceStrings,
            @"af_quantity":qtyStrings,
            @"af_currency":@"USD",
            @"af_revenue":[NSString stringWithFormat:@"%@",model.money_info.payable_amount],
        };
        
        [OSSVAnalyticsTool appsFlyerOrderCancel:dic];
    }
    
    ////
    NSString *contacts = [NSString stringWithFormat:@"%@ %@",
                          STLToString(model.receiver_info.first_name),
                          STLToString(model.receiver_info.last_name)];
    
    NSArray *counrty = [model.receiver_info.country_name componentsSeparatedByString:@"/"];
    NSArray *province = [model.province componentsSeparatedByString:@"/"];
    NSArray *city = [model.city componentsSeparatedByString:@"/"];
    NSArray *street = [model.district componentsSeparatedByString:@"/"];

    NSString *countryString = counrty.firstObject;
    NSString *stateString = province.firstObject;
    NSString *cityString = city.firstObject;
    NSString *streetString = street.firstObject;
    NSArray *addressArray = @[streetString,cityString,stateString,countryString];
    NSString *addressString = [addressArray componentsJoinedByString:@","];

//    cancel_button--点击取消按钮；repurchase--点击重新购买取消
    NSString *payType = [STLToString(model.payCode) isEqualToString:@"Influencer"] ? @"kol" : @"normal";
    NSString *cancelType = isNormal ? @"cancel_button" : @"repurchase";
    BOOL flag = isSuccess;
    
    [OSSVAnalyticsTool sharedManager].analytics_uuid = [OSSVAnalyticsTool appsAnalyticUUID];
    NSString *analyticsUUID = [OSSVAnalyticsTool sharedManager].analytics_uuid;
    NSString *goodSkuCount = [NSString stringWithFormat:@"%lu",(unsigned long)model.ordersGoodsList.count];
 
    
    NSDictionary *sensorsDic = @{@"order_type":payType,
                                 @"cancel_type":cancelType,
                                 @"order_sn":STLToString(model.orderSn),
                                 @"order_actual_amount"        :   @([STLToString(model.money_info.payable_amount) floatValue]),
                                 @"total_price_of_goods"        :   @([STLToString(model.money_info.goods_amount) floatValue]),
                                 @"payment_method"        :   STLToString(model.payCode),
                                 @"currency":@"USD",
                                 @"receiver_name"      :   STLToString(contacts),
                                 @"receiver_country"      :   STLToString(countryString),
                                 @"receiver_province"        :   STLToString(stateString),
                                @"receiver_city"           :   STLToString(cityString),
                                 @"receiver_district"   :   STLToString(streetString),
                                 @"receiver_address"   :   STLToString(addressString),
                                 @"shipping_fee"        :   @([STLToString(model.money_info.shipping_fee) floatValue]),
                                 @"discount_id":STLToString(model.coupon_code),
                                 @"discount_amount": @([STLToString(model.money_info.coupon_save) floatValue]),
                                 @"is_use_discount":(STLIsEmptyString(model.coupon_code) ? @(0) : @(1)),
                                 @"is_success": @(flag),
                                 @"uu_id":analyticsUUID,
                                 @"goods_sn_count":goodSkuCount,
                                 @"cancel_reason":STLToString(cancelReason),

    };
    
    [OSSVAnalyticsTool analyticsSensorsEventWithName:@"CancelOrder" parameters:sensorsDic];
    
    for (NSInteger i = 0; i < model.ordersGoodsList.count; i ++) {
        OSSVAccounteMyOrderseGoodseModel *goodsModel = (OSSVAccounteMyOrderseGoodseModel*)model.ordersGoodsList[i];
        
        NSString *payType = [STLToString(model.payCode) isEqualToString:@"Influencer"] ? @"kol" : @"normal";
        NSDictionary *sensorsDic = @{
                                     @"order_type":payType,
                                     @"order_sn"        :   STLToString(model.orderSn),
                                     @"goods_sn"      :   STLToString(goodsModel.goods_sn),
                                     @"goods_name"      :   STLToString(goodsModel.goods_name),
                                     @"cat_id"           :   STLToString(goodsModel.cat_id),
                                     @"cat_name"        :   STLToString(goodsModel.cat_name),
                                     @"original_price"   :   @([STLToString(goodsModel.money_info.market_price) floatValue]),
                                     @"present_price"   :   @([STLToString(goodsModel.money_info.goods_price) floatValue]),
                                     @"goods_quantity"        :   @([STLToString(goodsModel.goods_number) integerValue]),
                                     @"goods_size":@"",
                                     @"goods_color":@"",
                                     @"currency":@"USD",
                                     @"payment_method"        :   STLToString(model.payCode),
                                     @"is_success": @(flag),
                                     @"uu_id":analyticsUUID,

        };
        [OSSVAnalyticsTool analyticsSensorsEventWithName:@"CancelOrderDetail" parameters:sensorsDic];

    };
    
}


- (void)orderOnlePayResultAnalytics:(OSSVAccounteMyeOrdersListeModel *)model state:(BOOL)flag {

    ////
    NSString *contacts = [NSString stringWithFormat:@"%@ %@",
                          STLToString(model.receiver_info.first_name),
                          STLToString(model.receiver_info.last_name)];
    
    NSArray *counrty = [model.receiver_info.country_name componentsSeparatedByString:@"/"];
    NSArray *province = [model.province componentsSeparatedByString:@"/"];
    NSArray *city = [model.city componentsSeparatedByString:@"/"];
    NSArray *street = [model.district componentsSeparatedByString:@"/"];

    NSString *countryString = counrty.firstObject;
    NSString *stateString = province.firstObject;
    NSString *cityString = city.firstObject;
    NSString *streetString = street.firstObject;
    NSArray *addressArray = @[streetString,cityString,stateString,countryString];
    NSString *addressString = [addressArray componentsJoinedByString:@","];

    
    BOOL isfirstOrder = [OSSVAccountsManager sharedManager].account.is_first_order_time;
    NSString *payType = [STLToString(model.payCode) isEqualToString:@"Influencer"] ? @"kol" : @"normal";
    
    [OSSVAnalyticsTool sharedManager].analytics_uuid = [OSSVAnalyticsTool appsAnalyticUUID];
    NSString *analyticsUUID = [OSSVAnalyticsTool sharedManager].analytics_uuid;
    NSString *goodSkuCount = [NSString stringWithFormat:@"%lu",(unsigned long)model.ordersGoodsList.count];
 
    
    NSDictionary *sensorsDic = @{@"is_first_time":(isfirstOrder ? @(1) : @(0)),
                                 @"order_type":payType,
                                 @"order_sn":STLToString(model.orderSn),
                                 @"order_actual_amount"        :   @([STLToString(model.money_info.payable_amount) floatValue]),
                                 @"total_price_of_goods"        :   @([STLToString(model.money_info.goods_amount) floatValue]),
                                 @"payment_method"        :   STLToString(model.payCode),
                                 @"currency":@"USD",
                                 @"receiver_name"      :   STLToString(contacts),
                                 @"receiver_country"      :   STLToString(countryString),
                                 @"receiver_province"        :   STLToString(stateString),
                                @"receiver_city"           :   STLToString(cityString),
                                 @"receiver_district"   :   STLToString(streetString),
                                 @"receiver_address"   :   STLToString(addressString),
                                 @"shipping_fee"        :   @([STLToString(model.money_info.shipping_fee) floatValue]),
                                 @"discount_id":STLToString(model.coupon_code),
                                 @"discount_amount": @([STLToString(model.money_info.coupon_save) floatValue]),
                                 @"is_use_discount":(STLIsEmptyString(model.coupon_code) ? @(0) : @(1)),
                                 @"is_success": @(flag),
                                 @"uu_id":analyticsUUID,
                                 @"goods_sn_count":goodSkuCount,

    };
    
    [OSSVAnalyticsTool analyticsSensorsEventWithName:@"OnlinePayOrder" parameters:sensorsDic];
    
    if(flag){
        [ABTestTools.shared onlinePayOrderWithOrderSn:STLToString(model.orderSn)
                                    orderActureAmount:[STLToString(model.money_info.payable_amount) floatValue]
                                    totalPriceOfGoods:[STLToString(model.money_info.goods_amount) floatValue]
                                         goodsSnCount:model.ordersGoodsList.count
                                        paymentMethod:STLToString(model.payCode)
                                        isUseDiscount:(STLIsEmptyString(model.coupon_code) ? @"0" : @"1")];
    }
    

    
    for (NSInteger i = 0; i < model.ordersGoodsList.count; i ++) {
        OSSVAccounteMyOrderseGoodseModel *goodsModel = (OSSVAccounteMyOrderseGoodseModel*)model.ordersGoodsList[i];
        
        BOOL isfirstOrder = [OSSVAccountsManager sharedManager].account.is_first_order_time;
        NSString *payType = [STLToString(model.payCode) isEqualToString:@"Influencer"] ? @"kol" : @"normal";
        NSDictionary *sensorsDic = @{@"is_first_time":(isfirstOrder ? @(1) : @(0)),
                                     @"order_type":payType,
                                     @"order_sn"        :   STLToString(model.orderSn),
                                     @"goods_sn"      :   STLToString(goodsModel.goods_sn),
                                     @"goods_name"      :   STLToString(goodsModel.goods_name),
                                     @"cat_id"           :   STLToString(goodsModel.cat_id),
                                     @"cat_name"        :   STLToString(goodsModel.cat_name),
                                     @"original_price"   :   @([STLToString(goodsModel.money_info.market_price) floatValue]),
                                     @"present_price"   :   @([STLToString(goodsModel.money_info.goods_price) floatValue]),
                                     @"goods_quantity"        :   @([STLToString(goodsModel.goods_number) integerValue]),
                                     @"goods_size":@"",
                                     @"goods_color":@"",
                                     @"currency":@"USD",
                                     @"payment_method"        :   STLToString(model.payCode),
                                     @"is_success": @(flag),
                                     @"uu_id":analyticsUUID,

        };
        [OSSVAnalyticsTool analyticsSensorsEventWithName:@"OnlinePayOrderDetail" parameters:sensorsDic];
        
    };
}

- (void)repurchaseAnalytics:(OSSVAccounteMyeOrdersListeModel *)model success:(BOOL)flag {
    
    if (!model) {
        return;
    }
    NSString *payType = [STLToString(model.payCode) isEqualToString:@"Influencer"] ? @"kol" : @"normal";
    NSDictionary *sensorsDic = @{
                                 @"order_type"          :   payType,
                                 @"order_sn"            :   STLToString(model.orderSn),
                                 @"payment_method"      :   STLToString(model.payCode),
                                 @"is_success"          :  @(flag),
                                 @"order_status"        :  STLToString(model.orderStatus),

    };
    [OSSVAnalyticsTool analyticsSensorsEventWithName:@"ClickRepurchase" parameters:sensorsDic];
    
}
@end
