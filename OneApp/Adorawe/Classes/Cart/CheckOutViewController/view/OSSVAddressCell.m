//
//  OSSVAddressCell.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/9.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVAddressCell.h"
#import "Adorawe-Swift.h"

@interface OSSVAddressCell ()

@property (nonatomic, strong) UIView                *addressView;
@property (nonatomic, strong) UIView                *addressIconBgView;
@property (nonatomic, strong) YYAnimatedImageView   *addressIconImageView;
@property (nonatomic, strong) UILabel               *nameLabel;
@property (nonatomic,weak) UILabel *phoneLbl;
@property (nonatomic, strong) AddressShowLabel      *addressLabel;
@property (nonatomic, strong) UIImageView           *arrowImageView;

@property (nonatomic, strong) UIView                *noAddressView;
//@property (nonatomic, strong) UIImageView           *noAddressFreeImage;
@property (nonatomic, strong) UILabel               *selectAddressLabel;
@property (nonatomic, strong) UIButton              *selectAddressButton;
@end

@implementation OSSVAddressCell
@synthesize delegate = _delegate;
@synthesize model = _model;



-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        UIView *contentView = self.contentView;
//        contentView.backgroundColor = [UIColor orangeColor];
        [contentView addSubview:self.addressView];
        [contentView addSubview:self.noAddressView];
        
        [self.addressView addSubview:self.addressIconBgView];
        [self.addressIconBgView addSubview:self.addressIconImageView];
        [self.addressView addSubview:self.addressLabel];
        [self.addressView addSubview:self.nameLabel];
        [self.addressView addSubview:self.arrowImageView];
        
        [self.noAddressView addSubview:self.selectAddressLabel];
        [self.noAddressView addSubview:self.selectAddressButton];
        
        UILabel *shippingAddrLbl = [[UILabel alloc] init];
        [self.noAddressView addSubview:shippingAddrLbl];
        [shippingAddrLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            if (APP_TYPE == 3) {
                make.top.equalTo(9);
                make.height.equalTo(18);
            } else {
                make.top.equalTo(15.5);
            }
            make.leading.equalTo(14);
        }];
        shippingAddrLbl.text = [STLLocalizedString_(@"ShippingAddress", nil) uppercaseString];
        shippingAddrLbl.font = [UIFont boldSystemFontOfSize:14];
        shippingAddrLbl.textColor = OSSVThemesColors.col_0D0D0D;
        
        [self.addressView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(contentView);
        }];
        
        [self.noAddressView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(contentView);
        }];
        
        [self.addressIconBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(14);
            make.leading.mas_equalTo(14);
            make.width.mas_equalTo(20);
            make.height.mas_equalTo(20);
        }];
        
        [self.addressIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.mas_equalTo(self.addressView).mas_offset(topPadding);
//            make.leading.mas_equalTo(CheckOutCellLeftPadding);
            make.size.mas_equalTo(CGSizeMake(12, 12));
            make.centerY.mas_equalTo(self.addressIconBgView.mas_centerY);
            make.centerX.mas_equalTo(self.addressIconBgView.mas_centerX);
        }];
        
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.addressIconBgView.mas_trailing).mas_offset(4);
            make.trailing.mas_equalTo(self.arrowImageView.mas_leading).mas_offset(-CheckOutCellLeftPadding);
            make.centerY.equalTo(self.addressIconBgView.mas_centerY);
//            make.centerY.mas_equalTo(self.addressIconImageView);
        }];
        
        UILabel *phoneLbl = [[UILabel alloc] init];
        phoneLbl.font = [UIFont systemFontOfSize:14];
        phoneLbl.textColor = OSSVThemesColors.col_6C6C6C;
        [self.addressView addSubview:phoneLbl];
        self.phoneLbl = phoneLbl;
        [phoneLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.addressIconBgView.mas_leading);
            make.top.equalTo(self.nameLabel.mas_bottom).offset(5);
        }];
        
        [self.addressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(phoneLbl.mas_bottom).mas_offset(4);
            make.trailing.mas_equalTo(self.arrowImageView.mas_leading);
            make.leading.mas_equalTo(phoneLbl.mas_leading);
            make.bottom.mas_equalTo(self.addressView.mas_bottom).mas_offset(-12);
        }];
        
        ///使用自动布局的时候，如果Label的行数超过一行，就一定要设置这个值
        self.addressLabel.preferredMaxLayoutWidth = SCREEN_WIDTH - CheckOutCellLeftPadding*2 - 24 - 10 - 24;
        
        [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.addressView).mas_offset(-CheckOutCellLeftPadding);
            make.centerY.mas_equalTo(self.addressView);
            make.width.height.mas_offset(12);
        }];
        
        [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self).priorityHigh();
        }];
        
        [self.selectAddressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(shippingAddrLbl.mas_leading);
            if (APP_TYPE == 3) {
                make.top.mas_equalTo(shippingAddrLbl.mas_bottom).offset(9);
                make.height.equalTo(15);
            } else {
                make.top.mas_equalTo(shippingAddrLbl.mas_bottom).mas_offset(16.5);
                make.centerY.equalTo(self.selectAddressButton.mas_centerY);
            }
        }];

                
        [self.selectAddressButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(28);
            make.bottom.mas_equalTo(self.noAddressView.mas_bottom).mas_offset(-14);
            if (APP_TYPE == 3) {
                make.top.mas_equalTo(self.selectAddressLabel.mas_bottom).offset(8);
                make.leading.equalTo(14);
            } else {
                make.trailing.equalTo(-14);
            }
        }];
        
        
        [self addBottomLine:CellSeparatorStyle_LeftRightInset];
        
        [self addContentViewTap:@selector(didClickCell)];
    }
    return self;
}

-(void)didClickCell
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(STL_DidClickAddressCell:)]) {
        [self.delegate STL_DidClickAddressCell:self.model];
    }
}

#pragma mark - setter and getter

-(void)setModel:(OSSVCheckOutAdressCellModel *)model
{
    _model = model;
    
    BOOL hasAddress = ![OSSVNSStringTool isEmptyString:model.addressModel.addressId];
    self.addressView.hidden = hasAddress ? NO : YES;
    self.noAddressView.hidden = hasAddress ? YES : NO;
    
    if (hasAddress) {
        self.nameLabel.text = STLToString(model.personInfo);
        
        if (![OSSVNSStringTool isEmptyString:model.addressModel.countryCode]) {
            self.phoneLbl.text = [NSString stringWithFormat:@"+%@  %@%@",STLToString(model.addressModel.countryCode), STLToString(model.addressModel.phoneHead), STLToString(model.addressModel.phone)];
        } else {
            self.phoneLbl.text = [NSString stringWithFormat:@"%@%@", STLToString(model.addressModel.phoneHead),STLToString(model.addressModel.phone)];
        }
        self.addressLabel.text = STLToString(model.addressInfo);
        
        
        [self.noAddressView mas_remakeConstraints:^(MASConstraintMaker *make) {
        }];
        [self.addressView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.contentView);
        }];
    } else {
        
        [self.noAddressView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.contentView);
        }];
        [self.addressView mas_makeConstraints:^(MASConstraintMaker *make) {
        }];
    }
    NSString *addressType = STLToString(model.addressModel.addressType);
    switch (addressType.intValue) {
        case 1:
            self.addressIconImageView.image = [UIImage imageNamed:@"home_button_white"];
            break;
        case 2:
            self.addressIconImageView.image = [UIImage imageNamed:@"school_button_white"];
            break;
        case 3:
            self.addressIconImageView.image = [UIImage imageNamed:@"company_button_white"];
            break;

        default:
            self.addressIconImageView.image = [UIImage imageNamed:@"address_white"];
            break;
    }

}

- (UIView *)addressView {
    if (!_addressView) {
        _addressView = [[UIView alloc] initWithFrame:CGRectZero];
        _addressView.hidden = YES;
    }
    return _addressView;
}

- (UIView *)noAddressView {
    if (!_noAddressView) {
        _noAddressView = [[UIView alloc] initWithFrame:CGRectZero];
        _noAddressView.hidden = YES;
    }
    return _noAddressView;
}

- (UIView *)addressIconBgView {
    if (!_addressIconBgView) {
        _addressIconBgView = [UIView new];
        _addressIconBgView.backgroundColor = OSSVThemesColors.col_0D0D0D;
        _addressIconBgView.layer.cornerRadius = 10.f;
        _addressIconBgView.layer.masksToBounds = YES;
    }
    return _addressIconBgView;
}
- (YYAnimatedImageView *)addressIconImageView {
    if (!_addressIconImageView) {
        _addressIconImageView = [[YYAnimatedImageView alloc] init];
        _addressIconImageView.contentMode = UIViewContentModeCenter;
        _addressIconImageView.image = [UIImage imageNamed:@"address_white"];
    }
    return _addressIconImageView;
}

-(AddressShowLabel *)addressLabel
{
    if (!_addressLabel) {
        _addressLabel = ({
            AddressShowLabel *label = [[AddressShowLabel alloc] init];
            label.text = STLLocalizedString_(@"Test", nil);
            label.textColor = OSSVThemesColors.col_6C6C6C;
            label.font = [UIFont systemFontOfSize:14];
            label.numberOfLines = 0;
            label;
        });
        [_addressLabel convertTextAlignmentWithARLanguage];
    }
    return _addressLabel;
}

-(UILabel *)nameLabel
{
    if (!_nameLabel) {
        _nameLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.text = STLLocalizedString_(@"Test", nil);
            label.textColor = OSSVThemesColors.col_0D0D0D;
            label.font = [UIFont boldSystemFontOfSize:14];
            label;
        });
        [_nameLabel convertTextAlignmentWithARLanguage];
    }
    return _nameLabel;
}

-(UIImageView *)arrowImageView
{
    if (!_arrowImageView) {
        _arrowImageView = ({
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.image = [UIImage imageNamed:@"address_arr_right"];
            if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
                imageView.transform = CGAffineTransformMakeRotation(M_PI);
            }
            imageView;
        });
    }
    return _arrowImageView;
}

- (UILabel *)selectAddressLabel {
    if (!_selectAddressLabel) {
        _selectAddressLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _selectAddressLabel.text = STLLocalizedString_(@"Please_fill_Shipping_address", nil);
        _selectAddressLabel.textAlignment = NSTextAlignmentCenter;
        _selectAddressLabel.textColor = OSSVThemesColors.col_6C6C6C;
        _selectAddressLabel.font = [UIFont systemFontOfSize:12];
    }
    return _selectAddressLabel;
}

- (UIButton *)selectAddressButton {
    if (!_selectAddressButton) {
        _selectAddressButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _selectAddressButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
        [_selectAddressButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _selectAddressButton.backgroundColor = [OSSVThemesColors col_262626];
        
        _selectAddressButton.enabled = NO;
        [_selectAddressButton setContentEdgeInsets:UIEdgeInsetsMake(8, 12, 8, 12)];
        if (APP_TYPE == 3) {
            [_selectAddressButton setTitle:STLLocalizedString_(@"addressAddAdress", nil) forState:UIControlStateNormal];
        } else {
            [_selectAddressButton setTitle:[STLLocalizedString_(@"addressAddAdress", nil) uppercaseString] forState:UIControlStateNormal];
        }
    }
    return _selectAddressButton;
}

@end
