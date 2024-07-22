//
//  ZFOrderDetailPaymentStatusTableViewCell.m
//  ZZZZZ
//
//  Created by YW on 2018/3/7.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFOrderDetailPaymentStatusTableViewCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "Masonry.h"

@interface ZFOrderDetailPaymentStatusTableViewCell() <ZFInitViewProtocol>

@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *dateContentLabel;
@property (nonatomic, strong) UILabel *deliveryLabel;
@property (nonatomic, strong) UILabel *deliveryContentLabel;
@property (nonatomic, strong) UILabel *paymentLabel;
@property (nonatomic, strong) UILabel *paymentContentLabel;
@property (nonatomic, strong) UIButton *trackingInfoButton;

@end

@implementation ZFOrderDetailPaymentStatusTableViewCell
#pragma mark - init methods
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.contentView.backgroundColor = ZFCOLOR_WHITE;
    [self.contentView addSubview:self.dateLabel];
    [self.contentView addSubview:self.dateContentLabel];
    [self.contentView addSubview:self.deliveryLabel];
    [self.contentView addSubview:self.deliveryContentLabel];
    [self.contentView addSubview:self.paymentLabel];
    [self.contentView addSubview:self.paymentContentLabel];
    [self.contentView addSubview:self.trackingInfoButton];
}

- (void)zfAutoLayoutView {
    CGFloat upPadding = 9;
    [self.deliveryLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top).offset(15);
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(15);
    }];
    
    [self.deliveryContentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.deliveryLabel.mas_centerY);
        make.leading.mas_equalTo(self.deliveryLabel.mas_trailing).offset(2);
        make.trailing.mas_lessThanOrEqualTo(self.trackingInfoButton.mas_leading);
    }];
    
    [self.paymentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.deliveryLabel.mas_bottom).offset(upPadding);
        make.leading.mas_equalTo(self.deliveryLabel.mas_leading);
    }];
    
    [self.paymentContentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.paymentLabel.mas_centerY);
        make.leading.mas_equalTo(self.paymentLabel.mas_trailing).offset(2);
    }];

    [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.paymentLabel.mas_bottom).offset(upPadding);
        make.leading.mas_equalTo(self.deliveryLabel.mas_leading);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-15);
    }];
    
    [self.dateContentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.dateLabel.mas_centerY);
        make.leading.mas_equalTo(self.dateLabel.mas_trailing).offset(2);
    }];
    
    [self.trackingInfoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.deliveryLabel);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).mas_offset(-15);
        make.height.mas_offset(25);
    }];
    
    [self.deliveryLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [self.deliveryContentLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [self.trackingInfoButton setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
}

#pragma mark - setter
- (void)setModel:(OrderDetailOrderModel *)model {
    _model = model;
    
    self.dateContentLabel.text = _model.add_time;
    self.deliveryContentLabel.text = _model.shipping_name;
    self.paymentContentLabel.text = _model.pay_name;
    if (_model.pay_name && _model.pay_name.length) {
        [self.paymentLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.deliveryLabel.mas_bottom).offset(5);
            make.leading.mas_equalTo(self.deliveryLabel.mas_leading);
        }];
        self.paymentContentLabel.hidden = NO;
    }else{
        [self.paymentLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.deliveryLabel.mas_bottom).offset(5);
            make.leading.mas_equalTo(self.deliveryLabel.mas_leading);
            make.height.mas_offset(0.1);
        }];
        self.paymentContentLabel.hidden = YES;
    }
    
    self.trackingInfoButton.hidden = YES;
    NSString *payMethod = _model.pay_id;
    NSInteger orderStatus = [_model.order_status integerValue];
    if ([payMethod isEqualToString:@"Cod"]) {
        if (orderStatus != 13) {
            self.trackingInfoButton.hidden = NO;
        }
    } else {
        if (orderStatus == 1 || orderStatus == 2 || orderStatus == 3 || orderStatus == 4 ||
            orderStatus == 15 || orderStatus == 16 || orderStatus == 20) {
            /** 显示【Tracking info】按钮的情况
             *  1:已付款Paid, 2:备货Processing, 3:完全发货Shipped, 4:已收到货Delivered
             *  15:部分配货PartialOrderDispatched 16:完全配货Dispatched,20:部分发货PartialOrderShipped
             */
            self.trackingInfoButton.hidden = NO;
        }
    }
}

- (void)trackingInfoButtonAction:(UIButton *)sender
{
    if (self.orderDetailOrderTrakingInfoCompletionHandler) {
        self.orderDetailOrderTrakingInfoCompletionHandler();
    }
}

#pragma mark - getter
-(UILabel *)dateLabel{
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc] init];
        _dateLabel.text = [NSString stringWithFormat:@"%@:",ZFLocalizedString(@"OrderDetail_Delivery_Cell_Date",nil)];
        _dateLabel.textColor = ZFC0x999999();
        _dateLabel.font = [UIFont systemFontOfSize:14.0];
    }
    return _dateLabel;
}

-(UILabel *)dateContentLabel{
    if (!_dateContentLabel) {
        _dateContentLabel = [[UILabel alloc] init];
        _dateContentLabel.textColor = ZFCOLOR(45, 45, 45, 1.0);
        _dateContentLabel.font = [UIFont systemFontOfSize:14.0];
    }
    return _dateContentLabel;
}

-(UILabel *)deliveryLabel{
    if (!_deliveryLabel) {
        _deliveryLabel = [[UILabel alloc] init];
        _deliveryLabel.text = [NSString stringWithFormat:@"%@:",ZFLocalizedString(@"OrderDetail_Delivery_Cell_Delivery",nil)];
        _deliveryLabel.textColor = ZFC0x999999();
        _deliveryLabel.font = [UIFont systemFontOfSize:14.0];
    }
    return _deliveryLabel;
}

-(UILabel *)deliveryContentLabel{
    if (!_deliveryContentLabel) {
        _deliveryContentLabel = [[UILabel alloc] init];
        _deliveryContentLabel.textColor = ZFCOLOR(45, 45, 45, 1.0);
        _deliveryContentLabel.font = [UIFont systemFontOfSize:14.0];
    }
    return _deliveryContentLabel;
}

-(UILabel *)paymentLabel{
    if (!_paymentLabel) {
        _paymentLabel = [[UILabel alloc] init];
        _paymentLabel.text = [NSString stringWithFormat:@"%@:",ZFLocalizedString(@"OrderDetail_Delivery_Cell_Payment",nil)];
        _paymentLabel.textColor = ZFCOLOR(136, 136, 136, 1.0);
        _paymentLabel.font = [UIFont systemFontOfSize:14.0];
    }
    return _paymentLabel;
}

-(UILabel *)paymentContentLabel{
    if (!_paymentContentLabel) {
        _paymentContentLabel = [[UILabel alloc] init];
        _paymentContentLabel.textColor = ZFCOLOR(45, 45, 45, 1.0);
        _paymentContentLabel.font = [UIFont systemFontOfSize:14.0];
    }
    return _paymentContentLabel;
}

-(UIButton *)trackingInfoButton
{
    if (!_trackingInfoButton) {
        _trackingInfoButton = ({
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setTitle:ZFLocalizedString(@"ZFTracking_information_title", nil) forState:UIControlStateNormal];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            button.layer.borderWidth = .8f;
            button.layer.borderColor = [UIColor blackColor].CGColor;
            button.layer.cornerRadius = 2;
            button.layer.masksToBounds = YES;
            button.titleLabel.font = [UIFont systemFontOfSize:14];
            button.contentEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 8);
            [button addTarget:self action:@selector(trackingInfoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
    }
    return _trackingInfoButton;
}

@end
