//
//  ZFAddressEditCountryTableViewCell.m
//  ZZZZZ
//
//  Created by YW on 2017/8/31.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFAddressEditCountryTableViewCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "NSStringUtils.h"
#import "UIView+ZFViewCategorySet.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "Masonry.h"

@interface ZFAddressEditCountryTableViewCell () <ZFInitViewProtocol>
@property (nonatomic, strong) UILabel           *countryInfoLabel;
@property (nonatomic, strong) UIImageView       *arrowView;
@property (nonatomic, strong) UILabel           *tipsLabel;
@end

@implementation ZFAddressEditCountryTableViewCell
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
    [self.contentView addSubview:self.countryInfoLabel];
    [self.contentView addSubview:self.arrowView];
    [self.contentView addSubview:self.lineView];
    [self.contentView addSubview:self.tipsLabel];
}

- (void)zfAutoLayoutView {
    [self.countryInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(16);
        make.centerY.mas_equalTo(self.contentView);
        make.trailing.mas_equalTo(self.arrowView.mas_leading).offset(-16);
        make.height.mas_equalTo(30);
    }];
    
    [self.arrowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
        make.size.mas_equalTo(CGSizeMake(16, 16));
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.countryInfoLabel);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
        make.bottom.mas_equalTo(self.contentView.mas_bottom);
        make.height.mas_equalTo(1);
    }];
    
    [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.lineView);
        make.top.mas_equalTo(self.lineView.mas_bottom);
        make.bottom.mas_equalTo(self.contentView.mas_bottom);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
    }];
}

#pragma mark - setter
- (void)updateInfo:(ZFAddressInfoModel *)infoModel typeModel:(ZFAddressEditTypeModel *)typeModel {
    self.infoModel = infoModel;
    self.typeModel = typeModel;
    
    if ([NSStringUtils isEmptyString:self.infoModel.country_str]) {
        self.countryInfoLabel.text = ZFLocalizedString(@"ModifyAddress_Country_Placeholder", nil);
        self.countryInfoLabel.textColor = ZFCOLOR(153, 153, 153, 0.5f);
    } else {
        self.countryInfoLabel.text = self.infoModel.country_str;
        self.countryInfoLabel.textColor = ZFCOLOR(51, 51, 51, 1.f);
    }
    
    self.tipsLabel.hidden = YES;
    self.lineView.backgroundColor = ZFCOLOR(221, 221, 221, 1.f);

    if ([self isShowTips] && self.typeModel.isShowTips) {
        self.tipsLabel.hidden = NO;
        self.lineView.backgroundColor = ZFC0xFE5269();
        [self.lineView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-22);
        }];
        
    } else {
        [self.lineView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.contentView.mas_bottom);
        }];
    }
}

- (void)updateContentText:(NSString *)text {
    if (!ZFIsEmptyString(text)) {
        self.countryInfoLabel.text = text;
    }
}

- (BOOL)isShowTips {
    BOOL showTips = NO;
    if(ZFIsEmptyString(self.infoModel.country_str)){
        self.tipsLabel.text = ZFLocalizedString(@"ModifyAddress_Country_TipLabel",nil);
        showTips = YES;
    }
    return showTips;
}

#pragma mark - getter

- (UILabel *)countryInfoLabel {
    if (!_countryInfoLabel) {
        _countryInfoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _countryInfoLabel.font = [UIFont systemFontOfSize:14];
        _countryInfoLabel.textColor = ZFCOLOR(153, 153, 153, 0.5f);
        _countryInfoLabel.text = ZFLocalizedString(@"ModifyAddress_Country_Placeholder", nil);
    }
    return _countryInfoLabel;
}

- (UIImageView *)arrowView {
    if (!_arrowView) {
        _arrowView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _arrowView.image = [UIImage imageNamed:@"account_arrow_right"];
        [_arrowView convertUIWithARLanguage];
    }
    return _arrowView;
}

- (UILabel *)tipsLabel {
    if (!_tipsLabel) {
        _tipsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _tipsLabel.textColor = ZFC0xFE5269();
        _tipsLabel.font = [UIFont systemFontOfSize:12];
        _tipsLabel.hidden = YES;
    }
    return _tipsLabel;
}
@end
