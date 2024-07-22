//
//  ZFOrderAddressCell.m
//  ZZZZZ
//
//  Created by YW on 17/10/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFOrderAddressCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFAddressInfoModel.h"
#import "ZFThemeManager.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "UIView+ZFViewCategorySet.h"

@interface ZFOrderAddressCell ()<ZFInitViewProtocol>
//@property (nonatomic, strong) YYAnimatedImageView   *addressIcon;
@property (nonatomic, strong) UILabel               *userNameLabel;
@property (nonatomic, strong) UILabel               *userTelLabel;
@property (nonatomic, strong) UILabel               *addressLabel;
@property (nonatomic, strong) UIImageView           *arrowImage;
@end

@implementation ZFOrderAddressCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - Public method
+ (NSString *)queryReuseIdentifier {
    return NSStringFromClass([self class]);
}

#pragma mark - ZFInitViewProtocol
- (void)zfInitView {
    self.selectionStyle = UITableViewCellSeparatorStyleNone;
//    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.contentView.backgroundColor = ZFCOLOR(255, 255, 255, 1);
//    [self.contentView addSubview:self.addressIcon];
    [self.contentView addSubview:self.userNameLabel];
    [self.contentView addSubview:self.userTelLabel];
    [self.contentView addSubview:self.addressLabel];
    [self.contentView addSubview:self.arrowImage];
}

- (void)zfAutoLayoutView {
//    [self.addressIcon mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.equalTo(self.contentView).offset(12);
//        make.centerY.mas_equalTo(self.contentView);
//    }];
    
    [self.userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(12);
//        make.trailing.mas_equalTo(self.contentView.mas_trailing).mas_offset(-42);
        make.top.equalTo(self.contentView).offset(12);
        make.height.mas_equalTo(24);
    }];
    
    [self.userTelLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.userNameLabel.mas_trailing).offset(10);
        make.trailing.equalTo(self.contentView.mas_trailing).offset(-42);
        make.centerY.equalTo(self.userNameLabel.mas_centerY);
        make.height.mas_equalTo(24);
    }];
    
    [self.addressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.userNameLabel.mas_leading);
        make.top.equalTo(self.userNameLabel.mas_bottom);
        make.trailing.equalTo(self.contentView).offset(-24);
        make.bottom.equalTo(self.contentView).offset(-12);
    }];
     
     [self.arrowImage mas_makeConstraints:^(MASConstraintMaker *make) {
         make.trailing.mas_equalTo(self.contentView.mas_trailing).mas_offset(-12);
         make.centerY.mas_equalTo(self.contentView);
     }];
    
    [self.userNameLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [self.userTelLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
}

#pragma mark - Setter
- (void)setAddressModel:(ZFAddressInfoModel *)addressModel {
    _addressModel = addressModel;
    self.userNameLabel.text = [NSString stringWithFormat:@"%@ %@",ZFToString(addressModel.firstname),ZFToString(addressModel.lastname)];
    self.userTelLabel.text = [NSString stringWithFormat:@"+%@ %@%@",ZFToString(addressModel.code),ZFToString(addressModel.supplier_number),ZFToString(addressModel.tel)];
    
    if (ZFIsEmptyString(addressModel.barangay)) {
        
        self.addressLabel.text = [NSString stringWithFormat:@"%@ %@,%@ %@/%@ %@",ZFToString(addressModel.addressline1),ZFToString(addressModel.addressline2),ZFToString(addressModel.city),ZFToString(addressModel.province),ZFToString(addressModel.country_str),ZFToString(addressModel.zipcode)];
        
    } else {
        
        self.addressLabel.text = [NSString stringWithFormat:@"%@ %@,%@ %@ %@/%@ %@",ZFToString(addressModel.addressline1),ZFToString(addressModel.addressline2),ZFToString(addressModel.city),ZFToString(addressModel.province),ZFToString(addressModel.barangay),ZFToString(addressModel.country_str),ZFToString(addressModel.zipcode)];
    }
}

#pragma mark - Getter
//- (YYAnimatedImageView *)addressIcon {
//    if (!_addressIcon) {
//        _addressIcon = [YYAnimatedImageView new];
//        _addressIcon.image = [UIImage imageNamed:@"account_home_adress"];
//    }
//    return _addressIcon;
//}

- (UILabel *)userNameLabel {
    if (!_userNameLabel) {
        _userNameLabel = [[UILabel alloc] init];
        _userNameLabel.font = [UIFont boldSystemFontOfSize:14];
        _userNameLabel.textColor = ZFCOLOR(45, 45, 45, 1);
        _userNameLabel.preferredMaxLayoutWidth = KScreenWidth - 80;
    }
    return _userNameLabel;
}

- (UILabel *)userTelLabel {
    if (!_userTelLabel) {
        _userTelLabel = [[UILabel alloc] init];
        _userTelLabel.font = [UIFont systemFontOfSize:14];
        _userTelLabel.textColor = _userNameLabel.textColor;
    }
    return _userTelLabel;
}

- (UILabel *)addressLabel {
    if (!_addressLabel) {
        _addressLabel = [[UILabel alloc] init];
        _addressLabel.font = [UIFont systemFontOfSize:14];
        _addressLabel.textColor = ZFC0x999999();
        _addressLabel.numberOfLines = 0;
        _addressLabel.preferredMaxLayoutWidth = KScreenWidth - 68;
    }
    return _addressLabel;
}

- (UIImageView *)arrowImage
{
    if (!_arrowImage) {
        _arrowImage = ({
            UIImageView *img = [[UIImageView alloc] init];
            img.image = [UIImage imageNamed:@"account_arrow_right"];
            [img convertUIWithARLanguage];
            img;
        });
    }
    return _arrowImage;
}

@end
