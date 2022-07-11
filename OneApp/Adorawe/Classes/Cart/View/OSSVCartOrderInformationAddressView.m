//
//  OSSVCartOrderInformationAddressView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/8.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCartOrderInformationAddressView.h"
#import "OSSVAddressOfsOrderEntersVC.h"
#import "OSSVAddresseBookeModel.h"
#import "Adorawe-Swift.h"

@interface OSSVCartOrderInformationAddressView ()


/** 用户名*/
@property (nonatomic, strong) UILabel                  *addressUserName;
/** 电话*/
@property (nonatomic, strong) UILabel                  *addressUserTel;
/** 地址*/
@property (nonatomic, strong) AddressShowLabel         *addressUserDetail;
@property (nonatomic, strong) YYAnimatedImageView      *addressIcon;
@property (nonatomic, strong) UIView                   *addressBgView;


@end

@implementation OSSVCartOrderInformationAddressView

/*========================================分割线======================================*/

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        UIView *ws = self;
        ws.backgroundColor = OSSVThemesColors.col_FFFFFF;
        
        [ws addSubview:self.addressBgView];
        [self.addressBgView addSubview:self.addressIcon];
        [ws addSubview:self.addressUserName];
        [ws addSubview:self.addressUserTel];
        [ws addSubview:self.addressUserDetail];
        [ws addSubview:self.addressShowBtn];
        
        
        /*
         * 设置优先级
         * addressUserTel优先级高于addressUserName
         * 保证了addressUserTel能够显示完整不被压缩
         *  将addressUserTel距容器尾部的优先级降低保证了内容跟在addressUserName后面
         *
         */
        [self.addressBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(ws.mas_leading).mas_offset(14);
            make.top.mas_equalTo(ws.mas_top).mas_offset(14);
            make.height.width.equalTo(20);
        }];
        
        [self.addressIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(self.addressBgView);
            make.height.width.mas_equalTo(@12);
        }];
        
        [self.addressUserName mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.addressBgView.mas_centerY);
            make.leading.mas_equalTo(self.addressBgView.mas_trailing).mas_offset(4);
            make.trailing.mas_equalTo(ws.mas_trailing).mas_offset(-14);
        }];
        
        [self.addressUserTel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.addressBgView.mas_leading);
            make.top.mas_equalTo(self.addressBgView.mas_bottom).offset(4);
            make.trailing.mas_equalTo(ws.mas_trailing).mas_offset(-14);
        }];
        
        [self.addressUserDetail mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.addressBgView.mas_leading);
            make.trailing.mas_equalTo(ws.mas_trailing).mas_offset(-14);
            make.top.mas_equalTo(self.addressUserTel.mas_bottom).mas_offset(4);
            make.bottom.mas_equalTo(ws.mas_bottom).mas_offset(-14);
        }];
        
        [self.addressShowBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.mas_centerY);
            make.trailing.mas_equalTo(ws.mas_trailing).mas_offset(-10);
            make.leading.mas_equalTo(ws.mas_leading);
        }];
    }
    return self;
}

/*========================================分割线======================================*/

- (void)setAddressModel:(OSSVAddresseBookeModel *)addressModel {
    _addressModel = addressModel;
    self.addressUserName.text = [NSString stringWithFormat:@"%@ %@",addressModel.firstName,addressModel.lastName];
    
    //后台暂时返回phone时拼接好的，没phoneHead，也没countryCode
    if (![OSSVNSStringTool isEmptyString:addressModel.countryCode]) {
        self.addressUserTel.text = [NSString stringWithFormat:@"+%@  %@%@",STLToString(addressModel.countryCode), STLToString(addressModel.phoneHead), addressModel.phone];
    } else {
        self.addressUserTel.text = [NSString stringWithFormat:@"%@%@", STLToString(addressModel.phoneHead),addressModel.phone];
    }

    
    NSString *contentString = [NSString addressStringWithAddres:addressModel];
    if ([contentString hasPrefix:@"\n"]) {
        contentString = [contentString stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
    }
    self.addressUserDetail.text = contentString;
}




/*========================================分割线======================================*/

- (void)chooseAddress:(UIButton*)sender {
    
    OSSVAddressOfsOrderEntersVC *addressVC = [OSSVAddressOfsOrderEntersVC new];
    addressVC.selectedAddressId = self.addressModel.addressId;
    
    addressVC.chooseDefaultAddressBlock = ^(OSSVAddresseBookeModel *addressModel) {
        if (self.changeAddressBlock) {
            self.changeAddressBlock(addressModel);
        }
    };
    
    addressVC.directReBackActionBlock = ^(OSSVAddresseBookeModel *modifyAddressModel){
        if (self.changeAddressBlock) {
            self.changeAddressBlock(modifyAddressModel);
        }
    };
    
    
    [self.viewController.navigationController pushViewController:addressVC animated:YES];
}

#pragma mark - LazyLoad

- (UIView *)addressBgView {
    if (!_addressBgView) {
        _addressBgView = [UIView new];
        _addressBgView.backgroundColor = [OSSVThemesColors col_0D0D0D];
        _addressBgView.layer.cornerRadius = 10;
        _addressBgView.layer.masksToBounds = YES;
    }
    return _addressBgView;
}
- (YYAnimatedImageView *)addressIcon {
    if (!_addressIcon) {
        _addressIcon = [YYAnimatedImageView new];
        _addressIcon.image = [UIImage imageNamed:@"orderDetail_addressMap"];
    }
    return _addressIcon;
}

- (UILabel *)addressUserName {
    if (!_addressUserName) {
        _addressUserName = [UILabel new];
        [_addressUserName setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [_addressUserName setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        [_addressUserName setFont:[UIFont boldSystemFontOfSize:14]];
        _addressUserName.textColor = [OSSVThemesColors col_0D0D0D];
        
        _addressUserName.textAlignment = NSTextAlignmentLeft;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _addressUserName.textAlignment = NSTextAlignmentRight;
        }
    }
    return _addressUserName;
}

- (UILabel *)addressUserTel {
    if (!_addressUserTel) {
        _addressUserTel = [UILabel new];
//        [_addressUserTel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
//        [_addressUserTel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        
        _addressUserTel.textColor = [OSSVThemesColors col_6C6C6C];
        _addressUserTel.font = [UIFont systemFontOfSize:14];
        
        _addressUserTel.textAlignment = NSTextAlignmentLeft;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _addressUserTel.textAlignment = NSTextAlignmentRight;
        }
    }
    return _addressUserTel;
}

- (AddressShowLabel *)addressUserDetail {
    if (!_addressUserDetail) {
        _addressUserDetail = [AddressShowLabel new];
        _addressUserDetail.numberOfLines = 0;
        _addressUserDetail.textColor = [OSSVThemesColors col_6C6C6C];
        _addressUserDetail.font = [UIFont systemFontOfSize:14];
        [_addressUserDetail setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        _addressUserDetail.textAlignment = NSTextAlignmentLeft;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _addressUserDetail.textAlignment = NSTextAlignmentRight;
        }
    }
    return _addressUserDetail;
}

- (UIButton *)addressShowBtn {
    if (!_addressShowBtn) {
        _addressShowBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _addressShowBtn.transform = CGAffineTransformMakeRotation(M_PI);
        }
        [_addressShowBtn addTarget:self action:@selector(chooseAddress:) forControlEvents:UIControlEventTouchUpInside];
        _addressShowBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        _addressShowBtn.imageEdgeInsets = UIEdgeInsetsMake(-10, 0, 0, 0);
        [_addressShowBtn setImage:[UIImage imageNamed:@"arrow_12"] forState:UIControlStateNormal];
    }
    return _addressShowBtn;
}

@end
