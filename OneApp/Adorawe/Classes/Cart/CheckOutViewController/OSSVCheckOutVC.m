//
//  OSSVCheckOutVC.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/9.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
// ------下单页面------------

//Controllers
#import "OSSVCheckOutVC.h"
#import "OSSVAddressOfsOrderEntersVC.h"
#import "OSSVCartShippingMethodVC.h"
#import "OSSVCartSelectCouponVC.h"
#import "AppDelegate+STLCategory.h"
//Views
#import "OSSVAddressCell.h"
#import "OSSVPayMentCell.h"
#import "OSSVTotalDetailCell.h"
#import "OSSVSwitchCell.h"
#import "OSSVNormalHeadCell.h"
#import "OSSVArrowTableViewCell.h"
#import "OSSVCouponCell.h"
#import "OSSVShowErrorCell.h"
#import "OSSVCheckOutProductListCell.h"
#import "OSSVPayTotalTableViewCell.h"
#import "OSSVCheckOutBottomView.h"
#import "STLAlertView.h"
#import "OSSVSMSVerifysView.h"
#import "OSSVCheckOutCodMsgAlertView.h"
#import "OSSVCouponApplyView.h"
#import "OSSVPersonalIdView.h"
#import "OSSVPayMentDiscountChangePopView.h"
#import "OSSVCheckOutGoodsAlterView.h"
#import "OSSVGetCoinsTableViewCell.h"
#import "OSSVFreeShippingView.h"
//ViewModels

#import "OSSVCartOrderInfoViewModel.h"
#import "OSSVMyCouponsListsModel.h"
#import "OSSVOrderInfoeModel.h"
#import "OSSVCheckOutPayModule.h"
#import "OSSVAdvsEventsManager.h"
#import "OSSVShowErrorManager.h"
#import "STLAlertControllerView.h"
#import "OSSVCoinCellModel.h"
#import "OSSVCodCancelAddAip.h"

#import "UINavigationController+FDFullscreenPopGesture.h"
#import <DXPopover.h>
#import "OSSVTipView.h"
#import "Adorawe-Swift.h"
#import "OSSVShippingCellModel.h"
#import "OSSVShippingMethCell.h"
#import "Adorawe-Swift.h"


@interface OSSVCheckOutVC ()
<
    UITableViewDelegate,
    UITableViewDataSource,
    OSSVSwitchCellDelegate,
    OSSVPayMentCellDelegate,
    STLPayTotalCellDelegate,
    STLArrowCellDelegate,
    OSSVAddressCellDelegate,
    OSSVCouponCellDelegate,
    OSSVCheckOutBottomViewDelegate,
    OSSVCheckOutProductListCellDelegate,
    OSSVPersonalIdViewDelegate,
    OSSVPayMentDiscountChangePopViewDelegate,
    OSSVGetCoinsTableViewCellDelegate
>
@property (nonatomic, strong) UITableView                        *checkOutTableView;
@property (nonatomic, strong) OSSVCheckOutBottomView              *checkOutBottomView;
@property (nonatomic, strong) OSSVSMSVerifysView                   *smsVerifyView;
@property (nonatomic, strong) OSSVCheckOutCodMsgAlertView         *codMsgAlertView;
@property (nonatomic, strong) OSSVCheckOutGoodsAlterView         *outGoodsAlterView;
@property (nonatomic, strong) OSSVCheckOutGoodsAlterView         *goodsListAlertView;
@property (nonatomic, strong) NSMutableArray                    *checkOutDataSourceList;
@property (nonatomic, strong) OSSVCartOrderInfoViewModel            *infoViewModel;
@property (nonatomic, strong) OSSVCartOrderInfoViewModel            *orderInfoPayModel;
@property (nonatomic, strong) id<OSSVCheckOutPayModuleProtocol>   payModule;         ///<因为在Block里会被释放，所以用全局持有
@property (nonatomic, strong) OSSVPersonalIdView                 *popView;  //身份证信息弹窗
@property (nonatomic, strong) OSSVPayMentDiscountChangePopView   *payMentPopView; //支付方式优惠改变的弹窗
@property (nonatomic, assign) BOOL isSelectPayMent; //是否选择了支付方式
@property (nonatomic, assign) BOOL isShowPayMentFooter; //是否展示支付方式的footer

@property (nonatomic, strong) NSMutableArray<OSSVCartGoodsModel*>   *noShipGoodsArray;
@property (nonatomic, assign) BOOL                              hadShipGoods;
@property (nonatomic, assign) BOOL                              isSelectKOLPayment; //是否选中KOL支付方式支付

@property (nonatomic,weak) OSSVAddressCell *addressCell;
@property (nonatomic,assign) BOOL isShowAddressFooter;
@property (nonatomic,weak) CALayer *paymethodBorder;
@property (nonatomic,weak) UILabel *payErrMsgLbl;
//无地址，向上滚动出现的View
@property (nonatomic,weak) AddressTopView *addressTopView;

@property (copy,nonatomic) NSString *addressFooterText;

//@property (nonatomic,strong) DXPopover *popover;
//@property (nonatomic,strong) OSSVTipView *tipView;
//
//@property (nonatomic,assign) BOOL isShowTips;
@end

@implementation OSSVCheckOutVC

-(void)dealloc
{
    DLog(@"OSSVCheckOutVC");
    if (_infoViewModel) {
        [_infoViewModel freesource];
        _infoViewModel = nil;
    }
    
    if (_outGoodsAlterView) {
        [_outGoodsAlterView removeFromSuperview];
        _outGoodsAlterView= nil;
    }
    
    if (_goodsListAlertView) {
        [_goodsListAlertView removeFromSuperview];
        _goodsListAlertView= nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!self.firstEnter && self.checkOutModel.wareHouseList.count > 0) {
        self.firstEnter = YES;
    }

    [self.navigationController.navigationBar setBackgroundImage:[UIImage yy_imageWithColor:[UIColor whiteColor]] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage yy_imageWithColor:OSSVThemesColors.col_EEEEEE]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (_outGoodsAlterView) {
        [_outGoodsAlterView dismiss];
    }
    
    if (_goodsListAlertView){
        [_goodsListAlertView dismiss];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [UIViewController lastViewControllerPageName];
    [[OSSVAnalyticPagesManager sharedManager] pageStartTime:NSStringFromClass(OSSVCheckOutVC.class)];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    NSString *startTime = [[OSSVAnalyticPagesManager sharedManager] startPageTime:NSStringFromClass(OSSVCheckOutVC.class)];
    NSString *endTime = [[OSSVAnalyticPagesManager sharedManager] endPageTime:NSStringFromClass(OSSVCheckOutVC.class)];

    NSString *timeLeng = [[OSSVAnalyticPagesManager sharedManager] pageEndTimeLength:NSStringFromClass(OSSVCheckOutVC.class)];
    [OSSVAnalyticsTool analyticsSensorsEventWithName:@"key_page_load" parameters:@{@"$screen_name":NSStringFromClass(OSSVCheckOutVC.class),
                                                                              @"$referrer":[UIViewController lastViewControllerPageName],
                                                                              @"$title":STLToString(self.title),
                                                                                @"$url":STLToString(@""),
                                                                                @"load_begin":startTime,
                                                                                @"load_end":endTime,
                                                                              @"load_time":timeLeng}];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = OSSVThemesColors.col_F5F5F5;
    self.title = STLLocalizedString_(@"orderInformation",nil);
//    self.fd_interactivePopDisabled = YES;
    self.isSelectPayMent = NO;
    self.isShowPayMentFooter = NO;
    self.isSelectKOLPayment = NO;
    //fffff暂停功能 隐藏 - points
    if (self.checkOutModel.points) {
        self.checkOutModel.points = nil;
    }
    self.infoViewModel.checkOutModel = self.checkOutModel;

    [self.view addSubview:self.checkOutTableView];
    [self.view addSubview:self.checkOutBottomView];
    
    
    [self.checkOutBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view);
    }];
 
    
    [self.checkOutTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (APP_TYPE == 3) {
            make.leading.trailing.equalTo(self.view);
        } else {
            make.leading.equalTo(self.view).offset(12);
            make.trailing.equalTo(self.view).offset(-12);
        }
        make.top.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.checkOutBottomView.mas_top);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCheckOrderData) name:kNotif_updateCheckOrder object:nil];
    
    AddressTopView *topView = [[AddressTopView alloc] init];
    self.addressTopView = topView;
    [self.view addSubview:topView];
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.equalTo(self.view);
        make.height.greaterThanOrEqualTo(44);
    }];
    topView.hidden = YES;
    topView.address = self.checkOutModel.address;
    
    @weakify(self)
    [topView addTapGestureWithComplete:^(UIView * _Nonnull view) {
       @strongify(self)
       [self addOrSelectAddress:self.addressTopView.address];
    }];
}
#pragma mark --接收到删除改订单页的地址，来更新下单接口
- (void)updateCheckOrderData {
    [self reloadCheckModel:nil completion:nil];
}
- (void)hanldOutGoods:(NSMutableArray<OSSVCartGoodsModel *> *)cartGoodsArray message:(NSString *)msg {
    
    [OSSVCheckOutGoodsAlterView fetchSizeShieldTipHeight:cartGoodsArray message:msg completion:^(NSAttributedString * _Nonnull stringAttributed, CGSize calculateSize) {
        
        self.outGoodsAlterView.contentHeight = UIScreen.mainScreen.bounds.size.height * 0.8;
        self.outGoodsAlterView.attributeMessage = stringAttributed;
        self.outGoodsAlterView.cartGoddsArray = cartGoodsArray;
        self.outGoodsAlterView.hasCanShip = self.hadShipGoods;
    }];
    
}

- (void)fillGoodsList:(NSMutableArray<OSSVCartGoodsModel *> *)cartGoodsArray message:(NSString *)msg {
    
    [OSSVCheckOutGoodsAlterView fetchSizeShieldTipHeight:cartGoodsArray message:msg completion:^(NSAttributedString * _Nonnull stringAttributed, CGSize calculateSize) {
        
        self.goodsListAlertView.contentHeight = UIScreen.mainScreen.bounds.size.height * 0.8;
//        self.goodsListAlertView.attributeMessage = stringAttributed;
        self.goodsListAlertView.cartGoddsArray = cartGoodsArray;
        self.goodsListAlertView.hasCanShip = self.hadShipGoods;
        self.goodsListAlertView.tipMessage = stringAttributed;
    }];
    
}

#pragma mark - tabelview datasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.checkOutDataSourceList count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *rows = self.checkOutDataSourceList[section];
    return [rows count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (DSYSTEM_VERSION < 11.0) {
        id <OSSVBaseCellModelProtocol> model = self.checkOutDataSourceList[indexPath.section][indexPath.row];
        return [tableView fd_heightForCellWithIdentifier:[model cellIdentifier] configuration:^(id<OSSVTableViewCellProtocol>cell) {
            cell.model = model;
        }];
    }
    return UITableViewAutomaticDimension;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 8;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 0 && self.isShowAddressFooter) {
        UILabel *lbl = [[UILabel alloc] init];
//        lbl.text = STLLocalizedString_(@"Please_fill_Shipping_address", nil);
        lbl.text = self.addressFooterText;
        lbl.font = [UIFont systemFontOfSize:12];
        lbl.textColor = OSSVThemesColors.col_B62B21;
        lbl.numberOfLines = 0;
        return lbl;
    }
    
    if (section == 1 && self.isShowPayMentFooter){
        UILabel *lbl = [[UILabel alloc] init];
        lbl.text = STLLocalizedString_(@"unSelectPayment", nil);
        lbl.font = [UIFont systemFontOfSize:12];
        lbl.textColor = OSSVThemesColors.col_B62B21;
        self.payErrMsgLbl = lbl;
        return lbl;
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0 && self.isShowAddressFooter) {//地址
        UILabel *lbl = [[UILabel alloc] init];
        lbl.text = self.addressFooterText;
        lbl.numberOfLines = 0;
        lbl.font = [UIFont systemFontOfSize:12];
        CGSize size = [lbl sizeThatFits:CGSizeMake(tableView.bounds.size.width - 28, CGFLOAT_MAX)];
        return size.height;
    }
    if (section == 1 && self.isShowPayMentFooter) {//支付方式
        return 26;
    }
    return 0.1;//CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id <OSSVBaseCellModelProtocol>model = self.checkOutDataSourceList[indexPath.section][indexPath.row];
    id <OSSVTableViewCellProtocol>cell = [tableView dequeueReusableCellWithIdentifier:[model cellIdentifier] forIndexPath:indexPath];
    model.indexPath = indexPath;
    cell.model = model;
    cell.delegate = self;
    if ([cell isKindOfClass:OSSVAddressCell.class]) {
        self.addressCell = (OSSVAddressCell *)cell;
    }
    
    if ([cell isKindOfClass:OSSVShippingMethCell.class]) {
        NSDictionary*attrCenterLine = @{NSFontAttributeName : [UIFont systemFontOfSize:10],
                 NSForegroundColorAttributeName : OSSVThemesColors.col_6C6C6C,
                 NSStrikethroughStyleAttributeName: @(NSUnderlineStyleSingle),
        };
        
        NSDictionary* attributesHightL = @{NSFontAttributeName : [UIFont systemFontOfSize:14], NSForegroundColorAttributeName : OSSVThemesColors.col_B62B21};
        NSDictionary* attributes = @{NSFontAttributeName : [UIFont systemFontOfSize:14]};
        OSSVShippingMethCell *shippingCell = (OSSVShippingMethCell*)cell;
        CartCheckFreeDataModel *feeData = self.checkOutModel.fee_data;
        if (feeData.shipping_regular_converted.length > 0 && feeData.shipping_regular.floatValue > 0 && feeData.shipping_regular.floatValue > feeData.shipping.floatValue) {
            NSAttributedString *src = [[NSAttributedString alloc] initWithString:STLToString(feeData.shipping_regular_converted)
                                                                      attributes:attrCenterLine];
            NSAttributedString *activityStr = [[NSAttributedString alloc] initWithString:STLToString(feeData.shipping_converted) attributes:attributesHightL];
            shippingCell.centerLinelbl.attributedText = src;
            shippingCell.priceLbl.attributedText = activityStr;
        }else{
            NSAttributedString *activityStr = [[NSAttributedString alloc] initWithString:STLToString(feeData.shipping_converted) attributes:attributes];
            shippingCell.centerLinelbl.attributedText = nil;
            shippingCell.priceLbl.attributedText = activityStr;
        }
    }
    return (UITableViewCell *)cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView roundedGroupWithWillDisplay:cell forRowAt:indexPath radius:6 backgroundColor:UIColor.whiteColor horizontolPadding:0];
    
    id <OSSVBaseCellModelProtocol>model = self.checkOutDataSourceList[indexPath.section][indexPath.row];
    if ([model isKindOfClass:OSSVPayMentCellModel.class]) {
        ///判断是否显示过提示
//        NSString *key = [NSString stringWithFormat:@"isShowedTipMessage_%@",OSSVAccountsManager.sharedManager.userToken];
//        BOOL isShowedTipmessage = [[NSUserDefaults standardUserDefaults] boolForKey:key];
////        isShowedTipmessage = false;
//        if (!isShowedTipmessage) {
//            NSString *tipmsg = ((OSSVPayMentCellModel *)model).payMentModel.dialog_tip_text;
//            if (tipmsg.length > 0) {
//                CGFloat x = SCREEN_WIDTH - 24;
//                CGFloat y = cell.frame.origin.y;
//                if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
//                    x = 24;
//                }
//                CGPoint destP = CGPointMake(x, y + 36);
//                self.tipView.tipMsgLbl.text = tipmsg;
//                if (!self.isShowTips) {
//                    [self.popover showAtPoint:destP popoverPostion:DXPopoverPositionDown withContentView:self.tipView inView:tableView];
//                    self.isShowTips = YES;
//                }
//            }
//        }
        
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    NSArray *visibleArray = [self.checkOutTableView visibleCells];
    BOOL findAddress = YES;
    OSSVAddressCell *addressCell = [self.checkOutTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if ([visibleArray containsObject:addressCell]) {
        findAddress = NO;
    }
    
    ///1.4.4  地址展示到顶部
    self.addressTopView.hidden = !findAddress;
}

#pragma mark - cell delegate

#pragma mark - 选择带箭头的cell <包括物流方式，选择优惠券，查看商品列表>
-(void)STL_ArrowDidClick:(OSSVArrowCellModel *)model {
    ///选择物流
    if ([model.dataSourceModel isKindOfClass:[OSSVCartShippingModel class]]) {
        OSSVCartShippingMethodVC *shippingMethodVC = [OSSVCartShippingMethodVC new];
        shippingMethodVC.curRate = self.infoViewModel.checkOutModel.currencyInfo;
        shippingMethodVC.shippingList = self.checkOutModel.shippingList;
        shippingMethodVC.shippingModel = (OSSVCartShippingModel *)model.dataSourceModel;
        self.infoViewModel.shippingModel = shippingMethodVC.shippingModel;
        if ([self.infoViewModel.paymentModel.payCode isEqualToString:@"Cod"]) {
            shippingMethodVC.isOptional = YES;
        }
        
        @weakify(self)
        shippingMethodVC.callBackBlock = ^(OSSVCartShippingModel *shippingModel){
            @strongify(self)
            if (![self.infoViewModel.shippingModel.sid isEqualToString:shippingModel.sid]) {

                __block CGFloat totalPrice = 0.0;
                self.infoViewModel.shippingModel = shippingModel;
                model.dataSourceModel = shippingModel;
                [model.depenDentModelList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    @strongify(self)
                    if (![obj isKindOfClass:[STLPayTotalCellModel class]])*stop = YES;
                    STLPayTotalCellModel *totalModel = obj;
                    totalModel.dataSourceModel = self.infoViewModel;
                    totalPrice += totalModel.totalPrice.floatValue;
                    if (!totalModel.indexPath) return;
                    if (totalModel.isShowingDetail) {
                        [totalModel handleTotalListDetailWithDataSoruce:self.checkOutDataSourceList];
                    }
                }];
                [self handleBottomTotalPrice:totalPrice];
                [self.checkOutTableView reloadData];
                
//                [self reloadCheckModel:nil completion:nil];

            }
        };
        
        [self.navigationController pushViewController:shippingMethodVC animated:YES];
    }
    ///选择优惠券
    if ([model.dataSourceModel isKindOfClass:[OSSVCartCheckModel class]]) {
        
        [GATools logOrderInfomationWithEventName:@"select_coupon" action:@""];
        
        OSSVCartSelectCouponVC *selectCoupon = [OSSVCartSelectCouponVC new];
        selectCoupon.cartGoodsArray = self.infoViewModel.effectiveProductList;
        selectCoupon.couponApplyView.couponModel = self.infoViewModel.checkOutModel.coupon;
        selectCoupon.viewModel.couponCode = self.infoViewModel.checkOutModel.coupon.code;
        selectCoupon.selectedModel = [[OSSVMyCouponsListsModel alloc] init];
        selectCoupon.selectedModel.couponCode = self.infoViewModel.checkOutModel.coupon.code;
        @weakify(self)
        selectCoupon.golBackBlock = ^(OSSVMyCouponsListsModel *couponModel){
            @strongify(self)
            self.infoViewModel.couponModel.code = couponModel.couponCode;
            [self reloadCheckModel:nil completion:nil];
        };
        self.infoViewModel.cartCheckType = CartCheckType_Coupon;
//        [self.navigationController pushViewController:selectCoupon animated:YES];
        OSSVNavigationVC *couponNav = [[OSSVNavigationVC alloc] initWithRootViewController:selectCoupon];
        couponNav.modalPresentationStyle = UIModalPresentationPageSheet;
        [self presentViewController:couponNav animated:YES completion:nil];
    }
    ///查看商品列表
    if ([model.dataSourceModel isKindOfClass:[OSSVCartWareHouseModel class]]) {
        //1.4.4  改成弹窗
        [self showList];
    }
}

#pragma mark - 查看商品列表
-(void)STL_CheckOutProductListDidClickCell:(OSSVProductListCellModel *)model
{
    //1.4.4 改成弹窗
    [self showList];
}

///1.4.4 更新地址Cell 状态
-(void)addressVadidate:(BOOL)valid{
    [self.checkOutTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    [self updateAddressCellBorder:valid];
    [self.checkOutTableView reloadData];
}

-(void)updateAddressCellBorder:(BOOL)valid{
    self.isShowAddressFooter = !valid;
    if (valid) {
        self.addressCell.layer.borderColor = [UIColor clearColor].CGColor;
        self.addressCell.layer.borderWidth = 0;
    }else{
        [self.checkOutTableView setContentOffset:CGPointMake(0, 0) animated:true];
        self.addressCell.layer.borderColor = OSSVThemesColors.col_B62B21.CGColor;
        self.addressCell.layer.borderWidth = 1;

        if (APP_TYPE == 3) {
            self.addressCell.layer.cornerRadius = 0;
        } else {
            self.addressCell.layer.cornerRadius = 6;
        }
    }
}

///1.4.4 更新支付方式状态
-(void)paymethodValidate:(BOOL)vaild{
    self.isShowPayMentFooter = !vaild;
    
    [self.paymethodBorder removeFromSuperlayer];
    
    if (vaild){
        [self.paymethodBorder removeFromSuperlayer];
        [self.payErrMsgLbl removeFromSuperview];
    }else{
        CGRect sectionRect = [self.checkOutTableView rectForSection:1];
        CGRect headerSection = [self.checkOutTableView rectForHeaderInSection:1];
        CGRect footerSection = [self.checkOutTableView rectForFooterInSection:1];
        
        sectionRect.origin.y += headerSection.size.height - self.checkOutTableView.contentOffset.y;
        sectionRect.size.height -= footerSection.size.height + 9;
        sectionRect = CGRectInset(sectionRect, 1, 0);
        
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:sectionRect cornerRadius:6];
        CAShapeLayer *layer = [[CAShapeLayer alloc] init];
        layer.path = path.CGPath;
        layer.strokeColor = OSSVThemesColors.col_B62B21.CGColor;
        layer.fillColor = UIColor.clearColor.CGColor;
        layer.lineWidth = 1;
        layer.frame = self.checkOutTableView.bounds;
        [self.checkOutTableView.layer addSublayer:layer];
        
        self.paymethodBorder = layer;
//        [self.checkOutTableView setNeedsDisplay];
        [self.checkOutTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:false];
    }
}

#pragma mark  选择地址
-(void)STL_DidClickAddressCell:(OSSVCheckOutAdressCellModel *)model
{
    [self addOrSelectAddress:model.addressModel];
}

-(void)addOrSelectAddress:(OSSVAddresseBookeModel *)address{
    if ([OSSVNSStringTool isEmptyString:address.addressId]) {
        [GATools logOrderInfomationWithEventName:@"shipping_information" action:@"Select_Address"];
        OSSVEditAddressVC *modifyAddressCtrl = [[OSSVEditAddressVC alloc] init];
        modifyAddressCtrl.saveBtnTitle = APP_TYPE == 3 ? STLLocalizedString_(@"SaveNContinue", nil) : STLLocalizedString_(@"SaveNContinue", nil).uppercaseString;
        @weakify(self)
        modifyAddressCtrl.successBlock = ^(NSString *addressID) {
            @strongify(self)
            
            if (addressID) {
                OSSVAddresseBookeModel *addressModel = [[OSSVAddresseBookeModel alloc] init];
                addressModel.addressId = [NSString stringWithFormat:@"%@",addressID];
                self.infoViewModel.addressModel = addressModel;
                self.isSelectPayMent = NO; //取消支付方式选中
                [self paymethodValidate:true];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_changePaymentSelectedIcon object:nil]; //发送通知更新选中图标
                self.infoViewModel.paymentModel = nil;
                [self reloadCheckModel:nil completion:nil];
                [self addressVadidate:true];
            }
        };
        [self.navigationController pushViewController:modifyAddressCtrl animated:YES];
        
        return;
    }
    [GATools logOrderInfomationWithEventName:@"shipping_information" action:@"Add_Address"];
    OSSVAddressOfsOrderEntersVC *addressVC = [OSSVAddressOfsOrderEntersVC new];
    addressVC.selectedAddressId = address.addressId;
    @weakify(self)
    addressVC.chooseDefaultAddressBlock = ^(OSSVAddresseBookeModel *addressModel) {
        @strongify(self)
        self.infoViewModel.addressModel = addressModel;
        self.isSelectPayMent = NO;//取消支付方式选中
        [self paymethodValidate:true];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_changePaymentSelectedIcon object:nil]; //发送通知更新选中图标
        self.infoViewModel.paymentModel = nil;

        [self reloadCheckModel:nil completion:nil];
        [self addressVadidate:true];
    };
    self.infoViewModel.cartCheckType = CartCheckType_Normal;
    addressVC.directReBackActionBlock = ^(OSSVAddresseBookeModel *modifyAddressModel){
        @strongify(self)
        self.infoViewModel.addressModel = modifyAddressModel;
        self.isSelectPayMent = NO;//取消支付方式选中
        [self paymethodValidate:true];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_changePaymentSelectedIcon object:nil]; //发送通知更新选中图标
        self.infoViewModel.paymentModel = nil;

        [self reloadCheckModel:nil completion:nil];
        [self addressVadidate:true];
    };
    [self.navigationController pushViewController:addressVC animated:YES];
}

#pragma mark  选择支付方式
-(void)STL_PayMentCellDidClick:(OSSVPayMentCellModel *)model
{
    [GATools logOrderInfomationWithEventName:@"payment_method"
                                      action:[NSString stringWithFormat:@"Select_%@",STLToString(model.payMentModel.payCode)]
    ];
    
    if (!model.payMentModel.isOptional)return;
//    if ([model.payMentModel.payCode isEqualToString:self.infoViewModel.paymentModel.payCode]) {return;}   //如果不屏蔽会导致COD支付选择不了
    if ([model.payMentModel isCodPayment]) {
        self.infoViewModel.checkOutModel.currencyInfo = self.checkOutModel.currency_list.currency_cod;
    }else{
        self.infoViewModel.checkOutModel.currencyInfo = self.checkOutModel.currency_list.currency_check;
    }
    if ([model.payMentModel isInfluencerPayment]) {
        self.isSelectKOLPayment = YES;
        self.infoViewModel.couponModel.code = @"";
        self.infoViewModel.coinPayType = @"0";
    } else {
        self.isSelectKOLPayment = NO;
    }
    //这里是为了刷新货币
    if (model.insuranceCellModel) {
        model.insuranceCellModel.rateModel = self.infoViewModel.checkOutModel.currencyInfo;
        model.insuranceCellModel.dataSourceModel = self.infoViewModel.checkOutModel;
    }
    if (model.saveCellModel) {
        model.saveCellModel.checkModel = self.infoViewModel.checkOutModel;
    }
    if (model.pointCellModel) {
        model.pointCellModel.rateModel = self.infoViewModel.checkOutModel.currencyInfo;
        model.pointCellModel.dataSourceModel = self.infoViewModel.checkOutModel.points;
    }
    if (model.productCellModel) {
        model.productCellModel.rateModel = self.infoViewModel.checkOutModel.currencyInfo;
    }
    NSIndexPath *currentIndexPath = model.indexPath;
    NSMutableArray *payMentList = self.checkOutDataSourceList[currentIndexPath.section];
    for (int i = 0; i < [payMentList count]; i++) {
        OSSVPayMentCellModel *payMentModel = payMentList[i];
        if ([payMentModel isKindOfClass:[OSSVPayMentCellModel class]]) {
            payMentModel.isSelect = NO;
            model.isSelect = YES;
            model.islast = i == payMentList.count - 1;
        }
    }
    
    self.isSelectPayMent = YES;
    [self paymethodValidate:true];
    self.infoViewModel.paymentModel = model.payMentModel;
    self.infoViewModel.paymentModel.isSelectedPayMent = self.isSelectPayMent;
    //选择不同支付方式，重新请求订单页面数据
        [self reloadCheckModel:nil completion:nil];

    //重新计算
//    __block CGFloat totalPrice = 0.0;
//    [model.depenDentModelList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        if (![obj isKindOfClass:[STLPayTotalCellModel class]])*stop = YES;
//        STLPayTotalCellModel *totalModel = obj;
//        totalModel.dataSourceModel = self.infoViewModel;
//        totalPrice += totalModel.totalPrice.floatValue;
//        if (!totalModel.indexPath) return;
//        if (totalModel.isShowingDetail) {
//            [totalModel handleTotalListDetailWithDataSoruce:self.checkOutDataSourceList];
//        }
//    }];
//    [self handleBottomTotalPrice:totalPrice];
    [self handleBottomTotalPrice:0];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_changePaymentSelectedIcon object:nil]; //发送通知更新选中图标

    [self.checkOutTableView reloadData];
}

#pragma mark  使用优惠券
-(void)STL_CouponCellDidClickApply:(OSSVCouponCellModel *)model
{
    if (model.status == ApplyButtonStatusClear) {
        model.couponModel.code = @"";
        self.infoViewModel.couponModel.code = @"";
    }else if(model.status == ApplyButtonStatusApply){
        self.infoViewModel.couponModel.code = model.couponModel.code;
    }
    self.infoViewModel.cartCheckType = CartCheckType_Coupon;
    [self reloadCheckModel:nil completion:nil];
}

#pragma mark  选择带switch的cell
-(void)STL_DidClickSwitch:(OSSVSwitchCellModel *)model
{
    ///处理
    if (model.depenType == TotalDetailTypeYpoint) {
        if (model.switchStatus) {
            self.infoViewModel.ypointModel = (OSSVPointsModel *)model.dataSourceModel;
        }else{
            self.infoViewModel.ypointModel = nil;
        }
        self.infoViewModel.cartCheckType = CartCheckType_Point;
        @weakify(self)
        [self reloadCheckModel:^{
            @strongify(self)
            self.infoViewModel.ypointModel = nil;
            OSSVSwitchCell *ypointCell = [self.checkOutTableView cellForRowAtIndexPath:model.indexPath];
            model.switchStatus = NO;
            ypointCell.model = model;
        } completion:nil];
    }
    //运费保险
    if (model.depenType == TotalDetailTypeShippingInsurance) {
        if (model.switchStatus) {
            self.infoViewModel.shippingInsurance = @"1";
        }else{
            self.infoViewModel.shippingInsurance = @"0";
        }
        @weakify(self)
        [self reloadCheckModel:^{
            
        } completion:^{
            @strongify(self)
            [self.checkOutTableView reloadData];
        }];
        
//        __block CGFloat totalPrice = 0.0;
//        NSMutableArray *dependList = model.depenDentModelList;
//        [dependList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            id <OSSVBaseCellModelProtocol>depenDentModel = obj;
//            ///找到依赖关系模型，修改模型数据, 增删改查
//            if (![depenDentModel isKindOfClass:[STLPayTotalCellModel class]]) {NSAssert(YES, @"依赖关系发生了错误");return;}
//            STLPayTotalCellModel *totalMoel = (STLPayTotalCellModel *)depenDentModel;
//            totalMoel.dataSourceModel = self.infoViewModel;
//            totalPrice += totalMoel.totalPrice.floatValue;
//            if (!totalMoel.indexPath) return;
//            if (totalMoel.isShowingDetail) {
//                ///重置显示详情
//                [totalMoel handleTotalListDetailWithDataSoruce:self.checkOutDataSourceList];
//            }
//        }];
//        [self handleBottomTotalPrice:totalPrice];
        
    }
}

#pragma mark  选择商品列表的小计
-(void)STLPrdTotalDidClick:(STLPayTotalCellModel *)model
{
    NSIndexPath *currentIndexPath = model.indexPath;
    NSMutableArray *payMentList = self.checkOutDataSourceList[currentIndexPath.section];
    NSMutableArray *reloadIndexPath = [[NSMutableArray alloc] init];
    if (!model.isShowingDetail) {
        //隐藏
        NSArray *detailList = [payMentList subarrayWithRange:model.detailRange];
        if (![model.dependModelList count]) {
            [model.dependModelList addObjectsFromArray:detailList];
        }
        for (NSUInteger i = model.detailRange.location; i < payMentList.count; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:currentIndexPath.section];
            [reloadIndexPath addObject:indexPath];
        }
        [payMentList removeObjectsInRange:model.detailRange];
        [self.checkOutTableView beginUpdates];
        [self.checkOutTableView deleteRowsAtIndexPaths:reloadIndexPath withRowAnimation:UITableViewRowAnimationBottom];
        [self.checkOutTableView endUpdates];
    }else{
        //显示
        [payMentList addObjectsFromArray:model.dependModelList];
        [payMentList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[OSSVTotalDetailCellModel class]]) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:currentIndexPath.section];
                [reloadIndexPath addObject:indexPath];
            }
        }];
        [self.checkOutTableView insertRowsAtIndexPaths:reloadIndexPath withRowAnimation:UITableViewRowAnimationTop];
        [self.checkOutTableView scrollToRowAtIndexPath:[reloadIndexPath lastObject] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

#pragma mark  点击了运费物流的问号
-(void)STL_DidClickQuestionMarkButton:(OSSVSwitchCellModel *)model
{
    if ([model.dataSourceModel isKindOfClass:[OSSVCartCheckModel class]]) {
        [OSSVAlertsViewNew showAlertWithAlertType:STLAlertTypeButton isVertical:YES messageAlignment:NSTextAlignmentLeft isAr:YES showHeightIndex:0 title:@"" message:STLLocalizedString_(@"insuranceDescribeNewContent", nil) buttonTitles:APP_TYPE == 3 ? @[STLLocalizedString_(@"ok",nil)]: @[STLLocalizedString_(@"ok",nil).uppercaseString] buttonBlock:^(NSInteger index, NSString * _Nonnull title) {
        }];
    }
}

#pragma mark  点击了优惠券问号
-(void)STL_ArrowDidClickQuestionMarkButton:(OSSVArrowCellModel *)model
{
    if ([model.dataSourceModel isKindOfClass:[OSSVCartCheckModel class]]) {
        [OSSVAlertsViewNew showAlertWithAlertType:STLAlertTypeButton isVertical:YES messageAlignment:NSTextAlignmentLeft isAr:YES showHeightIndex:0 title:@"" message:[NSString couponUseDesc] buttonTitles:APP_TYPE == 3 ? @[STLLocalizedString_(@"confirm",nil)]: @[STLLocalizedString_(@"confirm",nil).uppercaseString] buttonBlock:^(NSInteger index, NSString * _Nonnull title) {
        }];
    }
}
#pragma mark ---点击金币支付的问号说明
- (void)STL_coinButtonDidClickQuestionMarkButton:(OSSVArrowCellModel *)model {
    
    [OSSVAlertsViewNew showAlertWithAlertType:STLAlertTypeButton isVertical:YES messageAlignment:NSTextAlignmentLeft isAr:YES showHeightIndex:0 title:@"" message:[NSString cashBackHeadline] buttonTitles:APP_TYPE == 3 ? @[STLLocalizedString_(@"confirm",nil)]: @[STLLocalizedString_(@"confirm",nil).uppercaseString] buttonBlock:^(NSInteger index, NSString * _Nonnull title) {
    }];
}
#pragma mark ---点击订单返现的问号说明
- (void)coinInstructionPopView {
    
    [OSSVAlertsViewNew showAlertWithAlertType:STLAlertTypeButton isVertical:YES messageAlignment:NSTextAlignmentLeft isAr:YES showHeightIndex:0 title:@"" message:[NSString cashBackHeadline] buttonTitles:APP_TYPE == 3 ? @[STLLocalizedString_(@"confirm",nil)]: @[STLLocalizedString_(@"confirm",nil).uppercaseString] buttonBlock:^(NSInteger index, NSString * _Nonnull title) {
    }];
}

#pragma mark ----选中使用金币
- (void)STL_coinSelectPayDidClickButton:(BOOL )isUserCoin {
    if (isUserCoin) {
        NSLog(@"使用金币");
        self.infoViewModel.coinPayType = @"1";
    } else {
        NSLog(@"不使用金币");
        self.infoViewModel.coinPayType = @"0";
    }
    
    @weakify(self)
    [self reloadCheckModel:^{
        @strongify(self)
        //为了失败还原状态
        [self.checkOutTableView reloadData];

    } completion:nil];
}
#pragma mark - 结算按钮事件
-(void)STL_CheckOutBottomDidClickBuy:(OSSVCartOrderInfoViewModel *)model {
    

    self.orderInfoPayModel = model;

    BOOL isValid = YES;
    if (!model.addressModel) {
//        [HUDManager showHUDWithMessage:STLLocalizedString_(@"Please_fill_Shipping_address", nil)];
        ///1.4.4  地址红框  + 定位
        self.addressFooterText = STLLocalizedString_(@"Please_fill_Shipping_address", nil);
        [self addressVadidate:false];
        
        isValid = NO;
    } else if ([model.paymentModel.payCode isEqualToString:@"Cod"] && !model.paymentModel.isOptional) {
        //支付方式只有COD并且不可选的时候
        [HUDManager showHUDWithMessage:model.paymentModel.payHelp];
        isValid = NO;
    }
    
    //////*************************此提示不再要了********************************//
//    if (model.paymentModel == nil) {
//        [HUDManager showHUDWithMessage:STLLocalizedString_(@"selectShippingOrPay", nil)];
//        return;
//    }
    //所有的支付方式都没选择的情况下----先选中COD，再去选择优惠券，COD不可用的情况
    else if (!self.isSelectPayMent || !model.paymentModel.isOptional) {
//        self.checkOutDataSourceList = nil;
//        [self checkOutDataSourceList];
        [self paymethodValidate:false];
//        [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_changePaymentSelectedRedIcon object:nil]; //发送通知更新选择圈圈为红色
        ///1.4.4  整组红框移动到顶部
        
        [self.checkOutTableView reloadData];
        isValid = NO;
    }
    else if (model.shippingModel == nil) {
        [HUDManager showHUDWithMessage:STLLocalizedString_(@"selectShippingOrPay", nil)];
        isValid = NO;
    }
    
    //是否有屏蔽商品
    else if (self.noShipGoodsArray.count > 0) {
        self.outGoodsAlterView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        [WINDOW addSubview:self.outGoodsAlterView];
        [self.outGoodsAlterView show];
        isValid = NO;
    }
    
    NSString *contacts = [NSString stringWithFormat:@"%@ %@",
                          STLToString(model.checkOutModel.address.firstName),
                          STLToString(model.checkOutModel.address.lastName)];
    
    
    NSArray *counrty = [model.checkOutModel.address.country componentsSeparatedByString:@"/"];
    NSArray *state = [model.checkOutModel.address.state componentsSeparatedByString:@"/"];
    NSArray *city = [model.checkOutModel.address.city componentsSeparatedByString:@"/"];
    NSArray *street = [model.checkOutModel.address.street componentsSeparatedByString:@"/"];

    NSString *countryString = counrty.firstObject;
    NSString *stateString = state.firstObject;
    NSString *cityString = city.firstObject;
    NSString *streetString = street.firstObject;

    NSArray *addressArray = @[streetString,cityString,stateString,countryString];
    NSString *addressString = [addressArray componentsJoinedByString:@","];
    
    NSString *payType = @"normal";
    NSDictionary *sensorsDic = @{@"order_type":payType,
                                 @"order_actual_amount":@([STLToString(model.checkOutModel.fee_data.total) floatValue]),
                                 @"total_price_of_goods"        :   @([STLToString(model.checkOutModel.fee_data.product) floatValue]),
                                 @"currency":@"USD",
                                 @"payment_method":STLToString(model.paymentModel.payCode),
                                 @"receiver_name"      :   STLToString(contacts),
                                 @"receiver_country"      :   STLToString(countryString),
                                 @"receiver_province"        :   STLToString(stateString),
                                 @"receiver_city"           :   STLToString(cityString),
                                 @"receiver_district"   :   STLToString(streetString),
                                 @"receiver_address"   :   STLToString(addressString),
                                 @"shipping_fee"        :   @([STLToString(model.checkOutModel.fee_data.shipping) floatValue]),
                                 @"discount_id":STLToString(model.couponModel.code),
                                 @"discount_amount":@([STLToString(model.checkOutModel.fee_data.coupon_save) floatValue]),
                                 @"is_use_discount":(STLIsEmptyString(model.couponModel.code) ? @(0) : @(1)),
                                 @"is_success": @(isValid),

    };
    [OSSVAnalyticsTool analyticsSensorsEventWithName:@"ClickPlaceOrder" parameters:sensorsDic];
    
    
    if (isValid) {//校验通过
        if (model.paymentModel.isOptional && [model.paymentModel.payCode isEqualToString:@"Cod"]) {
            //cod结算           
            [self checkOut:model];
            
        } else {
            [self checkOut:model];
        }
    }
}


#pragma mark - COD取消原因
- (void)cancelCodReason {
    [self.codMsgAlertView show];
}

- (void)codCancelRequest:(NSString *)type {
    
    NSString *contacts = [NSString stringWithFormat:@"%@ %@",
                          STLToString(self.orderInfoPayModel.checkOutModel.address.firstName),
                          STLToString(self.orderInfoPayModel.checkOutModel.address.lastName)];
    
    NSString *address = [NSString stringWithFormat:@"%@-%@-%@-%@-%@",
                         STLToString(self.orderInfoPayModel.checkOutModel.address.country),
                         STLToString(self.orderInfoPayModel.checkOutModel.address.state),
                         STLToString(self.orderInfoPayModel.checkOutModel.address.city),
                         STLToString(self.orderInfoPayModel.checkOutModel.address.street),
                         STLToString(self.orderInfoPayModel.checkOutModel.address.streetMore)];
    
    NSString *userPhoneNum = [NSString stringWithFormat:@"+%@ %@%@",
                              self.orderInfoPayModel.checkOutModel.address.countryCode,
                              STLToString(self.orderInfoPayModel.checkOutModel.address.phoneHead), self.orderInfoPayModel.checkOutModel.address.phone];
    CGFloat paymentAmount;
    NSString *currency;
    
    if (self.orderInfoPayModel.checkOutModel.currencyInfo) {
        currency = self.orderInfoPayModel.checkOutModel.currencyInfo.code;
//        paymentAmount = self.orderInfoPayModel.totalPrice;
    } else {
        currency = [ExchangeManager localCurrency].code;
//        paymentAmount = self.orderInfoPayModel.totalPrice;
    }
    paymentAmount = [self.checkOutModel.fee_data.product floatValue];
    
    NSDictionary *params = @{@"cancel_type"  :STLToString(type),
                             @"address"      :address,
                             @"phone"        :userPhoneNum,
                             @"receiver"     :contacts,
                             @"amount"       :@(paymentAmount),
                             @"currency"     :STLToString(currency),
                             @"api_currency" :STLToString(currency),
                             };
    
    OSSVCodCancelAddAip *codCancelApi = [[OSSVCodCancelAddAip alloc] initWithDict:params];
    [codCancelApi startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
        NSLog(@"----- codCancell Success");
    } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
        NSLog(@"----- codCancell failure: %@",error.debugDescription);
    }];
}

#pragma mark - private method-----结算创建订单

- (void)checkOutAndPay {
    [self reloadCheckModel:nil completion:^{
        [self checkOut:self.checkOutBottomView.dataSourceModel];
    }];
}

-(void)checkOut:(OSSVCartOrderInfoViewModel *)model {

    @weakify(self)
    [self.infoViewModel requestNetwork:model completion:^(OSSVCreateOrderModel *orderModel) {
        @strongify(self)
        if (!orderModel) {
            [self analyticsOrderSubmit:nil orderInfoViewModel:model resultState:NO];
            return;
        }

        BOOL resultState = YES;
        if (orderModel.statusCode != kStatusCode_200) {
            resultState = NO;
            //没有查询到身份证信息，需要弹窗----与接口约定状态码208 或者210
            if (orderModel.statusCode == kStatusCode_208 || orderModel.statusCode == kStatusCode_210) {
                self.popView = [[OSSVPersonalIdView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
                self.popView.delegate = self;
                self.popView.infoModel = model;
                [self.popView showView];
                
            } else if (orderModel.statusCode == kStatusCode_209) {
                //支付优惠有所改变，需要弹窗----与接口约定状态码209
                self.payMentPopView = [[OSSVPayMentDiscountChangePopView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
                self.payMentPopView.delegate = self;
                [self.payMentPopView showView];
                
            } else {
                orderModel.message ? [HUDManager showHUDWithMessage:orderModel.message] : nil;

            }
            
        } else {

            //下单成功，通知购物车刷新页面
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_Cart object:nil];

            if ([model.paymentModel.payCode isEqualToString:@"Cod"]) {

                [self analyticsOrderSubmit:orderModel orderInfoViewModel:model resultState:resultState];

                STLOrderModel *tempFirstOrder = orderModel.orderList.firstObject;

                OSSVAccounteMyeOrdersListeModel *tempOrderModel = [[OSSVAccounteMyeOrdersListeModel alloc] init];
                tempOrderModel.orderId = tempFirstOrder.order_id;
                tempOrderModel.selAddressModel = model.addressModel;
                tempOrderModel.payCode = @"Cod";
                [OSSVAdvsEventsManager advEventOrderListWithPaymentStutas:STLOrderPayStatusDone OSSVAddresseBookeModel:tempOrderModel];

                return;
            }

            /*
             如果是KOL网红单支付，则直接跳转到支付成功页
             */
            if ([model.paymentModel.payCode isEqualToString:@"Influencer"]) {
               
                OSSVOrderFinishsVC *orderFinishVC = [OSSVOrderFinishsVC new];
                orderModel.payCode = STLToString(self.infoViewModel.paymentModel.payCode);
                orderModel.orderAmount = STLToString(self.infoViewModel.checkOutModel.fee_data.total_converted);
                orderModel.payName = STLToString(self.infoViewModel.paymentModel.payName);
                orderFinishVC.createOrderModel = orderModel;
//                orderFinishVC.createOrderModel.orderList = model.effectiveProductList;
                orderFinishVC.block = ^{
                    [OSSVAdvsEventsManager advEventOrderListWithPaymentStutas:STLOrderPayStatusDone];
                };
                [self.navigationController pushViewController:orderFinishVC animated:YES];

            } else {
                // 正常下单
                id<OSSVCheckOutPayModuleProtocol>payModule = [OSSVCheckOutPayModule handleCheckOutPay:model.paymentModel.payCode];
                if (payModule) {
                    orderModel.shippingFee = self.infoViewModel.shippingModel.shippingFee;
                    orderModel.couponCode = self.infoViewModel.couponModel.code;
                    orderModel.payCode = self.infoViewModel.paymentModel.payCode;
                    orderModel.orderAmount = self.infoViewModel.checkOutModel.fee_data.total_converted;
                    orderModel.payName = STLToString(self.infoViewModel.paymentModel.payName);
                    payModule.OSSVOrderInfoeModel = orderModel;
                    payModule.OSSVOrderInfoeModel.goodsList = model.effectiveProductList;
                    payModule.controller = self;
                    @weakify(self)
//                    if ([payModule isKindOfClass:[OSSVCodPayModule class]]) {
//                        payModule.payModuleFinsh = ^{
//                            @strongify(self)
//                            if ([model.paymentModel.payCode isEqualToString:@"Cod"]) {
//                                [self.smsVerifyView coolse];
//                            }
//                        };
//                    }
                    [payModule handlePay];
                    payModule.onalyAnalyticsBlock = ^(STLOrderPayStatus status) {
                        @strongify(self)
                        [self analyticsOrderPay:orderModel orderInfoViewModel:model resultState:status == STLOrderPayStatusDone];
                    };
                    self.payModule = payModule;
                }else{
                    DLog(@"不支持的支付方式");
                }
            }
        }
        
        [self analyticsOrderSubmit:orderModel orderInfoViewModel:model resultState:resultState];
        
    } failure:^(id obj) {
        @strongify(self)
        STLAlertViewController *alertController = [STLAlertViewController alertControllerWithTitle:nil message:STLLocalizedString_(@"createFailed", nil) preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:APP_TYPE == 3 ? STLLocalizedString_(@"ok",nil) : STLLocalizedString_(@"ok",nil).uppercaseString style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        }]];
        [self presentViewController:alertController animated:YES completion:^{}];
    }];
}


#pragma mark --OSSVPersonalIdViewDelegate-----身份信息 确认的代理方法
- (void)payMentWithIdCard:(UITextField *)textField {
    //国家ID：172：沙特， 125：约旦， 165：卡塔尔   这几个国家需要身份证号
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_orderCreateWithIdCard object:nil userInfo:@{@"idCard":textField.text}];
        [self checkOut:self.infoViewModel];
}

#pragma mark --OSSVPayMentDiscountChangePopViewDelegate --支付方式优惠比例变化OK健 确认
- (void)updateOrderMakeSure {
    //重新请求数据
    [self reloadCheckModel:nil completion:nil];
}




#pragma mark --重新请求订单页面数据
-(void)reloadCheckModel:(void(^)(void))failBlock completion:(void(^)(void))completionBlock
{
    @weakify(self)
    [self.infoViewModel requestCartCheckNetwork:self.infoViewModel completion:^(OSSVCartCheckModel *obj) {
        @strongify(self)
        if (obj && [obj isKindOfClass:[OSSVCartCheckModel class]]) {
            if (obj.statusCode == kStatusCode_200 && obj.flag == CartCheckOutResultEnumTypeSuccess) {
                self.checkOutModel = obj;
                
                //fffff暂停功能 隐藏 - points
                if (self.checkOutModel.points) {
                    self.checkOutModel.points = nil;
                }
                self.infoViewModel.checkOutModel = self.checkOutModel;
                [self.checkOutDataSourceList removeAllObjects];
                [self reloadTableViewDatasource:self.checkOutDataSourceList];
//                self.isShowTips = NO;
                [self.checkOutTableView reloadData];
                self.addressTopView.address = obj.address;
                if (completionBlock) {
                    completionBlock();
                }
            }else{
//                //失败的处理
//                if (obj.statusCode == 202) {
//                    ///优惠券不可用
//                    self.checkOutModel.coupon.code = @"";
//                    self.checkOutModel.coupon.save = @"";
//                    self.infoViewModel.couponModel.save = @"";
//                    self.infoViewModel.couponModel.code = @"";
//                    [self.checkOutTableView reloadData];
//                }
                [obj modalErrorMessage:self errorManager:[OSSVShowErrorManager new]];
                ///失败的时候给个回调，为了方便刷新用户操作数据
                if (failBlock) {
                    failBlock();
                }
            }
        } else {
            ///失败的时候给个回调，为了方便刷新用户操作数据
            if (failBlock) {
                failBlock();
            }
        }
    } failure:^(id obj) {
        ///失败的时候给个回调，为了方便刷新用户操作数据
        if (failBlock) {
            failBlock();
        }
    }];
}

///设置底部总价格
-(void)handleBottomTotalPrice:(CGFloat)totalPrice
{
//    self.infoViewModel.totalPrice = totalPrice;
    self.checkOutBottomView.dataSourceModel = self.infoViewModel;
}

#pragma mark ----加载数据并创建UI

///分组里面放数组不好管理
-(void)reloadTableViewDatasource:(NSMutableArray *)list
{
    ///地址
    OSSVCheckOutAdressCellModel *addressModel = [[OSSVCheckOutAdressCellModel alloc] init];
    addressModel.addressModel = self.checkOutModel.address;
    [list addObject:[@[addressModel] mutableCopy]];
    self.infoViewModel.addressModel = self.checkOutModel.address;
    
    ///处理支付方式
    NSArray *payMentList = [self handlePayment:list];
    
    /**
     *  物流保险视图关系
     *  物流方式Header
     *        +
     *  选择的物流方式
     *        +
     *  可选择的物流保险
     **/
    
    //暂时隐藏运费险
    ///处理物流保险
    ///
    OSSVSwitchCellModel *shippInsuranceModel = [self handleShippingInsurance];
    OSSVShippingCellModel *shippingCellModel = nil;
    
    //在不选中支付方式的情况下， 不添加物流入口
    if (self.isSelectPayMent) {
                ///依赖关系的model-->shippingmodel-->STLPayTotalCellModel
        {
            NSMutableArray *shippingMethodSection = [NSMutableArray array];
            ///物流方式
            STLNormalHeadCellModel *shippingNoromalModel = [STLNormalHeadCellModel initWithTitile:[STLLocalizedString_(@"shipMethod", nil) uppercaseString]];
            [shippingMethodSection addObject:shippingNoromalModel];
            if (self.infoViewModel.shippingModel) {
                ///如果有物流方式
                shippingCellModel = [[OSSVShippingCellModel alloc] init];
                shippingCellModel.dataSourceModel = self.infoViewModel.shippingModel;
                [shippingMethodSection addObject:shippingCellModel];
                
                //暂时隐藏运费险
                ///添加运费保险model
                ///
                [shippingMethodSection addObject:shippInsuranceModel];
            }
            [list addObject:shippingMethodSection];
        }
    }
    STLCouponSaveCellModel *couponSaveCellModel = [[STLCouponSaveCellModel alloc] init];
    OSSVCoinCellModel       *coinModel = [[OSSVCoinCellModel alloc] init];
    //KOL支付方式不展示优惠券和金币
    if (!self.isSelectKOLPayment) {
        //1.4.4 放到一个group 里面
        NSMutableArray *tempList = [[NSMutableArray alloc] init];
        NSMutableArray *couponCoinGroup = [[NSMutableArray alloc] init];
        ///处理优惠券
        couponSaveCellModel = [self handleCoupon:tempList];
        
        ///增加金币支付cell
        ///vivaia 隐藏金币
//        coinModel = [self handleCoin:tempList];
        
        for (NSArray *littleGp in tempList) {
            [couponCoinGroup addObjectsFromArray:littleGp];
        }
        [list addObject:couponCoinGroup];
        
    }
    
    

    ///处理积分 依赖关系的model-->STLPayTotalCellModel
    OSSVSwitchCellModel *ypointModel = [self handleYPoint:list];

    ///数据清空操作,清空用户有效的商品列表
    [self.infoViewModel.effectiveProductList removeAllObjects];
    
    [self.noShipGoodsArray removeAllObjects];
    self.hadShipGoods = NO;
    //1.4.4 goodsList 弹窗
    
    //当所有仓库都不支持的时候，只显示地址的错误提示
    if ([self.checkOutModel.wareHouseList count]) {
//        __block CGFloat totalAllPrice = 0.0;
        //重置仓库商品信息
        [self.checkOutModel.wareHouseList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![obj isKindOfClass:[OSSVCartWareHouseModel class]])*stop = YES;
            OSSVCartWareHouseModel *wareHouseModel = obj;
            
            NSMutableArray *productSection = [[NSMutableArray alloc] init];
            ///列表头
            OSSVArrowCellModel *productHeadModel = [[OSSVArrowCellModel alloc] init];
            productHeadModel.dataSourceModel = wareHouseModel;
            [productSection addObject:productHeadModel];
            ///商品列表容器
            OSSVProductListCellModel *productModel = [[OSSVProductListCellModel alloc] init];
            productModel.rateModel = self.infoViewModel.checkOutModel.currencyInfo;
            productModel.dataSourceModel = wareHouseModel;
            [productSection addObject:productModel];
            
            ///当后台返回的字段为1 或者支付方式和物流方式支持某一种的时候，显示支付信息详情
            if (wareHouseModel.isShowSubtotal && (self.infoViewModel.paymentModel || self.infoViewModel.shippingModel)) {
                STLPayTotalCellModel *totalModel = [[STLPayTotalCellModel alloc] init];
                totalModel.index = idx;
                totalModel.dataSourceModel = self.infoViewModel;
                totalModel.isShowingDetail = NO;
                ///此处设置indexPath是因为tableview在加载完成后，这里由于没有滑动的到，一直为nill，所以在切换支付方式的时候，取不到这个indexPath，导致界面无法正常更新
                ///其实到这里的时候，已经是知道了indexPath是多少了，所以自己先赋值，后续其实还是用cell自己的indexPath赋值，更准确
                totalModel.indexPath = [NSIndexPath indexPathForRow:[productSection count] inSection:[list count]];
                [productSection addObject:totalModel];
                //total -> switch 设置依赖关系
                if (shippInsuranceModel) {
                    [shippInsuranceModel.depenDentModelList addObject:totalModel];
                }
                if (ypointModel) {
                    [ypointModel.depenDentModelList addObject:totalModel];
                }
                //物流方式 -> 依赖关系
                if (shippingCellModel) {
                    [shippingCellModel.depenDentModelList addObject:totalModel];
                }
                //支付方式 ->依赖关系
                if ([payMentList count] > 1) {
                    [payMentList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if ([obj isKindOfClass:[OSSVPayMentCellModel class]]) {
                            
                            //PaymentCellModel  赋值
                            OSSVPayMentCellModel *paymentModel = obj;
                            [paymentModel.depenDentModelList addObject:totalModel];
                            paymentModel.insuranceCellModel = shippInsuranceModel;
                            paymentModel.pointCellModel = ypointModel;
                            paymentModel.productCellModel = productModel;
                            paymentModel.coinCellModel = coinModel;

                            paymentModel.saveCellModel = couponSaveCellModel;
                            paymentModel.checkModel = self.checkOutModel;
                            paymentModel.islast = idx == payMentList.count - 1;
                        }
                    }];
                }
                
                ///将有效商品加入到数组
                [self.infoViewModel.effectiveProductList addObjectsFromArray:wareHouseModel.goodsList];
                ///将现有仓库状态存到viewModel
                
                if ([self.checkOutModel.wareHouseList count] == 1) {
                    //当只有一个仓库的时候，需要隐藏小计栏，默认显示详情
                    totalModel.isHiddenCell = YES;
                    totalModel.isShowingDetail = YES;
                    [productSection addObjectsFromArray:totalModel.dependModelList];
                }
                
//                totalAllPrice += totalModel.totalPrice.floatValue;
            }else{
                ///不支持仓库和物流的情况下，显示错误信息
                if (self.infoViewModel.paymentModel != nil && self.infoViewModel.shippingModel != nil) {
                    STLShowErrorCellModel *errorModel = [[STLShowErrorCellModel alloc] init];
                    if (wareHouseModel.wid.integerValue == 1) {
                        errorModel.errorMessage = STLLocalizedString_(@"nosupporSaudi", nil);
                    }else if(wareHouseModel.wid.integerValue == 2){
                        errorModel.errorMessage = STLLocalizedString_(@"nosupporGlobal", nil);
                    }
                    [productSection addObject:errorModel];
                }
            }
            
            //1.4.4 这里挪到商品列表了
            //返回金币文案的View
            if (STLToString(self.checkOutModel.rebate_activity_info).length) {
                STLGetCoinsTableViewCellModel *coinModel = [STLGetCoinsTableViewCellModel initWithTitile:STLToString(self.checkOutModel.rebate_activity_info)];

                [productSection insertObject:coinModel atIndex:1];
            }
            [list addObject:productSection];
            
            if (wareHouseModel.goodsList) {
                [wareHouseModel.goodsList enumerateObjectsUsingBlock:^(OSSVCartGoodsModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj.shield_status integerValue] == 1) {
                        [self.noShipGoodsArray addObject:obj];
                    } else {
                        self.hadShipGoods = YES;
                    }
                }];
            }
        }];
        
        [self hanldOutGoods:self.noShipGoodsArray message:STLToString(self.checkOutModel.goods_shield_info.shield_tips)];
        self.infoViewModel.wareHouseModelList = self.checkOutModel.wareHouseList;
//        [self handleBottomTotalPrice:totalAllPrice];
        [self handleBottomTotalPrice:0];

    }
    
    NSMutableArray *goods = [[NSMutableArray alloc] init];
    for (OSSVCartWareHouseModel* item in self.checkOutModel.wareHouseList) {
        if(item.goodsList.count){
            [goods addObjectsFromArray:item.goodsList];
        }
    }
    [self fillGoodsList:goods message:STLToString(self.checkOutModel.goods_shield_info.shield_tips)];
}

///处理支付方式， 返回一个 OSSVPayMentCellModel 的数组
-(NSArray *)handlePayment:(NSMutableArray *)dataList
{
    ///默认先选一个cod 汇率模型（最新需求， 默认不是COD的模型）
    self.infoViewModel.checkOutModel.currencyInfo = self.checkOutModel.currency_list.currency_check;
    /**
     *  支付方式视图模型
     *  支付方式Header
     *       +
     *  多个可选择的支付方式
     **/
    NSMutableArray *payMentList = [[NSMutableArray alloc] init];

    //如果后台返回了支付方式列表，并且需要刷新的时候，进入到这里的流程
    if (![self.checkOutModel.paymentList count]) {
        ///支付方式
        STLNormalHeadCellModel *model = [STLNormalHeadCellModel initWithTitile:[STLLocalizedString_(@"paymentMethod", nil) uppercaseString]];
        [payMentList addObject:model];
        [dataList addObject:payMentList];
        //地址不支持支付地址栏下要加一个错误信息提示
        ///1.4.4 修改样式
        [self updateAddressCellBorder:false];
        self.addressFooterText = STLLocalizedString_(@"nosupporAddress", nil);
//        STLShowErrorCellModel *addressErrorModel = [[STLShowErrorCellModel alloc] init];
        
//        [dataList[0] addObject:addressErrorModel];
        self.infoViewModel.paymentModel = nil;
        self.infoViewModel.shippingInsurance = nil;
        return payMentList;
    }
    
    ///是否包含COD
    __block BOOL isCod = NO;
    ///如果之前选择的支付方式还存在
    __block BOOL oldPaymentNot = NO;
    __block NSString *oldPayCode = self.infoViewModel.paymentModel.payCode;
    self.infoViewModel.paymentModel = nil;
    [self.checkOutModel.paymentList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        OSSVPayMentCellModel *payMentModel = [[OSSVPayMentCellModel alloc] init];
        payMentModel.payMentModel = obj;
        if ([payMentModel.payMentModel.payCode isEqualToString:oldPayCode]) {
            //在后台返回的支付列表里找到了用户之前选择的
            if (payMentModel.payMentModel.isOptional && self.isSelectPayMent) { //新增判断是否有选中支付方式
                payMentModel.isSelect = YES;
                oldPaymentNot = YES;
                self.infoViewModel.paymentModel = payMentModel.payMentModel;
                self.infoViewModel.paymentModel.isSelectedPayMent = self.isSelectPayMent;
            }
        }
        //去掉此判断，因为默认不是选中COD支付的
//        if ([payMentModel.payMentModel isCodPayment]) {
//            //后台返回的列表中有COD
//            isCod = YES;
//        }
        [payMentList addObject:payMentModel];
    }];
    
    if (!oldPaymentNot) {
        ///如果之前选择的支付方式不在后台返回的支付方式列表中
        self.infoViewModel.paymentModel = nil;
        [payMentList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            OSSVPayMentCellModel *payMentModel = obj;
            if (payMentModel.payMentModel.isOptional) {
                payMentModel.isSelect = NO;    //以前是yes，改为No后，取消选中
                //self.infoViewModel.paymentModel = payMentModel.payMentModel;//不再赋值支付方式
                *stop = YES;
            }
        }];
    }
    
    if (!self.infoViewModel.paymentModel.isOptional) {
        ///如果没有一个可选的支付方式，默认选择一个COD，为什么能要选择一个COD，因为要用户在点击的时候，做异常判断.(最新改版，不做默认选择)
        [payMentList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            OSSVPayMentCellModel *payMentModel = obj;
            if ([payMentModel.payMentModel isCodPayment]) {
                payMentModel.isSelect = NO;
                //self.infoViewModel.paymentModel = payMentModel.payMentModel;  //不再赋值支付方式
                *stop = YES;
            }
        }];
    }
    
    if (self.isSelectPayMent && [self.infoViewModel.paymentModel isCodPayment]) {
        //COD的物流方式
        self.infoViewModel.shippingModel = [self findCodShipping:self.checkOutModel.shippingList];
        self.infoViewModel.checkOutModel.currencyInfo = self.checkOutModel.currency_list.currency_cod;
    }else{
        if (!self.infoViewModel.paymentModel) {
            //self.infoViewModel.paymentModel = [self resetPayMentMethod:payMentList]; //不再赋值支付方式
        }
        if (![self findOldShippingMethod]) {
            //当用户选中的物流方式没有的时候，重新寻找用户的物流方式
            self.infoViewModel.shippingModel = [self findUnCodShipping:self.checkOutModel.shippingList];
        }
        self.infoViewModel.checkOutModel.currencyInfo = self.checkOutModel.currency_list.currency_check;
    }
    ///支付方式的头最后插入
    STLNormalHeadCellModel *model = [STLNormalHeadCellModel initWithTitile:[STLLocalizedString_(@"paymentMethod", nil) uppercaseString]];
    [payMentList insertObject:model atIndex:0];
    
    //1.4.4 这里挪到商品列表了
    //返回金币文案的View
//    if (STLToString(self.checkOutModel.rebate_activity_info).length) {
//        STLGetCoinsTableViewCellModel *coinModel = [STLGetCoinsTableViewCellModel initWithTitile:STLToString(self.checkOutModel.rebate_activity_info)];
//
//        [payMentList insertObject:coinModel atIndex:1];
//    }
    //去除标题;
    //[payMentList removeObjectAtIndex:0];
    
    
    [dataList addObject:payMentList];
    return payMentList;
}

///处理物流保险cell
-(OSSVSwitchCellModel *)handleShippingInsurance
{
    ///依赖关系的model-->switchModel->STLPayTotalCellModel
    OSSVSwitchCellModel *shippInsuranceModel = [[OSSVSwitchCellModel alloc] init];
    shippInsuranceModel.rateModel = self.infoViewModel.checkOutModel.currencyInfo;
    shippInsuranceModel.dataSourceModel = self.checkOutModel;
    //重置运费保险状态
    if (self.infoViewModel.shippingInsurance) {
        shippInsuranceModel.switchStatus = YES;
    }else{
        shippInsuranceModel.switchStatus = NO;
    }
    return shippInsuranceModel;
}

//金币cell
-(OSSVCoinCellModel *)handleCoin:(NSMutableArray *)dataList
{
    OSSVCoinModel *coinModel = [[OSSVCoinModel alloc] init];
    coinModel.save = STLToString(self.checkOutModel.coin_discount_info.coinSave);
    coinModel.coins = STLToString(self.checkOutModel.coin_discount_info.usedCoins);
    coinModel.coinText1 = STLToString(self.checkOutModel.coin_discount_info.coinText1);
    coinModel.coinText2 = STLToString(self.checkOutModel.coin_discount_info.coinText2);

    NSMutableArray *couponSection = [NSMutableArray array];
    OSSVArrowCellModel *couponTitleModel = [[OSSVArrowCellModel alloc] init];
    couponTitleModel.dataSourceModel = coinModel;
    couponTitleModel.checkOutModel = self.checkOutModel;
    couponTitleModel.isUserCoin = [self.checkOutModel.fee_data.coin_save floatValue] > 0 ? YES : NO;
    [couponSection addObject:couponTitleModel];
    
    OSSVCoinCellModel *saveModel = nil;
    [dataList addObject:couponSection];
    return saveModel;
}

///优惠券cell
-(STLCouponSaveCellModel *)handleCoupon:(NSMutableArray *)dataList
{
    NSMutableArray *couponSection = [NSMutableArray array];
    OSSVArrowCellModel *couponTitleModel = [[OSSVArrowCellModel alloc] init];
    couponTitleModel.dataSourceModel = self.checkOutModel;
    [couponSection addObject:couponTitleModel];
    
    //重置优惠券状态
    STLCouponSaveCellModel *saveModel = nil;
//    if (couponModel.status == ApplyButtonStatusClear) {
//        //此时要显示 优惠金额
//        saveModel = [[STLCouponSaveCellModel alloc] init];
//        saveModel.checkModel = self.checkOutModel;
//        [couponSection addObject:saveModel];
//        self.infoViewModel.couponModel = self.checkOutModel.coupon;
//    }else{
//        self.infoViewModel.couponModel = nil;
//    }

    [dataList addObject:couponSection];
    return saveModel;
}

///处理积分cell
-(OSSVSwitchCellModel *)handleYPoint:(NSMutableArray *)list
{
    OSSVSwitchCellModel *ypointModel = nil;
    if (self.checkOutModel.points.points.floatValue > 0) {
        ypointModel = [[OSSVSwitchCellModel alloc] init];
        ypointModel.rateModel = self.infoViewModel.checkOutModel.currencyInfo;
        ypointModel.dataSourceModel = self.checkOutModel.points;
        //重置积分选择状态
        if (self.infoViewModel.ypointModel) {
            ypointModel.switchStatus = YES;
        }else{
            ypointModel.switchStatus = NO;
        }
        [list addObject:[@[ypointModel] mutableCopy]];
    }
    return ypointModel;
}

///寻找旧的物流方式是否存在后台返回的物流方式里面, 有就直接赋值
-(BOOL)findOldShippingMethod
{
    __block BOOL findOldShipping = NO;
    if (!self.infoViewModel.shippingModel) {
        return findOldShipping;
    }
    [self.checkOutModel.shippingList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        OSSVCartShippingModel *shippingModel = obj;
        //需要排除COD物流，因为COD物流是指定COD才能使用的
        if (shippingModel.sid.integerValue == self.infoViewModel.shippingModel.sid.integerValue && ![shippingModel isCodShipping]) {
            findOldShipping = YES;
            self.infoViewModel.shippingModel = shippingModel;
            *stop = YES;
        }
    }];
    return findOldShipping;
}

///搜索COD物流
-(OSSVCartShippingModel *)findCodShipping:(NSArray *)shippingList
{
    self.infoViewModel.shippingModel = nil;
    __block OSSVCartShippingModel *blockShippingModel = nil;
    [shippingList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        OSSVCartShippingModel *shippingModel = obj;
        if ([shippingModel isCodShipping]) {
            blockShippingModel = shippingModel;
            *stop = YES;
        }
    }];
    return blockShippingModel;
}

///搜索非COD物流
-(OSSVCartShippingModel *)findUnCodShipping:(NSArray *)shippingList
{
    self.infoViewModel.shippingModel = nil;
    __block OSSVCartShippingModel *blockShippingModel = nil;
    [shippingList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        OSSVCartShippingModel *shippingModel = obj;
        if (![shippingModel isCodShipping]) {
            blockShippingModel = shippingModel;
            *stop = YES;
        }
    }];
    return blockShippingModel;
}

//重置支付方式选择
-(OSSVCartPaymentModel *)resetPayMentMethod:(NSMutableArray *)payMentList
{
    self.infoViewModel.paymentModel = nil;
    __block OSSVCartPaymentModel *blockPayMentModel = nil;
    [payMentList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj isKindOfClass:[OSSVPayMentCellModel class]]) {
            OSSVPayMentCellModel *payMentModel = obj;
            if (![payMentModel.payMentModel isCodPayment]) {
                payMentModel.isSelect = YES;
                blockPayMentModel = payMentModel.payMentModel;
                *stop = YES;
            }else{
                payMentModel.isSelect = NO;
            }
        }
    }];
    return blockPayMentModel;
}

#pragma mark - setter and getter

- (NSMutableArray<OSSVCartGoodsModel *> *)noShipGoodsArray {
    if (!_noShipGoodsArray) {
        _noShipGoodsArray = [[NSMutableArray alloc] init];
    }
    return _noShipGoodsArray;
}
-(UITableView *)checkOutTableView
{
    if (!_checkOutTableView) {
        _checkOutTableView = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            tableView.backgroundColor = UIColor.clearColor;
            tableView.showsVerticalScrollIndicator = NO;
            tableView.showsHorizontalScrollIndicator = NO;
            tableView.estimatedRowHeight = UITableViewAutomaticDimension;
            tableView.contentInset = UIEdgeInsetsMake(4, 0, 14, 0);

            [tableView registerClass:[OSSVAddressCell class] forCellReuseIdentifier:[OSSVCheckOutAdressCellModel cellIdentifier]];
            [tableView registerClass:[OSSVPayMentCell class] forCellReuseIdentifier:[OSSVPayMentCellModel cellIdentifier]];
            [tableView registerClass:[OSSVTotalDetailCell class] forCellReuseIdentifier:[OSSVTotalDetailCellModel cellIdentifier]];
            [tableView registerClass:[OSSVNormalHeadCell class] forCellReuseIdentifier:[STLNormalHeadCellModel cellIdentifier]];
            //优惠券，金币 cell
            [tableView registerClass:[OSSVArrowTableViewCell class] forCellReuseIdentifier:[OSSVArrowCellModel cellIdentifier]];
            //运费保险
            [tableView registerClass:[OSSVSwitchCell class] forCellReuseIdentifier:[OSSVSwitchCellModel cellIdentifier]];

            //没有用的cell
            [tableView registerClass:[OSSVCouponCell class] forCellReuseIdentifier:[OSSVCouponCellModel cellIdentifier]];
            [tableView registerClass:[OSSVShowErrorCell class] forCellReuseIdentifier:[STLShowErrorCellModel cellIdentifier]];

            //商品信息cell
            [tableView registerClass:[OSSVCheckOutProductListCell class] forCellReuseIdentifier:[OSSVProductListCellModel cellIdentifier]];
            [tableView registerClass:[OSSVPayTotalTableViewCell class] forCellReuseIdentifier:[STLPayTotalCellModel cellIdentifier]];
            [tableView registerClass:[STLCouponSaveCell class] forCellReuseIdentifier:[STLCouponSaveCellModel cellIdentifier]];
            [tableView registerClass:[OSSVGetCoinsTableViewCell class] forCellReuseIdentifier:[STLGetCoinsTableViewCellModel cellIdentifier]];
            [tableView registerClass:[OSSVShippingMethCell class] forCellReuseIdentifier:[OSSVShippingCellModel cellIdentifier]];

            tableView.delegate = self;
            tableView.dataSource = self;
            tableView;
        });
    }
    return _checkOutTableView;
}

-(OSSVCheckOutBottomView *)checkOutBottomView
{
    if (!_checkOutBottomView) {
        _checkOutBottomView = [[OSSVCheckOutBottomView alloc] init];
        _checkOutBottomView.delegate = self;
    }
    return _checkOutBottomView;
}

- (OSSVCheckOutCodMsgAlertView *)codMsgAlertView {
    if (!_codMsgAlertView) {
        _codMsgAlertView = [[OSSVCheckOutCodMsgAlertView alloc] initWithFrame:CGRectZero];
        @weakify(self);
        _codMsgAlertView.codAlertBlock = ^(NSString *resultId, NSString *resultStr) {
            @strongify(self);
            [self codCancelRequest:resultId];
        };
    }
    return _codMsgAlertView;
}

- (OSSVCheckOutGoodsAlterView *)outGoodsAlterView {
    if (!_outGoodsAlterView) {
        _outGoodsAlterView = [[OSSVCheckOutGoodsAlterView alloc] initWithFrame:CGRectZero];
        
        @weakify(self);
        
        _outGoodsAlterView.checkTipEventBlock = ^(CheckOutEvent event) {
            @strongify(self);
            if (event == CheckOutEventHome) {

                [self.navigationController popToRootViewControllerAnimated:NO];
                OSSVTabBarVC *tabbarCtrl = [AppDelegate mainTabBar];
                [tabbarCtrl setModel:STLMainMoudleHome];

                OSSVNavigationVC *homeNav = [tabbarCtrl navigationControllerWithMoudle:STLMainMoudleHome];
                if (homeNav.viewControllers.count>1) {
                    [homeNav popToRootViewControllerAnimated:NO];
                }
            } else if(event == CheckOutEventPay) {
                
                __block NSMutableArray *cartIds = [[NSMutableArray alloc] init];
                [self.noShipGoodsArray enumerateObjectsUsingBlock:^(OSSVCartGoodsModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [cartIds addObject:STLToString(obj.cart_id)];
                }];
                
                @weakify(self)
                [[OSSVCartsOperateManager sharedManager] cartUncheckServiceDataGoods:cartIds showView:self.view Completion:^(id obj) {
                    @strongify(self)
                    [self checkOutAndPay];
                    
                } failure:^(id obj) {
                                    
                }];
            } else if(event == CheckOutEventAddress) {
                
                OSSVCheckOutAdressCellModel *addressModel = [[OSSVCheckOutAdressCellModel alloc] init];
                addressModel.addressModel = self.checkOutModel.address;
                [self STL_DidClickAddressCell:addressModel];
            } else if(event == CheckOutEventProducts){
                ///
                [self showList];
            }
        };
    }
    return _outGoodsAlterView;
}

-(void)showList{
    [GATools logOrderInfomationWithEventName:@"check_items" action:@""];
    
    self.goodsListAlertView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [WINDOW addSubview:self.goodsListAlertView];
    [self.goodsListAlertView show];
}

-(OSSVCheckOutGoodsAlterView *)goodsListAlertView{
    if (!_goodsListAlertView) {
        _goodsListAlertView = [[OSSVCheckOutGoodsAlterView alloc] initWithFrame:CGRectZero];
        _goodsListAlertView.justList = true;
        _goodsListAlertView.tipMessage = self.outGoodsAlterView.attributeMessage;
        _goodsListAlertView.tipButton.hidden = false;
        
        @weakify(self);
        
        _goodsListAlertView.checkTipEventBlock = ^(CheckOutEvent event) {
            @strongify(self);
            if (event == CheckOutEventHome) {

                [self.navigationController popToRootViewControllerAnimated:NO];
                OSSVTabBarVC *tabbarCtrl = [AppDelegate mainTabBar];
                [tabbarCtrl setModel:STLMainMoudleHome];

                OSSVNavigationVC *homeNav = [tabbarCtrl navigationControllerWithMoudle:STLMainMoudleHome];
                if (homeNav.viewControllers.count>1) {
                    [homeNav popToRootViewControllerAnimated:NO];
                }
            } else if(event == CheckOutEventPay) {
                
                __block NSMutableArray *cartIds = [[NSMutableArray alloc] init];
                [self.noShipGoodsArray enumerateObjectsUsingBlock:^(OSSVCartGoodsModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [cartIds addObject:STLToString(obj.cart_id)];
                }];
                
                @weakify(self)
                [[OSSVCartsOperateManager sharedManager] cartUncheckServiceDataGoods:cartIds showView:self.view Completion:^(id obj) {
                    @strongify(self)
                    [self checkOutAndPay];
                    
                } failure:^(id obj) {
                                    
                }];
            } else if(event == CheckOutEventAddress) {
                
                OSSVCheckOutAdressCellModel *addressModel = [[OSSVCheckOutAdressCellModel alloc] init];
                addressModel.addressModel = self.checkOutModel.address;
                [self STL_DidClickAddressCell:addressModel];
                
            }
        };
    }
    return _goodsListAlertView;
}

-(OSSVCartOrderInfoViewModel *)infoViewModel
{
    if (!_infoViewModel) {
        _infoViewModel = [[OSSVCartOrderInfoViewModel alloc] init];
        _infoViewModel.controller = self;
    }
    return _infoViewModel;
}

-(NSMutableArray *)checkOutDataSourceList
{
    if (!_checkOutDataSourceList) {
        _checkOutDataSourceList = ({
            NSMutableArray *list = [NSMutableArray array];
            ///首次进入的时候，肯定是normal
            self.infoViewModel.cartCheckType = CartCheckType_Normal;
            [self reloadTableViewDatasource:list];
            list;
        });
    }
    return _checkOutDataSourceList;
}





- (void)analyticsOrderSubmit:(OSSVCreateOrderModel *)orderModel orderInfoViewModel:(OSSVCartOrderInfoViewModel *)cartInfoModel resultState:(BOOL)flag{
    
    
    CGFloat reallPayPrice = 0.0;
    NSString *payMethodString = @"";
    
    __block NSMutableArray *snArray = [[NSMutableArray alloc]initWithCapacity: 1];
    __block NSMutableArray *qtyArray = [[NSMutableArray alloc]initWithCapacity: 1];
//    NSMutableArray *payMethodArray = [[NSMutableArray alloc]initWithCapacity: 1];
    NSMutableArray *orderIdsArray = [[NSMutableArray alloc]initWithCapacity: 1];
    __block NSMutableArray *contentTypeArray = [[NSMutableArray alloc]initWithCapacity: 1];
    __block NSMutableArray *goodsPriceArray = [[NSMutableArray alloc]initWithCapacity: 1];

    __block NSMutableArray *itemsGoods = [[NSMutableArray alloc] init];

    if (orderModel && [orderModel isKindOfClass:[OSSVCreateOrderModel class]]) {
        for (NSInteger i = 0; i < orderModel.orderList.count; i ++) {
            STLOrderModel *orderMode = (STLOrderModel*)orderModel.orderList[i];
            [orderIdsArray addObject:orderMode.order_sn];
            
            reallPayPrice += [orderMode.order_amount floatValue];
            payMethodString = [NSString stringWithFormat:@"%@",orderMode.method];
        }
    }

    NSString *orderIdsStrings = [(NSArray *)orderIdsArray componentsJoinedByString:@","];
    
    
    ////
    NSString *contacts = [NSString stringWithFormat:@"%@ %@",
                          STLToString(cartInfoModel.checkOutModel.address.firstName),
                          STLToString(cartInfoModel.checkOutModel.address.lastName)];
    
    
    NSArray *counrtyArray = [cartInfoModel.checkOutModel.address.country componentsSeparatedByString:@"/"];
    NSArray *stateArray = [cartInfoModel.checkOutModel.address.state componentsSeparatedByString:@"/"];
    NSArray *cityArray = [cartInfoModel.checkOutModel.address.city componentsSeparatedByString:@"/"];
    NSArray *streetArray = [cartInfoModel.checkOutModel.address.street componentsSeparatedByString:@"/"];

    NSString *countryString = counrtyArray.firstObject;
    NSString *stateString = stateArray.firstObject;
    NSString *cityString = cityArray.firstObject;
    NSString *streetString = streetArray.firstObject;


    NSArray *addressArray = @[streetString,cityString,stateString,countryString];
    NSString *addressString = [addressArray componentsJoinedByString:@","];
    
    NSString *payType = [STLToString(cartInfoModel.paymentModel.payCode) isEqualToString:@"Influencer"] ? @"kol" : @"normal";
    [OSSVAnalyticsTool sharedManager].analytics_uuid = [OSSVAnalyticsTool appsAnalyticUUID];
    NSString *analyticsUUID = [OSSVAnalyticsTool sharedManager].analytics_uuid;
    NSString *goodSkuCount = [NSString stringWithFormat:@"%lu",(unsigned long)cartInfoModel.effectiveProductList.count];
    NSDictionary *sensorsDic = @{@"order_type":payType,
                                 @"order_sn":STLToString(orderIdsStrings),
//                                 @"order_actual_amount"        :   @([STLToString(cartInfoModel.checkOutModel.fee_data.total) floatValue]),
                                 @"order_actual_amount"        :   @(reallPayPrice),

                                 @"total_price_of_goods"        :   @([STLToString(cartInfoModel.checkOutModel.fee_data.product) floatValue]),
                                 @"payment_method"        :   STLToString(cartInfoModel.paymentModel.payCode),
                                 @"currency":@"USD",
                                 @"receiver_name"      :   STLToString(contacts),
                                 @"receiver_country"      :   STLToString(countryString),
                                 @"receiver_province"        :   STLToString(stateString),
                                @"receiver_city"           :   STLToString(cityString),
                                 @"receiver_district"   :   STLToString(streetString),
                                 @"receiver_address"   :   STLToString(addressString),
                                 @"shipping_fee"        :   @([STLToString(cartInfoModel.checkOutModel.fee_data.shipping) floatValue]),
                                 @"discount_id":STLToString(cartInfoModel.couponModel.code),
                                 @"discount_amount":@([STLToString(cartInfoModel.checkOutModel.fee_data.coupon_save) floatValue]),
                                 @"is_use_discount":(STLIsEmptyString(cartInfoModel.couponModel.code) ? @(0) : @(1)),
                                 @"is_success": @(flag),
                                 @"uu_id":analyticsUUID,
                                 @"goods_sn_count":goodSkuCount,

    };
    [OSSVAnalyticsTool analyticsSensorsEventWithName:@"SubmitOrder" parameters:sensorsDic];
    
    //AB生成订单
    if(flag){//只埋成功
        [ABTestTools.shared submitOrderWithOrderSn:STLToString(orderIdsStrings)
                                 orderActureAmount:reallPayPrice
                                 totalPriceOfGoods:[STLToString(cartInfoModel.checkOutModel.fee_data.product) floatValue]
                                      goodsSnCount:cartInfoModel.effectiveProductList.count
                                     paymentMethod:STLToString(cartInfoModel.paymentModel.payCode)
                                     isUseDiscount:(STLIsEmptyString(cartInfoModel.couponModel.code) ? @"0" : @"1")];
    }
    
    [DotApi placeOrder];
    
    
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (OSSVCartWareHouseModel *wh in self.checkOutModel.wareHouseList) {
        for (OSSVCartGoodsModel *good in wh.goodsList) {
            GAEventItems *item = [[GAEventItems alloc] initWithItem_id:STLToString(good.goodsId)
                                                             item_name:STLToString(good.goodsName)
                                                            item_brand:[OSSVLocaslHosstManager appName]
                                                         item_category:STLToString(good.cat_name)
                                                          item_variant:@""
                                                                 price:STLToString(good.shop_price)
                                                              quantity:@(good.goodsNumber)
                                                              currency:@"USD" index:nil];
            [arr addObject:item];
        }
    }
    [GATools logOrderInfomationPlaceOrderWithValue:reallPayPrice
                                            coupon:STLToString(cartInfoModel.couponModel.code)
                                    shippingMethod:STLToString(cartInfoModel.shippingModel.shipName)
                                             items:arr];
    
    [self.checkOutModel.wareHouseList enumerateObjectsUsingBlock:^(OSSVCartWareHouseModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [obj.goodsList enumerateObjectsUsingBlock:^(OSSVCartGoodsModel *  _Nonnull goodsObj, NSUInteger goodsIdx, BOOL * _Nonnull goodsStop) {
            [snArray addObject:STLToString(goodsObj.goodsSn)];
            [contentTypeArray addObject:STLToString(goodsObj.cat_name)];
            [qtyArray addObject:[NSNumber numberWithInteger:goodsObj.goodsNumber]];
//            allProductPrice += goodsObj.goodsNumber * [goodsObj.shop_price floatValue];
            [goodsPriceArray addObject:STLToString(goodsObj.shop_price)];

            
            CGFloat price = [goodsObj.shop_price floatValue];
            
            NSDictionary *items = @{
                kFIRParameterItemID: STLToString(goodsObj.goodsSn),
                kFIRParameterItemName: STLToString(goodsObj.goodsName),
                kFIRParameterItemCategory: STLToString(goodsObj.cat_name),
                kFIRParameterPrice: @(price),
                kFIRParameterQuantity: @(goodsObj.goodsNumber),
                kFIRParameterItemVariant:STLToString(goodsObj.goodsAttr),
                kFIRParameterItemBrand:@"",
            };
            
            [itemsGoods addObject:items];
            
            NSDictionary *sensorsDic = @{@"order_type"      : payType,
                                         @"order_sn"        : STLToString(orderIdsStrings),
                                         @"goods_sn"        : STLToString(goodsObj.goodsSn),
                                         @"goods_name"      : STLToString(goodsObj.goodsName),
                                         @"cat_id"          : STLToString(goodsObj.cat_id),
                                         @"cat_name"        : STLToString(goodsObj.cat_name),
                                         @"original_price"  : @([STLToString(goodsObj.market_price) floatValue]),
                                         @"present_price"   : @(price),
                                         @"goods_quantity"  : @(goodsObj.goodsNumber),
                                         @"goods_size"      : @"",
                                         @"goods_color"     : @"",
                                         @"currency"        : @"USD",
                                         @"is_success"      : @(flag),
                                         @"uu_id"           : analyticsUUID,
            };
            [OSSVAnalyticsTool analyticsSensorsEventWithName:@"SubmitOrderDetail" parameters:sensorsDic];
        }];
        
    }];
    

    if (flag) {
        
        NSString *goodsSNsStrings = [(NSArray *)snArray componentsJoinedByString:@","];
        NSString *goodsQtyStrings = [(NSArray *)qtyArray componentsJoinedByString:@","];
        NSString *goodsPricesStrings = [(NSArray *)goodsPriceArray componentsJoinedByString:@","];
        
        
        NSDictionary *dic = @{@"af_content_id"  : goodsSNsStrings,
                              @"af_order_id"    : orderIdsStrings,
                              @"af_price"       : goodsPricesStrings,
                              @"af_quantity"    : goodsQtyStrings,
                              @"af_currency"    : @"USD",
                              @"af_revenue":[NSString stringWithFormat:@"%.2f",reallPayPrice],
                              @"af_param_user_id"      : USERID_STRING,
        };
        
        // 谷歌统计 统计下单成功
        [OSSVAnalyticsTool appsFlyerOrderSuccess:dic];
        
        ///Branch 生成订单
        NSDictionary *itemsDic = @{@"items":itemsGoods,
                                   kFIRParameterCurrency: @"USD",
                                   kFIRParameterValue: @(reallPayPrice),
                                   kFIRParameterCoupon:STLToString(self.infoViewModel.couponModel.code),
                                   //@"payment_type":STLToString(self.infoViewModel.paymentModel.payCode),
                                   //运输等级
                                   kFIRParameterShippingTier:@"",
                                   @"screen_group":@"Checkout"
        };
        [OSSVBrancshToolss logAddPaymentInfo:itemsDic];
        
//        //数据GA埋点曝光 下单成功 ok
//        //GA
//        NSDictionary *itemsDic = @{@"items":itemsGoods,
//                                   kFIRParameterCurrency: @"USD",
//                                   kFIRParameterValue: @(reallPayPrice),
//                                   kFIRParameterCoupon:STLToString(self.infoViewModel.couponModel.code),
//                                   //@"payment_type":STLToString(self.infoViewModel.paymentModel.payCode),
//                                   //运输等级
//                                   kFIRParameterShippingTier:@"",
//                                   @"screen_group":@"Checkout"
//        };
//        
//        [OSSVAnalyticsTool analyticsGAEventWithName:kFIREventAddShippingInfo parameters:itemsDic];
    }
}

- (void)analyticsOrderPay:(OSSVCreateOrderModel *)orderModel orderInfoViewModel:(OSSVCartOrderInfoViewModel *)cartInfoModel resultState:(BOOL)flag {
    
    CGFloat reallPayPrice = 0.0;
    NSString *payMethodString = @"";
    
    __block NSMutableArray *snArray = [[NSMutableArray alloc]initWithCapacity: 1];
    __block NSMutableArray *qtyArray = [[NSMutableArray alloc]initWithCapacity: 1];
//    NSMutableArray *payMethodArray = [[NSMutableArray alloc]initWithCapacity: 1];
    NSMutableArray *orderIdsArray = [[NSMutableArray alloc]initWithCapacity: 1];
    __block NSMutableArray *contentTypeArray = [[NSMutableArray alloc]initWithCapacity: 1];
    __block NSMutableArray *goodsPriceArray = [[NSMutableArray alloc]initWithCapacity: 1];

    __block NSMutableArray *itemsGoods = [[NSMutableArray alloc] init];

    
    for (NSInteger i = 0; i < orderModel.orderList.count; i ++) {
        STLOrderModel *orderMode = (STLOrderModel*)orderModel.orderList[i];
        [orderIdsArray addObject:orderMode.order_sn];
        
        reallPayPrice += [orderMode.order_amount floatValue];
        payMethodString = [NSString stringWithFormat:@"%@",orderMode.method];
    }

    NSString *orderIdsStrings = [(NSArray *)orderIdsArray componentsJoinedByString:@","];
    
    
    
    ////
    NSString *contacts = [NSString stringWithFormat:@"%@ %@",
                          STLToString(cartInfoModel.checkOutModel.address.firstName),
                          STLToString(cartInfoModel.checkOutModel.address.lastName)];
    
    
    NSArray *counrtyArray = [cartInfoModel.checkOutModel.address.country componentsSeparatedByString:@"/"];
    NSArray *stateArray = [cartInfoModel.checkOutModel.address.state componentsSeparatedByString:@"/"];
    NSArray *cityArray = [cartInfoModel.checkOutModel.address.city componentsSeparatedByString:@"/"];
    NSArray *streetArray = [cartInfoModel.checkOutModel.address.street componentsSeparatedByString:@"/"];

    NSString *countryString = counrtyArray.firstObject;
    NSString *stateString = stateArray.firstObject;
    NSString *cityString = cityArray.firstObject;
    NSString *streetString = streetArray.firstObject;

    NSArray *addressArray = @[streetString,cityString,stateString,countryString];
    NSString *addressString = [addressArray componentsJoinedByString:@","];
    
    BOOL isfirstOrder = [OSSVAccountsManager sharedManager].account.is_first_order_time;
    NSString *payType = [STLToString(cartInfoModel.paymentModel.payCode) isEqualToString:@"Influencer"] ? @"kol" : @"normal";
    [OSSVAnalyticsTool sharedManager].analytics_uuid = [OSSVAnalyticsTool appsAnalyticUUID];
    NSString *analyticsUUID = [OSSVAnalyticsTool sharedManager].analytics_uuid;
    NSString *goodSkuCount = [NSString stringWithFormat:@"%lu",(unsigned long)cartInfoModel.effectiveProductList.count];
    
    NSDictionary *sensorsDic = @{@"is_first_time":(isfirstOrder ? @(1) : @(0)),
                                 @"order_type":payType,
                                 @"order_sn":STLToString(orderIdsStrings),
                                 @"order_actual_amount"        :   @([STLToString(cartInfoModel.checkOutModel.fee_data.total) floatValue]),
                                 @"total_price_of_goods"        :   @([STLToString(cartInfoModel.checkOutModel.fee_data.product) floatValue]),
                                 @"payment_method"        :   STLToString(cartInfoModel.paymentModel.payCode),
                                 @"currency":@"USD",
                                 @"receiver_name"      :   STLToString(contacts),
                                 @"receiver_country"      :   STLToString(countryString),
                                 @"receiver_province"        :   STLToString(stateString),
                                @"receiver_city"           :   STLToString(cityString),
                                 @"receiver_district"   :   STLToString(streetString),
                                 @"receiver_address"   :   STLToString(addressString),
                                 @"shipping_fee"        :   @([STLToString(cartInfoModel.checkOutModel.fee_data.shipping) floatValue]),
                                 @"discount_id":STLToString(cartInfoModel.couponModel.code),
                                 @"discount_amount":@([STLToString(cartInfoModel.checkOutModel.fee_data.coupon_save) floatValue]),
                                 @"is_use_discount":(STLIsEmptyString(cartInfoModel.couponModel.code) ? @(0) : @(1)),
                                 @"is_success": @(flag),
                                 @"uu_id":analyticsUUID,
                                 @"goods_sn_count":goodSkuCount,

    };
    [OSSVAnalyticsTool analyticsSensorsEventWithName:@"OnlinePayOrder" parameters:sensorsDic];
    
    if(flag){//只埋成功
        [ABTestTools.shared onlinePayOrderWithOrderSn:STLToString(orderIdsStrings)
                                    orderActureAmount:[STLToString(cartInfoModel.checkOutModel.fee_data.total) floatValue]
                                    totalPriceOfGoods:[STLToString(cartInfoModel.checkOutModel.fee_data.product) floatValue]
                                         goodsSnCount:cartInfoModel.effectiveProductList.count
                                        paymentMethod:STLToString(cartInfoModel.paymentModel.payCode)
                                        isUseDiscount:(STLIsEmptyString(cartInfoModel.couponModel.code) ? @"0" : @"1")];
    }
    

    
    [self.checkOutModel.wareHouseList enumerateObjectsUsingBlock:^(OSSVCartWareHouseModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [obj.goodsList enumerateObjectsUsingBlock:^(OSSVCartGoodsModel *  _Nonnull goodsObj, NSUInteger goodsIdx, BOOL * _Nonnull goodsStop) {
            [snArray addObject:STLToString(goodsObj.goodsSn)];
            [contentTypeArray addObject:STLToString(goodsObj.cat_name)];
            [qtyArray addObject:[NSNumber numberWithInteger:goodsObj.goodsNumber]];
//            allProductPrice += goodsObj.goodsNumber * [goodsObj.shop_price floatValue];
            [goodsPriceArray addObject:STLToString(goodsObj.shop_price)];

            
            CGFloat price = [goodsObj.shop_price floatValue];
            
            NSDictionary *items = @{
                kFIRParameterItemID: STLToString(goodsObj.goodsSn),
                kFIRParameterItemName: STLToString(goodsObj.goodsName),
                kFIRParameterItemCategory: STLToString(goodsObj.cat_name),
                kFIRParameterPrice: @(price),
                kFIRParameterQuantity: @(goodsObj.goodsNumber),
                kFIRParameterItemVariant:STLToString(goodsObj.goodsAttr),
                kFIRParameterItemBrand:@"",
            };
            
            [itemsGoods addObject:items];
            
            BOOL isfirstOrder = [OSSVAccountsManager sharedManager].account.is_first_order_time;
            NSString *payType = [STLToString(cartInfoModel.paymentModel.payCode) isEqualToString:@"Influencer"] ? @"kol" : @"normal";
            NSDictionary *sensorsDic = @{@"is_first_time":(isfirstOrder ? @(1) : @(0)),
                                         @"order_type":payType,
                                         @"order_sn"        :   STLToString(orderIdsStrings),
                                         @"goods_sn"        :   STLToString(goodsObj.goodsSn),
                                         @"goods_name"      :   STLToString(goodsObj.goodsName),
                                         @"cat_id"          :   STLToString(goodsObj.cat_id),
                                         @"cat_name"        :   STLToString(goodsObj.cat_name),
                                         @"original_price"  :   @([STLToString(goodsObj.market_price) floatValue]),
                                         @"present_price"   :   @(price),
                                         @"goods_quantity"  :   @(goodsObj.goodsNumber),
                                         @"goods_size"      :   @"",
                                         @"goods_color"     :   @"",
                                         @"currency"        :   @"USD",
                                         @"payment_method"  :   STLToString(cartInfoModel.paymentModel.payCode),
                                         @"is_success"      : @(flag),
                                         @"uu_id":analyticsUUID,

            };
            [OSSVAnalyticsTool analyticsSensorsEventWithName:@"OnlinePayOrderDetail" parameters:sensorsDic];
        }];
        
    }];
    
    
    if (flag) {
        
        NSString *goodsSNsStrings = [(NSArray *)snArray componentsJoinedByString:@","];
        NSString *goodsQtyStrings = [(NSArray *)qtyArray componentsJoinedByString:@","];
        NSString *goodsPricesStrings = [(NSArray *)goodsPriceArray componentsJoinedByString:@","];
        
        
        NSDictionary *dic = @{@"af_content_id":goodsSNsStrings,
                              @"af_order_id":orderIdsStrings,
                              @"af_price":goodsPricesStrings,
                              @"af_quantity":goodsQtyStrings,
                              @"af_currency":@"USD",
                              @"af_revenue":[NSString stringWithFormat:@"%.2f",reallPayPrice],
                              @"af_param_user_id"      : USERID_STRING,
        };
        
        // 谷歌统计 统计下单成功
        [OSSVAnalyticsTool appsFlyerOrderSuccess:dic];
        
        //GA
        NSDictionary *itemsDic = @{kFIRParameterItems:itemsGoods,
                                   kFIRParameterCurrency: @"USD",
                                   kFIRParameterValue: @(reallPayPrice),
                                   kFIRParameterCoupon:STLToString(self.infoViewModel.couponModel.code),
                                   kFIRParameterPaymentType:STLToString(self.infoViewModel.paymentModel.payCode),
                                   @"screen_group":@"Payment",
        };
        
        [OSSVAnalyticsTool analyticsGAEventWithName:kFIREventAddPaymentInfo parameters:itemsDic];
    }
}
@end
