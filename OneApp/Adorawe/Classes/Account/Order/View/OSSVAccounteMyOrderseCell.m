//
//  OSSVAccounteMyOrderseCell.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/8.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVAccounteMyOrderseCell.h"
#import "OSSVAccounteMyeOrdersListeModel.h"
#import "STLLableEdgeInsets.h"
#import "OSSVPaymenteTipseAlertView.h"
#import "OSSVAccounteMyOrderseGoodseModel.h"
#import "OSSVOrdereItemeButtonView.h"
#import "OSSVOrdereGoodseView.h"
#import "Adorawe-Swift.h"

@interface OSSVAccounteMyOrderseCell ()

@property (nonatomic,strong) UIView             *bgView;//状态容器
@property (nonatomic,strong) UIView             *topView;//状态容器
@property (nonatomic,strong) UIView             *lineView;
@property (nonatomic,strong) UIView             *waitCheckBgView;
@property (nonatomic,strong) UIView             *waitCheckView;
@property (nonatomic,strong) UIImageView        *waitTipArrowImageView;
@property (nonatomic,strong) UILabel            *codCheckTipLabel;//cod 等待check
@property (nonatomic,strong) UIView             *middleView;//商品容器
@property (nonatomic,strong) OSSVOrdereGoodseView  *orderGoodsView;
@property (nonatomic,strong) UIView             *totalView;//价格容器
@property (nonatomic,strong) UIView             *bottomView;//按钮容器
@property (nonatomic,strong) UIButton           *colorStatue;//显示状态
@property (nonatomic,strong) UILabel            *statusLabel;//订单状态
@property (nonatomic,strong) UILabel            *orderTimeLabel;
@property (nonatomic,strong) UILabel            *totalPrice;//订单价格
@property (nonatomic,strong) UILabel            *totalPriceLbl;//订单价格
@property (nonatomic,strong) UILabel            *totalItemsLabel;
@property (nonatomic,strong) UILabel            *taxLabel; //含税label
@property (nonatomic,strong) UIView             *secondLineView;
@property (nonatomic,strong) UIView             *threeLineView;
@property (nonatomic,strong) OSSVOrdereRepurchaseeTipeView *repurchaseTipView;

@property (nonatomic,strong) OSSVOrdereItemeButtonView           *cancleBtn;//取消按钮
@property (nonatomic,strong) OSSVOrdereItemeButtonView           *payBtn;//支付按钮
@property (nonatomic,strong) OSSVOrdereItemeButtonView           *buyAgainBtn;//再次购买
@property (nonatomic,strong) OSSVOrdereItemeButtonView           *reviewBtn;//评论
@property (nonatomic,strong) OSSVOrdereItemeButtonView           *shipmentBtn;//物流
@property (nonatomic,strong) OSSVOrdereItemeButtonView           *tempPayBtn;//支付按钮
@property (nonatomic,strong) NSMutableArray     *mutableArray;//图片数组

/*cod订单展示需求 */
@property (nonatomic, strong) STLLableEdgeInsets  *codOrderStatueLabel; //cod支付方式.
@property (nonatomic, strong) UILabel            *countDownTipsLabel;
@property (nonatomic, strong) BigClickAreaButton *countDownDetailBtn;             ///<倒计时解释
@end

@implementation OSSVAccounteMyOrderseCell

#pragma mark -
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self= [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initView];
    }
    return self;
}

- (void)initView {
    UIView *ws = self.contentView;
    ws.backgroundColor = [OSSVThemesColors col_F5F5F5];
    
    [ws addSubview:self.bgView];
    [ws addSubview:self.topView];
    [ws addSubview:self.lineView];
    [ws addSubview:self.waitCheckBgView];
    [ws addSubview:self.waitCheckView];
    [ws addSubview:self.waitTipArrowImageView];
    [ws addSubview:self.middleView];
    [ws addSubview:self.totalView];
    [ws addSubview:self.secondLineView];
    [ws addSubview:self.codOrderStatueLabel];
    [ws addSubview:self.threeLineView];
    [ws addSubview:self.bottomView];

    [self.topView addSubview:self.colorStatue];
    [self.topView addSubview:self.statusLabel];
    [self.topView addSubview:self.countDownDetailBtn];
    [self.topView addSubview:self.orderTimeLabel];

    [self.waitCheckView addSubview:self.codCheckTipLabel];
    [self.waitCheckView addSubview:self.countDownTipsLabel];
    [self.waitCheckView addSubview:self.countDownLabel];
    
    [self.totalView addSubview:self.totalItemsLabel];
    [self.totalView addSubview:self.totalPrice];
    [self.totalView addSubview:self.taxLabel];
    [self.totalView addSubview:self.totalPriceLbl];
    
    [self.bottomView addSubview:self.cancleBtn];
    [self.bottomView addSubview:self.shipmentBtn];
    [self.bottomView addSubview:self.tempPayBtn];
    [self.bottomView addSubview:self.payBtn];
    [self.bottomView addSubview:self.buyAgainBtn];
    [self.bottomView addSubview:self.reviewBtn];
    
    [self.middleView addSubview:self.orderGoodsView];
    
    [self.bottomView addSubview:self.repurchaseTipView];
    
    [self makeConstraints];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.statusLabel.text = nil;
    self.totalPrice.text = nil;
    self.totalItemsLabel.text = nil;
    self.taxLabel.text = nil;
}

#pragma mark - Constraints

- (void)makeConstraints {
    
    UIView *ws = self.bgView;
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(12);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
        make.top.mas_equalTo(self.contentView.mas_top).mas_offset(8);
        make.bottom.mas_equalTo(self.contentView.mas_bottom);
    }];
    
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(ws.mas_top);
        make.leading.mas_equalTo(ws.mas_leading);
        make.trailing.mas_equalTo(ws.mas_trailing);
        make.height.mas_equalTo(@48);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.bgView.mas_leading).offset(14);
        make.trailing.mas_equalTo(self.bgView.mas_trailing).offset(-14);
        make.top.mas_equalTo(self.topView.mas_bottom);
        make.height.mas_equalTo(0.5);
    }];
    
    [self.colorStatue mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.topView.mas_leading).offset(14);
        make.top.mas_equalTo(self.topView.mas_top).offset(16);
        make.width.mas_equalTo(@8);
        make.height.mas_equalTo(@8);
    }];
    
    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.colorStatue.mas_centerY).offset(-2);
        make.leading.mas_equalTo(self.colorStatue.mas_trailing).offset(8);
    }];
    
    [self.countDownDetailBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.statusLabel.mas_centerY);
        make.width.height.mas_offset(12);
        make.leading.mas_equalTo(self.statusLabel.mas_trailing).offset(5);
    }];
    
    [self.orderTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.statusLabel.mas_leading);
        make.top.mas_equalTo(self.statusLabel.mas_bottom).offset(2);
    }];
    
    
    [self.middleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.lineView.mas_bottom);
        make.leading.mas_equalTo(ws.mas_leading);
        make.trailing.mas_equalTo(ws.mas_trailing);
        make.height.mas_equalTo(112);
    }];
    
    [self.orderGoodsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.mas_equalTo(self.middleView);
    }];
    
    [self.totalView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.middleView.mas_bottom);
        make.leading.mas_equalTo(ws.mas_leading);
        make.trailing.mas_equalTo(ws.mas_trailing);
        make.height.mas_equalTo(@36);
    }];
        
    [self.secondLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.bgView.mas_leading).offset(14);
        make.trailing.mas_equalTo(self.bgView.mas_trailing).offset(-14);
        make.top.mas_equalTo(self.totalView.mas_bottom);
        make.height.mas_equalTo(0.5);
    }];
    
    [self.totalPrice mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.totalView.mas_trailing).offset(-14);
        make.top.mas_equalTo(self.totalView.mas_top);
        make.height.equalTo(17);
//        make.centerY.mas_equalTo(self.totalView.mas_centerY);
    }];
    
    [self.totalPriceLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.totalPrice.mas_leading);
        make.top.mas_equalTo(self.totalView.mas_top);
        make.height.equalTo(17);
//        make.centerY.mas_equalTo(self.totalView.mas_centerY);
    }];
    
    [self.totalItemsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.totalPriceLbl.mas_leading).offset(-4);
        make.centerY.mas_equalTo(self.totalPrice.mas_centerY);
    }];
    
    [self.taxLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.totalPrice.mas_bottom).offset(2);
        make.trailing.mas_equalTo(self.totalView.mas_trailing).offset(-14);
        make.height.equalTo(12);
    }];
    
    [self.codOrderStatueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.bgView.mas_leading).offset(14);
        make.trailing.mas_equalTo(self.bgView.mas_trailing).offset(-14);
        make.top.mas_equalTo(self.secondLineView.mas_bottom);
        make.height.mas_equalTo(0);
    }];
    
    [self.threeLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.bgView.mas_leading).offset(14);
        make.trailing.mas_equalTo(self.bgView.mas_trailing).offset(-14);
        make.top.mas_equalTo(self.codOrderStatueLabel.mas_bottom);
        make.height.mas_equalTo(0.5);
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.threeLineView.mas_bottom);
        make.leading.mas_equalTo(ws.mas_leading);
        make.trailing.mas_equalTo(ws.mas_trailing);
        //make.bottom.mas_equalTo(ws.mas_bottom);
        make.height.mas_equalTo(@50);
    }];
    
    [self.payBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.bottomView.mas_centerY);
        make.trailing.mas_equalTo(self.bottomView.mas_trailing).offset(-4);
        make.height.mas_equalTo(@28);
    }];
    
    [self.tempPayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.bottomView.mas_centerY);
        make.trailing.mas_equalTo(self.bottomView.mas_trailing).offset(-4);
        make.height.mas_equalTo(@28);
    }];
    
    [self.buyAgainBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.bottomView.mas_centerY);
        make.trailing.mas_equalTo(self.bottomView.mas_trailing).offset(-4);
        make.height.mas_equalTo(@28);
    }];
    
    [self.reviewBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.bottomView.mas_centerY);
        make.trailing.mas_equalTo(self.buyAgainBtn.mas_leading);
        make.height.mas_equalTo(@28);
    }];
    
    [self.shipmentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.bottomView.mas_centerY);
        make.trailing.mas_equalTo(self.buyAgainBtn.mas_leading);
        make.height.mas_equalTo(@28);
    }];
    
    [self.cancleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.bottomView.mas_centerY);
        make.trailing.mas_equalTo(self.buyAgainBtn.mas_leading);
        make.height.mas_equalTo(@28);
    }];
    
    [self.repurchaseTipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.bottomView.mas_leading).offset(14);
        make.trailing.mas_equalTo(self.tempPayBtn.mas_leading).offset(-8);
        make.height.mas_equalTo(20);
        make.bottom.mas_equalTo(self.tempPayBtn.mas_top).offset(-0.5);
    }];
    
    [self.waitCheckBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.bgView);
        make.top.mas_equalTo(self.bottomView.mas_bottom);
        make.bottom.mas_equalTo(self.bgView.mas_bottom);
        make.height.mas_greaterThanOrEqualTo(0);
    }];
        
    [self.waitCheckView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.waitCheckBgView.mas_top);
        make.leading.mas_equalTo(self.waitCheckBgView.mas_leading).offset(14);
        make.trailing.mas_equalTo(self.waitCheckBgView.mas_trailing).offset(-14);
        make.bottom.mas_equalTo(self.waitCheckBgView.mas_bottom);
    }];
    
    [self.waitTipArrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.waitCheckView.mas_trailing).offset(-24);
        make.bottom.mas_equalTo(self.waitCheckView.mas_top);
    }];
    
    [self.codCheckTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.waitCheckView.mas_leading).offset(12);
        make.trailing.mas_equalTo(self.waitCheckView.mas_trailing).offset(-12);
        make.top.mas_equalTo(self.waitCheckView.mas_top).offset(7);
        make.bottom.mas_equalTo(self.waitCheckView.mas_bottom).offset(-7);
    }];
    
    [self.countDownLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.waitCheckView.mas_top);
        make.height.mas_offset(28);
        make.leading.mas_equalTo(self.countDownTipsLabel.mas_trailing).offset(4);
        make.trailing.mas_equalTo(self.waitCheckView.mas_trailing).offset(-12);
    }];
    
    [self.countDownTipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.waitCheckView.mas_top);
        make.leading.mas_equalTo(self.waitCheckView.mas_leading).offset(12);
        make.height.mas_equalTo(28);
    }];
}


#pragma mark - Action
#pragma mark  Cancel
- (void)cancelTouch:(UIButton *)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(OSSVAccounteMyOrderseCell:sender:event:)]) {
        [self.delegate OSSVAccounteMyOrderseCell:self sender:sender event:OrderOperateTypeCancel];
    }
}

#pragma mark  PayNow
- (void)payNowTouch:(UIButton *)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(OSSVAccounteMyOrderseCell:sender:event:)]) {
        [self.delegate OSSVAccounteMyOrderseCell:self sender:sender event:OrderOperateTypePaying];
    }
}

#pragma mark  BuyAgain
- (void)buyAgainTouch:(UIButton *)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(OSSVAccounteMyOrderseCell:sender:event:)]) {
        
        //未付款、扣款失败
        if ([self.orderListModel.orderStatus integerValue] == OrderStateTypeWaitingForPayment || [self.orderListModel.orderStatus integerValue] == OrderStateTypeDeductionFailed || [self.orderListModel.orderStatus integerValue] == OrderStateTypeWaitConfirm) {
            [self.delegate OSSVAccounteMyOrderseCell:self sender:sender event:OrderOperateTypeBuyAddCart];
        } else {
            [self.delegate OSSVAccounteMyOrderseCell:self sender:sender event:OrderOperateTypeBuyAgain];
        }
    }
}

#pragma mark
- (void)reviewTouch:(UIButton *)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(OSSVAccounteMyOrderseCell:sender:event:)]) {
        [self.delegate OSSVAccounteMyOrderseCell:self sender:sender event:OrderOperateTypeReview];
    }
}

- (void)shipmentTouch:(UIButton *)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(OSSVAccounteMyOrderseCell:sender:event:)]) {
        [self.delegate OSSVAccounteMyOrderseCell:self sender:sender event:OrderOperateTypeShipment];
    }
}

#pragma mark  TipsPop

-(void)countDownDetailBtnAction {
//    OSSVPaymenteTipseAlertView *paypopView = [[OSSVPaymenteTipseAlertView alloc] init];
//    [paypopView show];
    
    NSString *string = STLLocalizedString_(@"Order_remaining_payment_time_message", nil);
    NSMutableParagraphStyle *parStyle = [[NSMutableParagraphStyle alloc] init];
    parStyle.lineSpacing = [OSSVAlertsViewNew lineSpace];
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:string];
    [attString addAttribute:NSParagraphStyleAttributeName value:parStyle range:NSMakeRange(0, string.length)];
    [attString addAttribute:NSParagraphStyleAttributeName value:parStyle range:NSMakeRange(0, string.length)];
    [attString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, string.length)];
    
    [OSSVAlertsViewNew showAlertWithFrame:[UIScreen mainScreen].bounds alertType:STLAlertTypeButtonColumn isVertical:YES messageAlignment:NSTextAlignmentCenter isAr:NO showHeightIndex:0 title:@"" message:attString buttonTitles:@[STLLocalizedString_(@"yes", nil)] buttonBlock:^(NSInteger index , NSString * _Nonnull title) {
        
    }];
}


#pragma mark - 赋值

- (void)showBottomTimeTipView:(BOOL)show {
    
    self.waitTipArrowImageView.hidden = !show;
    self.waitCheckBgView.hidden = !show;
    self.waitCheckView.hidden = !show;
    
    if (show) {
        [self.waitCheckBgView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_greaterThanOrEqualTo(28);
            make.bottom.mas_equalTo(self.bgView.mas_bottom).offset(-14);
        }];
        
        [self.codCheckTipLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.waitCheckView.mas_top).offset(7);
            make.bottom.mas_equalTo(self.waitCheckView.mas_bottom).offset(-7);
        }];
        
    } else {
        [self.waitCheckBgView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_greaterThanOrEqualTo(0);
            make.bottom.mas_equalTo(self.bgView.mas_bottom);
        }];
        [self.codCheckTipLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.waitCheckView.mas_top);
            make.bottom.mas_equalTo(self.waitCheckView.mas_bottom);
        }];
    }
}
- (void)setOrderListModel:(OSSVAccounteMyeOrdersListeModel *)orderListModel {
    
    //v1.4.6 经产品、设计暂时隐藏
    orderListModel.isAccord = NO;
    
    _orderListModel = orderListModel;
    
    self.countDownLabel.hidden = YES;
    self.countDownDetailBtn.hidden = YES;
    self.countDownTipsLabel.hidden = YES;
    self.countDownTipsLabel.text = STLLocalizedString_(@"Remaining_payment_time", nil);
    self.buyAgainBtn.hidden = YES;
    self.bottomView.hidden = YES;
    self.codOrderStatueLabel.hidden = YES;
    self.threeLineView.hidden = YES;
    self.payBtn.hidden = YES;
    self.reviewBtn.hidden = YES;
    self.repurchaseTipView.hidden = YES;
    self.waitTipArrowImageView.hidden = YES;
    self.waitCheckBgView.hidden = YES;
    self.waitCheckView.hidden = YES;
    
    [self.buyAgainBtn.button setBackgroundColor:[OSSVThemesColors stlClearColor]];
    [self.buyAgainBtn.button setTitleColor:[OSSVThemesColors col_0D0D0D] forState:UIControlStateNormal];
    
    BOOL hasPay = NO;
    BOOL hasReview = NO;
    BOOL hasBuyAgain = NO;
    BOOL hasCancle = NO;
    BOOL hasShipment = NO;
    BOOL hasShowRepurchaseTip = NO;
    
    self.repurchaseTipView.title = STLToString(_orderListModel.retrieve_tips);

    //状态太多，默认绿色
    self.colorStatue.backgroundColor = [OSSVThemesColors col_60CD8E];
    [self.payBtn.button setTitle:[STLLocalizedString_(@"payNow",nil) uppercaseString]forState:UIControlStateNormal];
    [self.tempPayBtn.button setTitle:[STLLocalizedString_(@"payNow",nil) uppercaseString]forState:UIControlStateNormal];

//    [self.topView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.height.mas_offset(40);
//    }];
    
    self.orderTimeLabel.text = [OSSVCommonsManagers dateFormatString:[OSSVCommonsManagers sharedManager].arDateTimeFormatter time:STLToString(_orderListModel.add_time)];
    
    [self showBottomTimeTipView:NO];
    self.codCheckTipLabel.text = @"";
    if (!STLIsEmptyString(_orderListModel.order_remark)) {
        self.codCheckTipLabel.text = STLToString(_orderListModel.order_remark);
         
//        self.waitCheckView.backgroundColor = OSSVThemesColors.col_FFF5DF;
        self.waitCheckBgView.hidden = NO;
        self.codCheckTipLabel.hidden = NO;
        [self showBottomTimeTipView:YES];
    }
    //普通再次购买按钮标识
    self.buyAgainBtn.button.sensor_element_id = @"repurchase_complete_button";
    if ([orderListModel.orderStatus integerValue] == OrderStateTypeCancelled
        || [orderListModel.orderStatus integerValue] == OrderStateTypeRefunded) {// 取消、退款
        self.colorStatue.backgroundColor = [OSSVThemesColors col_CCCCCC];
//        self.waitCheckView.backgroundColor = [OSSVThemesColors col_FAFAFA];
        
        hasBuyAgain = YES;

    }else if ([orderListModel.orderStatus integerValue] == OrderStateTypeWaitingForPayment
               || [orderListModel.orderStatus integerValue] == OrderStateTypePaying
               || [orderListModel.orderStatus integerValue] == OrderStateTypePartialOrderPaid
               || [orderListModel.orderStatus integerValue] == OrderStateTypeWaitConfirm
               || [orderListModel.orderStatus integerValue] == OrderStateTypeDeductionFailed) {// 未付款、付款中、部分付款、扣款失败、待确认
        
        self.colorStatue.backgroundColor = [OSSVThemesColors col_B62B21];
        if (![orderListModel.payCode isEqualToString:@"Cod"]) {
            
            ///非COD订单未支付状态新增一个倒计时label, 非COD待支付商品隐藏Cancle按钮
            if ([orderListModel.orderStatus integerValue] != OrderStateTypePartialOrderPaid
                && [orderListModel.orderStatus integerValue] != OrderStateTypeDeductionFailed
                && [orderListModel.orderStatus intValue] != OrderStateTypePaying) {
                
                if ([orderListModel.expiresTime integerValue] > 0) {
                    
                    self.codCheckTipLabel.hidden = YES;
                    self.countDownLabel.hidden = NO;
                    self.countDownDetailBtn.hidden = NO;
                    self.countDownTipsLabel.hidden = NO;
                    [self.countDownLabel setupCellWithModel:_orderListModel indexPath:self.indexPath];
                    self.countDownLabel.attributedText = [self.countDown countDownWithTimeLabel:self.countDownLabel];
                    self.codCheckTipLabel.text = @"time";
                    self.waitCheckBgView.hidden = NO;
                    [self showBottomTimeTipView:YES];
                }
            }
            
            if ([orderListModel.orderStatus integerValue] == OrderStateTypeWaitingForPayment
                || [orderListModel.orderStatus integerValue] == OrderStateTypePartialOrderPaid
                || [orderListModel.orderStatus integerValue] == OrderStateTypeDeductionFailed) {
                hasPay = YES;
                
                if ([orderListModel.orderStatus integerValue] == OrderStateTypeWaitingForPayment
                    || [orderListModel.orderStatus integerValue] == OrderStateTypeDeductionFailed) {//未付款、扣款失败
                    hasCancle = YES;
                    hasBuyAgain = YES;
                    //订单挽留再次购买按钮标识
                    self.buyAgainBtn.button.sensor_element_id = @"repurchase_button";
                }
                [self.payBtn.button setBackgroundColor:[OSSVThemesColors col_0D0D0D]];
                [self.payBtn.button setTitleColor:[OSSVThemesColors stlWhiteColor] forState:UIControlStateNormal];
                
                

            }
        } else if([orderListModel.payCode isEqualToString:@"Cod"]) {
            if ([orderListModel.orderStatus integerValue] == OrderStateTypeWaitingForPayment || [orderListModel.orderStatus integerValue] == OrderStateTypeWaitConfirm) {
                hasPay = YES;
                hasCancle = YES;
                hasBuyAgain = YES;
                //订单挽留再次购买按钮标识
                self.buyAgainBtn.button.sensor_element_id = @"repurchase_button";
                
                [self.payBtn.button setBackgroundColor:[OSSVThemesColors col_0D0D0D]];
                [self.payBtn.button setTitleColor:[OSSVThemesColors stlWhiteColor] forState:UIControlStateNormal];
                if([orderListModel.orderStatus integerValue] == OrderStateTypeWaitConfirm) {
                    if (APP_TYPE == 3) {
                        [self.payBtn.button setTitle:STLLocalizedString_(@"confirm",nil) forState:UIControlStateNormal];
                        [self.tempPayBtn.button setTitle:STLLocalizedString_(@"confirm",nil) forState:UIControlStateNormal];

                    } else {
                        [self.payBtn.button setTitle:[STLLocalizedString_(@"confirm",nil) uppercaseString] forState:UIControlStateNormal];
                        [self.tempPayBtn.button setTitle:[STLLocalizedString_(@"confirm",nil) uppercaseString] forState:UIControlStateNormal];

                    }
                    self.countDownTipsLabel.text = STLLocalizedString_(@"Remaining_confirm_time", nil);
                }
                
                if ([orderListModel.expiresTime integerValue] > 0) {

                    self.codCheckTipLabel.hidden = YES;
                    self.codCheckTipLabel.text = @"time";
                    self.countDownLabel.hidden = NO;
                    self.countDownDetailBtn.hidden = NO;
                    self.countDownTipsLabel.hidden = NO;
                    [self.countDownLabel setupCellWithModel:_orderListModel indexPath:self.indexPath];
                    self.countDownLabel.attributedText = [self.countDown countDownWithTimeLabel:self.countDownLabel];
//                    [self.topView mas_updateConstraints:^(MASConstraintMaker *make) {
//                        make.height.mas_offset(60);
//                    }];
//                    self.waitCheckView.backgroundColor = OSSVThemesColors.col_FFF5DF;
                    self.waitCheckBgView.hidden = NO;
                    [self showBottomTimeTipView:YES];
                }
                
            }
        }
        
        
    }else if ([orderListModel.orderStatus integerValue] == OrderStateTypePaid
              || [orderListModel.orderStatus integerValue] == OrderStateTypeProcessing
              || [orderListModel.orderStatus integerValue] == OrderStateTypeShippedOut
              || [orderListModel.orderStatus integerValue] == OrderStateTypeDelivered
              || [orderListModel.orderStatus integerValue] == OrderStateTypePartialOrderShipped) {// 已付款、备货、完全发货、已收到货、部分发货
        
        self.colorStatue.backgroundColor = [OSSVThemesColors col_60CD8E];
        if ([orderListModel.orderStatus integerValue] == OrderStateTypeShippedOut
            || [orderListModel.orderStatus integerValue] == OrderStateTypeDelivered
            || [orderListModel.orderStatus integerValue] == OrderStateTypePartialOrderShipped ) {//部分发货，完全发货、已收到货
//            hasReview = YES;
            hasBuyAgain = YES;
            //只有COD订单才展示物流按钮
            if ([orderListModel.payCode isEqualToString:@"Cod"]) {
                hasShipment = YES;

            }
        }
        ///1.4.6 review 单独处理 //收到货才能评论
        if (//[orderListModel.orderStatus integerValue] == OrderStateTypeShippedOut||
            [orderListModel.orderStatus integerValue] == OrderStateTypeDelivered
            //|| [orderListModel.orderStatus integerValue] == OrderStateTypePartialOrderShipped //部分发货，完全发货、已收到货
            ) {
            hasReview = YES;
            
        }

        
    } else if([orderListModel.orderStatus integerValue] == OrderStateTypeWatingAudit) {
        //未支付状态
        self.colorStatue.backgroundColor = [OSSVThemesColors col_B62B21];
        if ([orderListModel.payCode isEqualToString:@"Cod"]) {
            
        }
    }
    
    if (hasBuyAgain && _orderListModel.is_retrieve && hasPay && !STLIsEmptyString(_orderListModel.retrieve_tips)) {
        self.repurchaseTipView.hidden = NO;
        hasShowRepurchaseTip = YES;
    }
    
    //订单状态
    self.statusLabel.text = orderListModel.orderStatusValue;
    NSString *taxStr = STLUserDefaultsGet(@"tax");
    if (taxStr) {
        self.taxLabel.text = [NSString stringWithFormat:@"(%@)", taxStr];
    }
    //订单价格
//    self.totalPrice.text = [NSString stringWithFormat:@"%@ : %@",STLLocalizedString_(@"total",nil),orderListModel.orderAmount];
    //经和PHP安卓统一为payable_amount_converted_symbol 这个字段
//    self.totalPrice.text = [NSString stringWithFormat:@"%@ : %@",STLLocalizedString_(@"total",nil),orderListModel.money_info.payable_amount_converted_symbol];
    self.totalPriceLbl.text = [NSString stringWithFormat:@"%@ : ",STLLocalizedString_(@"total",nil)];
    self.totalPrice.text = [NSString stringWithFormat:@"%@", STLToString(orderListModel.money_info.payable_amount_converted_symbol)];

    //商品数量总计
    if (orderListModel.ordersGoodsList.count) {
        int totalCount = 0;
        for (int i = 0; i < orderListModel.ordersGoodsList.count; i++) {
            totalCount += [orderListModel.ordersGoodsList[i].goods_number intValue];
        }
        if (totalCount > 1) {
            self.totalItemsLabel.text = [NSString stringWithFormat:@"%lu %@",(unsigned long)totalCount,STLLocalizedString_(@"checkOutItems", nil)];

        } else {
            self.totalItemsLabel.text = [NSString stringWithFormat:@"%lu %@",(unsigned long)totalCount,STLLocalizedString_(@"checkOutItem", nil)];
        }
    }
    //商品图片
    [self createGoodsImgView:orderListModel];
    
    CGFloat codStatueMsgHeight = 0;
    CGFloat bottomHeight = 0;

    if ([orderListModel.payCode isEqualToString:@"Cod"]) {
        if (orderListModel.isAccord) {//COD状态描述
            CGFloat codOrderStatueLabelH = [self codOrderStatueH];
            codStatueMsgHeight = codOrderStatueLabelH + 10;
        }
    }
    
    if (hasBuyAgain || hasReview || hasPay || hasCancle || hasShipment) {
        bottomHeight = 50;
    }
    
    self.codOrderStatueLabel.hidden = codStatueMsgHeight > 0 ? NO : YES;
    self.threeLineView.hidden = codStatueMsgHeight > 0 ? NO : YES;
    [self.codOrderStatueLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.secondLineView.mas_bottom);
        make.height.mas_equalTo(codStatueMsgHeight);
    }];

    self.bottomView.hidden = bottomHeight > 0 ? NO : YES;

    [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(bottomHeight);
        make.top.mas_equalTo(self.threeLineView.mas_bottom).offset(hasShowRepurchaseTip ? 5 : 0);
    }];
 
    
    //暂时没有有threeLineView，所以判断
    self.secondLineView.hidden = YES;
    if (bottomHeight > 0) {
        self.secondLineView.hidden = NO;
        [self.bottomView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if ([obj isEqual:self.repurchaseTipView] || [obj isEqual:self.tempPayBtn]) {
            } else {
                [obj mas_remakeConstraints:^(MASConstraintMaker *make) {
                }];
            }
        }];
        

        self.payBtn.hidden = !hasPay;
        self.reviewBtn.hidden = !hasReview;
        self.buyAgainBtn.hidden = !hasBuyAgain;
        self.cancleBtn.hidden = !hasCancle;
        self.shipmentBtn.hidden = !hasShipment;
        
        NSMutableArray *btnMutableArray = [NSMutableArray array];
        if (hasPay) {
            [btnMutableArray addObject:self.payBtn];
        }
        
        if (hasBuyAgain) {
            [btnMutableArray addObject:self.buyAgainBtn];
        }
        
        if (hasReview) {
            [btnMutableArray addObject:self.reviewBtn];
        }
       
        if (hasShipment) {
            [btnMutableArray addObject:self.shipmentBtn];
        }
        if (hasCancle) {
            [btnMutableArray addObject:self.cancleBtn];
        }
        
        UIButton *tempBtn;
        for (UIButton *eventBtn in btnMutableArray) {
            if (tempBtn) {
                [eventBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.mas_equalTo(self.bottomView.mas_centerY);
                    make.trailing.mas_equalTo(tempBtn.mas_leading);
                    make.height.mas_equalTo(@28);
                }];
            } else {
                [eventBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.mas_equalTo(self.bottomView.mas_centerY);
                    make.trailing.mas_equalTo(self.bottomView.mas_trailing).offset(-6);
                    make.height.mas_equalTo(@28);
                }];
            }
            [tempBtn setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];

            eventBtn.hidden = NO;
            tempBtn = eventBtn;
        }
        
        if (hasBuyAgain && !hasPay) {
            [self.buyAgainBtn.button setBackgroundColor:[OSSVThemesColors col_0D0D0D]];
            [self.buyAgainBtn.button setTitleColor:[OSSVThemesColors stlWhiteColor] forState:UIControlStateNormal];
        }
    }
    
}


- (CGFloat)codOrderStatueH {
    
   return [STLLocalizedString_(@"codOrderStatePrompt", @"COD订单提示语") boundingRectWithSize:CGSizeMake(SCREEN_WIDTH, 200)
                                                                          options: NSStringDrawingUsesLineFragmentOrigin
                                                                       attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14] }
                                                                          context:nil].size.height;
}

#pragma mark - 商品图片
- (void)createGoodsImgView:(OSSVAccounteMyeOrdersListeModel *)orderListModel {

    
    self.orderGoodsView.formated_goods_amount = orderListModel.money_info.goods_amount_converted_symbol;
    if (!STLJudgeEmptyArray(orderListModel.ordersGoodsList)) {
        self.orderGoodsView.ordersGoodsList = orderListModel.ordersGoodsList;
    } else {
        self.orderGoodsView.ordersGoodsList = @[];
    }
}



#pragma mark - setter and getter

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:CGRectZero];
        _bgView.backgroundColor = [OSSVThemesColors stlWhiteColor];
        _bgView.layer.cornerRadius = 6;
        _bgView.layer.masksToBounds = YES;
    }
    return _bgView;
}
- (UIView *)topView {
    if (!_topView) {
        _topView = [[UIView alloc] initWithFrame:CGRectZero];
        _topView.backgroundColor = [UIColor clearColor];
        
    }
    return _topView;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [OSSVThemesColors col_EEEEEE];
    }
    return _lineView;
}

- (UIButton *)colorStatue {
    if (!_colorStatue) {
        _colorStatue = [UIButton buttonWithType:UIButtonTypeCustom];
        _colorStatue.layer.cornerRadius = 4;
        _colorStatue.layer.masksToBounds = YES;
    }
    return _colorStatue;
}

- (UILabel *)statusLabel {
    if (!_statusLabel) {
        _statusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _statusLabel.textColor = [OSSVThemesColors col_0D0D0D];
        _statusLabel.font = [UIFont boldSystemFontOfSize:14];
    }
    return _statusLabel;
}

- (UILabel *)orderTimeLabel {
    if (!_orderTimeLabel) {
        _orderTimeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _orderTimeLabel.textColor = [OSSVThemesColors col_B2B2B2];
        _orderTimeLabel.font = [UIFont systemFontOfSize:10];
        _orderTimeLabel.textAlignment = NSTextAlignmentLeft;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _orderTimeLabel.textAlignment = NSTextAlignmentRight;
        }
    }
    return _orderTimeLabel;
}

- (UIView *)middleView {
    if (!_middleView) {
        _middleView = [[UIView alloc] initWithFrame:CGRectZero];
        _middleView.backgroundColor = [OSSVThemesColors stlWhiteColor];
    }
    return _middleView;
}

- (OSSVOrdereGoodseView *)orderGoodsView {
    if (!_orderGoodsView) {
        _orderGoodsView = [[OSSVOrdereGoodseView alloc] init];
    }
    return _orderGoodsView;
}

- (UIView *)totalView {
    if (!_totalView) {
        _totalView = [[UIView alloc] initWithFrame:CGRectZero];
        _totalView.backgroundColor = [OSSVThemesColors stlWhiteColor];
    }
    return _totalView;
}

- (UIView *)secondLineView {
    if (!_secondLineView) {
        _secondLineView = [[UIView alloc] init];
        _secondLineView.backgroundColor = [OSSVThemesColors col_EEEEEE];
    }
    return _secondLineView;
}

- (UIView *)threeLineView {
    if (!_threeLineView) {
        _threeLineView = [[UIView alloc] init];
        _threeLineView.backgroundColor = [OSSVThemesColors col_EEEEEE];
    }
    return _threeLineView;
}


- (UILabel *)totalPrice {
    if (!_totalPrice) {
        _totalPrice = [UILabel new];
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _totalPrice.lineBreakMode = NSLineBreakByTruncatingHead;
        }
        _totalPrice.textColor = [OSSVThemesColors col_0D0D0D];
        _totalPrice.font = [UIFont boldSystemFontOfSize:14];
    }
    return _totalPrice;
}

- (UILabel *)totalPriceLbl {
    if (!_totalPriceLbl) {
        _totalPriceLbl = [UILabel new];
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _totalPriceLbl.lineBreakMode = NSLineBreakByTruncatingHead;
        }
        _totalPriceLbl.textColor = [OSSVThemesColors col_0D0D0D];
        _totalPriceLbl.font = [UIFont boldSystemFontOfSize:14];
    }
    return _totalPriceLbl;
}

- (UILabel *)totalItemsLabel {
    if (!_totalItemsLabel) {
        _totalItemsLabel = [UILabel new];
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _totalItemsLabel.lineBreakMode = NSLineBreakByTruncatingHead;
        }
        _totalItemsLabel.textColor = [OSSVThemesColors col_666666];
        _totalItemsLabel.font = [UIFont systemFontOfSize:14];
    }
    return _totalItemsLabel;
}
- (UILabel *)taxLabel {
    if (!_taxLabel) {
        _taxLabel = [UILabel new];
        _taxLabel.textColor = [OSSVThemesColors col_B2B2B2];
        _taxLabel.font = [UIFont systemFontOfSize:10];
        _taxLabel.textAlignment = NSTextAlignmentRight;
    }
    return _taxLabel;
}


- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectZero];
        _bottomView.backgroundColor = [UIColor clearColor];
    }
    return _bottomView;
}

- (OSSVOrdereItemeButtonView *)cancleBtn {
    if (!_cancleBtn) {
        @weakify(self)
        _cancleBtn = [[OSSVOrdereItemeButtonView alloc] initWithFrame:CGRectZero title:APP_TYPE ? STLLocalizedString_(@"cancel",nil): [STLLocalizedString_(@"cancel",nil) uppercaseString] tapBlock:^{
            @strongify(self)
            [self cancelTouch:self.cancleBtn.button];
        }];
        _cancleBtn.button.sensor_element_id = @"cancel_order_button";
        _cancleBtn.hidden = YES;
    }
    return _cancleBtn;
}

- (OSSVOrdereItemeButtonView *)payBtn {
    if (!_payBtn) {
        @weakify(self)
        _payBtn = [[OSSVOrdereItemeButtonView alloc] initWithFrame:CGRectZero title:[STLLocalizedString_(@"payNow",nil) uppercaseString] tapBlock:^{
            @strongify(self)
            [self payNowTouch:self.payBtn.button];
        }];
        _payBtn.hidden = YES;
    }
    return _payBtn;
}

- (OSSVOrdereItemeButtonView *)tempPayBtn {
    if (!_tempPayBtn) {
        _tempPayBtn = [[OSSVOrdereItemeButtonView alloc] initWithFrame:CGRectZero title:[STLLocalizedString_(@"payNow",nil) uppercaseString] tapBlock:^{
        }];
        _tempPayBtn.hidden = YES;
    }
    return _tempPayBtn;
}

- (OSSVOrdereItemeButtonView *)buyAgainBtn {
    if (!_buyAgainBtn) {
        @weakify(self)
        _buyAgainBtn = [[OSSVOrdereItemeButtonView alloc] initWithFrame:CGRectZero title:[STLLocalizedString_(@"Repurchase",nil) uppercaseString] tapBlock:^{
            @strongify(self)
            [self buyAgainTouch:self.buyAgainBtn.button];
        }];
        _buyAgainBtn.button.sensor_element_id = @"repurchase_complete_button";
        _buyAgainBtn.hidden = YES;
    }
    return _buyAgainBtn;
}
//物流查询button
- (OSSVOrdereItemeButtonView *)shipmentBtn {
    if (!_shipmentBtn) {
        @weakify(self)
        
        _shipmentBtn = [[OSSVOrdereItemeButtonView alloc] initWithFrame:CGRectZero title:APP_TYPE == 3 ? STLLocalizedString_(@"SHIPMENT",nil) : [STLLocalizedString_(@"SHIPMENT",nil) uppercaseString] tapBlock:^{
            @strongify(self)
            [self shipmentTouch:self.shipmentBtn.button];
        }];
        _shipmentBtn.hidden = YES;
    }
    return _shipmentBtn;
}

//
- (OSSVOrdereItemeButtonView *)reviewBtn {
    if (!_reviewBtn) {
        @weakify(self)
        _reviewBtn = [[OSSVOrdereItemeButtonView alloc] initWithFrame:CGRectZero title:[STLLocalizedString_(@"reviews",nil) uppercaseString] tapBlock:^{
            @strongify(self)
            [self reviewTouch:self.reviewBtn.button];
        }];
        _reviewBtn.hidden = YES;
    }
    return _reviewBtn;
}


- (STLLableEdgeInsets *)codOrderStatueLabel {
    if (!_codOrderStatueLabel) {
        _codOrderStatueLabel = [[STLLableEdgeInsets alloc] init];
        _codOrderStatueLabel.edgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);
        _codOrderStatueLabel.hidden = YES;
        _codOrderStatueLabel.text = STLLocalizedString_(@"codOrderStatePrompt", @"COD订单提示语");
        _codOrderStatueLabel.font = [UIFont systemFontOfSize:14];
        _codOrderStatueLabel.textColor = OSSVThemesColors.col_FF9900;
        _codOrderStatueLabel.backgroundColor = OSSVThemesColors.col_FFFFFF;
        _codOrderStatueLabel.numberOfLines = 0;
    }
    return _codOrderStatueLabel;
}


-(UILabel *)countDownTipsLabel
{
    if (!_countDownTipsLabel) {
        _countDownTipsLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.text = STLLocalizedString_(@"Remaining_payment_time", nil);
            label.text = [NSString stringWithFormat:@"%@ :", label.text];
            label.textColor = [OSSVThemesColors col_6C6C6C];
            label.font = [UIFont systemFontOfSize:12];
            label.backgroundColor = [OSSVThemesColors stlClearColor];
            //v1.4.6显示位置刚好相反
            label.textAlignment = NSTextAlignmentRight;
            if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
                label.textAlignment = NSTextAlignmentLeft;
            }
            label;
        });
    }
    return _countDownTipsLabel;
}

-(ZJJTimeCountDownLabel *)countDownLabel
{
    if (!_countDownLabel) {
        _countDownLabel = ({
            ZJJTimeCountDownLabel *label = [[ZJJTimeCountDownLabel alloc] init];
            label.timeKey = @"expiresTime";
            label.font = [UIFont boldSystemFontOfSize:12];
            //设置文本自适应
            label.textAdjustsWidthToFitFont = YES;
            //边框模式
            label.textStyle = ZJJTextStlyeCustom;
            //字体颜色
            label.textColor = [OSSVThemesColors col_B62B21];
            label.textHeight = 18;
            //单个文本背景颜色
            label.textBackgroundColor = [UIColor redColor];
            //每个文本背景间隔
            label.textBackgroundInterval = 5;
            //设置文本距离背景左右边距
            label.textAdjustsWidthLeftRightSide = 2;
            //设置圆角
            label.textBackgroundRadius = 2;
            label.textIntervalSymbol = @":";
            label.textIntervalSymbolColor = [UIColor redColor];
            
            //v1.4.6显示位置刚好相反
            label.textAlignment = NSTextAlignmentRight;
            label.isRetainFinalValue = YES;
            if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
                label.textAlignment = NSTextAlignmentLeft;
            }
            label;
        });
    }
    return _countDownLabel;
}

-(BigClickAreaButton *)countDownDetailBtn
{
    if (!_countDownDetailBtn) {
        _countDownDetailBtn = ({
            BigClickAreaButton *button = [[BigClickAreaButton alloc] init];
            [button setImage:[UIImage imageNamed:@"icon_help_12"] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(countDownDetailBtnAction) forControlEvents:UIControlEventTouchUpInside];
            button.clickAreaRadious = 80;
            button;
        });
    }
    return _countDownDetailBtn;
}

- (UIImageView *)waitTipArrowImageView {
    if (!_waitTipArrowImageView) {
        _waitTipArrowImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _waitTipArrowImageView.hidden = YES;
        _waitTipArrowImageView.image = [UIImage imageNamed:@"order_tip_arrowUp"];
    }
    return _waitTipArrowImageView;
}

- (UIView *)waitCheckBgView {
    if (!_waitCheckBgView) {
        _waitCheckBgView = [[UIView alloc] initWithFrame:CGRectZero];
        _waitCheckBgView.backgroundColor = [OSSVThemesColors stlWhiteColor];
    }
    return _waitCheckBgView;
}

- (UIView *)waitCheckView {
    if (!_waitCheckView) {
        _waitCheckView = [[UIView alloc] initWithFrame:CGRectZero];
        _waitCheckView.backgroundColor = OSSVThemesColors.col_FFF3E4;
    }
    return _waitCheckView;
}

- (UILabel *)codCheckTipLabel {
    if (!_codCheckTipLabel) {
        _codCheckTipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _codCheckTipLabel.textColor = [OSSVThemesColors col_6C6C6C];
        _codCheckTipLabel.font = [UIFont systemFontOfSize:12];
        _codCheckTipLabel.numberOfLines = 2;
        _codCheckTipLabel.text = @"After the customer service check";
        
        //v1.4.6显示位置刚好相反
        _codCheckTipLabel.textAlignment = NSTextAlignmentRight;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _codCheckTipLabel.textAlignment = NSTextAlignmentLeft;
        }
    }
    return _codCheckTipLabel;
}

- (OSSVOrdereRepurchaseeTipeView *)repurchaseTipView {
    if (!_repurchaseTipView) {
        _repurchaseTipView = [[OSSVOrdereRepurchaseeTipeView alloc] initWithRect:CGRectZero title:@""];
        _repurchaseTipView.hidden = YES;
    }
    return _repurchaseTipView;
}
@end
