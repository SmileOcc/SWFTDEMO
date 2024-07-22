//
//  ZFOrderDetailAddressTableViewCell.m
//  ZZZZZ
//
//  Created by YW on 2018/3/7.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFOrderDetailAddressTableViewCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "NSStringUtils.h"
#import "Masonry.h"
#import "YWCFunctionTool.h"
#import "ZFLocalizationString.h"

@interface ZFOrderDetailAddressTableViewCell() <ZFInitViewProtocol>

@property (nonatomic, strong) UILabel                   *nameLabel;
@property (nonatomic, strong) UILabel                   *telNumLabel;
@property (nonatomic, strong) UILabel                   *addressLabel;

///确认地址视图
@property (nonatomic, strong) UIView                    *confirmView;
@property (nonatomic, strong) UILabel                   *confirmTipsLabel;
@property (nonatomic, strong) UIButton                  *confirmButton;

///修改地址按钮
@property (nonatomic, strong) UIButton                  *changeAddressButton;

@end

@implementation ZFOrderDetailAddressTableViewCell
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
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.telNumLabel];
    [self.contentView addSubview:self.addressLabel];
    [self.contentView addSubview:self.changeAddressButton];
    
    [self.contentView addSubview:self.confirmView];
    [self.confirmView addSubview:self.confirmTipsLabel];
    [self.confirmView addSubview:self.confirmButton];
}

- (void)zfAutoLayoutView {
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(15);
        make.top.mas_equalTo(self.contentView.mas_top).mas_offset(15);
    }];
    
    [self.telNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(6);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
        make.leading.mas_equalTo(self.nameLabel.mas_leading);
    }];
    
    [self.addressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.nameLabel.mas_leading);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-20);
        make.top.mas_equalTo(self.telNumLabel.mas_bottom).offset(6);
    }];
    
    [self.changeAddressButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.nameLabel.mas_top).mas_offset(5);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).mas_offset(-15);
        make.leading.mas_equalTo(self.nameLabel.mas_trailing).mas_offset(10);
        make.size.mas_offset(CGSizeMake(24, 24));
    }];
    
    [self.nameLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    
    [self.confirmView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.addressLabel.mas_bottom).mas_offset(12);
        make.leading.trailing.mas_equalTo(self.addressLabel);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-12);
    }];
    
    [self.confirmTipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.confirmView).mas_offset(8);
        make.leading.mas_equalTo(self.confirmView.mas_leading).mas_offset(12);
        make.trailing.mas_equalTo(self.confirmView.mas_trailing).mas_offset(-12);
    }];
    
    [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.confirmTipsLabel.mas_bottom).mas_offset(8);
        make.centerX.mas_equalTo(self.confirmView);
        make.bottom.mas_equalTo(self.confirmView.mas_bottom).mas_offset(-8);
    }];
}

#pragma mark - setter
- (void)setModel:(OrderDetailOrderModel *)model {
    _model = model;
    self.nameLabel.text = [NSString stringWithFormat:@"%@", _model.consignee];
    self.telNumLabel.text = [NSString stringWithFormat:@"%@", _model.tel];
    if([NSStringUtils isEmptyString: _model.code]) {
        self.telNumLabel.text = [NSString stringWithFormat:@"%@", _model.tel];
    } else {
        self.telNumLabel.text = [NSString stringWithFormat:@"+%@ %@", [NSStringUtils isEmptyString:_model.code withReplaceString:@""],_model.tel];
    }

    if (ZFIsEmptyString(_model.barangay)) {
        self.addressLabel.text = [NSString stringWithFormat:@"%@ %@ %@ %@ %@", _model.address, _model.city, _model.province, _model.country, _model.zipcode];
    } else {
        self.addressLabel.text = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@", _model.address, _model.barangay, _model.city, _model.province, _model.country, _model.zipcode];
    }
    
    if (model.confirm_btn_show) {
        self.confirmView.hidden = NO;
        [self.confirmView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-12);
        }];
    } else {
        self.confirmView.hidden = YES;
        [self.addressLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-12);
        }];
    }
    
    if (model.change_address_show) {
        self.changeAddressButton.hidden = NO;
    } else {
        self.changeAddressButton.hidden = YES;
    }
}

- (void)confirmButtonClick
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(ZFOrderDetailAddressTableViewCellDidClickConfirmButton:)]) {
        [self.delegate ZFOrderDetailAddressTableViewCellDidClickConfirmButton:self.model];
    }
}

- (void)changeAddressButtonClick
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(ZFOrderDetailAddressTableViewCellDidClickChangeAddressButton:)]) {
        [self.delegate ZFOrderDetailAddressTableViewCellDidClickChangeAddressButton:self.model];
    }
}

#pragma mark - getter

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.font = [UIFont boldSystemFontOfSize:14.0];
        _nameLabel.numberOfLines = 2;
        _nameLabel.textColor = ZFC0x2D2D2D();
    }
    return _nameLabel;
}

- (UILabel *)telNumLabel {
    if (!_telNumLabel) {
        _telNumLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _telNumLabel.textColor = ZFC0x2D2D2D();
        _telNumLabel.font = [UIFont systemFontOfSize:14.0];
    }
    return _telNumLabel;
}

- (UILabel *)addressLabel {
    if (!_addressLabel) {
        _addressLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _addressLabel.numberOfLines = 0;
        _addressLabel.textColor = ZFCOLOR(153, 153, 153, 1);
        _addressLabel.font = [UIFont systemFontOfSize:14];
    }
    return _addressLabel;
}

- (UIView *)confirmView
{
    if (!_confirmView) {
        _confirmView = ({
            UIView *view = [[UIView alloc] init];
            view.backgroundColor = ColorHex_Alpha(0xFEF0F2, 1.0);
            view;
        });
    }
    return _confirmView;
}

-(UILabel *)confirmTipsLabel
{
    if (!_confirmTipsLabel) {
        _confirmTipsLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.numberOfLines = 0;
            label.text = ZFLocalizedString(@"Order_detail_address_confirm_tip", nil);
            label.textColor = ZFC0xFE5269();
            label.font = [UIFont systemFontOfSize:12];
            label;
        });
    }
    return _confirmTipsLabel;
}

- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = ({
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.titleLabel.font = [UIFont systemFontOfSize:14];
            button.layer.borderColor = ZFCOLOR(254, 82, 105, 1).CGColor;
            button.layer.borderWidth = 1;
            button.contentEdgeInsets = UIEdgeInsetsMake(5, 25, 5, 25);
            [button setTitleColor:ZFCOLOR(254, 82, 105, 1) forState:UIControlStateNormal];
            [button setTitle:ZFLocalizedString(@"community_outfit_leave_confirm", nil) forState:UIControlStateNormal];
            [button addTarget:self action:@selector(confirmButtonClick) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
    }
    return _confirmButton;
}

- (UIButton *)changeAddressButton {
    if (!_changeAddressButton) {
        _changeAddressButton = ({
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setImage:[UIImage imageNamed:@"change_normal_black"] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(changeAddressButtonClick) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
    }
    return _changeAddressButton;
}

@end
