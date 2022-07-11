//
//  OSSVCartViewModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/6.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCartViewModel.h"
#import "OSSVCartHeaderView.h"
#import "OSSVCartTableInvalidHeaderView.h"
#import "OSSVCartTableMayLikeHeaderView.h"
#import "OSSVCartTableOtherHeaderView.h"
#import "OSSVCartCell.h"
#import "OSSVCartInvalidTableCell.h"
#import "OSSVCartLikeTableCell.h"
#import "OSSVCartEmptyTableCell.h"

#import "OSSVAddCollectApi.h"
#import "OSSVCartCheckAip.h"
#import "OSSVCartCheckModel.h"

#import "OSSVDetailsVC.h"
#import "OSSVAddresseBookeModel.h"
#import "OSSVCommendFooterView.h"
#import "STLAlertControllerView.h"
#import "STLAlertBottomView.h"
#import "OSSVCartNoDataView.h"
#import "OSSVCartFooterView.h"

#import "STLActivityWWebCtrl.h"
#import "OSSVCheckOutVC.h"                ///<提交订单页面
#import "OSSVCommonnRequestsManager.h"

#import "Adorawe-Swift.h"


@interface OSSVCartViewModel ()
@property (nonatomic, strong) STLCartAnalyticsAOP   *cartListAnalyticsManager;
@end

@implementation OSSVCartViewModel
//@synthesize emptyViewManager = _emptyViewManager;

- (void)dealloc {
    NSLog(@"OSSVCartViewModel dealloc");
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[OSSVAnalyticInjectsManager shareInstance] analyticsInject:self injectObject:self.cartListAnalyticsManager];
    }
    return self;
}

//处理请求数据
- (void)updateCartData:(STLCartModel *)cartModel {
    
    [self.cartListAnalyticsManager refreshDataSource];
    [self handleCartModelGoodsHeight:cartModel];
    [self reloadUI];
}

- (void)handleCartModelGoodsHeight:(STLCartModel *)cartModel {
    self.cartModel = cartModel;
    //[self.cartModel handleGroupData];
    
//    if (!cartModel) {
//        self.emptyViewShowType = EmptyViewShowTypeNoNet;
//    } else {
//        self.emptyViewShowType = self.cartModel.groupList.count > 0 ? EmptyViewShowTypeHide : EmptyViewShowTypeNoData;
//    }
}

- (void)requestFavoriteNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
    @weakify(self)
    [[STLNetworkStateManager sharedManager] networkState:^{
        @strongify(self)
        @weakify(self)
        OSSVAddCollectApi *api = [[OSSVAddCollectApi alloc] initWithAddCollectGoodsId:parmaters[0] wid:parmaters[1]];
        [api.accessoryArray addObject:[[STLRequestAccessory alloc] initWithApperOnView:self.controller.view]];
        [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            @strongify(self)
            id requestJSON = [OSSVNSStringTool desEncrypt:request];
            id state = [self dataAnalysisFromJson: requestJSON request:api];
            if (completion) {
                completion(state);
            }
        } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
            if (failure) {
                failure(nil);
            }
            STLLog(@"failure");
        }];
    } exception:^{
        if (failure) {
            failure(nil);
        }
    }];
}

- (void)requestCartCheckNetwork:(id)parmaters completion:(void (^)(id obj,id rawData))completion failure:(void (^)(id obj))failure {
    @weakify(self)
    [[STLNetworkStateManager sharedManager] networkState:^{
        @strongify(self)
        @weakify(self)
        self.bottomView.userInteractionEnabled = false;
        OSSVCartCheckAip *api = [[OSSVCartCheckAip alloc] initWithDict:parmaters];
        
        [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            self.bottomView.userInteractionEnabled = true;
            @strongify(self)
            id requestJSON = [OSSVNSStringTool desEncrypt:request];
            NSArray *array = [self dataAnalysisFromJson: requestJSON request:api];
            if (completion) {
                completion(array,requestJSON);
            }
        } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
            self.bottomView.userInteractionEnabled = true;
            if (failure) {
                failure(nil);
            }
        }];
    } exception:^{
        self.bottomView.userInteractionEnabled = true;
        if (failure) {
            failure(nil);
        }
    }];
}


- (void)buyOperationAddressId:(NSString *)addressId{
    
    NSMutableArray *selectGoods = [self.cartModel allSelectGoods];
    if (selectGoods.count == 0) {
        //请选择商品
        [self cartCheckOutNOSelectedGoods];
        return ;
    }
    
    ///不判断
    /***
    //点击Buy，如未达到COD的使用条件，弹出提示框,继续结算进入结算页，取消留在购物车，X后台取沙特国家的设置
    CartInfoModel *cartInfo = self.cartModel.cartInfo;
    CodConfModel *codInfo = self.cartModel.codConf;
    if ([codInfo.minAmount floatValue] > 0 && [codInfo.maxAmount floatValue] > [codInfo.minAmount floatValue]) {
        if ([cartInfo.total floatValue] < [codInfo.minAmount floatValue] || [cartInfo.total floatValue] > [codInfo.maxAmount floatValue]) {
            
            NSString *minMoney = [ExchangeManager changeRateModel:nil transforPrice:[NSString stringWithFormat:@"%lf",[codInfo.minAmount floatValue]]];
            NSString *maxMoney = [ExchangeManager changeRateModel:nil transforPrice:[NSString stringWithFormat:@"%lf",[codInfo.maxAmount floatValue]]];
            
            NSString *codMsg = STLLocalizedString_(@"Sincerely_recommend_cod_which_orders_over_$XX-$YY", nil);
            NSString *codMinMsg = [codMsg stringByReplacingOccurrencesOfString:@"$XX" withString:minMoney];
            NSString *payCodMsg = [codMinMsg stringByReplacingOccurrencesOfString:@"$YY" withString:maxMoney];
            
            
            [STLAlertControllerView showCtrl:self.controller
                                 alertTitle:nil
                                    message:payCodMsg
                                     oneMsg:STLLocalizedString_(@"cancel", nil)
                                     twoMsg:STLLocalizedString_(@"Continue_to_check_out", nil)
                          completionHandler:^(NSInteger flag) {
                              if(flag == 2) {
                                  [self cartCheckOrderAddress:addressId];
                              }
                          }];
            return;
        }
    }
     */
    
    [self cartCheckOrderAddress:addressId];
}



#pragma mark 下单
- (void)cartCheckOrderAddress:(NSString *)addressid {
        
    NSArray *allSelect = [self.cartModel allSelectGoods];
    __block BOOL hasNewGoods = NO;
    __block BOOL hasOtherGoods = NO;
    [allSelect enumerateObjectsUsingBlock:^(CartModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        if ([obj.freeGiftType isEqualToString:@"1"]) {
//            hasNewGoods = YES;
//        } else {
            hasOtherGoods = YES;
//        }
    }];
    
    //新人礼品不能单独购买
    if (hasNewGoods && !hasOtherGoods) {
        
        [HUDManager showHUDWithMessage:STLLocalizedString_(@"Free_gift_cannot_be_settled_solely", nil) margin:10];
        return;
    }
    
    @weakify(self)
    [[STLNetworkStateManager sharedManager] networkState:^{
        
        [HUDManager showLoading];

        [self requestCartCheckNetwork:@{@"is_use_coin":@"0", @"is_shipping_insurance":@"0"} completion:^(NSArray *objs,id rawData) {

            @strongify(self)

            if (![objs isKindOfClass:[NSArray class]]) {
                [self cartCheckOutOrderAnalytic:NO goodsCount:allSelect.count];
                return ;
            }
            
            BOOL state = NO;
            if (objs) {
                switch ([objs[0] integerValue]) {
                    case CartCheckOutResultEnumTypeNoAddress: { //没有地址 直接进入地址
                        [self CartCheckOutNoAddress:objs table:nil];
                    }
                        break;
                        
                    case CartCheckOutResultEnumTypeShelvesed: { //此商品已下架
                        
                        [OSSVAlertsViewNew showAlertWithAlertType:STLAlertTypeButton isVertical:YES messageAlignment:NSTextAlignmentCenter isAr:NO showHeightIndex:0 title:@"" message:objs[1] buttonTitles:APP_TYPE == 3 ? @[STLLocalizedString_(@"ok",nil)] : @[STLLocalizedString_(@"ok",nil).uppercaseString] buttonBlock:^(NSInteger index, NSString * _Nonnull title) {
                            
                            [self cartCheckOutShelvesed:objs table:nil];
                        }];
                    }
                        break;
                    case CartCheckOutResultEnumTypeSuccess: {
                        state = YES;
                        [self cartCheckOutOrderSuccess:objs rawData:rawData];
                    }
                        break;
                    case CartCheckOutResultEnumTypeNoGoods: //购物车没有此商品
                    case CartCheckOutResultEnumTypeNoShipping: //没有物流
                    case CartCheckOutResultEnumTypeNoStock: //库存不足
                    case CartCheckOutResultEnumTypeNoPayment:
                    case CartCheckOutResultEnumTypeNoSupportPayment: { //不支持此支付
                        
                        [OSSVAlertsViewNew showAlertWithAlertType:STLAlertTypeButton isVertical:YES messageAlignment:NSTextAlignmentCenter isAr:NO showHeightIndex:0 title:@"" message:objs[1] buttonTitles:APP_TYPE == 3 ? @[STLLocalizedString_(@"ok",nil)] : @[STLLocalizedString_(@"ok",nil).uppercaseString] buttonBlock:^(NSInteger index, NSString * _Nonnull title) {
                            
                        }];
                    }
                        break;
                    default:
                        break;
                }
            }
            
            [self cartCheckOutOrderAnalytic:state goodsCount:allSelect.count];
            
        } failure:^(id obj) {
            [HUDManager hiddenHUD];
        }];
        
    } exception:^{
    }];
}

#pragma mark - 刷新界面
- (void)reloadUI {
    if (self.updateResultBlock) {
        
        NSArray *allGoods = [self.cartModel allValidGoods];
        
//        [[OSSVCartsOperateManager sharedManager] cartSaveValidGoodsCount:allGoods.count];
//        [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_CartBadge object:nil];
        
        __block BOOL allSelected = YES;
        __block NSInteger selectedCount = 0;
        [allGoods enumerateObjectsUsingBlock:^(CartModel *  _Nonnull cartModel, NSUInteger idx, BOOL * _Nonnull stop) {
            if (!cartModel.isChecked) {
                allSelected = NO;
            } else {
                selectedCount += cartModel.goodsNumber;
            }
        }];
        self.updateResultBlock(self.cartModel.cartInfo, selectedCount, allSelected);
    }
}


#pragma mark - 立即购买
- (void)cartCheckOutBuy {
    
    [OSSVAnalyticsTool analyticsSensorsEventWithName:@"ClickCheckOut" parameters:@{}];

    if (![OSSVAccountsManager sharedManager].isSignIn) {
        ///支付旧流程
        [OSSVAnalyticsTool appsFlyerTrackEvent:@"af_checkout_nologin" withValues:nil];
        SignViewController *sign = [SignViewController new];
        sign.isCheckOutIn = YES;
        sign.modalPresentationStyle = UIModalPresentationFullScreen;
        @weakify(self)
        //如果登录后自动执行，可以在block中填写代码
        sign.modalBlock = ^{
            @strongify(self)
            ///刷新用户数据 ---
            [OSSVCommonnRequestsManager checkUpdateUserInfo:nil];
            [self cartCheckOrderAddress:@""];
        };
        [self.controller presentViewController:sign animated:YES completion:nil];

        ///支付新流程
//        sign.guestCheckOutAction = ^{
//            CheckoutStage1VC *vc = [[CheckoutStage1VC alloc] init];
//            [self.controller.navigationController pushViewController:vc animated:true];
//        };
//        CheckoutStage1VC *vc = [[CheckoutStage1VC alloc] init];
//        vc.nextStep = ^{
//            [self buyOperationAddressId:@""];
//        };
//        [self.controller.navigationController pushViewController:vc animated:true];
    } else {
        [OSSVAnalyticsTool appsFlyerTrackEvent:@"af_checkout_login" withValues:nil];

        //购买功能--跳转到订单页面
        [self buyOperationAddressId:@""];
    }
}

- (void)cartCheckOutOrderSuccess:(NSArray *)objs rawData:(NSDictionary *)rawData{
    ///旧流程
    OSSVCheckOutVC *checkOutViewController = [[OSSVCheckOutVC alloc] init];
    checkOutViewController.checkOutModel = objs[1];
    [self.controller.navigationController pushViewController:checkOutViewController animated:YES];
    
    ///新流程
    ///1.判断有没有地址
//    OSSVCartCheckModel *checkoutModel = objs[1];
//    if (checkoutModel.address == nil || checkoutModel.address.addressId.length <= 0) {
//        //进入地址编辑 邮箱隐藏
//        CheckoutStage1VC *vc = [[CheckoutStage1VC alloc] init];
//        [self.controller.navigationController pushViewController:vc animated:true];
//        vc.nextStep = ^{
//            [self buyOperationAddressId:@""];
//        };
//    }else{
//        ///TODO根据配置确定进入新老结算页
//        if(true){
//            CheckoutStage2VC *vc = [[CheckoutStage2VC alloc] init];
//            vc.rawData = rawData;
//            [self.controller.navigationController pushViewController:vc animated:true];
//        }else{
//            OSSVCheckOutVC *checkOutViewController = [[OSSVCheckOutVC alloc] init];
//            checkOutViewController.checkOutModel = objs[1];
//            [self.controller.navigationController pushViewController:checkOutViewController animated:YES];
//        }
//
//    }

    
            
}

- (void)cartCheckOutOrderAnalytic:(BOOL)flag goodsCount:(NSInteger)count{
    
    NSString *goodsCount = [NSString stringWithFormat:@"%li",(long)count];
    NSString *analyticsUUID = [OSSVAnalyticsTool appsAnalyticUUID];
    [OSSVAnalyticsTool sharedManager].analytics_uuid = analyticsUUID;

    NSDictionary *sensorsDic = @{@"total_price_of_goods":STLToString(self.cartModel.cartInfo.total),
                                 @"currency":@"USD",
                                 @"is_success":@(flag),
                                 @"uu_id":analyticsUUID,
                                 @"goods_sn_count":goodsCount,
    };
    [OSSVAnalyticsTool analyticsSensorsEventWithName:@"BeginCheckout" parameters:sensorsDic];
    
    [DotApi checkOutPage];
    
    NSArray *allSelect = [self.cartModel allSelectGoods];
    __block NSMutableArray *itemsGoods = [[NSMutableArray alloc] init];
    __block CGFloat allPrice = 0;
    [allSelect enumerateObjectsUsingBlock:^(CartModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        CGFloat price = [obj.shop_price floatValue];
        if (obj.flash_sale && [obj.flash_sale isCanBuyFlashSaleStateing]) {
            price = [obj.flash_sale.active_price floatValue];
        }
        
        
        //"- normal：普通商品
        //- free：0元购"
        NSString *item_type = @"normal";
        if (!STLIsEmptyString(obj.specialId) && ![obj.specialId isEqualToString:@"0"]) {
            item_type = @"free";
        }
        
        allPrice += obj.goodsNumber * price;
        NSDictionary *items = @{
            kFIRParameterItemID: STLToString(obj.goods_sn),
            kFIRParameterItemName: STLToString(obj.goodsName),
            kFIRParameterItemCategory: STLToString(obj.cat_name),
            kFIRParameterPrice: @(price),
            kFIRParameterQuantity: @(obj.goodsNumber),
            kFIRParameterItemVariant:STLToString(obj.goodsAttr),
            kFIRParameterItemBrand:@"",
        };
        
        [itemsGoods addObject:items];
        
        NSString *analyticsUUID = [OSSVAnalyticsTool sharedManager].analytics_uuid;
        
        NSDictionary *sensorsDic = @{@"goods_sn"        :   STLToString(obj.goods_sn),
                                     @"goods_name"      :   STLToString(obj.goodsName),
                                    @"cat_id"           :   STLToString(obj.cat_id),
                                     @"cat_name"        :   STLToString(obj.cat_name),
                                     @"item_type"       :   item_type,
                                     @"original_price"   :   @([STLToString(obj.marketPrice) floatValue]),
                                     @"present_price"   :   @(price),
                                     @"goods_quantity"        :   @(obj.goodsNumber),
                                     @"goods_size":@"",
                                     @"goods_color":@"",
                                     @"currency":@"USD",
                                     @"is_success":@(flag),
                                     @"uu_id":analyticsUUID,
                                     
        };
        [OSSVAnalyticsTool analyticsSensorsEventWithName:@"BeginCheckoutDetail" parameters:sensorsDic];
    }];
    
    if (flag) {
        //数据GA埋点曝光 去结账按钮 ok
        NSDictionary *itemsDic = @{kFIRParameterItems:itemsGoods,
                                   kFIRParameterCurrency: @"USD",
                                   kFIRParameterValue: @(allPrice),
                                   kFIRParameterCoupon: @"",
                                   @"screen_group":@"Cart",
        };
        
        ///Branch 发起购买
        [OSSVBrancshToolss logInitPurchase:itemsDic];
        
        [OSSVAnalyticsTool analyticsGAEventWithName:kFIREventBeginCheckout parameters:itemsDic];
    }
}

#pragma mark - 未选择商品
- (void)cartCheckOutNOSelectedGoods {
    
    [OSSVAlertsViewNew showAlertWithAlertType:STLAlertTypeButton isVertical:YES messageAlignment:NSTextAlignmentCenter isAr:NO showHeightIndex:0 title:@"" message:STLLocalizedString_(@"selectItem", nil) buttonTitles:APP_TYPE == 3 ? @[STLLocalizedString_(@"ok",nil)] : @[STLLocalizedString_(@"ok",nil).uppercaseString] buttonBlock:^(NSInteger index, NSString * _Nonnull title) {
        
    }];
    
}

#pragma mark 商品全选
- (void)cartCheckOutSelectAll:(BOOL)selected {
    
    NSMutableArray *allGoods = [self.cartModel allValidGoods];
    NSMutableArray *updateAllGoods = [[NSMutableArray alloc] init];
    
    [allGoods enumerateObjectsUsingBlock:^(CartModel * _Nonnull cartModel, NSUInteger idx, BOOL * _Nonnull stop) {

        CartModel *updateModel = [cartModel yy_modelCopy];
        updateModel.isChecked = selected;
        updateModel.stateType = CartGoodsOperateTypeUpdate;
        [updateAllGoods addObject:updateModel];
    }];
    
    @weakify(self)
    [[OSSVCartsOperateManager sharedManager] cartSyncServiceDataGoods:updateAllGoods showView:self.controller.view Completion:^(STLCartModel *obj) {
        @strongify(self)
        [self handleCartModelGoodsHeight:obj];
        [self reloadUI];
    } failure:^(id obj) {
        @strongify(self)
        [self reloadUI];
    }];
}

#pragma mark 商品 加 减 选择 收藏

- (void)cartCheckOutGoodsIncreaseCartModel:(CartModel*)cartModel eventBtn:(UIButton *)sender event:(CartTableCellEvent)event{
    
    CartModel *updateCartModel = [cartModel yy_modelCopy];
    
    updateCartModel.stateType = CartGoodsOperateTypeUpdate;
    
    if(event == CartTableCellEventIncrease) {//增加
        
        if ([cartModel.is_exchange boolValue]) {
            [OSSVAlertsViewNew showAlertWithAlertType:STLAlertTypeButton isVertical:YES messageAlignment:NSTextAlignmentCenter isAr:NO showHeightIndex:0 title:@"" message:STLLocalizedString_(@"Add_Only_One_Item", nil) buttonTitles:APP_TYPE == 3 ? @[STLLocalizedString_(@"ok",nil)] : @[STLLocalizedString_(@"ok",nil).uppercaseString] buttonBlock:^(NSInteger index, NSString * _Nonnull title) {
                
            }];

            return;
        }
        
        updateCartModel.goodsNumber += 1;
        if ([updateCartModel.goodsStock integerValue] > 1000 && updateCartModel.goodsNumber > 1000) {
            updateCartModel.goodsNumber = 1000;
        } else {
            if (updateCartModel.goodsNumber <= [updateCartModel.goodsStock integerValue]) {
                updateCartModel.goodsNumber = updateCartModel.goodsNumber;
            } else {
                updateCartModel.goodsNumber = [updateCartModel.goodsStock integerValue];
                [sender setTitle:@"" forState:UIControlStateNormal];
            }
        }
        
        @weakify(self)
        [[OSSVCartsOperateManager sharedManager] cartSyncServiceDataGoods:@[updateCartModel] showView:self.controller.view Completion:^(STLCartModel *obj) {
            @strongify(self)
            
            float price = [STLToString(updateCartModel.shop_price) floatValue];
            float allPrice = price * updateCartModel.goodsNumber;
            //数据GA埋点曝光 加购事件 ok
            NSDictionary *items = @{
                kFIRParameterItemID: STLToString(updateCartModel.goods_sn),
                kFIRParameterItemName: STLToString(updateCartModel.goodsName),
                kFIRParameterItemCategory: STLToString(updateCartModel.cat_name),
                kFIRParameterPrice: @(price),
                kFIRParameterQuantity: @(updateCartModel.goodsNumber),
                //产品规格
                kFIRParameterItemVariant: STLToString(updateCartModel.goodsAttr),
                kFIRParameterItemBrand: @"",
                kFIRParameterCurrency: @"USD",
                
            };
            
            NSDictionary *itemsDic = @{kFIRParameterItems:@[items],
                                       kFIRParameterCurrency: @"USD",
                                       kFIRParameterValue: @(allPrice),
                                       @"screen_group":[NSString stringWithFormat:@"%@",@"Cart"],
                                       @"position":@"Add_Number",
            };
            
            [OSSVAnalyticsTool analyticsGAEventWithName:kFIREventAddToCart parameters:itemsDic];
            
            [self handleCartModelGoodsHeight:obj];
            [self reloadUI];
        } failure:^(id obj) {
            @strongify(self)
            [self reloadUI];
        }];
        
    } else if(event == CartTableCellEventReduce) {//减少
        
        if (updateCartModel.goodsNumber > 1) {
            updateCartModel.goodsNumber -= 1;
            @weakify(self)
            [[OSSVCartsOperateManager sharedManager] cartSyncServiceDataGoods:@[updateCartModel] showView:self.controller.view Completion:^(STLCartModel *obj) {
                @strongify(self)
                
                float price = [STLToString(updateCartModel.shop_price) floatValue];
                float allPrice = price * updateCartModel.goodsNumber;
                //数据GA埋点曝光 加购事件 ok
                NSDictionary *items = @{
                    kFIRParameterItemID: STLToString(updateCartModel.goods_sn),
                    kFIRParameterItemName: STLToString(updateCartModel.goodsName),
                    kFIRParameterItemCategory: STLToString(updateCartModel.cat_name),
                    kFIRParameterPrice: @(price),
                    kFIRParameterQuantity: @(updateCartModel.goodsNumber),
                    //产品规格
                    kFIRParameterItemVariant: STLToString(updateCartModel.goodsAttr),
                    kFIRParameterItemBrand: @"",
                    kFIRParameterCurrency: @"USD",
                    
                };
                
                NSDictionary *itemsDic = @{kFIRParameterItems:@[items],
                                           kFIRParameterCurrency: @"USD",
                                           kFIRParameterValue: @(allPrice),
                                           @"screen_group":[NSString stringWithFormat:@"%@",@"Cart"],
                                           @"position":@"Mins_Number",
                };
                
                [OSSVAnalyticsTool analyticsGAEventWithName:kFIREventAddToCart parameters:itemsDic];
                
                [self handleCartModelGoodsHeight:obj];
                [self reloadUI];
            } failure:^(id obj) {
                @strongify(self)
                [self reloadUI];
            }];
        }
    } else if(event == CartTableCellEventSelected || event == CartTableCellEventUnSelecte) {
        
        updateCartModel.isChecked = event;
        
        [OSSVAnalyticsTool analyticsGAEventWithName:@"Cart_action" parameters:@{
               @"screen_group":@"Cart",
               @"action":[NSString stringWithFormat:@"%@_%@",STLToString(cartModel.goods_sn),(event ? @"On" : @"Off")]}];
        
        @weakify(self)
        [[OSSVCartsOperateManager sharedManager] cartSyncServiceDataGoods:@[updateCartModel] showView:self.controller.view Completion:^(STLCartModel *obj) {
            @strongify(self)
            [self handleCartModelGoodsHeight:obj];
            [self reloadUI];
            
            
        } failure:^(id obj) {
            @strongify(self)
            [self reloadUI];
        }];
    } else if(event == CartTableCellEventCollect) {
        
        UITableViewCell *cell = [sender viewTableViewCell];
        [self cartCheckGoodsLike:cell resultBlock:nil];
        
        float price = [STLToString(cartModel.shop_price) floatValue];
        // item
        NSMutableDictionary *item = [@{
            kFIRParameterItemID: STLToString(cartModel.goods_sn),
            kFIRParameterItemName: STLToString(cartModel.goodsName),
            kFIRParameterItemCategory: STLToString(cartModel.cat_id),
            kFIRParameterItemVariant: STLToString(cartModel.goodsAttr),
            kFIRParameterItemBrand: @"",
            kFIRParameterPrice: @(price),
        } mutableCopy];
        
        // Prepare item detail params
        NSMutableDictionary *itemDetails = [@{
            kFIRParameterCurrency: @"USD",
            kFIRParameterValue: @(price * cartModel.goodsNumber),
            @"screen_group":@"Cart",
            @"position":@"Move to Wishlist"
        } mutableCopy];
        
        // Add items
        itemDetails[kFIRParameterItems] = @[item];
        
        // Log an event when product is added to wishlist
        [OSSVAnalyticsTool analyticsGAEventWithName:kFIREventAddToWishlist parameters:itemDetails];
        
    } else if(event == CartTableCellEventDelete) {
        
        [self popViewAndDeleteAction:sender];
        
    }
}

#pragma  mark ---用于侧滑删除时候调用
- (void)popViewAndDeleteAction:(UIView *)sender {
    NSArray *upperTitle = @[[STLLocalizedString_(@"move_to_wishlist", nil) uppercaseString],[STLLocalizedString_(@"move_to_remove", nil) uppercaseString]];
    NSArray *lowserTitle = @[STLLocalizedString_(@"move_to_wishlist", nil),STLLocalizedString_(@"move_to_remove", nil)];
    [OSSVAnalyticsTool analyticsGAEventWithName:@"cart_action" parameters:@{
           @"screen_group":@"Cart",
           @"action":@"Delete"}];
    
     @weakify(self)
    [STLAlertBottomView alertBottomShowButtons:APP_TYPE == 3 ? lowserTitle : upperTitle title:STLLocalizedString_(@"move_cart_goods_tip", nil) message:nil operateBlock:^(NSInteger buttonIndex, id buttonTitle) {
        
        @strongify(self)
        UITableViewCell *cell = [sender viewTableViewCell];
        if (buttonIndex == 0) {
            @weakify(self)
            [self cartCheckGoodsLike:cell resultBlock:^(BOOL success) {
                @strongify(self)
                if (success) {
                    [self cartCheckOutDelete:cell];
                }
            }];
            if ([cell isKindOfClass:[OSSVCartBaseGoodsCell class]]) {
                OSSVCartBaseGoodsCell *cartCell = (OSSVCartBaseGoodsCell *)cell;
                CartModel *cartModel = cartCell.cartModel;
                
                float price = [STLToString(cartModel.shop_price) floatValue];
                // item
                NSMutableDictionary *item = [@{
                    kFIRParameterItemID: STLToString(cartModel.goods_sn),
                    kFIRParameterItemName: STLToString(cartModel.goodsName),
                    kFIRParameterItemCategory: STLToString(cartModel.cat_id),
                    kFIRParameterItemVariant: STLToString(cartModel.goodsAttr),
                    kFIRParameterItemBrand: @"",
                    kFIRParameterPrice: @(price),
                } mutableCopy];
                
                // Prepare item detail params
                NSMutableDictionary *itemDetails = [@{
                    kFIRParameterCurrency: @"USD",
                    kFIRParameterValue: @(price * cartModel.goodsNumber),
                    @"screen_group":@"Cart",
                    @"position":@"Move to Wishlist"
                } mutableCopy];
                
                // Add items
                itemDetails[kFIRParameterItems] = @[item];
                
                // Log an event when product is added to wishlist
                [OSSVAnalyticsTool analyticsGAEventWithName:kFIREventRemoveFromCart parameters:itemDetails];

            }
            
            
        } else if (buttonIndex == 1) {
            [self cartCheckOutDelete:cell];
            
            if ([cell isKindOfClass:[OSSVCartBaseGoodsCell class]]) {
                OSSVCartBaseGoodsCell *cartCell = (OSSVCartBaseGoodsCell *)cell;
                CartModel *cartModel = cartCell.cartModel;
                
                float price = [STLToString(cartModel.shop_price) floatValue];
                // item
                NSMutableDictionary *item = [@{
                    kFIRParameterItemID: STLToString(cartModel.goods_sn),
                    kFIRParameterItemName: STLToString(cartModel.goodsName),
                    kFIRParameterItemCategory: STLToString(cartModel.cat_id),
                    kFIRParameterItemVariant: STLToString(cartModel.goodsAttr),
                    kFIRParameterItemBrand: @"",
                    kFIRParameterPrice: @(price),
                } mutableCopy];
                
                // Prepare item detail params
                NSMutableDictionary *itemDetails = [@{
                    kFIRParameterCurrency: @"USD",
                    kFIRParameterValue: @(price * cartModel.goodsNumber),
                    @"screen_group":@"Cart",
                    @"position":@"Remove_Confirm"
                } mutableCopy];
                
                // Add items
                itemDetails[kFIRParameterItems] = @[item];
                
                // Log an event when product is added to wishlist
                [OSSVAnalyticsTool analyticsGAEventWithName:kFIREventRemoveFromCart parameters:itemDetails];

            }
        }
    } cancelBlock:^(id cancelTitle) {
        
    }];
    

}
#pragma mark  删除单个商品
- (void)cartCheckOutDelete:(UITableViewCell *)sender {
    
    
    OSSVCartBaseGoodsCell *cell = (OSSVCartBaseGoodsCell *)sender;
    CartModel *model = cell.cartModel;
    model.stateType = CartGoodsOperateTypeDelete;
    
    @weakify(self)
    [[OSSVCartsOperateManager sharedManager] cartSyncServiceDataGoods:@[model] showView:self.controller.view Completion:^(STLCartModel *obj) {
        @strongify(self)
        [self handleCartModelGoodsHeight:obj];
        [self reloadUI];
        
        [OSSVAnalyticsTool appsFlyerRemoveFromCartWithProduct:model];
        
        
        //GA
        CGFloat price = [model.shop_price floatValue];;
        //0 > 闪购 > 满减
        if (!STLIsEmptyString(model.specialId)) {//0元
            price = [model.shop_price floatValue];

        } else if (STLIsEmptyString(model.specialId) && !STLIsEmptyString(model.flash_sale.active_id) && [model.flash_sale isCanBuyFlashSaleStateing]) {//闪购
            price = [model.flash_sale.active_price floatValue];
        }

        CGFloat allPrice = model.goodsNumber * price;

        NSDictionary *items = @{
            @"item_id": STLToString(model.goods_sn),
            @"item_name": STLToString(model.goodsName),
            @"item_category": STLToString(model.cat_name),
            @"price": @(price),
            @"quantity": @(model.goodsNumber),

        };
        
        NSDictionary *itemsDic = @{@"items":@[items],
                                   @"currency": @"USD",
                                   @"value": @(allPrice),
        };
        
        [OSSVAnalyticsTool analyticsGAEventWithName:@"remove_from_cart" parameters:itemsDic];
        
    } failure:^(id obj) {
        @strongify(self)
        [self reloadUI];
        [self alertMessage:STLLocalizedString_(@"move_cart_goods_fail",nil)];

    }];
}

#pragma mark  清空失效商品
- (void)cartCheckFailureGoodsClear {
    NSArray *upperTitle = @[STLLocalizedString_(@"cancel", nil).uppercaseString,STLLocalizedString_(@"yes", nil).uppercaseString];
    NSArray *lowserTitle = @[STLLocalizedString_(@"cancel", nil),STLLocalizedString_(@"yes", nil)];
    [OSSVAlertsViewNew showAlertWithAlertType:STLAlertTypeButton isVertical:YES messageAlignment:NSTextAlignmentCenter isAr:NO showHeightIndex:1 title:STLLocalizedString_(@"Tip", nil) message:STLLocalizedString_(@"Are_you_sure_to_clear_all_invalid_products?", nil) buttonTitles:APP_TYPE == 3 ? lowserTitle : upperTitle buttonBlock:^(NSInteger index, NSString * _Nonnull title) {
                    if (index == 1) {
                        [self cartCheckFailureGoodsClearing];
                    }
    }];
}

- (void)cartCheckFailureGoodsClearing {
    NSArray *failureGoods = _cartModel.failureGoodsList;
    if (failureGoods) {
        
        [failureGoods enumerateObjectsUsingBlock:^(CartModel * _Nonnull cartModel, NSUInteger idx, BOOL * _Nonnull stop) {
            cartModel.stateType = CartGoodsOperateTypeDelete;
        }];
        
        @weakify(self)
        [[OSSVCartsOperateManager sharedManager] cartSyncServiceDataGoods:failureGoods showView:self.controller.view Completion:^(STLCartModel *obj) {
            @strongify(self)
            [self handleCartModelGoodsHeight:obj];
            [self reloadUI];
            
        } failure:^(id obj) {
            @strongify(self)
            [self reloadUI];
        }];
    }
}

#pragma mark  收藏
- (void)cartCheckGoodsLike:(UITableViewCell *)sender resultBlock:(void(^)(BOOL success))block {
    
    if (!sender) {
        return;
    }
    //    NSIndexPath *indexPath = self.swipeCallback(sender);
    
    OSSVCartBaseGoodsCell *cell = (OSSVCartBaseGoodsCell *)sender;
    CartModel *model = cell.cartModel;
    [self cartGoodsCollect:model cell:sender resultBlock:block];
}

- (void)cartGoodsCollect:(CartModel *)model cell:(UITableViewCell *)cartCell  resultBlock:(void(^)(BOOL success))block {
    
    if (!model) {
        return;
    }
    
    //如果没有登录就弹出登录，否则直接收藏
    if (![OSSVAccountsManager sharedManager].isSignIn) {
        SignViewController *sign = [SignViewController new];
        sign.modalPresentationStyle = UIModalPresentationFullScreen;
        @weakify(self)
        sign.signBlock = ^{
            @strongify(self)
            [self cartGoodsCollect:model cell:cartCell resultBlock:block];
        };
//        sign.closeBlock = ^{
//            @strongify(self)
            //[self reloadUI];
//        };
        [self.controller presentViewController:sign animated:YES completion:nil];
        
    } else {
        
        UITableView *tableView = cartCell.parentTableView;
        NSInteger index = 0;
        if (tableView) {
            NSIndexPath *indexPath = [tableView indexPathForCell:cartCell];
            index = indexPath.row;
        }
        @weakify(self)
        [self requestFavoriteNetwork:@[model.goodsId,model.wid] completion:^(id obj) {
            @strongify(self)
            model.isFavorite = [obj boolValue];
            if (block) {
                [self alertMessage:STLLocalizedString_(@"move_to_wishlist_success",nil)];

            } else {
                [self alertMessage:STLLocalizedString_(@"addedWishlist",nil)];
            }
            [self reloadUI];
            
            // 谷歌统计 收藏
            OSSVDetailsBaseInfoModel *baseInfoModel = [[OSSVDetailsBaseInfoModel alloc] init];
            baseInfoModel.goodsMarketPrice = model.marketPrice;
            baseInfoModel.shop_price = model.goodsPrice;
            baseInfoModel.goods_sn = model.goods_sn;
            baseInfoModel.cat_name = model.cat_name;
            baseInfoModel.goodsTitle = model.goodsName;
            baseInfoModel.specialId = STLToString(model.specialId);
            baseInfoModel.flash_sale = model.flash_sale;
            
            [OSSVAnalyticsTool appsFlyeraAddToWishlistWithProduct:baseInfoModel fromProduct:NO];
            
            
            //GA
            CGFloat price = [baseInfoModel.shop_price floatValue];;
            //0 > 闪购 > 满减
            if (!STLIsEmptyString(baseInfoModel.specialId)) {//0元
                price = [baseInfoModel.shop_price floatValue];

            } else if (STLIsEmptyString(baseInfoModel.specialId) && !STLIsEmptyString(baseInfoModel.flash_sale.active_id) && [model.flash_sale isCanBuyFlashSaleStateing]) {//闪购
                price = [baseInfoModel.flash_sale.active_price floatValue];
            }

            NSDictionary *items = @{
                @"item_id": STLToString(baseInfoModel.goods_sn),
                @"item_name": STLToString(baseInfoModel.goodsTitle),
                @"item_category": STLToString(baseInfoModel.cat_name),
                @"price": @(price),
                @"quantity": @"1",

            };
            
            NSDictionary *itemsDic = @{@"items":@[items],
                                       @"currency": @"USD",
                                       @"value": @(price),
            };
            
            [OSSVAnalyticsTool analyticsGAEventWithName:@"add_to_wishlist" parameters:itemsDic];
            
            NSDictionary *sensorsDic = @{@"goods_sn":STLToString(baseInfoModel.goods_sn),
                                        @"goods_name":STLToString(baseInfoModel.goodsTitle),
                                         @"cat_id":STLToString(baseInfoModel.cat_id),
                                         @"cat_name":STLToString(baseInfoModel.cat_name),
                                         @"original_price":@([STLToString(baseInfoModel.market_price) floatValue]),
                                         @"present_price":@(price),
                                         @"entrance":@"collect_quick",
                                         @"position_number":@(index+1)
                    };
            [OSSVAnalyticsTool analyticsSensorsEventWithName:@"GoodsCollect" parameters:sensorsDic];
            
            //收藏成功后，再从购物车移除
            [self cartCheckOutDelete:cartCell];

            if (block) {
                block(YES);
            }
            
        } failure:^(id obj) {
            @strongify(self)
            [self reloadUI];
            if (block) {
                [self alertMessage:STLLocalizedString_(@"move_to_wishlist_fail",nil)];
                block(NO);
            } else {
                //应该提示添加失败
            }
        }];
    }
}

#pragma mark  此商品已下架
- (void)cartCheckOutShelvesed:(NSArray *)objs table:(UITableView *)tableView {
    [self reloadUI];
}

#pragma mark  没有地址
- (void)CartCheckOutNoAddress:(NSArray *)objs table:(UITableView *)tableView {
    
    OSSVEditAddressVC *newAddress = [OSSVEditAddressVC new];
//    newAddress.isPresentVC = YES;
    newAddress.getAddressModelBlock = ^(OSSVAddresseBookeModel *addressModel){
        STLLog(@"test model name == %@",addressModel.lastName);
        //选择地址后,重新执行该方法
        [self buyOperationAddressId:@""];
    };
    OSSVNavigationVC *nav = [[OSSVNavigationVC alloc] initWithRootViewController:newAddress];
    [self.controller presentViewController:nav animated:YES completion:nil];
}

#pragma mark  商品详情
- (void)cartCheckGoodsDetail:(UITableViewCell *)indexCell {
    
    OSSVCartBaseGoodsCell *cell = (OSSVCartBaseGoodsCell *)indexCell;
    
    CartModel *cartModel = cell.cartModel;
    OSSVDetailsVC *detailsVC = [OSSVDetailsVC new];
    detailsVC.goodsId = cartModel.goodsId;
    detailsVC.wid = cartModel.wid;
    detailsVC.sourceType = STLAppsflyerGoodsSourceCart;
    detailsVC.specialId = cartModel.specialId;
    detailsVC.coverImageUrl = STLToString(cartModel.goodsThumb);
    [self.controller.navigationController pushViewController:detailsVC animated:YES];
    
    [OSSVAnalyticsTool analyticsGAEventWithName:@"view_product_detail" parameters:@{
           @"screen_group":@"Cart",
           @"action":[NSString stringWithFormat:@"Check_%@",STLToString(cartModel.goodsName)]}];
}

#pragma mark  满减活动跳转
- (void)goShopActivity:(ActivityInfoModel *)inforModel {
    
    [OSSVAnalyticsTool analyticsGAEventWithName:@"promotion_entrance" parameters:@{
           @"screen_group":@"Cart",
           @"action":[NSString stringWithFormat:@"Promotion_%@",STLToString(inforModel.activeName)]}];
    
    //新增判断， 活动ID > 0 时候做跳转
    if (inforModel.activeId.intValue > 0) {
        OSSVAdvsEventsModel *advEventModel = [[OSSVAdvsEventsModel alloc] init];
        advEventModel.actionType =  AdvEventTypeNativeCustom;
        advEventModel.url = STLToString(inforModel.activeId);
        advEventModel.name = STLToString(inforModel.activeName);
        [OSSVAdvsEventsManager advEventTarget:self.controller withEventModel:advEventModel];
        
    }
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.cartModel.groupList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.cartModel.groupList.count > section) {
        STLCartGroupModel *groupData = self.cartModel.groupList[section];
        
        //普通商品 //失效商品 //同类推荐 //新人免费
        if (groupData.type == CartGroupModelTypeNormal
            || groupData.type == CartGroupModelTypeFailure
            || groupData.type == CartGroupModelTypeRecommend
//            || groupData.type == CartGroupModelTypeFree
            ) {
            
            NSArray *groupDatas = (NSArray *)groupData.data;
            return groupDatas.count;
            
        } else if(groupData.type == CartGroupModelTypeActivity) {//满减活动
            
            STLCatrActivityModel *activityModel = (STLCatrActivityModel *)groupData.data;
            return activityModel.goodsList.count;
            
        } else if(groupData.type == CartGroupModelTypeEmpty) {// 空视图
            return 1;
        }
    }
    
    return 0;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return self.cartModel.groupList.count > section ? 16 : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.cartModel.groupList.count > section) {
        STLCartGroupModel *groupData = self.cartModel.groupList[section];
        
        if(groupData.type == CartGroupModelTypeActivity) {//满减活动
            STLCatrActivityModel *activityModel = (STLCatrActivityModel *)groupData.data;
            if (activityModel.activityInfo && activityModel.activityInfo.headerHeight > 0) {
                return  activityModel.activityInfo.headerHeight;
            }
        } else if(groupData.type == CartGroupModelTypeRecommend) {
            return 54;
        } else if (groupData.type == CartGroupModelTypeNormal) {
            return 10;
        }
    }
    return 48;
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    OSSVCartFooterView *footerView = [[OSSVCartFooterView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.bounds), 16)];
    footerView.backgroundColor = OSSVThemesColors.col_F7F7F7;
    return footerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (self.cartModel.groupList.count > section) {
        STLCartGroupModel *groupData = self.cartModel.groupList[section];
        
        if (groupData.type == CartGroupModelTypeNormal) {

            return [OSSVCartTableOtherHeaderView cartHeaderViewWithTableView:tableView];
            
        }
//        else if(groupData.type == CartGroupModelTypeFree) {
//
//            OSSVCartHeaderView *headerView = [OSSVCartHeaderView cartHeaderViewWithTableView:tableView];
//            [headerView updateInfoModel:nil freeGift:YES];
//            return headerView;
//
//        }
        else if(groupData.type == CartGroupModelTypeFailure) {
            
            OSSVCartTableInvalidHeaderView *inValidHeaderView = [OSSVCartTableInvalidHeaderView cartHeaderViewWithTableView:tableView];
            @weakify(self)
            inValidHeaderView.operateBlock = ^{
                @strongify(self)
                [self cartCheckFailureGoodsClear];
            };
            return inValidHeaderView;
            
        } else if(groupData.type == CartGroupModelTypeActivity) {//满减活动
            
            STLCatrActivityModel *activityModel = (STLCatrActivityModel *)groupData.data;
            OSSVCartHeaderView *headerView = [OSSVCartHeaderView cartHeaderViewWithTableView:tableView];
            
            [headerView updateInfoModel:activityModel.activityInfo freeGift:NO];
                @weakify(self)
                headerView.operateBlock = ^(ActivityInfoModel *infoModel) {
                    @strongify(self)
                    [self goShopActivity:infoModel];
                };
            return headerView;
            
        } else if(groupData.type == CartGroupModelTypeRecommend) {
            
            OSSVCartTableMayLikeHeaderView *likeHeaderView = [OSSVCartTableMayLikeHeaderView cartHeaderViewWithTableView:tableView];
            CartLikeGoodsTitleModel *titleModel = (CartLikeGoodsTitleModel *)groupData.titleModel;
            [likeHeaderView updateImage:STLToString(titleModel.titleImage) title:STLToString(titleModel.titleName)];
            return likeHeaderView;
        }
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.cartModel.groupList.count > indexPath.section) {
        
        STLCartGroupModel *groupData = self.cartModel.groupList[indexPath.section];
        if (groupData.type == CartGroupModelTypeNormal
//            || groupData.type == CartGroupModelTypeFree
            ) {
            NSArray *otherGoodsList = (NSArray *)groupData.data;
            CartModel *cartModel = otherGoodsList[indexPath.row];
            if (otherGoodsList.count) {
                if (indexPath.row == 0) {
                    cartModel.isFirstRow = YES;
                } else {
                    cartModel.isFirstRow = NO;
                }
            }
            //有效商品
            OSSVCartCell *cell = [OSSVCartCell cartCellWithTableView:tableView andIndexPath:indexPath];
//            [cell updateCartModel:cartModel freeGift:(groupData.type == CartGroupModelTypeFree ? YES : NO )];
            [cell updateCartModel:cartModel freeGift:NO];
            cell.lineView.hidden = indexPath.row == (otherGoodsList.count - 1) ? YES : NO;
            cell.delegate = self;
            cell.sourceType = groupData.type;
            
            @weakify(self)
            cell.operateBlock = ^(UIButton *sender, CartTableCellEvent event) {
                @strongify(self)
                [self cartCheckOutGoodsIncreaseCartModel:cartModel eventBtn:sender event:event];
            };
            
            return cell;
            
        } else if(groupData.type == CartGroupModelTypeFailure) {//无效商品
            
            NSArray *failureGoodsList = (NSArray *)groupData.data;
            CartModel *cartModel = failureGoodsList[indexPath.row];
            OSSVCartInvalidTableCell *cell = [OSSVCartInvalidTableCell cellTableInvalidWithTableView:tableView andIndexPath:indexPath];
            cell.cartModel = cartModel;
            cell.delegate = self;
            cell.lineView.hidden = indexPath.row == (failureGoodsList.count - 1) ? YES : NO;
            cell.sourceType = groupData.type;
            @weakify(self)
            cell.operateBlock = ^(UIButton *sender, CartTableCellEvent event) {
                @strongify(self)
                [self cartCheckOutGoodsIncreaseCartModel:cartModel eventBtn:sender event:event];
            };
            
            return cell;
            
        } else if(groupData.type == CartGroupModelTypeActivity) {//满减活动
            
            STLCatrActivityModel *activityModel = (STLCatrActivityModel *)groupData.data;
            CartModel *cartModel = activityModel.goodsList[indexPath.row];
            
            //有效商品
            OSSVCartCell *cell = [OSSVCartCell cartCellWithTableView:tableView andIndexPath:indexPath];
            cell.delegate = self;
            [cell updateCartModel:cartModel isFullActive:activityModel.activityInfo.is_full_active];
            cell.lineView.hidden = indexPath.row == (activityModel.goodsList.count - 1) ? YES : NO;
            cell.sourceType = groupData.type;
            cell.markePriceLabel.hidden = NO;
            @weakify(self)
            cell.operateBlock = ^(UIButton *sender, CartTableCellEvent event) {
                @strongify(self)
                [self cartCheckOutGoodsIncreaseCartModel:cartModel eventBtn:sender event:event];
            };
            
            return cell;
            
        } else if(groupData.type == CartGroupModelTypeRecommend) {
            
            OSSVCartLikeTableCell *cell = [OSSVCartLikeTableCell cellCartLikeTableWithTableView:tableView andIndexPath:indexPath];
            NSArray *likeGoodsArray = (NSArray *)groupData.data;
            cell.datasArray = likeGoodsArray[indexPath.row];
            cell.sourceType = groupData.type;

            return cell;
            
        } else if(groupData.type == CartGroupModelTypeEmpty) {
            
            OSSVCartEmptyTableCell *emptyCell = [OSSVCartEmptyTableCell cellCartEmptyTableWithTableView:tableView andIndexPath:indexPath];
            @weakify(self)
            emptyCell.noDataBlock = ^{
                @strongify(self)
                [self emptyJumpOperationTouch];
            };
            return emptyCell;
        }
    }
    
    return [UITableViewCell new];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    STLCartGroupModel *groupData = self.cartModel.groupList[indexPath.section];
    if (groupData.type == CartGroupModelTypeRecommend) {
        return;
    }
    [self cartCheckGoodsDetail:[tableView cellForRowAtIndexPath:indexPath]];
}

#pragma mark - Swipe Delegate

-(BOOL)swipeTableCell:(MGSwipeTableCell*)cell canSwipe:(MGSwipeDirection) direction {
    return YES;
}

-(NSArray*)swipeTableCell:(MGSwipeTableCell*) cell swipeButtonsForDirection:(MGSwipeDirection)direction
            swipeSettings:(MGSwipeSettings*) swipeSettings expansionSettings:(MGSwipeExpansionSettings*) expansionSettings {

    swipeSettings.transition = MGSwipeTransitionClipCenter;
    //    expansionSettings.buttonIndex = 1;//这里设置当拖拽过头，如个按钮在整个cell中显示

    if (direction == [OSSVSystemsConfigsUtils isRightToLeftShow] ? MGSwipeDirectionLeftToRight : MGSwipeDirectionRightToLeft)  {

        expansionSettings.fillOnTrigger = YES;
        expansionSettings.threshold = 1.1;


        //-------------------删除
        @weakify(self)
        MGSwipeButton * delete = [MGSwipeButton buttonWithTitle:STLLocalizedString_(@"delete",nil) backgroundColor:OSSVThemesColors.col_B62B21 callback:^BOOL(MGSwipeTableCell *sender) {
            @strongify(self)
//            [self cartCheckOutDelete:sender];
            [self popViewAndDeleteAction:sender];
            return YES;
        }];
        [delete setTitleColor:OSSVThemesColors.col_FFFFFF forState:UIControlStateNormal];
        delete.titleLabel.font = [UIFont systemFontOfSize:15];
        delete.buttonWidth = 75 * DSCREEN_HEIGHT_SCALE;

        //-------------------收藏
//
//        OSSVCartBaseGoodsCell *goodsCell = (OSSVCartBaseGoodsCell *)cell;
//        CartModel *cartModel = goodsCell.cartModel;
//        //是否已收藏
//        UIColor *wishTitleColor = cartModel.isFavorite ? OSSVThemesColors.col_999999 : OSSVThemesColors.col_333333;
//
//        MGSwipeButton * wish = [MGSwipeButton buttonWithTitle:STLLocalizedString_(@"addToWish",nil) backgroundColor:wishBackColor callback:^BOOL(MGSwipeTableCell *sender) {
//            @strongify(self)
//            if (!cartModel.isFavorite) {
//                [self  cartCheckGoodsLike:sender resultBlock:nil];
//            }
//            return YES;
//        }];
//        [wish setTitleColor:wishTitleColor forState:UIControlStateNormal];
//        wish.titleLabel.font = [UIFont systemFontOfSize:14];
//        wish.buttonWidth = 75 * DSCREEN_HEIGHT_SCALE;

        return @[delete];

//        return @[delete,wish];
    }
    return nil;
}

-(void)swipeTableCell:(MGSwipeTableCell*)cell didChangeSwipeState:(MGSwipeState)state gestureIsActive:(BOOL)gestureIsActive {

    if (state == MGSwipeStateSwippingRightToLeft){
    }
}

#pragma mark
#pragma mark - OSSVCartBottomResultViewDelegate

- (void)cartBottomResultView:(OSSVCartBottomResultView *)cartResultView selectAll:(BOOL)select {
    [self cartCheckOutSelectAll:select];
}

- (void)cartBottomResultView:(OSSVCartBottomResultView *)cartResultView eventBuy:(BOOL)buy {
    [self cartCheckOutBuy];
}


#pragma mark - 解析数据
- (id)dataAnalysisFromJson:(id)json request:(OSSVBasesRequests *)request{
    if ([request isKindOfClass:[OSSVAddCollectApi class]]) {
        //进行数据处理
        if ([json[kStatusCode] integerValue] == kStatusCode_200) {
            //进行数据解析
            return @(YES);
        } else {
            dispatch_after( DISPATCH_TIME_NOW + 0.5, dispatch_get_main_queue(), ^{
                [self alertMessage:json[@"message"]];
            });
            return @(NO);
        }
    } else if ([request isKindOfClass:[OSSVCartCheckAip class]]) {
        //进行数据处理
        [HUDManager hiddenHUD];
        if ([json[kStatusCode] integerValue] == kStatusCode_200) {
            //进行数据解析
            if ([json[@"flag"] integerValue] == CartCheckOutResultEnumTypeSuccess) {
                OSSVCartCheckModel *checkModel = [OSSVCartCheckModel yy_modelWithJSON:json[kResult]];
                return @[@(CartCheckOutResultEnumTypeSuccess),checkModel];
            }else if ([json[@"flag"] integerValue] == CartCheckOutResultEnumTypeNoAddress) {
                return @[@(CartCheckOutResultEnumTypeNoAddress),json[@"message"]];
            } else if ([json[@"flag"] integerValue] == CartCheckOutResultEnumTypeNoGoods) {
                return @[@(CartCheckOutResultEnumTypeNoGoods),json[@"message"]];
            }else if ([json[@"flag"] integerValue] == CartCheckOutResultEnumTypeNoShipping) {
                return @[@(CartCheckOutResultEnumTypeNoShipping),json[@"message"]];
            }else if ([json[@"flag"] integerValue] == CartCheckOutResultEnumTypeNoPayment) {
                return @[@(CartCheckOutResultEnumTypeNoPayment),json[@"message"]];
            }else if ([json[@"flag"] integerValue] == CartCheckOutResultEnumTypeShelvesed) {
                return @[@(CartCheckOutResultEnumTypeShelvesed),json[@"message"],json[kResult]];
            }else if ([json[@"flag"] integerValue] == CartCheckOutResultEnumTypeNoStock) {
                return @[@(CartCheckOutResultEnumTypeNoStock),json[@"message"]];
            }else if ([json[@"flag"] integerValue] == CartCheckOutResultEnumTypeNoSupportPayment) {
                return @[@(CartCheckOutResultEnumTypeNoSupportPayment),json[@"message"]];
            }
        } else if([json[kStatusCode] integerValue] == kStatusCode_205) {
            
            [OSSVAlertsViewNew showAlertWithAlertType:STLAlertTypeButton isVertical:YES messageAlignment:NSTextAlignmentCenter isAr:NO showHeightIndex:0 title:@"" message:json[@"message"] buttonTitles:APP_TYPE == 3 ? @[STLLocalizedString_(@"ok",nil)] : @[STLLocalizedString_(@"ok",nil).uppercaseString] buttonBlock:^(NSInteger index, NSString * _Nonnull title) {
                
            }];
            return @(NO);
        }
        else {
            [self alertMessage:json[@"message"]];
            return @(NO);
        }
    }
    return nil;
}

- (STLCartAnalyticsAOP *)cartListAnalyticsManager {
    if (!_cartListAnalyticsManager) {
        _cartListAnalyticsManager = [[STLCartAnalyticsAOP alloc] init];
        _cartListAnalyticsManager.source = STLAppsflyerGoodsSourceCart;
    }
    return _cartListAnalyticsManager;
}
@end
