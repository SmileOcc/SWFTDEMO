//
//  ZFOrderDetailOrderInfoTableViewCell.m
//  ZZZZZ
//
//  Created by YW on 2018/3/7.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFOrderDetailOrderInfoTableViewCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "ZFProgressHUD.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "Masonry.h"

@interface ZFOrderDetailOrderInfoTableViewCell() <ZFInitViewProtocol>
@property (nonatomic, strong) UILabel           *payStatusLabel;
@property (nonatomic, strong) UILabel           *orderNumLabel;
@property (nonatomic, strong) UIButton          *copyCodeButton;
@property (nonatomic, strong) UILabel           *trackingInfoLabel;
@property (nonatomic, strong) UIButton          *tipsButton;
@end

@implementation ZFOrderDetailOrderInfoTableViewCell
#pragma mark - init methods
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.orderSortNum = @"";
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - action methods
- (void)copyCodeButtonAction:(UIButton *)sender {
    [UIPasteboard generalPasteboard].string = ZFToString(_childModel.order_info.order_sn);
    ShowToastToViewWithText(nil, ZFLocalizedString(@"OrderDetail_Copy_Success", nil));
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.contentView.backgroundColor = ZFCOLOR_WHITE;
    [self.contentView addSubview:self.payStatusLabel];
    [self.contentView addSubview:self.orderNumLabel];
    [self.contentView addSubview:self.copyCodeButton];
    [self.contentView addSubview:self.trackingInfoLabel];
    [self.contentView addSubview:self.tipsButton];
}

- (void)zfAutoLayoutView {
    [self.payStatusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top).offset(15);
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(15);
    }];
    
    [self.orderNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.payStatusLabel.mas_bottom).mas_offset(6);
        make.leading.mas_equalTo(self.payStatusLabel.mas_leading);
        make.trailing.mas_equalTo(self.copyCodeButton.mas_leading).offset(-10);
    }];
    
    [self.copyCodeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-15);
    }];
    
    [self.trackingInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.orderNumLabel.mas_bottom).mas_offset(6);
        make.leading.mas_equalTo(self.orderNumLabel.mas_leading);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).mas_offset(-15);
    }];
    
    UIView *line = [UIView new];
    line.backgroundColor = ZFCOLOR(221, 221, 221, 1);
    [self.contentView addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_offset(1);
        make.bottom.mas_equalTo(self.contentView.mas_bottom);
        make.leading.mas_equalTo(self.payStatusLabel.mas_leading);
        make.trailing.mas_equalTo(self.contentView.mas_trailing);
    }];
    
    [self.tipsButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.payStatusLabel);
        make.leading.mas_equalTo(self.payStatusLabel.mas_trailing).mas_offset(5);
        make.size.mas_offset(CGSizeMake(18, 18));
    }];
}

- (void)tipsButtonClick
{
    ShowToastToViewWithText(nil, self.mainOrder.cancel_reason);
}

- (void)setOrderSortNum:(NSString *)orderSortNum {
    _orderSortNum = orderSortNum;
}

#pragma mark - setter
- (void)setChildModel:(ZFOrderDetailChildModel *)childModel {
    _childModel = childModel;
    self.payStatusLabel.text = ZFToString(_childModel.order_info.order_status_str);
    self.orderNumLabel.text = [NSString stringWithFormat:@"%@ %@: %@", ZFLocalizedString(@"OrderDetail_Order_Cell_Order",nil), ZFToString(self.orderSortNum), ZFToString(_childModel.order_info.order_sn)];
    self.trackingInfoLabel.text = ZFToString(_childModel.order_info.warehouse_msg);
}

- (void)setMainOrder:(OrderDetailOrderModel *)mainOrder
{
    _mainOrder = mainOrder;
    self.tipsButton.hidden = !mainOrder.is_system_cancel;
}

#pragma mark - getter

-(UILabel *)payStatusLabel{
    if (!_payStatusLabel) {
        _payStatusLabel = [[UILabel alloc] init];
        _payStatusLabel.textColor = ZFC0x2D2D2D();
        _payStatusLabel.font = [UIFont boldSystemFontOfSize:14.0];
    }
    return _payStatusLabel;
}

- (UILabel *)orderNumLabel {
    if (!_orderNumLabel) {
        _orderNumLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _orderNumLabel.textColor = ZFC0x2D2D2D();
        _orderNumLabel.font = [UIFont systemFontOfSize:14.0];
    }
    return _orderNumLabel;
}

- (UIButton *)copyCodeButton {
    if (!_copyCodeButton) {
        _copyCodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_copyCodeButton setImage:ZFImageWithName(@"orderCopy") forState:UIControlStateNormal];
        [_copyCodeButton addTarget:self action:@selector(copyCodeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _copyCodeButton;
}

-(UILabel *)trackingInfoLabel
{
    if (!_trackingInfoLabel) {
        _trackingInfoLabel = [[UILabel alloc] init];
        _trackingInfoLabel.textColor = ZFC0x999999();
        _trackingInfoLabel.font = [UIFont systemFontOfSize:14.0];
    }
    return _trackingInfoLabel;
}

- (UIButton *)tipsButton {
    if (!_tipsButton) {
        _tipsButton = ({
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setImage:[UIImage imageNamed:@"nationalID"] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(tipsButtonClick) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
    }
    return _tipsButton;
}

@end
