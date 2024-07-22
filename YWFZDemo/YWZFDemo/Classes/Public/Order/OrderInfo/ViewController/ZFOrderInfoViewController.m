
//
//  ZFOrderInfoViewController.m
//  ZZZZZ
//
//  Created by YW on 13/10/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFOrderInfoViewController.h"
#import "ZFOrderCell.h"
#import "ZFOrderPlaceBottomView.h"

#import "ZFWebViewViewController.h"
#import "CartInfoGoodsViewController.h"
#import "ZFAddressViewController.h"
#import "ZFOrderSuccessViewController.h"
#import "ZFOrderFailureViewController.h"
#import "BoletoFinishedViewController.h"
#import "ZFSelectShippingViewController.h"
#import "ZFOrderDetailViewController.h"
#import "ZFOfflineOrderSuccessViewController.h"
#import "ZFMyOrderListViewController.h"
#import "ZFCartViewController.h"
#import "ZFMyCouponViewController.h"

#import "ZFOrderManager.h"
#import "FilterManager.h"
#import "ZFOrderInformationViewModel.h"
#import "ZFOrderCheckInfoModel.h"
#import "ZFOrderCheckDoneModel.h"

#import "ZFOrderPayTools.h"
#import "ZFOrderInfoAnalyticsAOP.h"

#import "UINavigationController+FDFullscreenPopGesture.h"
#import <GGPaySDK/GGPaySDK.h>
#import "ZFThemeManager.h"
#import "NSStringUtils.h"
#import "ZFProgressHUD.h"
#import "ZFLocalizationString.h"
#import "ZFFireBaseAnalytics.h"
#import "ZFAnalyticsTimeManager.h"
#import "ZFGrowingIOAnalytics.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "YSAlertView.h"
#import "Masonry.h"
#import "ZFOrderCommitProgressView.h"
#import "ZFCommonRequestManager.h"
#import "ZFBTSManager.h"
#import "ZFOrderQuestionViewController.h"
#import "ZFCODVIPViewController.h"
#import "ZFLangugeSettingViewController.h"
#import "ZFAddressEditViewController.h"
#import "ZFOrderPayResultHandler.h"
#import "UIView+ZFViewCategorySet.h"

@interface ZFOrderInfoViewController ()
<
    ZFInitViewProtocol,
    UITableViewDelegate,
    UITableViewDataSource,
    ZFOrderPlaceBottomViewDelegate,
    ZFOrderCommitProgressViewDelegate,
    ZFOrderQuestionViewControllerDelegate,
    ZFPCCNumInputCellDelegate
>
@property (nonatomic,strong) UITableView                    *tableView;
@property (nonatomic,strong) NSMutableArray                 *sectionArray;
@property (nonatomic,strong) NSMutableArray                 *amountDetailModelArray;
@property (nonatomic,strong) ZFOrderInformationViewModel    *viewModel;
@property (nonatomic,strong) ZFOrderPlaceBottomView         *orderPlaceBottomView;
@property (nonatomic,assign) BOOL                           isBackToCart;
@property (nonatomic,assign) BOOL                           isCancelPlaceOrder;
//当前选择的物流方式
@property (nonatomic,strong) ShippingListModel              *currentShippingListModel;
//当前选择的支付方式
@property (nonatomic,strong) PaymentListModel               *currentPaymentListModel;
//支付集合工具
@property (nonatomic,strong) ZFOrderPayTools                *payTools;
//统计AOP
@property (nonatomic,strong) ZFOrderInfoAnalyticsAOP        *analyticsAop;
@property (nonatomic,strong) ZFOrderCheckDoneDetailModel    *checkDoneDetailModel;

///AB测试显示风格 0,1,2 v490使用原始版本0作为最终版本 by 陈佳佳 https://docs.google.com/spreadsheets/d/16xak7yTT0jinXTAAyZyC-14nbAmtwiqyE15ACuWyA3M/edit#gid=0
//@property (nonatomic, assign) NSInteger                     orderInfoABTestShow;
@property (nonatomic, weak) ZFPCCNumInputCell              *pccCell;

@property (nonatomic, strong) VerificationView              *codVerCodeView;
@end

@implementation ZFOrderInfoViewController
#pragma mark - Life Cycle

- (void)dealloc {
    HideLoadingFromView(nil);
    
    // V5.0.0标记从一键(快速)购买过来时,需要清除购物车选择主动记住的全局优惠券标识
    if (self.detailFastBuyInfo) {
        [AccountManager clearUserSelectedCoupon];
    }
    
    if (_codVerCodeView) {
        [self.codVerCodeView stopTimer];
    }
}

- (instancetype)init {
    if (self = [super init]) {
        // 配置A/B 测试
        [self.manager configureABTest];
        [[AnalyticsInjectManager shareInstance] analyticsInject:self injectObject:self.analyticsAop];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self zfInitView];
    [self zfAutoLayoutView];
}

- (void)refreshOrderAddress:(ZFAddressInfoModel *)model {
    
    if (model.is_default) {
        
    }
    
    NSString *tempAddressId = [self.manager.addressId copy];
    if ([NSStringUtils isEmptyString:[FilterManager isSupportCOD:self.manager.countryID]] != [NSStringUtils isEmptyString:[FilterManager isSupportCOD:model.country_id]]) {
        self.manager.paymentCode = @"";
        self.manager.shippingId = @"";
    }
    self.manager.addressId = model.address_id;
    self.manager.countryID = model.country_id;
    [self.manager configureABTest];
    // 购物车 ==> 1老流程 ==> 界面1 ==>  切换地址 ==> 1老流程 ==> 刷新本页面数据
    @weakify(self)
    [self reloadDataWhenChangeNewAddressCompletion:nil failure:^{
        @strongify(self);
        self.manager.addressId = tempAddressId;
    }];
}
#pragma mark - Setter
-(void)setCheckOutModel:(ZFOrderCheckInfoDetailModel *)checkOutModel {
    
    if ([checkOutModel.taxVerify.is_pcc isEqualToString:@"1"]) {
        [checkOutModel.taxVerify handleHtml];
    }
    
    if (!_checkOutModel) {
        // 默认勾选物流保险费用
        checkOutModel.ifNeedInsurance = self.manager.isSelectInsurance;
    } else {
        checkOutModel.ifNeedInsurance = _checkOutModel.ifNeedInsurance;
    }
    
    self.analyticsAop.checkOutModel = checkOutModel;
    
    _checkOutModel = checkOutModel;
    
    // 适配上传参数模型
    [self.manager adapterManagerWithModel:checkOutModel];
    // 改变下单按钮颜色
    [self changePlaceOrderButtonState];
    // 配置cell个数
    [self configureTableViewCell];
    // 配置(支付/物流)默认选择方式
    [self adapterDefaultSelected];
    
    [self.tableView reloadData];
}

#pragma mark - bottomView delegate

///点击支付按钮
-(void)ZFOrderPlaceBottomViewDidClickPlaceOrderButton
{
    if (self.isCancelPlaceOrder) {
        return;
    }
    [self jumpToPayment];
}

#pragma mark - progress delegate 弹出安全检查视图回调，从这里发起支付

//AB测试弹出安全检查回调
-(void)ZFOrderCommitProgressViewShowProgressView
{
    [self createOrderSuccess:nil failure:nil];
}

//AB测试不弹出安全检查回调
- (void)ZFOrderCommitProgressViewNoShow
{
    ShowLoadingToView(nil);
    [self createOrderSuccess:nil failure:nil];
}

#pragma mark - questionViewController delegate

//跳转订单详情页
-(void)ZFOrderQuestionViewControllerDidClickBackToOrders
{
    [self jumpToMyOrderListViewController:PaymentStatusCancel orderModel:self.checkDoneDetailModel payResult:nil];
}

//跳转首页
-(void)ZFOrderQuestionViewControllerDidClickGontinueShopping
{
    [self.navigationController popToRootViewControllerAnimated:NO];
    ZFTabBarController *tabBarVC = APPDELEGATE.tabBarVC;
    [tabBarVC setZFTabBarIndex:TabBarIndexHome];
}

#pragma mark - cell delegate

- (void)ZFPCCNumInputCellDidEndEditPccNum:(NSString *)value cell:(nonnull UITableViewCell *)cell
{
    self.manager.pccNum = value;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (indexPath) {
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - Private Method

- (void)configureTableViewCell {
    [self.sectionArray removeAllObjects];
    self.pccCell = nil;
    [self.sectionArray addObject:@[[ZFOrderAddressCell class]]];
    
    if ([self.checkOutModel.taxVerify.is_pcc isEqualToString:@"1"]) {
        //韩国、巴西才添加这个视图
        [self.sectionArray addObject:@[[ZFPCCNumInputCell class]]];
    }
    [self handlePaymentCell];
    [self handleShippingCell];
    [self.sectionArray addObject:@[[ZFOrderInsuranceCell class]]];
    
    [self.sectionArray addObject:@[[ZFOrderCouponCell class]]];
    if (self.checkOutModel.point.use_point_max.floatValue > 0) {
        [self.sectionArray addObject:@[[ZFOrderPointsV457Cell class]]];
    }
    
    [self.sectionArray addObject:@[[ZFOrderGoodsCell class]]];

    [self configureAmountDetailCell:self.sectionArray];
    // 使用积分则不显示返积分提示
    if (!self.manager.isUsePoint) {
        [self.sectionArray addObject:@[[ZFOrderRewardPointsCell class]]];
    }
    // 新用户首单送coupon实验
    if ([ZFToString(self.checkOutModel.first_order_bts_result.policy) isEqualToString:@"1"]) {
        [self.sectionArray addObject:@[[ZFOrderRewardCouponCell class]]];
    }
    
    [self.sectionArray addObject:@[[ZFOrderBottomTipsCell class]]];
    [self setPlaceOrderButtonParams];
}

///处理支付方式cell
- (void)handlePaymentCell
{
    Class paymentCell = [ZFOrderPaymentListCell class];
    NSArray *dataArray = self.checkOutModel.payment_list;
    NSMutableArray *cellArray = [NSMutableArray arrayWithCapacity:dataArray.count];
    PaymentListModel *oldPaymentModel = self.currentPaymentListModel;
    self.currentPaymentListModel = nil;
    self.manager.paymentCode = nil;
    self.manager.codFreight = @"0.00";
//    [FilterManager saveTempCOD:NO];
    self.manager.currentPaymentType = CurrentPaymentTypeUnSelect;
    //支付方式筛选
    for (int i = 0; i < [dataArray count]; i++) {
        PaymentListModel *model = dataArray[i];
        if (![model isKindOfClass:[PaymentListModel class]]) {
            break;
        }
        //已经选择过支付方式
        if (oldPaymentModel) {
            //后台返回的数据中也有已选择的支付方式
            if (![model.pay_id isEqualToString:oldPaymentModel.pay_id]) {
                continue;
            }
            //如果是COD支付
            if ([oldPaymentModel isCodePayment]) {
                BOOL isSupporCod = [self.manager isShowCODGoodsAmountLimit:oldPaymentModel.pay_code checkoutModel:self.checkOutModel];
                //支持COD，继续选择
                if (!isSupporCod) {
                    [dataArray setValue:@"0" forKeyPath:@"default_select"];
                    model.default_select = @"1";
                    self.currentPaymentListModel = model;
                    [self reloadManagerCodParam:model];
                    break;
                }
            }else{
                //不是COD，继续选择当前
                [dataArray setValue:@"0" forKeyPath:@"default_select"];
                model.default_select = @"1";
                self.currentPaymentListModel = model;
                [self reloadManagerCodParam:model];
                break;
            }
        }else{
            if (model.default_select.integerValue == 1) {
                self.currentPaymentListModel = model;
                [self reloadManagerCodParam:model];
                break;
            }
        }
    }
    
    if (self.currentPaymentListModel == nil) {
        //如果找了一遍都没有的话，就是使用后台传来的默认 "default_select"
        [dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            PaymentListModel *model = dataArray[idx];
            if (model.default_select.integerValue) {
                self.currentPaymentListModel = model;
                [self reloadManagerCodParam:model];
                *stop = YES;
            }
        }];
    }

    [dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PaymentListModel *model = dataArray[idx];
        if ([model isCodePayment]) {
            NSString *codFee = [FilterManager adapterCodWithAmount:self.checkOutModel.cod.codFee andCod:self.manager.currentPaymentType == CurrentPaymentTypeCOD priceType:PriceType_ShippingCost];
            model.pay_shuoming = [model.pay_shuoming stringByReplacingOccurrencesOfString:self.manager.codReplaceHold withString:codFee];
            self.manager.codReplaceHold = codFee;
        }
        [cellArray addObject:paymentCell];
    }];
    
    if (self.manager.currentPaymentType == CurrentPaymentTypeUnSelect && [cellArray count] == 1) {
        PaymentListModel *model = [dataArray firstObject];
        if ([model isOnlinePayment]) {
            self.manager.currentPaymentType = CurrentPaymentTypeOnline;
        } else {
            self.manager.currentPaymentType = CurrentPaymentTypeCOD;
        }
    }

    if ([cellArray count]) {
        [self.sectionArray addObject:[cellArray copy]];
    }else{
        [self.sectionArray addObject:@[[ZFOrderNoPaymentCell class]]];
    }
}

- (void)reloadManagerCodParam:(PaymentListModel *)model
{
    self.manager.currentPaymentType = [model isCodePayment] ? CurrentPaymentTypeCOD : CurrentPaymentTypeOnline;
    self.manager.paymentCode    = model.pay_code;
    self.manager.codFreight     = [model isCodePayment] ? self.checkOutModel.cod.codFee : @"0.00";
}

///处理物流方式cell
- (void)handleShippingCell
{
    Class shippingCell = [ZFOrderShippingV390Cell class];
    NSArray *dataArray = self.manager.shippingListArray;
    NSMutableArray *cellArray = [NSMutableArray arrayWithCapacity:dataArray.count];
    ShippingListModel *oldShippingModel = self.currentShippingListModel;
    ///视图显示使用的是这个模型
    self.currentShippingListModel = nil;

    [dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ///物流筛选
        if ([obj isKindOfClass:[ShippingListModel class]]) {
            ShippingListModel *shppingModel = obj;
            if ([cellArray count]) {
                ///只需要显示一个视图
                return;
            }
            if (self.manager.currentPaymentType == CurrentPaymentTypeCOD) {
                ///如果是COD， 选择COD物流
                if (shppingModel.is_cod_ship.integerValue == 1) {
                    self.currentShippingListModel = shppingModel;
                    [cellArray addObject:shippingCell];
                }
            }else if(self.manager.currentPaymentType == CurrentPaymentTypeOnline){
                ///非COD时，当前选择物流为COD物流时，重新选择物流 (需要排除COD物流)
                if (oldShippingModel.is_cod_ship.integerValue) {
                    if (shppingModel.default_select.integerValue == 1 && !shppingModel.is_cod_ship.integerValue) {
                        self.currentShippingListModel = shppingModel;
                        [cellArray addObject:shippingCell];
                    }
                }
                if (!oldShippingModel) {
                    ///self.currentShippingListModel 为nil 时，选择一个默认物流
                    if (shppingModel.default_select.integerValue == 1 && !shppingModel.is_cod_ship.integerValue) {
                        self.currentShippingListModel = shppingModel;
                        [cellArray addObject:shippingCell];
                    }
                }else{
                    if ([oldShippingModel.iD isEqualToString:shppingModel.iD] && !shppingModel.is_cod_ship.integerValue) {
                        ///匹配当前选中的物流，重新获取价格
                        self.currentShippingListModel = shppingModel;
                        [cellArray addObject:shippingCell];
                    }
                }
            }
        }
    }];
    if (!self.currentShippingListModel) {
        ///遍历了一个圈都没有找到的话，为了防止后台返回错误，默认选择第一个物流
        if (ZFJudgeNSArray(dataArray) && [dataArray count])  {
            NSInteger isCodShip = 1;
            if (self.manager.currentPaymentType == CurrentPaymentTypeCOD) {
                isCodShip = 0;
            }
            NSInteger index = 0;
            do {
                ShippingListModel *model = dataArray[index];
                self.currentShippingListModel = model;
                index++;
                //寻找一个适合当前支付方式的物流
            } while (self.currentShippingListModel.is_cod_ship.integerValue == isCodShip && index < dataArray.count);
            [cellArray addObject:shippingCell];
        }
    }
    if ([cellArray count]) {
        self.manager.shippingPrice = self.currentShippingListModel.ship_price;
        self.manager.shippingId = self.currentShippingListModel.iD;
        [self.sectionArray addObject:[cellArray copy]];
    }else{
        [self.sectionArray addObject:@[[ZFOrderNoShippingCell class]]];
    }
}

- (void)configureAmountDetailCell:(NSMutableArray *)sectionArray {
    @weakify(self)
    [self.manager queryAmountDetailArray:^(NSArray *amountDetailModelArray, NSArray *detailCellList) {
        @strongify(self)
        [self.amountDetailModelArray removeAllObjects];
        self.amountDetailModelArray = [amountDetailModelArray mutableCopy];
        [sectionArray addObject:detailCellList];
    }];
}

- (void)adapterDefaultSelected {
    ///当只有一个支付方式的时候，去掉黑色的选择按钮，换成支付方式对应的图标
    if ([self.checkOutModel.payment_list count] == 1) {
        PaymentListModel *model = [self.checkOutModel.payment_list lastObject];
        model.isOnlyOne = YES;
        if ([model isCodePayment]) {
            if ([self.manager isShowCODGoodsAmountLimit:model.pay_code checkoutModel:self.checkOutModel]) {
                model.default_select = @"0";
            }
        }
    }
}

- (NSInteger)querySectionIndex:(Class)class {
    NSInteger index = 0;
    for (NSArray *dataArray in self.sectionArray) {
        if ([dataArray containsObject:class]) {
            index = [self.sectionArray indexOfObject:dataArray];
            break;
        }
    }
    return index;
}

- (void)reloadAmountDetailData {
    [self configureTableViewCell];
    for (NSArray *dataArray in self.sectionArray) {
        if ([dataArray containsObject:[ZFOrderAmountDetailCell class]]) {
            NSUInteger index = [self.sectionArray indexOfObject:dataArray];
            [self.tableView beginUpdates];
            [self.tableView reloadSections:[[NSIndexSet alloc]initWithIndex:index] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView endUpdates];
            break;
        }
    }
}

- (void)reloadPaymethodAndShippingMethod:(PaymentListModel *)model {
    // 刷新付款方式
    [self.checkOutModel.payment_list setValue:@(NO) forKeyPath:@"default_select"];
    model.default_select = @"1";
    [self changePlaceOrderButtonState];
}

- (void)changePlaceOrderButtonState {
    if (self.checkOutModel.payment_list.count == 0 ||
        self.manager.shippingListArray.count == 0) {
        self.isCancelPlaceOrder = YES;
    }else{
        self.isCancelPlaceOrder = NO;
    }
}

- (void)showAlert:(NSString *)message actionTitle:(NSString *)string {
    ShowAlertSingleBtnView(nil, message, string);
}

- (void)jumpToPayment {
    //弹出一个选择国家站的alert
    {
        if (self.checkOutModel.change_coutry.region_id) {
            NSString *message = ZFLocalizedString(@"OrderInfo_check_regions", nil);
            NSString *buttonTitle = ZFLocalizedString(@"Cancel", nil);
            NSString *changeSit = [NSString stringWithFormat:ZFLocalizedString(@"OrderInfo_check_change_x_address", nil), self.checkOutModel.change_coutry.region_name];
            @weakify(self)
            ShowVerticalAlertView(nil, message, @[changeSit, buttonTitle], ^(NSInteger buttonIndex, id buttonTitle) {
                // 切换语言,切换国家时 重新初始化AppTabbr, 刷新国家运营数据
                @strongify(self)
                if (buttonIndex == 1) {
                    return;
                }
                ZFAddressCountryModel *counrtyModel = [[ZFAddressCountryModel alloc] init];//[AccountManager sharedManager].accountCountryModel;
                counrtyModel.region_id = self.checkOutModel.change_coutry.region_id;
                counrtyModel.region_code = self.checkOutModel.change_coutry.region_code;
                counrtyModel.region_name = self.checkOutModel.change_coutry.region_name;
                counrtyModel.support_lang = self.checkOutModel.change_coutry.support_lang;
                [AccountManager sharedManager].accountCountryModel = counrtyModel;
                [ZFLangugeSettingViewController initAppTabBarVCFromChangeLanguge:TabBarIndexHome completion:^(BOOL success){
                    // 跳转到购物车
                    if (success) {
                        ZFCartViewController *cartVC = [[ZFCartViewController alloc] init];
                        [[UIViewController currentTopViewController].navigationController pushViewController:cartVC animated:NO];
                    }
                }];
            }, nil, nil);
            return;
        }
    }
    
    {
        //需要重新修改地址
        if (!self.checkOutModel.is_valid_address) {
            NSString *title = ZFLocalizedString(@"OrderInfo_check_address_info_msg", nil);
            NSString *content = ZFLocalizedString(@"OrderInfo_check_error_address_msg", nil);
            NSString *cancel = ZFLocalizedString(@"Cancel", nil);
            NSString *modified = ZFLocalizedString(@"OrderInfo_check_error_address_change", nil);
            ShowAlertView(title, content, @[modified], ^(NSInteger buttonIndex, id buttonTitle) {
                ZFAddressEditViewController *editViewController = [[ZFAddressEditViewController alloc] init];
                editViewController.fd_interactivePopDisabled = YES;
                editViewController.isCheck = YES;
                [editViewController editOrderAddress:self.checkOutModel.address_info checkPHAddress:self.checkOutModel.checkPHAddress];
                editViewController.title = ZFLocalizedString(@"ModifyAddress_Edit_VC_title",nil);
                @weakify(self)
                editViewController.addressEditSuccessCompletionHandler = ^(AddressEditStateType editStateType) {
                    @strongify(self)
                    if (editStateType != AddressEditStateFail) {
                        [self reloadDataWhenChangeNewAddressCompletion:nil failure:^{}];
                    }
                };
                [self.navigationController pushViewController:editViewController animated:YES];
            }, cancel, nil);
            return;
        }
    }
    
    //物流方式列表异常
    if (self.manager.shippingListArray.count == 0) {
        ShowToastToViewWithText(self.view, ZFLocalizedString(@"CartOrderInfoViewModel_PlaceOrder_NoShipping",nil));
        return ;
    }
    
    //支付方式列表异常
    if (self.checkOutModel.payment_list.count == 0) {
        ShowToastToViewWithText(self.view, ZFLocalizedString(@"CartOrderInfoViewModel_PlaceOrder_NoPayment",nil));
        return ;
    }
    
    //韩国、巴西等需要验证PCC NUM
    if ([self.checkOutModel.taxVerify.is_pcc isEqualToString:@"1"]) {
        BOOL result = [NSStringUtils matchNewPCCNum:self.manager.pccNum regex:self.checkOutModel.taxVerify.reg];
        if (!result) {
            //获取PCC cell焦点
            if (self.pccCell) {
                if ([self.pccCell isKindOfClass:[ZFPCCNumInputCell class]]) {
                    if (ZFIsEmptyString(self.manager.pccNum)) {
                        self.manager.pccNum = ZFShowError;
                    }
                }
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            }
            
            NSString *pcc_err_msg = ZFToString(self.checkOutModel.taxVerify.error_msg);
            if (ZFIsEmptyString(pcc_err_msg)) {
                pcc_err_msg = ZFLocalizedString(@"OrderInfo_PCCErrorTips", nil);
            }
            ShowToastToViewWithText(self.view, pcc_err_msg);
            return;
        }
    }
    
    if (![NSStringUtils isEmptyString:[FilterManager tempCurrency]] && [self.manager.paymentCode isEqualToString:@"Cod"]) {
        [self showCODPay];
    }else{
        [self showOnlinePay];
    }
}

- (void)showCODPay {
    ///先判断一下，是否满足COD支付条件
    if ([self.manager isShowCODGoodsAmountLimit:@"Cod" checkoutModel:self.checkOutModel]) {
        [self showAlert:[NSString stringWithFormat:ZFLocalizedString(@"OrderInfoViewModel_alertMsg_COD",nil),self.checkOutModel.cod.totalMin,self.checkOutModel.cod.totalMax] actionTitle:ZFLocalizedString(@"SettingViewModel_Version_Latest_Alert_OK",nil)];
        return;
    }
    NSDictionary *dict = @{kLoadingView : self.view};
    @weakify(self);
    [self.viewModel requestPaymentProcess:dict Completion:^(NSInteger state) {
        @strongify(self);
        if (state == PaymentProcessTypeNoGoods) {
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        [self.codVerCodeView showTitle:[self.manager queryCashOnDelivery] andCode:self.manager.addressCode andphoneNum:[NSString stringWithFormat:@"%@%@",NullFilter(self.manager.supplierNumber),self.manager.tel]];
    } failure:nil];
}

- (void)showOnlinePay {
    [ZFOrderCommitProgressView showProgressViewType:ZFProgressViewType_Request delegate:self];
}

- (ZFNavigationController *)queryTargetNavigationController:(NSInteger)index {
    ZFTabBarController *tabBarVC = APPDELEGATE.tabBarVC;
    [tabBarVC setZFTabBarIndex:index];
    ZFNavigationController *targetNavVC = (ZFNavigationController *)tabBarVC.viewControllers[tabBarVC.selectedIndex];
    return targetNavVC;
}

- (void)showTipsWithPayState:(NSInteger )states {
    NSString *title;
    NSString *message;
    switch (states) {
        case PaymentStatusDone:
        {
            message = ZFLocalizedString(@"CartOrderInfoModel_PaymentStatusDone_Alert_Message",nil);
            title = ZFLocalizedString(@"CartOrderInfoModel_PaymentStatusDone_Alert_Title",nil);
        }
            break;
        case PaymentStatusCancel:
        {
            message = ZFLocalizedString(@"CartOrderInfoModel_PaymentStatusCancel_Alert_Message",nil);
            title = ZFLocalizedString(@"CartOrderInfoModel_PaymentStatusCancel_Alert_Title",nil);
        }
            break;
        case PaymentStatusFail:
        {
            message = ZFLocalizedString(@"CartOrderInfoModel_PaymentStatusFail_Alert_Message",nil);
            title = ZFLocalizedString(@"CartOrderInfoModel_PaymentStatusFail_Alert_Title",nil);
        }
            break;
    }
    ShowAlertSingleBtnView(title, message, ZFLocalizedString(@"OK", nil));
}

- (void)jumpToMyOrderListViewController:(NSInteger)state orderModel:(ZFOrderCheckDoneDetailModel *)model payResult:(ZFOrderPayResultModel *)payResultModel {
    ZFTabBarController *tabbar = (ZFTabBarController *)self.tabBarController;
    [tabbar setZFTabBarIndex:TabBarIndexAccount];
    ZFNavigationController *nav = [tabbar navigationControllerWithMoudle:TabBarIndexAccount];
    if (nav) {
        if (nav.viewControllers.count>1) {
            [nav popToRootViewControllerAnimated:NO];
        }
        ZFMyOrderListViewController *orderListVC = [[ZFMyOrderListViewController alloc] init];
        //取消、失败需要传入订单ID到后面支付这个订单时，是否弹窗远程通知视图
        if (state == PaymentStatusCancel || state == PaymentStatusFail) {
            orderListVC.sourceOrderId = ZFToString(model.order_id);
        }
        [nav pushViewController:orderListVC animated:NO];
        
        ZFOrderDetailViewController *orderDetailVC = [[ZFOrderDetailViewController alloc] init];
        orderDetailVC.orderId = model.order_id;
        [orderListVC.navigationController pushViewController:orderDetailVC animated:YES];
    }
    if (ZFToString(payResultModel.ebanxUrl).length) {
        //线下支付不弹窗
        state = PaymentStatusUnknown;
    }
    [self showTipsWithPayState:state];
}

- (void)showPaySuccessViewController:(ZFOrderCheckDoneDetailModel *)model payResult:(ZFOrderPayResultModel *)payResultModel {
    // 清除购物车选择主动记住的全局优惠券
    [AccountManager clearUserSelectedCoupon];
    
    ///物流费用
    if (!ZFToString(model.shipping_fee).length) {
        model.shipping_fee = self.manager.shippingPrice;
    }
    
    ///统计字段
    NSMutableArray *goodsList = [[NSMutableArray alloc] init];
    [self.checkOutModel.cart_goods.goods_list enumerateObjectsUsingBlock:^(CheckOutGoodListModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [goodsList addObject:obj];
    }];
    model.baseGoodsList = goodsList;
    
    ///是否显示COD
    if (self.manager.currentPaymentType == CurrentPaymentTypeCOD) {
        model.isCodPay = YES;
        [FilterManager removeCurrency];
    }
    ZFOrderPayResultHandler *handler = [ZFOrderPayResultHandler handler];
    handler.zfParentViewController = self;
    [handler orderPaySuccess:ZFOrderPayResultSource_OrderInfo baseOrderModel:model resultModel:payResultModel];
    
//    ZFOrderSuccessViewController *finischVC = [[ZFOrderSuccessViewController alloc] init];
//    finischVC.isShowNotictionView = YES;
//    finischVC.orderPayResultModel = payResultModel;
//
//    NSMutableArray *goodsList = [[NSMutableArray alloc] init];
//    [self.checkOutModel.cart_goods.goods_list enumerateObjectsUsingBlock:^(CheckOutGoodListModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        [goodsList addObject:obj];
//    }];
//    model.baseGoodsList = goodsList;
//    if (!ZFToString(model.shipping_fee).length) {
//        model.shipping_fee = self.manager.shippingPrice;
//    }
//    finischVC.baseOrderModel = model;
//
//    if (self.manager.currentPaymentType == CurrentPaymentTypeCOD) {
//        finischVC.isCodPay = YES;
//    }
//    if ([model.pay_method isEqualToString:@"Cod"]) {
//        [FilterManager removeCurrency];
//    }
//
//    finischVC.toAccountOrHomeblock = ^(BOOL gotoOrderList){
//        @weakify(self)
//        [self dismissViewControllerAnimated:NO completion:^{
//            @strongify(self)
//            if (gotoOrderList) {
//                [self jumpToMyOrderListViewController:PaymentStatusDone orderModel:model payResult:payResultModel];
//            }else{
//                [self.navigationController popToRootViewControllerAnimated:NO];
//                ZFTabBarController *tabBarVC = APPDELEGATE.tabBarVC;
//                [tabBarVC setZFTabBarIndex:TabBarIndexHome];
//                [ZFFireBaseAnalytics selectContentWithItemId:@"Payment_Success_ToHome" itemName:@"" ContentType:@"Payment Success" itemCategory:@""];
//            }
//        }];
//    };
//
//    ZFNavigationController *nav = [[ZFNavigationController alloc] initWithRootViewController:finischVC];
//    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

//显示boleto支付完成页面
//- (void)showBoletoPage:(ZFOrderPayResultModel *)model
//{
//    ZFOfflineOrderSuccessViewController *offlineVC = [[ZFOfflineOrderSuccessViewController alloc] init];
//    offlineVC.orderResultModel = model;
//    offlineVC.checkOrderHandler = ^{
//        //跳转到订单详情页
//        @weakify(self)
//        [self dismissViewControllerAnimated:NO completion:^{
//            @strongify(self)
////            self.checkDoneDetailModel.offlineLine = model.ebanxUrl;
//            [self jumpToMyOrderListViewController:PaymentStatusDone orderModel:self.checkDoneDetailModel payResult:model];
//        }];
//    };
//
//    ZFNavigationController *navi = [[ZFNavigationController alloc] initWithRootViewController:offlineVC];
//    [self.navigationController presentViewController:navi animated:YES completion:nil];
//}

- (void)showPayFailureViewController:(ZFOrderCheckDoneDetailModel *)model {
    ZFOrderFailureViewController *failureVC = [[ZFOrderFailureViewController alloc] init];
    @weakify(self)
    failureVC.orderFailureBlock = ^{
        @strongify(self)
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        [self jumpToMyOrderListViewController:PaymentStatusFail orderModel:model payResult:nil];
    };
    [self.navigationController presentViewController:failureVC animated:YES completion:nil];
}

- (void)jumpToBoletoFinishedViewController:(ZFOrderCheckDoneDetailModel *)model goodsStr:(NSString *)goodsStr {
    BoletoFinishedViewController *boletoVC = [[BoletoFinishedViewController alloc] init];
    boletoVC.order_number = model.order_sn;
    boletoVC.order_id = model.order_id;
    ZFNavigationController *nav = [[ZFNavigationController alloc] initWithRootViewController:boletoVC];
    [self.navigationController presentViewController:nav animated:YES completion:^{
    }];
}

- (void)jumpCodVipViewController:(NSString *)codVipUrl
{
    if (!ZFToString(codVipUrl).length) {
        return;
    }
    ZFCODVIPViewController *codVip = [[ZFCODVIPViewController alloc] init];
    codVip.link_url = codVipUrl;
    codVip.fd_interactivePopDisabled = YES;
    codVip.didDismissHandle = ^{
        //回到页面需要刷新视图，获取用户是否开启了Cod Vip
        [self reloadDataWhenChangeNewAddressCompletion:nil failure:nil];
    };
    [self.navigationController pushViewController:codVip animated:YES];
}

#pragma mark - 发起支付

- (void)showPaymentView:(ZFOrderCheckDoneDetailModel *)checkDoneDetailModel{

    NSInteger payModel = [checkDoneDetailModel.pay_before_info[@"pay_mode"] integerValue];
    ZFOrderPayTools *payTools = [ZFOrderPayTools paytools];
    payTools.channel = PayChannel_PayModel;
    payTools.orderId = ZFToString(checkDoneDetailModel.order_id);
    payTools.payModel = payModel;
    //H5的支付链接
    payTools.payUrlH5 = checkDoneDetailModel.pay_url;
    //原生支付的支付链接
    NSString *payUrl = checkDoneDetailModel.pay_before_info[@"pay_url"];
    payTools.payUrl = payUrl;
    payTools.parentViewController = self;
    payTools.walletPasswordUrl = checkDoneDetailModel.pay_before_info[@"wallet_password_url"];
    
    @weakify(self)
    payTools.paySuccessCompletionHandle = ^(ZFOrderPayResultModel * _Nonnull orderPayResultModel) {
        ///SOA 支付成功
        @strongify(self)
        checkDoneDetailModel.realPayment = orderPayResultModel.payChannelCode;
        //如果是boleto, 开启一个线下支付支付成功页面
        if (ZFToString(orderPayResultModel.boletoBarcodeRaw).length) {
            checkDoneDetailModel.showOfflinePageVC = YES;
        }
        [self showPaySuccessViewController:checkDoneDetailModel payResult:orderPayResultModel];
    };
    
    payTools.payFailureCompletionHandle = ^{
        @strongify(self)
        ///SOA 失败
        [self showPayFailureViewController:checkDoneDetailModel];
    };
    
    payTools.payCancelCompolementHandle = ^{
        @strongify(self)
        [ZFOrderInformationViewModel requestPayTag:checkDoneDetailModel.order_sn step:@"cancel"];
        [self jumpToMyOrderListViewController:PaymentStatusCancel orderModel:checkDoneDetailModel payResult:nil];
    };
    
    payTools.loadH5PaymentHandle = ^{
        [ZFOrderInformationViewModel requestPayTag:checkDoneDetailModel.order_sn step:@"load"];
    };
    
    payTools.paymentSurveyHandle = ^{
        @strongify(self)
        ZFOrderQuestionViewController *questionVC = [[ZFOrderQuestionViewController alloc] init];
        questionVC.delegate = self;
        questionVC.ordersn = checkDoneDetailModel.order_sn;
        questionVC.orderId = checkDoneDetailModel.order_id;
        questionVC.fd_interactivePopDisabled = NO;
        [self.navigationController pushViewController:questionVC animated:YES];
    };

    [payTools startPay];
    
    _payTools = payTools;
}

- (void)createOrderSuccess:(void (^)(void))success failure:(void (^)(void))failure {
    [self.manager queryCurrentOrderCurrency];
    
    NSDictionary *order_info = [self.viewModel queryCheckDonePublicParmas:self.manager];
    NSMutableDictionary *parmaters = [NSMutableDictionary dictionaryWithDictionary:order_info];
    // 从商详一键(快速)购买过来时,需要带入相应参数
    if (ZFJudgeNSDictionary(self.detailFastBuyInfo)) {
        [parmaters addEntriesFromDictionary:self.detailFastBuyInfo];
    }
    
    @weakify(self)
    [self.viewModel requestCheckDoneOrder:parmaters completion:^(NSArray<ZFOrderCheckDoneModel *> *dataArray) {
        HideLoadingFromView(nil);
        [ZFOrderCommitProgressView hiddenProgressView:^{
            @strongify(self)
            [self handlePayEvent:dataArray success:success failure:failure];
        }];
    } failure:^(id obj) {
        HideLoadingFromView(nil);
        [ZFOrderCommitProgressView cancelProgressView];
        if (!ZFToString(obj).length) {
            ShowToastToViewWithText(nil, ZFLocalizedString(@"payNow_failure", nil));
        }
        [[ZFAnalyticsTimeManager sharedManager] logTimeWithEventName:kFinishLoadingCreateOrder];
    }];
}

- (void)handlePayEvent:(NSArray<ZFOrderCheckDoneModel *>*)dataArray success:(void (^)(void))success failure:(void (^)(void))failure
{    
    ZFOrderCheckDoneModel *checkDoneModel = (ZFOrderCheckDoneModel *)dataArray.firstObject;
    ZFOrderCheckDoneDetailModel *checkDoneDetailModel = checkDoneModel.order_info;
    self.checkDoneDetailModel = checkDoneDetailModel;
    // 支付打点
    [ZFOrderInformationViewModel requestPayTag:checkDoneDetailModel.order_sn step:@"place"];
    
    // 订单开始支付
    [ZFGrowingIOAnalytics ZFGrowingIOPayOrder:checkDoneDetailModel orderManager:self.manager paySource:@"OrderInfo"];
    [ZFGrowingIOAnalytics ZFGrowingIOPayOrderSKU:checkDoneDetailModel checkInfoOderDetail:self.checkOutModel orderManager:self.manager paySource:@"OrderInfo"];
    
    if (checkDoneModel.isBackToCart) {
        ShowToastToViewWithText(self.view, checkDoneDetailModel.msg);
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    [ZFFireBaseAnalytics addPaymentInfo];
    
    NSString *payMethod = checkDoneDetailModel.pay_method;
    NSInteger state = checkDoneDetailModel.flag;
    
    if (checkDoneDetailModel.error == 0) {
        [self.manager analyticsClickButton:payMethod state:state];
        
        switch (state) {
                //快速付款成功
            case FastPaypalOrderTypeSuccess:
            {
                [self showPaymentView:checkDoneDetailModel];
            }
                break;
                //快速付款失败
            case FastPaypalOrderTypeFail:
            {
                [self showPayFailureViewController:checkDoneDetailModel];
            }
                break;
                //普通付款
            case FastPaypalOrderTypeCommon:
            {
                if (![checkDoneModel.order_info.pay_method isEqualToString:@"Cod"]) {
                    [self showPaymentView:checkDoneDetailModel];
                }else{
                    if (success) success();
                    [self showPaySuccessViewController:checkDoneDetailModel payResult:nil];
                }
                //下单成功，根据订单号保存二次付款弹窗信息（表示这已经是第一次了）
                [ZFCommonRequestManager savePlaceOrderUnpaidMark:checkDoneDetailModel.order_id];
            }
                break;
            case FastPayPalOrderTypeRestJump:{
                ///重新打开后台传的url
                [self showPaymentView:checkDoneDetailModel];
            }
                break;
        }
        //更新购物车数据
        [self.viewModel requestCartBadgeNum];
    }else{
        if (failure) { //回调显示手机验证码错误
            failure();
        }
    }
}

- (void)exchangeSubViewController:(NSArray *)childsVCArray contentVC:(UIViewController *)contentVC completion:(void (^)(void))completion{
    UIViewController *oldVC = childsVCArray.count == 3 ? [childsVCArray objectAtIndex:1] : [childsVCArray objectAtIndex:0];
    UIViewController *newVC = childsVCArray.count == 3 ? [childsVCArray objectAtIndex:2] : [childsVCArray objectAtIndex:1];
    [oldVC willMoveToParentViewController:nil];
    [contentVC transitionFromViewController:oldVC
                           toViewController:newVC
                                   duration:0.25
                                    options:UIViewAnimationOptionTransitionCrossDissolve
                                 animations:^{}
                                 completion:^(BOOL finished) {
                                     if (finished && completion) {
                                         completion();
                                     }
                                 }];
    [oldVC didMoveToParentViewController:self];
}

- (NSDictionary *)configureRequestCheckInfoParmas {
    NSDictionary *dict = @{
                           @"order_info"  : [self.viewModel queryCheckoutInfoPublicParmas:self.manager],
                           kLoadingView : self.view
                           };
    return dict;
}

- (void)refreshTableViewDataWithArray:(NSArray *)dataArray {
    ZFOrderCheckInfoModel *model = dataArray.firstObject;
    self.payCode = model.node;
    self.manager.codReplaceHold = @"$cod_fee";
    self.checkOutModel = model.order_info;
}

- (void)reloadDataWhenChangeNewAddressCompletion:(void (^)(id obj))completion failure:(void (^)(void))failure {
    NSDictionary *dict = [self configureRequestCheckInfoParmas];
    @weakify(self)
    [self.viewModel requestCheckInfoNetwork:dict completion:^(NSArray<ZFOrderCheckInfoModel *> *dataArray) {
        @strongify(self)
        [self refreshTableViewDataWithArray:dataArray];
        if (completion) {
            completion(dataArray);
        }
    } failure:^(id obj) {
        if (failure) {
            failure();
        }
    }];
}

- (void)removePayMethodVC {
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.navigationController.childViewControllers];
    [array removeObjectAtIndex:2];
    [self.navigationController setViewControllers:array];
}

- (void)checkoutCouponWithCouponModel:(NSString *)couponCode myCouponViewController:(UIViewController *)viewController {
    if (ZFIsEmptyString(couponCode)) {
        self.manager.isSelectCoupon = NO;
        self.manager.autoCoupon = @"0";
    }
    self.manager.couponCode = couponCode;
    NSString *currentCouponCode = [self.manager.couponCode copy];
    NSDictionary *dict = [self configureRequestCheckInfoParmas];
    ShowLoadingToView(nil);
    @weakify(self)
    [self.viewModel requestCheckInfoNetwork:dict completion:^(NSArray<ZFOrderCheckInfoModel *> *dataArray) {
        @strongify(self)
        HideLoadingFromView(nil);
        ZFOrderCheckInfoModel *infoModel = dataArray.firstObject;
        if (infoModel.isBackToCart) {
            NSMutableArray *array = [NSMutableArray arrayWithArray:self.navigationController.childViewControllers];
            ZFCartViewController *cartVC = [[ZFCartViewController alloc] init];
            [array insertObject:cartVC atIndex:2];
            [self.navigationController setViewControllers:array];
            [self.navigationController popToViewController:cartVC animated:YES];
            return;
        }
        [viewController.navigationController popViewControllerAnimated:YES];
        [self refreshTableViewDataWithArray:dataArray];
    } failure:^(id obj) {
        @strongify(self)
        self.manager.couponCode = currentCouponCode;
    }];
}

///给底部提交按钮设置属性
-(void)setPlaceOrderButtonParams
{
    if ([self.amountDetailModelArray count]) {
        ZFOrderAmountDetailModel *model = [[ZFOrderAmountDetailModel alloc] init];
        if (self.manager.currentPaymentType == CurrentPaymentTypeCOD) {
            model.value = [self.manager queryTotalPayable];
        }else{
            double totalValue = [self.manager queryAmountNumber].doubleValue;
            double tipsValue = [ExchangeManager transPurePriceforPrice:self.currentPaymentListModel.offer_message.amount].doubleValue;
            NSString *value = [self.manager queryGrandTotal];
            NSString *discountValue = [ExchangeManager transPurePriceforPrice:self.currentPaymentListModel.offer_message.discount];
            BOOL discountUnzero = [NSStringUtils matchPriceMorethanZero:discountValue];
            if (totalValue >= tipsValue && discountUnzero) {
                NSString *discount = [NSString stringWithFormat:@"(-%@)", discountValue];
                NSString *showValue = [NSString stringWithFormat:@"%@%@", value, discount];
                NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:showValue];
                NSRange showValueRange = [showValue rangeOfString:discount];
                [attrString addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16] , NSForegroundColorAttributeName : ZFC0x2D2D2D()} range:showValueRange];
                model.attriValue = [attrString copy];
            } else {
                model.value = value;
            }
        }
        self.orderPlaceBottomView.detailModel = model;
    }
    self.orderPlaceBottomView.currentPaymentType = self.manager.currentPaymentType;
    self.orderPlaceBottomView.isFast = self.isFastPay;
    self.orderPlaceBottomView.placeOrderButtonState = self.isCancelPlaceOrder;
    self.orderPlaceBottomView.isShowRewardPoints = !self.manager.isUsePoint;
    self.orderPlaceBottomView.checkOutModel = self.checkOutModel;
    self.orderPlaceBottomView.isCenterShow = self.manager.isUsePoint && ![ZFToString(self.checkOutModel.first_order_bts_result.policy) isEqualToString:@"1"];
}

#pragma mark - TableView delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat headerHeight = 12;
    NSArray *cellArray = self.sectionArray[section];
    //改变视图位置
    if (cellArray.firstObject == [ZFOrderPointsV457Cell class]) {
        headerHeight = CGFLOAT_MIN;
    }
    
    if (cellArray.firstObject == [ZFOrderInsuranceCell class]) {
        headerHeight = CGFLOAT_MIN;
    }
    
    if (cellArray.firstObject == [ZFPCCNumInputCell class]) {
        headerHeight = 12;
    }
    
    if (cellArray.firstObject == [ZFOrderBottomTipsCell class]) {
        headerHeight = CGFLOAT_MIN;
    }
    
    if (cellArray.firstObject == [ZFOrderRewardPointsCell class]) {
        headerHeight = CGFLOAT_MIN;
    }
    
    if (cellArray.firstObject == [ZFOrderRewardCouponCell class]) {
        headerHeight = CGFLOAT_MIN;
    }
    
    return headerHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = self.sectionArray[section];
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Class class = self.sectionArray[indexPath.section][indexPath.row];
    
    if (class == [ZFOrderAddressCell class]) {
        ZFOrderAddressCell *addressCell = [tableView dequeueReusableCellWithIdentifier:[ZFOrderAddressCell queryReuseIdentifier]];
        addressCell.addressModel = self.checkOutModel.address_info;
        return addressCell;
    }
    
    if (class == [ZFOrderPaymentListCell class]) {
        ZFOrderPaymentListCell *paymentListCell = [tableView dequeueReusableCellWithIdentifier:[ZFOrderPaymentListCell queryReuseIdentifier]];
        PaymentListModel *paymentListModel = self.checkOutModel.payment_list[indexPath.row];
        paymentListCell.paymentListmodel = paymentListModel;
        BOOL choose = self.currentPaymentListModel && [self.currentPaymentListModel.pay_id isEqualToString:paymentListModel.pay_id];
        paymentListCell.isChoose = choose;
        return paymentListCell;
    }
    
    if (class == [ZFOrderShippingV390Cell class]) {
        ZFOrderShippingV390Cell *shippingListCell = [tableView dequeueReusableCellWithIdentifier:[ZFOrderShippingV390Cell queryReuseIdentifier]];
        shippingListCell.isShowTax = self.checkOutModel.is_use_tax_id;
        shippingListCell.isCod = self.manager.currentPaymentType == CurrentPaymentTypeCOD ? YES : NO;
        shippingListCell.checkOutModel = self.checkOutModel;
        shippingListCell.model = self.currentShippingListModel;
        //        shippingListCell.isChoose = self.currentShippingselectedIndexPath && self.currentShippingselectedIndexPath == indexPath ? YES : NO;
        return shippingListCell;
    }
    
    if (class == [ZFOrderInsuranceCell class]) {
        ZFOrderInsuranceCell *insuranceCell = [tableView dequeueReusableCellWithIdentifier:[ZFOrderInsuranceCell queryReuseIdentifier]];
        insuranceCell.isCod = self.manager.currentPaymentType == CurrentPaymentTypeCOD ? YES : NO;
        insuranceCell.insuranceFee = self.checkOutModel.total.insure_fee;
        insuranceCell.isChoose = self.checkOutModel.ifNeedInsurance;
        return insuranceCell;
    }

    if (class == [ZFOrderPointsV457Cell class]) {
        ZFOrderPointsV457Cell *newPointsCell = [tableView dequeueReusableCellWithIdentifier:[ZFOrderPointsV457Cell queryReuseIdentifier]];
        newPointsCell.isCod = self.manager.currentPaymentType == CurrentPaymentTypeCOD ? YES : NO;
        newPointsCell.pointModel = self.checkOutModel.point;
        newPointsCell.isChoose = self.manager.isUsePoint;
        @weakify(self)
        newPointsCell.pointSwitchHandler = ^(BOOL isOn) {
            @strongify(self)
            self.manager.isUsePoint = isOn;
            if (isOn) {
                self.manager.currentPoint = self.checkOutModel.point.use_point_max;
            }
//            [self reloadAmountDetailData];
            [self configureTableViewCell];
            [self adapterDefaultSelected];
            [self.tableView reloadData];
        };
        return newPointsCell;
    }
    
    if (class == [ZFOrderCouponCell class]) {
        ZFOrderCouponCell *couponCell = [tableView dequeueReusableCellWithIdentifier:[ZFOrderCouponCell queryReuseIdentifier]];
        couponCell.isCod = self.manager.currentPaymentType == CurrentPaymentTypeCOD ? YES : NO;
        
        //NSUInteger availableCount = self.checkOutModel.coupon_list.available.count;
        
        //NSString *couponTip = availableCount > 0 ? [NSString stringWithFormat:ZFLocalizedString(@"MyCoupon_Coupon_Available", nil), self.checkOutModel.coupon_list.available.count] : @"";
        
        NSString *couponTip = @"";//V5.4.0 @佳佳 版本去掉提示显示可用优惠券数
        
        if (self.manager.isSelectCoupon) {
            NSString *amountText = [FilterManager adapterCodWithAmount:ZFToString(self.manager.couponAmount)
                                                                andCod:couponCell.isCod
                                                             priceType:PriceType_Coupon];
            couponCell.couponAmount = [NSString stringWithFormat:@"- %@", amountText];
        }else{
            [couponCell initCouponAmount:couponTip];
        }
        return couponCell;
    }
    
    if (class == [ZFOrderGoodsCell class]) {
        ZFOrderGoodsCell *goodsCell = [tableView dequeueReusableCellWithIdentifier:[ZFOrderGoodsCell queryReuseIdentifier]];
        goodsCell.goodsList = self.checkOutModel.cart_goods.goods_list;
        return goodsCell;
    }
    
    if (class == [ZFOrderAmountDetailCell class]) {
        ZFOrderAmountDetailCell *amountDetailCell = [tableView dequeueReusableCellWithIdentifier:[ZFOrderAmountDetailCell queryReuseIdentifier]];
        amountDetailCell.model = self.amountDetailModelArray[indexPath.row];
        return amountDetailCell;
    }
    
    if (class == [ZFOrderNoPaymentCell class]) {
        ZFOrderNoPaymentCell *noPaymentCell = [tableView dequeueReusableCellWithIdentifier:[ZFOrderNoPaymentCell queryReuseIdentifier]];
        return noPaymentCell;
    }
    
    if (class == [ZFOrderNoShippingCell class]) {
        ZFOrderNoShippingCell *noShippingCell = [tableView dequeueReusableCellWithIdentifier:[ZFOrderNoShippingCell queryReuseIdentifier]];
        return noShippingCell;
    }
    
    if (class == [ZFAcceptPaymentTipsCell class]) {
        ZFAcceptPaymentTipsCell *paymentTipsCell = [tableView dequeueReusableCellWithIdentifier:[ZFAcceptPaymentTipsCell queryReuseIdentifier]];
        return paymentTipsCell;
    }
    
    if (class == [ZFOrderBottomTipsCell class]) {
        ZFOrderBottomTipsCell *orderBottomTipsCell = [tableView dequeueReusableCellWithIdentifier:[ZFOrderBottomTipsCell queryReuseIdentifier]];
        orderBottomTipsCell.model = self.checkOutModel.footer;
        @weakify(self)
        orderBottomTipsCell.orderInfoH5Block = ^(NSString * _Nonnull url) {
            @strongify(self)
            ZFWebViewViewController *webView = [[ZFWebViewViewController alloc] init];
            webView.link_url = url;
            [self.navigationController pushViewController:webView animated:YES];
        };
        return orderBottomTipsCell;
    }
    
    if (class == [ZFPCCNumInputCell class]) {
        ZFPCCNumInputCell *pccnumCell = [tableView dequeueReusableCellWithIdentifier:[ZFPCCNumInputCell queryReuseIdentifier]];
        pccnumCell.delegate = self;
        [pccnumCell configurate:self.checkOutModel.taxVerify pccNum:self.manager.pccNum];
        
        @weakify(self)
        pccnumCell.refreshBlock = ^{
            @strongify(self)
            [self.tableView reloadData];
        };
        self.pccCell = pccnumCell;
        pccnumCell.refreshCellTextHeight = ^{
            [tableView reloadData];
        };
        return pccnumCell;
    }
    
    if (class == [ZFOrderRewardPointsCell class]) {
        ZFOrderRewardPointsCell *rewardPointsCell = [tableView dequeueReusableCellWithIdentifier:[ZFOrderRewardPointsCell queryReuseIdentifier]];
        rewardPointsCell.pointsTip = self.checkOutModel.get_points;
        return rewardPointsCell;
    }
    
    if (class == [ZFOrderRewardCouponCell class]) {
        ZFOrderRewardCouponCell *rewardCoponCell = [tableView dequeueReusableCellWithIdentifier:[ZFOrderRewardCouponCell queryReuseIdentifier]];
        NSString *couponTip = self.checkOutModel.first_order_Coupon;
        if (!ZFIsEmptyString(self.checkOutModel.first_order_Coupon_amount)) {
            NSString *currency = self.manager.currentPaymentType == CurrentPaymentTypeCOD ? [FilterManager tempCurrency] : [ExchangeManager localCurrency];
            NSString *priceString = [ExchangeManager transPurePriceforCurrencyPrice:self.checkOutModel.first_order_Coupon_amount currency:currency priceType:PriceType_Coupon];
            NSRange originalRange = [self.checkOutModel.first_order_Coupon rangeOfString:self.checkOutModel.first_order_Coupon_amount];
            if (originalRange.location != NSNotFound) {
                couponTip = [couponTip stringByReplacingCharactersInRange:originalRange withString:priceString];
            }
        }
        rewardCoponCell.rewardCouponTip = couponTip;
        return rewardCoponCell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(nonnull UITableViewCell *)cell forRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    Class class = self.sectionArray[indexPath.section][indexPath.row];
    NSInteger cellNumbers = [self.sectionArray[indexPath.section] count];
    if (cellNumbers <= 1) {
        if (class == [ZFOrderPaymentListCell class]) {
            ZFOrderPaymentListCell *paymentCell = (ZFOrderPaymentListCell *)cell;
            [paymentCell zfAddCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(8, 8)];
            paymentCell.separatorLine.hidden = YES;
        } else if (class == [ZFOrderRewardPointsCell class]) {
            if (![ZFToString(self.checkOutModel.first_order_bts_result.policy) isEqualToString:@"1"]) {
                [cell zfAddCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(8, 8)];
            } else {
                [cell zfAddCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(0, 0)];
            }
        } else if (class == [ZFOrderAddressCell class] || class == [ZFOrderGoodsCell class] || class == [ZFPCCNumInputCell class]) {
            [cell zfAddCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(8, 8)];
        }
    } else {
        if (indexPath.row == 0) { // 第一个cell
            if (class == [ZFOrderPaymentListCell class]) {
                ZFOrderPaymentListCell *paymentCell = (ZFOrderPaymentListCell *)cell;
                paymentCell.separatorLine.hidden = NO;
                [paymentCell zfAddCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(8, 8)];
            } else if (class == [ZFOrderAmountDetailCell class]) {
                [cell zfAddCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(8, 8)];
            }
        } else if (indexPath.row == cellNumbers - 1) {  // 最后一个cell
            if (class == [ZFOrderPaymentListCell class]) {
                ZFOrderPaymentListCell *paymentCell = (ZFOrderPaymentListCell *)cell;
                paymentCell.separatorLine.hidden = YES;
                [paymentCell zfAddCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(8, 8)];
            } else if (class == [ZFOrderAmountDetailCell class]) {
                if (self.manager.isUsePoint && ![ZFToString(self.checkOutModel.first_order_bts_result.policy) isEqualToString:@"1"]) {
                    [cell zfAddCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(8, 8)];
                } else {
                    [cell zfAddCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(0, 0)];
                }
            }
        } else {  // 中间的cell
            if (class == [ZFOrderPaymentListCell class] || class == [ZFOrderAmountDetailCell class]) {
                [cell zfAddCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(0, 0)];
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Class class = self.sectionArray[indexPath.section][indexPath.row];
    // 统计
    NSString *orderTypeName = [self.manager orderTypeNameWithPayCode:self.payCode];
    
    if (class == [ZFOrderAddressCell class]) {
        ZFAddressViewController *addressVC = [[ZFAddressViewController alloc] init];
        addressVC.addressShowType = AddressInfoShowTypeCheckOrderInfo;
        @weakify(self);
        addressVC.addressChooseCompletionHandler  = ^(ZFAddressInfoModel *model){
            @strongify(self);
            [self refreshOrderAddress:model];
        };
        ZFNavigationController *nav = [[ZFNavigationController alloc] initWithRootViewController:addressVC];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:nav animated:YES completion:nil];
        });
        return;
    }
    
    if (class == [ZFOrderPaymentListCell class]) {
        
        ZFOrderPaymentListCell *paymentListCell = [tableView cellForRowAtIndexPath:indexPath];
        PaymentListModel *model = paymentListCell.paymentListmodel;
        
        if ([model isCodePayment]) {
            if (model.cod_state == 2) {
                NSString *title = ZFLocalizedString(@"OrderDetail_Apologies", nil);
                NSString *message = ZFLocalizedString(@"OrderInfo_COD_Apologies_Msg", nil);
                NSString *confirm = ZFLocalizedString(@"community_outfit_leave_confirm", nil);
                NSMutableArray *list = [[NSMutableArray alloc] init];
                if (ZFToString(model.join_member_url).length) {
                    NSString *joinCod = ZFLocalizedString(@"Join COD Membership", nil);
                    NSMutableAttributedString *joinCodAttr = [[NSMutableAttributedString alloc] initWithString:joinCod];
                    [joinCodAttr addAttributes:@{NSForegroundColorAttributeName : ZFC0xFE5269()} range:NSMakeRange(0, joinCod.length)];
                    [list addObject:joinCodAttr];
                }
                [list addObject:confirm];
                
                NSMutableAttributedString *titleAttr = [[NSMutableAttributedString alloc] initWithString:title];
                [titleAttr addAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:17]} range:NSMakeRange(0, title.length)];
                ShowVerticalAlertView(titleAttr, message, [list copy], ^(NSInteger buttonIndex, id buttonTitle) {
                    //跳转办理cod会员
                    if (buttonIndex == 0) {
                        [self jumpCodVipViewController:model.join_member_url];
                    }
                }, nil, nil);
                return;
            }
            if (model.cod_state == 1) {
                //跳转办理cod会员
                [self jumpCodVipViewController:model.join_member_url];
                return;
            }
        }
        
        BOOL isShow = [self.manager isShowCODGoodsAmountLimit:model.pay_code checkoutModel:self.checkOutModel];
        if (isShow) {
            [self showAlert:[NSString stringWithFormat:ZFLocalizedString(@"OrderInfoViewModel_alertMsg_COD",nil),self.checkOutModel.cod.totalMin,self.checkOutModel.cod.totalMax] actionTitle:ZFLocalizedString(@"SettingViewModel_Version_Latest_Alert_OK",nil)];
            return;
        }

        if ([self.currentPaymentListModel.pay_id isEqualToString:model.pay_id]) {
            return;
        }
        if (self.currentPaymentListModel) {
            NSUInteger row = [self.checkOutModel.payment_list indexOfObject:self.currentPaymentListModel];
            NSIndexPath *currentIndexPath = [NSIndexPath indexPathForRow:row inSection:indexPath.section];
            ZFOrderPaymentListCell *lastSelectCell = [tableView cellForRowAtIndexPath:currentIndexPath];
            lastSelectCell.isChoose = NO;
        }
        
        paymentListCell.isChoose = YES;
        self.currentPaymentListModel = model;
        
        [self reloadPaymethodAndShippingMethod:model];
        [self configureTableViewCell];
        [self adapterDefaultSelected];
        [self.tableView reloadData];
        return;
    }
    
    if (class == [ZFOrderShippingV390Cell class]) {
        if (self.manager.currentPaymentType == CurrentPaymentTypeCOD) {
            ///COD不能选择其他物流
            return;
        }
        ZFSelectShippingViewController *shippingVC = [[ZFSelectShippingViewController alloc] init];
        shippingVC.selectShippingModel = self.currentShippingListModel;
        shippingVC.shippingList = self.manager.shippingListArray;
        shippingVC.oldTaxString = self.manager.taxString;
        shippingVC.isShowTax = self.checkOutModel.is_use_tax_id;
        shippingVC.isCod = self.manager.currentPaymentType == CurrentPaymentTypeCOD ? YES : NO;
        @weakify(self)
        shippingVC.selectShippingComplation = ^(ShippingListModel *model) {
            @strongify(self)
            self.manager.shippingId = model.iD;
            self.manager.shippingPrice = model.ship_price;
            self.currentShippingListModel = model;
            ZFOrderShippingV390Cell *shippingListCell = [tableView cellForRowAtIndexPath:indexPath];
            shippingListCell.model = model;
            [self reloadAmountDetailData];
            [ZFFireBaseAnalytics selectContentWithItemId:[NSString stringWithFormat:@"Click_ShippingMethod_%@", model.ship_name] itemName:[NSString stringWithFormat:@"%@ ShippingMethod", orderTypeName] ContentType:@"Order - Information" itemCategory:[NSString stringWithFormat:@"%@ ShippingMethod", orderTypeName]];
        };
        shippingVC.didEndEditDniBlock = ^(NSString *dniString) {
            @strongify(self)
            self.manager.taxString = dniString;
        };
        [self.navigationController pushViewController:shippingVC animated:YES];
        return;
    }
    
    if (class == [ZFOrderInsuranceCell class]) {
        ZFOrderInsuranceCell *insuranceCell = [tableView cellForRowAtIndexPath:indexPath];
        self.checkOutModel.ifNeedInsurance = !self.checkOutModel.ifNeedInsurance;
        insuranceCell.isChoose = self.checkOutModel.ifNeedInsurance;
        self.manager.insurance = self.checkOutModel.ifNeedInsurance ? self.checkOutModel.total.insure_fee : @"0.00";
        [self reloadAmountDetailData];
        return;
    }
    
    if (class == [ZFOrderCouponCell class]) {
        NSDictionary *dict = [self configureRequestCheckInfoParmas];
        [self.viewModel requestCheckInfoNetwork:dict completion:^(NSArray<ZFOrderCheckInfoModel *> *dataArray) {
            ZFOrderCheckInfoModel *infoModel = dataArray.firstObject;
            if (infoModel.isBackToCart) {
                [self.navigationController popViewControllerAnimated:YES];
                return;
            }
            [self refreshTableViewDataWithArray:dataArray];
            ZFMyCouponViewController *myCouponViewController = [[ZFMyCouponViewController alloc] init];
            myCouponViewController.availableArray = self.checkOutModel.coupon_list.available;
            myCouponViewController.disabledArray  = self.checkOutModel.coupon_list.disabled;
            myCouponViewController.couponCode     = self.manager.isSelectCoupon ? self.manager.couponCode : nil;
            myCouponViewController.couponAmount   = self.manager.couponAmount;
            myCouponViewController.currentPaymentType = self.manager.currentPaymentType;
            [self.navigationController pushViewController:myCouponViewController animated:YES];
            
            @weakify(myCouponViewController)
            myCouponViewController.applyCouponHandle = ^(NSString *couponCode, BOOL shouldPop) {
                @strongify(myCouponViewController);
                [self checkoutCouponWithCouponModel:couponCode myCouponViewController:myCouponViewController];
            };
        } failure:nil];
        return;
    }
    
    if (class == [ZFOrderGoodsCell class]) {
        CartInfoGoodsViewController *goodsVC = [[CartInfoGoodsViewController alloc] init];
        goodsVC.goodsList = self.checkOutModel.cart_goods.goods_list;
        [self.navigationController pushViewController:goodsVC animated:YES];
        return;
    }
    
    if (class == [ZFOrderAmountDetailCell class]) {
        ZFOrderAmountDetailCell *cell = (ZFOrderAmountDetailCell *)[tableView cellForRowAtIndexPath:indexPath];
        BOOL tipsButton = cell.model.isShowTipsButton;
        if (tipsButton) {
            NSString *content = ZFLocalizedString(@"OrderInfo_discount_info_desc", nil);
            [self showAlert:content actionTitle:ZFLocalizedString(@"SettingViewModel_Version_Latest_Alert_OK",nil)];
        }
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self.tableView numberOfSections] > 2) {
        NSInteger maxSection = [self.tableView numberOfSections] - 2;
        NSInteger lastRow = [self.tableView numberOfRowsInSection:maxSection] - 1;
        NSIndexPath *lastRowIndexPath = [NSIndexPath indexPathForRow:lastRow inSection:maxSection];
        CGRect lastRect = [self.tableView rectForRowAtIndexPath:lastRowIndexPath];
        CGFloat offsetY = scrollView.contentOffset.y + scrollView.frame.size.height - scrollView.contentInset.bottom;
        if (offsetY > CGRectGetMinY(lastRect)) {
            [self.orderPlaceBottomView exchangePriceViewStatus:YES];
        } else {
            [self.orderPlaceBottomView exchangePriceViewStatus:NO];
        }
    }
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.title = ZFLocalizedString(@"CartOrderInfo_VC_Title",nil);
    self.view.backgroundColor = ZFCOLOR(244, 244, 244, 1);
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.orderPlaceBottomView];
}

- (void)zfAutoLayoutView {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 12, 0, 12));
    }];
    [self.orderPlaceBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(self.view);
        make.height.mas_offset(56 + kiphoneXHomeBarHeight);
    }];
}

#pragma mark - Getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = ZFCOLOR(244, 244, 244, 1);
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.estimatedRowHeight = 112;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 64, 0);
        [_tableView registerClass:[ZFOrderAddressCell class] forCellReuseIdentifier:[ZFOrderAddressCell queryReuseIdentifier]];
        [_tableView registerClass:[ZFOrderCurrentPaymentCell class] forCellReuseIdentifier:[ZFOrderCurrentPaymentCell queryReuseIdentifier]];
        [_tableView registerClass:[ZFOrderPaymentListCell class] forCellReuseIdentifier:[ZFOrderPaymentListCell queryReuseIdentifier]];
        [_tableView registerClass:[ZFOrderNoPaymentCell class] forCellReuseIdentifier:[ZFOrderNoPaymentCell queryReuseIdentifier]];
        [_tableView registerClass:[ZFOrderShippingV390Cell class] forCellReuseIdentifier:[ZFOrderShippingV390Cell queryReuseIdentifier]];
        [_tableView registerClass:[ZFOrderNoShippingCell class] forCellReuseIdentifier:[ZFOrderNoShippingCell queryReuseIdentifier]];
        [_tableView registerClass:[ZFOrderInsuranceCell class] forCellReuseIdentifier:[ZFOrderInsuranceCell queryReuseIdentifier]];
        [_tableView registerClass:[ZFOrderCouponCell class] forCellReuseIdentifier:[ZFOrderCouponCell queryReuseIdentifier]];
        [_tableView registerClass:[ZFOrderGoodsCell class] forCellReuseIdentifier:[ZFOrderGoodsCell queryReuseIdentifier]];
        [_tableView registerClass:[ZFOrderAmountDetailCell class] forCellReuseIdentifier:[ZFOrderAmountDetailCell queryReuseIdentifier]];
        [_tableView registerClass:[ZFOrderPointsV457Cell class] forCellReuseIdentifier:[ZFOrderPointsV457Cell queryReuseIdentifier]];
        [_tableView registerClass:[ZFAcceptPaymentTipsCell class] forCellReuseIdentifier:[ZFAcceptPaymentTipsCell queryReuseIdentifier]];
        [_tableView registerClass:[ZFOrderBottomTipsCell class] forCellReuseIdentifier:[ZFOrderBottomTipsCell queryReuseIdentifier]];
        [_tableView registerClass:[ZFPCCNumInputCell class] forCellReuseIdentifier:[ZFPCCNumInputCell queryReuseIdentifier]];
        [_tableView registerClass:[ZFOrderRewardPointsCell class] forCellReuseIdentifier:[ZFOrderRewardPointsCell queryReuseIdentifier]];
        [_tableView registerClass:[ZFOrderRewardCouponCell class] forCellReuseIdentifier:[ZFOrderRewardCouponCell queryReuseIdentifier]];
    }
    return _tableView;
}

- (NSMutableArray *)sectionArray {
    if (!_sectionArray) {
        _sectionArray = [NSMutableArray array];
    }
    return _sectionArray;
}

- (NSMutableArray *)amountDetailModelArray {
    if (!_amountDetailModelArray) {
        _amountDetailModelArray = [NSMutableArray array];
    }
    return _amountDetailModelArray;
}

- (ZFOrderManager *)manager {
    if (!_manager) {
        _manager = [[ZFOrderManager alloc] init];
    }
    return _manager;
}

- (ZFOrderInformationViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[ZFOrderInformationViewModel alloc] init];
        _viewModel.detailFastBuyInfo = self.detailFastBuyInfo;
        _viewModel.controller = self;
    }
    return _viewModel;
}

-(ZFOrderPlaceBottomView *)orderPlaceBottomView
{
    if (!_orderPlaceBottomView) {
        _orderPlaceBottomView = [[ZFOrderPlaceBottomView alloc] init];
        _orderPlaceBottomView.delegate = self;
    }
    return _orderPlaceBottomView;
}

- (VerificationView *)codVerCodeView
{
    if (!_codVerCodeView) {
        _codVerCodeView = ({
            VerificationView *verifView = [[VerificationView alloc] init];
  
            @weakify(self)
            @weakify(verifView)
            verifView.codeBlock = ^(NSString *codeStr) {
                @strongify(self)
                self.manager.verifyCode = codeStr;
                ShowLoadingToView(nil);
                [self createOrderSuccess:^{
                    @strongify(verifView)
                    [verifView dismiss];
                } failure:^{
                    @strongify(verifView)
                    verifView.isCodeSuccess = NO;
                }];
            };;
            // 发送验证码到手机
            verifView.sendCodeBlock = ^{
                @strongify(self)
                NSDictionary *dict = @{
                                       @"address_id" : self.manager.addressId,
                                       kLoadingView  : self.view
                                       };
                [self.viewModel sendPhoneCod:dict completion:^(id obj) {
                } failure:^(id obj) {}];
            };
            verifView;
        });
    }
    return _codVerCodeView;
}

- (ZFOrderInfoAnalyticsAOP *)analyticsAop
{
    if (!_analyticsAop) {
        _analyticsAop = [[ZFOrderInfoAnalyticsAOP alloc] init];
        _analyticsAop.payCode = self.payCode;
        _analyticsAop.manager = self.manager;
    }
    return _analyticsAop;
}

@end

