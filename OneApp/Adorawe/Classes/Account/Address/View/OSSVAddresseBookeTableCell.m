//
//  OSSVAddresseBookeTableCell.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/2.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVAddresseBookeTableCell.h"
#import "OSSVAddresseBookeModel.h"
#import "Adorawe-Swift.h"


@interface OSSVAddresseBookeTableCell ()

@end


@implementation OSSVAddresseBookeTableCell

+ (OSSVAddresseBookeTableCell *)addressBookCellWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath {
    [tableView registerClass:[OSSVAddresseBookeTableCell class] forCellReuseIdentifier:@"OSSVAddresseBookeTableCell"];
    return [tableView dequeueReusableCellWithIdentifier:@"OSSVAddresseBookeTableCell" forIndexPath:indexPath];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {

        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.addressBgView];
        self.contentView.backgroundColor = OSSVThemesColors.col_F1F1F1;
        [self.addressBgView addSubview:self.addressIconBgView];
        [self.addressBgView addSubview:self.nameLabel];
        [self.addressBgView addSubview:self.phoneLabel];
        [self.addressBgView addSubview:self.addressLabel];
        [self.addressBgView addSubview:self.editButton];
        [self.addressBgView addSubview:self.deleteButton];
        
        [self.addressIconBgView addSubview:self.addressIconImageView];
        
        UIImageView *cornerSlect = [[UIImageView alloc] init];
        [self.addressBgView addSubview:cornerSlect];
        self.selectCornerImg = cornerSlect;
        cornerSlect.highlightedImage = [UIImage imageNamed:@"select_corner"];
        [cornerSlect mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(24);
            make.top.trailing.equalTo(0);
        }];
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]){
            cornerSlect.highlightedImage = [UIImage imageNamed:@"select_corner1"];
        }
        
        [self.phoneLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];

        [self.addressBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.contentView.mas_leading).offset(12);
            make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
            make.top.mas_equalTo(self.contentView.mas_top).offset(8);
            make.bottom.mas_equalTo(self.contentView.mas_bottom);
        }];
        
        [self.addressIconBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.addressBgView.mas_top).offset(14);
            make.leading.mas_equalTo(self.addressBgView.mas_leading).offset(14);
            make.size.mas_equalTo(CGSizeMake(20, 20));
        }];

        
        [self.addressIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(12, 12));
            make.centerY.mas_equalTo(self.addressIconBgView.mas_centerY);
            make.centerX.mas_equalTo(self.addressIconBgView.mas_centerX);
        }];
        
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make){
            make.leading.equalTo(self.addressIconBgView.mas_trailing).offset(4);
            make.height.mas_equalTo(@20);
            make.centerY.mas_equalTo(self.addressIconBgView.mas_centerY);
        }];
        
        [self.phoneLabel mas_makeConstraints:^(MASConstraintMaker *make){
            make.top.mas_equalTo(self.addressIconBgView.mas_bottom).offset(4);
            make.leading.mas_equalTo(self.addressIconBgView.mas_leading);
            make.height.mas_equalTo(@20);
        }];
        
        [self.addressLabel mas_makeConstraints:^(MASConstraintMaker *make){
            make.top.equalTo(self.phoneLabel.mas_bottom).offset(4);
            make.leading.equalTo(self.addressIconBgView.mas_leading);
            make.trailing.mas_equalTo(self.addressBgView.mas_trailing).offset(-14);
            make.bottom.mas_equalTo(self.addressBgView.mas_bottom).offset(-14);
        }];
        
        
        [self.editButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(36);
            make.centerY.mas_equalTo(self.addressIconBgView.mas_centerY);
            //按钮36 图片18 空白20
            make.trailing.mas_equalTo(self.addressBgView.mas_trailing).offset(-11);
        }];
        
        [self.editButton.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(18);
            make.centerY.equalTo(self.editButton.mas_centerY);
            make.centerX.equalTo(self.editButton.mas_centerX);
        }];
        
        
        [self.deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(36);
            make.centerY.mas_equalTo(self.addressIconBgView.mas_centerY);
            make.trailing.equalTo(self.editButton.mas_leading);
        }];
        
        [self.deleteButton.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(18);
            make.centerY.equalTo(self.deleteButton.mas_centerY);
            make.centerX.equalTo(self.deleteButton.mas_centerX);
        }];
        
        UILabel *defalutLbl = [[UILabel alloc] init];
        defalutLbl.text = STLLocalizedString_(@"Default_Address", nil);
        self.isDefaultLbl = defalutLbl;
        [self.addressBgView addSubview:defalutLbl];
        defalutLbl.textColor = UIColor.whiteColor;
        defalutLbl.font = [UIFont boldSystemFontOfSize:10];
        CGSize defSize = [defalutLbl sizeThatFits:CGSizeMake(MAXFLOAT, 16)];
        defalutLbl.backgroundColor = OSSVThemesColors.col_0D0D0D;
        defalutLbl.textAlignment = NSTextAlignmentCenter;
        [defalutLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.lessThanOrEqualTo(self.addressBgView.mas_trailing).offset(-96);
            make.leading.equalTo(self.nameLabel.mas_trailing).offset(8);
            make.height.equalTo(16);
            make.centerY.mas_equalTo(self.addressIconBgView.mas_centerY);
            make.width.equalTo(defSize.width + 8);
        }];
        
    }
    return self;
}

- (void)handleAddressBookModel:(OSSVAddresseBookeModel *)addresseBookeModel editState:(BOOL)isEdit isMark:(BOOL)isMark isFromOrder:(BOOL)isOrder {
    self.isEdit = isEdit;
    self.isMark = isMark;
    self.isOrder = isOrder;
    self.addressBookModel = addresseBookeModel;
    self.addressBgView.layer.borderColor = self.isMark ? OSSVThemesColors.col_0D0D0D.CGColor : UIColor.clearColor.CGColor;
}

- (void)setAddressBookModel:(OSSVAddresseBookeModel *)addresseBookeModel {
    
    _addressBookModel = addresseBookeModel;
    
    self.nameLabel.text = [NSString stringWithFormat:@"%@ %@",addresseBookeModel.firstName,addresseBookeModel.lastName];
    ///电话号码拆分为 head 和 phone
    if (![OSSVNSStringTool isEmptyString:addresseBookeModel.countryCode]) {
        self.phoneLabel.text = [NSString stringWithFormat:@"+%@  %@%@",STLToString(addresseBookeModel.countryCode), STLToString(addresseBookeModel.phoneHead), STLToString(addresseBookeModel.phone)];
    } else {
        self.phoneLabel.text = [NSString stringWithFormat:@"%@%@", STLToString(addresseBookeModel.phoneHead),STLToString(addresseBookeModel.phone)];
    }
    self.addressLabel.text = [NSString addressStringWithAddres:addresseBookeModel];
    
    //地址类型图标赋值
    NSString *addressType = STLToString(addresseBookeModel.addressType);
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
    
    self.isDefaultLbl.hidden = !addresseBookeModel.isDefault;
    self.selectCornerImg.highlighted = self.isMark;
    
    self.deleteButton.hidden = self.isMark;
    
    
    [self.isDefaultLbl mas_updateConstraints:^(MASConstraintMaker *make) {
        make.trailing.lessThanOrEqualTo(self.addressBgView.mas_trailing).offset(self.isMark ? -48 : -96);
    }];
    
}

- (void)setIsSelectedAddress:(BOOL)isSelectedAddress {

   
}

// 其实这里应该不会调用，最多是5个的数据下
- (void)prepareForReuse {
    [super prepareForReuse];
    self.nameLabel.text = nil;
    self.phoneLabel.text = nil;
    self.addressLabel.text = nil;
    
    self.isDefaultLbl.hidden = true;
    self.selectCornerImg.highlighted = false;
}

#pragma mark - Action

- (void)defaultAction:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(yyAddressBookTableCell:addressEvent:)]) {
        [self.delegate yyAddressBookTableCell:self addressEvent:AddressBookEventDefault];
        NSString *statue = self.addressBookModel.isDefault ? @"On" : @"Off";
        [GATools logAddressBookEventWithAction:[NSString stringWithFormat:@"Defualt Address_%@",statue]];
    }
}
- (void)editAction:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(yyAddressBookTableCell:addressEvent:)]) {
        [self.delegate yyAddressBookTableCell:self addressEvent:AddressBookEventEdit];
        [GATools logAddressBookEventWithAction:@"Edit Address"];
    }
}

- (void)deleteAction:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(yyAddressBookTableCell:addressEvent:)]) {
        [self.delegate yyAddressBookTableCell:self addressEvent:AddressBookEventDelete];
        [GATools logAddressBookEventWithAction:@"Remove Address"];
    }
}

#pragma mark - LazyLoad
-(UIView *)addressBgView {
    if (!_addressBgView) {
        _addressBgView = [UIView new];
        _addressBgView.backgroundColor = [UIColor whiteColor];
        _addressBgView.layer.cornerRadius = 6.f;
        _addressBgView.layer.masksToBounds = YES;
        _addressBgView.layer.borderWidth = 1;
        _addressBgView.layer.borderColor = UIColor.clearColor.CGColor;
    }
    return _addressBgView;
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

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont boldSystemFontOfSize:14];
        _nameLabel.textColor = OSSVThemesColors.col_333333;
    }
    return _nameLabel;
}

- (UILabel *)phoneLabel {
    if (!_phoneLabel) {
        _phoneLabel = [[UILabel alloc] init];
        _phoneLabel.font = [UIFont systemFontOfSize:14];
        _phoneLabel.textColor = OSSVThemesColors.col_6C6C6C;
    }
    return _phoneLabel;
}


- (AddressShowLabel *)addressLabel {
    if (!_addressLabel) {
        _addressLabel = [[AddressShowLabel alloc] init];
        _addressLabel.numberOfLines = 0;
        _addressLabel.font = [UIFont systemFontOfSize:14];
        _addressLabel.textColor = OSSVThemesColors.col_6C6C6C;
        [_addressLabel convertTextAlignmentWithARLanguage];
    }
    return _addressLabel;
}



- (UIButton *)editButton {
    if (!_editButton) {
        _editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_editButton setImage:[UIImage imageNamed:@"address_edit_h"] forState:UIControlStateNormal];
        [_editButton addTarget:self action:@selector(editAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _editButton;
}

- (UIButton *)deleteButton {
    if (!_deleteButton) {
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteButton setImage:[UIImage imageNamed:@"address_delete_h"] forState:UIControlStateNormal];
        [_deleteButton addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteButton;
}


@end
