//
//  OSSVOrderFinishsVC.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/24.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVOrderFinishsVC.h"
//#import "ACTReporter.h"
#import "OSSVOrderEditAip.h"
#import "UIViewController+PopBackButtonAction.h"
#import "OSSVPaymentsStatussViewModel.h"
#import "Adorawe-Swift.h"

@interface OSSVOrderFinishsVC ()

@property (nonatomic, strong) UIView        *topBgView;
@property (nonatomic, strong) UIView        *headerView;
@property (nonatomic, strong) UIImageView   *headerImageView;
@property (nonatomic, strong) UILabel       *tipLabel;

@property (nonatomic, strong) UIView        *orderBgView;
@property (nonatomic, strong) UILabel       *orderTitleLabel;
@property (nonatomic, strong) UILabel       *orderNumberLabel;
@property (nonatomic, strong) UILabel       *payMethodTitleLabel;
@property (nonatomic, strong) UILabel       *payMethodLabel;
@property (nonatomic, strong) UIView        *lineView;
@property (nonatomic, strong) UIView        *lineView2;
@property (nonatomic, strong) UILabel       *amountTitleLabel;
@property (nonatomic, strong) UILabel       *amountLabel;

@property (nonatomic, strong) UIButton      *goShopButton;
@property (nonatomic, strong) UIButton      *checkOrderButton;

///1.3.4 需求兼容支付中台返回数据
@property (nonatomic,copy) NSString *orderNum;
@property (nonatomic,copy) NSString *paymentMethod;
@property (nonatomic,copy) NSString *paymentAmount;

@property (nonatomic,strong) OSSVPaymentsStatussViewModel *viewModel;
@end

@implementation OSSVOrderFinishsVC


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [OSSVLocaslHosstManager appName];
    [OSSVAccountsManager sharedManager].account.is_first_order_time = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_RefrshUserInfo object:nil];

//    [self initUI];
    [self stlLayoutView];
    
    [self analyticsOrderSuccess];

}


- (UIView *)topBgView {
    if (!_topBgView) {
        _topBgView = [[UIView alloc] initWithFrame:CGRectZero];
        _topBgView.backgroundColor = [OSSVThemesColors stlWhiteColor];
    }
    return _topBgView;
}

- (void)stlLayoutView {
    
    [self.view addSubview:self.headerView];
    [self.headerView addSubview:self.headerImageView];
    [self.headerView addSubview:self.tipLabel];
    
    [self.view addSubview:self.orderBgView];
    [self.orderBgView addSubview:self.orderTitleLabel];
    [self.orderBgView addSubview:self.orderNumberLabel];
    [self.orderBgView addSubview:self.payMethodTitleLabel];
    [self.orderBgView addSubview:self.payMethodLabel];
    [self.orderBgView addSubview:self.lineView];
    [self.orderBgView addSubview:self.lineView2];
    [self.orderBgView addSubview:self.amountTitleLabel];
    [self.orderBgView addSubview:self.amountLabel];
    
    
    [self.view addSubview:self.goShopButton];
    [self.view addSubview:self.checkOrderButton];
    
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.mas_equalTo(self.view);
    }];
    
    [self.headerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.headerView.mas_top).offset(20);
        make.centerX.mas_equalTo(self.headerView.mas_centerX);
    }];
    
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.headerImageView.mas_bottom).offset(12);
        make.centerX.mas_equalTo(self.headerView.mas_centerX);
        make.width.mas_lessThanOrEqualTo((SCREEN_WIDTH - 2*12));
        make.bottom.mas_equalTo(self.headerView.mas_bottom).offset(-24);
    }];
    
    [self.orderBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.view.mas_leading).offset(12);
        make.trailing.mas_equalTo(self.view.mas_trailing).offset(-12);
        make.top.mas_equalTo(self.headerView.mas_bottom).offset(12);
        make.height.mas_equalTo(134);
    }];
    
    [self.orderTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.orderBgView.mas_leading).offset(12);
        make.top.mas_equalTo(self.orderBgView.mas_top);
        make.height.mas_equalTo(44);
    }];
    
    [self.orderNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.orderBgView.mas_trailing).offset(-12);
        make.centerY.mas_equalTo(self.orderTitleLabel.mas_centerY);
        make.height.mas_equalTo(44);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.orderBgView.mas_leading).offset(12);
        make.trailing.mas_equalTo(self.orderBgView.mas_trailing).offset(-12);
        make.top.mas_equalTo(self.orderTitleLabel.mas_bottom);
        make.height.mas_equalTo(1);
    }];

    [self.payMethodTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.orderTitleLabel.mas_leading);
        make.top.mas_equalTo(self.orderTitleLabel.mas_bottom);
        make.height.mas_equalTo(44);
    }];
    
    [self.payMethodLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.orderBgView.mas_trailing).offset(-12);
        make.centerY.mas_equalTo(self.payMethodTitleLabel.mas_centerY);
        make.height.mas_equalTo(44);
    }];
    
    
    [self.lineView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.orderBgView.mas_leading).offset(12);
        make.trailing.mas_equalTo(self.orderBgView.mas_trailing).offset(-12);
        make.height.mas_equalTo(1);
        make.top.mas_equalTo(self.payMethodTitleLabel.mas_bottom);
    }];
    
    [self.amountTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.orderTitleLabel.mas_leading);
        make.top.mas_equalTo(self.lineView2.mas_bottom);
        make.height.equalTo(44);
    }];
    
    [self.amountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.orderBgView.mas_trailing).offset(-12);
        make.centerY.mas_equalTo(self.amountTitleLabel.mas_centerY);
        make.height.mas_equalTo(44);
    }];

    [self.goShopButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.view.mas_leading).offset(12);
        make.trailing.mas_equalTo(self.view.mas_trailing).offset(-12);
        make.top.mas_equalTo(self.orderBgView.mas_bottom).offset(12);
        make.height.mas_equalTo(44);
    }];
    
    [self.checkOrderButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.view.mas_leading).offset(12);
        make.trailing.mas_equalTo(self.view.mas_trailing).offset(-12);
        make.top.mas_equalTo(self.goShopButton.mas_bottom).offset(12);
        make.height.mas_equalTo(44);
    }];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (self.orderNum.length > 0) {
        @weakify(self)
        ///请求接口
        [self.viewModel checkOrderStatus:@{@"order_sn":self.orderNum} completion:^(id  _Nonnull obj, NSString * _Nonnull msg) {
            @strongify(self)
            id resultObj = obj[kResult];
            if ([resultObj isKindOfClass:[NSDictionary class]]) {
                NSDictionary *result = obj[kResult];
                NSString *payMethod = [result objectForKey:@"pay_code"];
                self.payMethodLabel.text = payMethod.length > 0 ? payMethod : STLToString(self.paymentMethod);
                
                NSString *amount = [result objectForKey:@"order_amount"];
                self.amountLabel.text = amount.length > 0 ? amount : STLToString(self.paymentAmount);
            }
        } failure:^(id  _Nonnull obj, NSString * _Nonnull msg) {
            @strongify(self)
            self.payMethodLabel.text = STLToString(self.paymentMethod); //支付方式
            self.amountLabel.text = STLToString(self.paymentAmount);
        }];
    }
}




#pragma mark ----数据赋值
- (void)setCreateOrderModel:(OSSVCreateOrderModel *)createOrderModel {
    _createOrderModel = createOrderModel;
    if (createOrderModel.orderList.count) {
        STLOrderModel *orderModel = (STLOrderModel*)createOrderModel.orderList[0];
        self.orderNumberLabel.text = STLToString(orderModel.order_sn);
        self.orderNum = orderModel.order_sn;
    }

    self.paymentMethod = createOrderModel.payName;
    self.paymentAmount = createOrderModel.orderAmount;
    
}


#pragma mark - UI
- (void)initUI {
    
    [self.view addSubview:self.topBgView];
    
    [self.topBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.mas_equalTo(self.view);
    }];
    
    YYAnimatedImageView *img = [[YYAnimatedImageView alloc] init];
    img.image = [UIImage imageNamed:@"pay_success"];
    [self.view addSubview:img];
    
    [img mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(80);
        make.width.equalTo(@102);
        make.height.equalTo(@64);
        make.centerX.mas_equalTo(self.view.mas_centerX);
    }];
    
    ///若订单拆分两个会提示 <此订单将拆成两个包裹发货>
    UILabel *tipsLabel = nil;
    if ([self.createOrderModel.orderList count] > 1) {
        tipsLabel = [[UILabel alloc] init];
        tipsLabel.font = [UIFont systemFontOfSize:14];
        tipsLabel.textColor = OSSVThemesColors.col_333333;
        tipsLabel.textAlignment = NSTextAlignmentCenter;
        tipsLabel.text = STLLocalizedString_(@"twoPackagesToDelivery", nil);
        [self.view addSubview:tipsLabel];
        [tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(img.mas_bottom).mas_offset(20);
            make.centerX.mas_equalTo(self.view.mas_centerX);
        }];
    }
    
    NSMutableArray <UILabel *>*orderLabelArray = [[NSMutableArray alloc] init];
    ///拆单分成多个订单号
    [self.createOrderModel.orderList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        STLOrderModel *orderModel = obj;
        
        if (idx > 0) {
            UILabel *lastLabel = [orderLabelArray lastObject];
            UILabel *orderSnLab = [[UILabel alloc] init];
            orderSnLab.font = [UIFont systemFontOfSize:12];
            orderSnLab.textColor = [OSSVThemesColors col_262626];
            orderSnLab.textAlignment = NSTextAlignmentCenter;
            orderSnLab.text = [OSSVSystemsConfigsUtils isRightToLeftShow] ? [NSString stringWithFormat:@"%@ : %@", orderModel.order_sn,STLLocalizedString_(@"finishOrder", nil)] : [NSString stringWithFormat:@"%@ : %@",STLLocalizedString_(@"finishOrder", nil), orderModel.order_sn];
            [self.view addSubview:orderSnLab];
            [orderSnLab mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(lastLabel.mas_bottom).offset(5);
                make.centerX.mas_equalTo(self.view.mas_centerX);
            }];
            [orderLabelArray addObject:orderSnLab];
            
        }else{
            
            UILabel *orderSnLab = [[UILabel alloc] init];
            orderSnLab.font = [UIFont systemFontOfSize:12];
            orderSnLab.textColor = [OSSVThemesColors col_262626];
            orderSnLab.textAlignment = NSTextAlignmentCenter;
            orderSnLab.text = [OSSVSystemsConfigsUtils isRightToLeftShow] ? [NSString stringWithFormat:@"%@ : %@", orderModel.order_sn,STLLocalizedString_(@"finishOrder", nil)] : [NSString stringWithFormat:@"%@ : %@",STLLocalizedString_(@"finishOrder", nil), orderModel.order_sn];
            [self.view addSubview:orderSnLab];
            
            [orderSnLab mas_makeConstraints:^(MASConstraintMaker *make) {
                if (tipsLabel) {
                    make.top.mas_equalTo(tipsLabel.mas_bottom).mas_offset(40);
                }else{
                    make.top.mas_equalTo(img.mas_bottom).offset(40);
                }
                make.centerX.mas_equalTo(self.view.mas_centerX);
            }];
            [orderLabelArray addObject:orderSnLab];
        }
    }];
    
    UILabel *tipLab = [[UILabel alloc] init];
    tipLab.font = [UIFont systemFontOfSize:12];
    tipLab.textColor = [OSSVThemesColors col_262626];
    tipLab.textAlignment = NSTextAlignmentCenter;
    tipLab.numberOfLines = 0;
    [self.view addSubview:tipLab];
    
    if (self.isCOD) {
        
        UILabel *paymentLabel = [UILabel new];
        paymentLabel.font = [UIFont systemFontOfSize:12];
        paymentLabel.textColor = [OSSVThemesColors col_262626];
        paymentLabel.textAlignment = NSTextAlignmentCenter;
        paymentLabel.text = [NSString stringWithFormat:@"%@:%@", STLLocalizedString_(@"paymentMethod", nil), STLLocalizedString_(@"cod", nil)];
        [self.view addSubview:paymentLabel];
        [paymentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo([orderLabelArray lastObject].mas_bottom).offset(5);
            make.centerX.mas_equalTo(self.view.mas_centerX);
        }];
        
        UILabel *paymentAmountLab = [UILabel new];
        paymentAmountLab.font = [UIFont systemFontOfSize:12];
        paymentAmountLab.textColor = [OSSVThemesColors col_262626];
        paymentAmountLab.textAlignment = NSTextAlignmentCenter;
        
        
        //不是四舍五入，是到小数点后2位
        //NSString *resultPriceString = [NSString stringWithFormat:@"%@:%@",STLLocalizedString_(@"PaymentAmount", nil),[ExchangeManager changeRateModel:self.rateModel transforPrice:nil]];
        //COD订单 后台金额直接处理，有单位的
        __block CGFloat codAmount = 0.0;
        __block NSString *symbol = @"";
        [self.createOrderModel.orderList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            STLOrderModel *model = obj;
            codAmount += model.order_amount_arab.floatValue;
            symbol = model.currency;
        }];
        
        paymentAmountLab.text = [NSString stringWithFormat:@"%@:%@ %.2f",STLLocalizedString_(@"PaymentAmount", nil),symbol, codAmount];
        
        [self.view addSubview:paymentAmountLab];
        [paymentAmountLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(paymentLabel.mas_bottom).offset(5);
            make.centerX.mas_equalTo(self.view.mas_centerX);
        }];
        
        //白色的底，突出
        UIView *whiteView = [UIView new];
        whiteView.backgroundColor = [UIColor clearColor];
        whiteView.layer.borderColor = OSSVThemesColors.col_DDDDDD.CGColor;
        whiteView.layer.cornerRadius = 2;
        whiteView.layer.borderWidth = 1;
        [self.view addSubview:whiteView];
        [self.view insertSubview:whiteView belowSubview:tipLab];
        
        NSString *hour48 = @"48";
        NSString *hour = STLLocalizedString_(@"codHour", nil);
        NSString *tips = STLLocalizedString_(@"codSuccessfulTip", nil);
        NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc] initWithString:tips];
        [attriString addAttributes:@{NSForegroundColorAttributeName : OSSVThemesColors.col_666666} range:NSMakeRange(0, tips.length)];
        NSRange hourRange = [tips rangeOfString:hour];
        NSRange hour48Range = [tips rangeOfString:hour48];
        [attriString addAttributes:@{NSForegroundColorAttributeName : OSSVThemesColors.col_FA6730} range:hourRange];
        [attriString addAttributes:@{NSForegroundColorAttributeName : OSSVThemesColors.col_FA6730} range:hour48Range];
        tipLab.attributedText = attriString;
        tipLab.backgroundColor = [UIColor clearColor];
        [tipLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(paymentAmountLab.mas_bottom).offset(50);
            make.centerX.mas_equalTo(self.view.mas_centerX);
            make.width.equalTo(@260);
        }];
        
        [whiteView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(tipLab.mas_top).mas_offset(-20);
            make.bottom.mas_equalTo(tipLab.mas_bottom).mas_offset(20);
            make.center.mas_equalTo(tipLab);
            make.width.equalTo(@300);
        }];
    } else {
        tipLab.text = STLLocalizedString_(@"finishView", nil);
        [tipLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo([orderLabelArray lastObject].mas_bottom).offset(20);
            make.centerX.mas_equalTo(self.view.mas_centerX);
            make.width.equalTo(@260);
        }];
    }
    
    UIButton *checkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    checkBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [checkBtn setTitle:STLLocalizedString_(@"checkMyOrder", nil) forState:0];
    [checkBtn setTitleColor:[OSSVThemesColors stlWhiteColor] forState:0];
    [checkBtn setTitleColor:[OSSVThemesColors stlWhiteColor] forState:1];
    checkBtn.backgroundColor = [OSSVThemesColors col_262626];
    checkBtn.layer.cornerRadius = 4;
    checkBtn.layer.masksToBounds = YES;
    [checkBtn addTarget:self action:@selector(jumpToOrderList) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:checkBtn];
    
    [checkBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipLab.mas_bottom).offset(55);
        make.width.equalTo(@300);
        make.height.equalTo(@40);
        make.centerX.mas_equalTo(self.view.mas_centerX);
    }];
}

- (void)jumpToOrderList {
    
    [OSSVAnalyticsTool analyticsGAEventWithName:@"after_payment" parameters:@{
           @"screen_group":@"PaymentSuccess",
           @"action":@"View_Orders"}];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    if (_block) {
        _block();
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - 统计
- (void)analyticsOrderSuccess {
    [self paySuccesWithProduct:self.createOrderModel];
}

- (void)paySuccesWithProduct:(OSSVCreateOrderModel *)model
{
    NSMutableArray *goodsSnArray = [[NSMutableArray alloc]initWithCapacity: 1];
    NSMutableArray *priceArray = [[NSMutableArray alloc]initWithCapacity: 1];
    NSMutableArray *qtyArray = [[NSMutableArray alloc]initWithCapacity: 1];
    NSMutableArray *orderSNsArray = [[NSMutableArray alloc]initWithCapacity: 1];
    
    NSMutableArray *itemsGoods = [[NSMutableArray alloc] init];
    CGFloat allAmount = 0;
    for (NSInteger i = 0; i < model.goodsList.count; i ++) {
        OSSVCartGoodsModel *goodsModel = (OSSVCartGoodsModel*)model.goodsList[i];
        
        if ([goodsModel isKindOfClass:[OSSVAccounteMyOrderseGoodseModel class]]) {
            
            OSSVAccounteMyOrderseGoodseModel *goodsModel = (OSSVAccounteMyOrderseGoodseModel*)model.goodsList[i];
            NSString *priceString = STLToString(goodsModel.money_info.goods_price);
            if (STLIsEmptyString(priceString)) {
                priceString = STLToString(goodsModel.goods_price);
            }
            
            [goodsSnArray addObject:STLToString(goodsModel.goods_sn)];
            [priceArray addObject:priceString];
            [qtyArray addObject:STLToString(goodsModel.goods_number)];
            
            CGFloat price = [priceString floatValue];
            
            NSDictionary *items = @{
                @"item_id": STLToString(goodsModel.goods_sn),
                @"item_name": STLToString(goodsModel.goods_name),
                @"item_category": STLToString(goodsModel.cat_name),
                @"price": @(price),
                @"quantity": STLToString(goodsModel.goods_number),
                @"item_variant":STLToString(goodsModel.goods_attr),
            };
            
            [itemsGoods addObject:items];
            
        } else if([goodsModel isKindOfClass:[OSSVAccounteOrdersDetaileGoodsModel class]]) {
            
            OSSVAccounteOrdersDetaileGoodsModel *goodsModel = (OSSVAccounteOrdersDetaileGoodsModel*)model.goodsList[i];

            NSString *priceString = STLToString(goodsModel.money_info.goods_price);
            if (STLIsEmptyString(priceString)) {
                priceString = STLToString(goodsModel.goods_price);
            }
            
            [goodsSnArray addObject:STLToString(goodsModel.goods_sn)];
            [priceArray addObject:priceString];
            [qtyArray addObject:STLToString(goodsModel.goodsNumber)];

            CGFloat price = [priceString floatValue];
            
            NSDictionary *items = @{
                @"item_id": STLToString(goodsModel.goods_sn),
                @"item_name": STLToString(goodsModel.goodsName),
                @"item_category": STLToString(goodsModel.cat_name),
                @"price": @(price),
                @"quantity": STLToString(goodsModel.goodsNumber),
                @"item_variant":STLToString(goodsModel.goodsAttr),
            };
            
            [itemsGoods addObject:items];
            
        } else {
            [goodsSnArray addObject:STLToString(goodsModel.goodsSn)];
            [priceArray addObject:STLToString(goodsModel.shop_price)];
            [qtyArray addObject:[NSNumber numberWithInteger:goodsModel.goodsNumber]];

            CGFloat price = [goodsModel.shop_price floatValue];
            
            NSDictionary *items = @{
                kFIRParameterItemID: STLToString(goodsModel.goodsSn),
                kFIRParameterItemName: STLToString(goodsModel.goodsName),
                kFIRParameterItemCategory: STLToString(goodsModel.cat_name),
                kFIRParameterPrice: @(price),
                kFIRParameterQuantity: @(goodsModel.goodsNumber),
                kFIRParameterItemVariant:STLToString(goodsModel.goodsAttr),
                kFIRParameterItemBrand:@"",
            };
            
            [itemsGoods addObject:items];
        }
    }
    for (NSInteger i = 0; i < model.orderList.count; i ++) {
        STLOrderModel *orderModel = (STLOrderModel*)model.orderList[i];
        [orderSNsArray addObject:STLToString(orderModel.order_sn)];
        allAmount += [orderModel.order_amount floatValue];
    }
    
    NSString *goodsSnStrings = [(NSArray *)goodsSnArray componentsJoinedByString:@","];
    NSString *priceStrings = [(NSArray *)priceArray componentsJoinedByString:@","];
    NSString *qtyStrings = [(NSArray *)qtyArray componentsJoinedByString:@","];
    NSString *orderSNsStrings = [(NSArray *)orderSNsArray componentsJoinedByString:@","];
    
    NSDictionary *dic = @{
      @"af_content_id":goodsSnStrings,
      @"af_order_id":orderSNsStrings,
      @"af_price":priceStrings,
      @"af_quantity":qtyStrings,
      @"af_currency":@"USD",
      @"af_revenue":[NSString stringWithFormat:@"%.2f",allAmount],
    };
    
    [OSSVAnalyticsTool appsFlyerOrderPaySuccess:dic];

    //数据GA埋点曝光 支付成功事件 ok
    //GA
    NSDictionary *itemsDic = @{kFIRParameterItems:itemsGoods,
                               kFIRParameterCurrency: @"USD",
                               kFIRParameterValue: @(allAmount),
                               kFIRParameterCoupon:STLToString(model.couponCode),
                               kFIRParameterPaymentType:STLToString(model.payCode),
                               kFIRParameterTransactionID:STLToString(orderSNsStrings),
                               kFIRParameterShipping:STLToString(model.shippingFee),
                               kFIRParameterDiscount:@"",
                               kFIRParameterTax:@"",
                               @"cod_cost": @"0",
                               @"cod_discount":@"0",
                               @"screen_group":@"PaymentSuccess",
    };
    
    [OSSVAnalyticsTool analyticsGAEventWithName:kFIREventPurchase parameters:itemsDic];
    ///Branch 购买成功
    [OSSVBrancshToolss logPurchaseGMV:itemsDic];
    
    [DotApi payOrder];
}

- (BOOL)navigationShouldPopOnBackButton {
    /**
        此处是为了防止，删除按钮没有恢复
        而让self.viewModel 在被释放后还继续使用
     */
    //[self.tableView setEditing:NO];
    [OSSVAdvsEventsManager advEventOrderListWithPaymentStutas:YES];

    return NO;
}

-(void)goBackAction {
    [OSSVAnalyticsTool analyticsGAEventWithName:@"after_payment" parameters:@{
           @"screen_group":@"PaymentSuccess",
           @"action":@"continue_shopping"}];
    [OSSVAdvsEventsManager goHomeModule];
}

- (void)actionShop:(UIButton *)sender {
    
    [OSSVAdvsEventsManager goHomeModule];
}

- (void)actionOrder:(UIButton *)sender {
    
    if (self.isFromOrder && self.block) {
        if (self.navigationController) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        self.block();
    } else {
        [OSSVAdvsEventsManager advEventOrderListWithPaymentStutas:YES];
    }

}


- (UIView *)headerView {
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:CGRectZero];
        _headerView.backgroundColor = [OSSVThemesColors stlWhiteColor];
    }
    return _headerView;
}

- (UIImageView *)headerImageView {
    if (!_headerImageView) {
        _headerImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _headerImageView.image = [UIImage imageNamed:@"pay_success_online"];
    }
    return _headerImageView;
}

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _tipLabel.numberOfLines = 0;
        _tipLabel.textColor = [OSSVThemesColors col_0D0D0D];
        _tipLabel.font = [UIFont systemFontOfSize:13];
        _tipLabel.text = STLLocalizedString_(@"finishView", nil);
        _tipLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _tipLabel;
}

- (UIView *)orderBgView {
    if (!_orderBgView) {
        _orderBgView = [[UIView alloc] initWithFrame:CGRectZero];
        _orderBgView.backgroundColor = [OSSVThemesColors stlWhiteColor];
        _orderBgView.layer.cornerRadius = 2;
    }
    return _orderBgView;
}

- (UILabel *)orderTitleLabel {
    if (!_orderTitleLabel) {
        _orderTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _orderTitleLabel.textColor = [OSSVThemesColors col_0D0D0D];
        _orderTitleLabel.font = [UIFont systemFontOfSize:13];
        _orderTitleLabel.text = [NSString stringWithFormat:@"%@:",STLLocalizedString_(@"finishOrder", nil)];
    }
    return _orderTitleLabel;
}

- (UILabel *)orderNumberLabel {
    if (!_orderNumberLabel) {
        _orderNumberLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _orderNumberLabel.textColor = [OSSVThemesColors col_0D0D0D];
        _orderNumberLabel.font = [UIFont systemFontOfSize:13];
    }
    return _orderNumberLabel;
}

- (UILabel *)payMethodTitleLabel {
    if (!_payMethodTitleLabel) {
        _payMethodTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _payMethodTitleLabel.textColor = [OSSVThemesColors col_0D0D0D];
        _payMethodTitleLabel.font = [UIFont systemFontOfSize:13];
        _payMethodTitleLabel.text = [NSString stringWithFormat:@"%@:",STLLocalizedString_(@"paymentMethod", nil)];

    }
    return _payMethodTitleLabel;
}

- (UILabel *)payMethodLabel {
    if (!_payMethodLabel) {
        _payMethodLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _payMethodLabel.textColor = [OSSVThemesColors col_0D0D0D];
        _payMethodLabel.font = [UIFont systemFontOfSize:13];
    }
    return _payMethodLabel;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = [OSSVThemesColors col_EEEEEE];
    }
    return _lineView;
}

- (UIView *)lineView2 {
    if (!_lineView2) {
        _lineView2 = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView2.backgroundColor = [OSSVThemesColors col_EEEEEE];
    }
    return _lineView2;
}


- (UILabel *)amountTitleLabel {
    if (!_amountTitleLabel) {
        _amountTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _amountTitleLabel.textColor = [OSSVThemesColors col_0D0D0D];
        _amountTitleLabel.font = [UIFont systemFontOfSize:13];
        _amountTitleLabel.text = [NSString stringWithFormat:@"%@:",STLLocalizedString_(@"PaymentAmount", nil)];

    }
    return _amountTitleLabel;
}

- (UILabel *)amountLabel {
    if (!_amountLabel) {
        _amountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _amountLabel.textColor = [OSSVThemesColors col_0D0D0D];
        _amountLabel.font = [UIFont systemFontOfSize:13];
    }
    return _amountLabel;
}


- (UIButton *)goShopButton {
    if (!_goShopButton) {
        _goShopButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_goShopButton addTarget:self action:@selector(actionShop:) forControlEvents:UIControlEventTouchUpInside];
        [_goShopButton setTitle:[STLLocalizedString_(@"ContinueShopping", nil) uppercaseString] forState:UIControlStateNormal];
        _goShopButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        [_goShopButton setTitleColor:[OSSVThemesColors stlWhiteColor] forState:UIControlStateNormal];
        _goShopButton.backgroundColor = [OSSVThemesColors col_0D0D0D];
        _goShopButton.layer.cornerRadius = 2.f;
        _goShopButton.layer.masksToBounds = YES;
    }
    return _goShopButton;
}

- (UIButton *)checkOrderButton {
    if (!_checkOrderButton) {
        _checkOrderButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_checkOrderButton addTarget:self action:@selector(actionOrder:) forControlEvents:UIControlEventTouchUpInside];
        [_checkOrderButton setTitle:[STLLocalizedString_(@"checkMyOrder", nil) uppercaseString] forState:UIControlStateNormal];
        _checkOrderButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        [_checkOrderButton setTitleColor:[OSSVThemesColors col_0D0D0D] forState:UIControlStateNormal];
        _checkOrderButton.backgroundColor = [OSSVThemesColors stlWhiteColor];
        _checkOrderButton.layer.cornerRadius = 2.f;
        _checkOrderButton.layer.masksToBounds =  YES;
    }
    return _checkOrderButton;
}

-(OSSVPaymentsStatussViewModel *)viewModel{
    if (!_viewModel) {
        _viewModel = [[OSSVPaymentsStatussViewModel alloc] init];
    }
    return _viewModel;
}


@end
