//
//  ZFAccountListTableViewCell.m
//  ZZZZZ
//
//  Created by YW on 2018/4/28.
//  Copyright © 2018年 YW. All rights reserved.
//

/*
 * 备注：个人中心，复用Cell。
 * 根据不同的ZFAccountListCellType 进行UI显示以及逻辑处理
 * tipsInfo 用于需要显示的提示语，比如说App本地化语言，币种类型等。
 */

#import "ZFAccountListTableViewCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "UIView+ZFViewCategorySet.h"
#import "ZFLocalizationString.h"
#import "SystemConfigUtils.h"
#import "Masonry.h"

@interface ZFAccountListTableViewCell() <ZFInitViewProtocol>

@property (nonatomic, strong) UIImageView       *iconImageView;
@property (nonatomic, strong) UILabel           *titleLabel;
@property (nonatomic, strong) UILabel           *tipsLabel;
@property (nonatomic, strong) UIImageView       *arrowImageView;
@property (nonatomic, strong) UIView            *lineView;
@end

@implementation ZFAccountListTableViewCell


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
    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.tipsLabel];
    [self.contentView addSubview:self.arrowImageView];
    [self.contentView addSubview:self.lineView];
}

- (void)zfAutoLayoutView {
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(17);
        make.size.mas_equalTo(CGSizeMake(22, 22));
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.leading.mas_equalTo(self.iconImageView.mas_trailing).offset(17);
    }];
    
    [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.leading.mas_equalTo(self.titleLabel.mas_trailing).offset(12);
        make.trailing.mas_equalTo(self.arrowImageView.mas_leading).offset(-8);
    }];
    
    [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.titleLabel);
        make.trailing.mas_equalTo(self.contentView);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-1.f);
        make.height.mas_equalTo(1.f);
    }];
}

#pragma mark - setter
- (void)setCellType:(ZFAccountTypeModelType)cellType {
    _cellType = cellType;
    
    //根据不同的cell Type 处理不同的iconImageView.image 以及titleLabel.text
    NSArray *titles = @[ZFLocalizedString(@"Address_VC_Title", nil),
                        ZFLocalizedString(@"History_View_Title", nil),
                        ZFLocalizedString(@"ZFOrderList_Contact_us", nil),
                        ZFLocalizedString(@"Account_Cell_Help", nil),
                        ZFLocalizedString(@"Account_Survey", nil)];
    
    NSArray *imageNames = @[@"account_home_adress",@"account_home_history",
                            @"contact_us-min",@"account_home_help",@"account_home_survey"];
    
    NSInteger index = _cellType - ZFAccountTypeModelTypeAddress;
    self.iconImageView.image = [UIImage imageNamed:imageNames[index]];
    self.titleLabel.text = titles[index];

    self.lineView.hidden = (_cellType == ZFAccountTypeModelTypeHistory || _cellType == ZFAccountTypeModelTypeSurvey);
}

- (void)setTipsInfo:(NSString *)tipsInfo {
    _tipsInfo = tipsInfo;
    self.tipsLabel.text = _tipsInfo;
}

#pragma mark - getter
- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _iconImageView.image = [UIImage imageNamed:@"address"];
    }
    return _iconImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textColor = ZFCOLOR(45, 45, 45, 1.f);
        _titleLabel.text = @"Shipping Address";
        _titleLabel.textAlignment = ![SystemConfigUtils isRightToLeftShow] ? NSTextAlignmentLeft : NSTextAlignmentRight;
    }
    return _titleLabel;
}

- (UILabel *)tipsLabel {
    if (!_tipsLabel) {
        _tipsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _tipsLabel.textColor = ZFCOLOR(153, 153, 153, 1.f);
        _tipsLabel.font = [UIFont systemFontOfSize:14];
        _tipsLabel.textAlignment = [SystemConfigUtils isRightToLeftShow] ? NSTextAlignmentLeft : NSTextAlignmentRight;
    }
    return _tipsLabel;
}

- (UIImageView *)arrowImageView {
    if (!_arrowImageView) {
        _arrowImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _arrowImageView.image = [UIImage imageNamed:@"account_arrow"];
        [_arrowImageView convertUIWithARLanguage];        
    }
    return _arrowImageView;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = ZFCOLOR(247, 247, 247, 1.f);
    }
    return _lineView;
}
    
@end
