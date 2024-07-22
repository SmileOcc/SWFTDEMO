//
//  ZFOrderBottomTipsCell.m
//  ZZZZZ
//
//  Created by YW on 2019/6/25.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFOrderBottomTipsCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFOrderInfoFooterModel.h"
#import "HyperlinksButton.h"
#import "YWLocalHostManager.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"

@interface ZFOrderBottomTipsCell ()
@property (nonatomic, strong) UILabel   *topLabel;
@property (nonatomic, strong) UILabel   *midelabel;
@property (nonatomic, strong) UIView    *bottomView;
@property (nonatomic, strong) HyperlinksButton   *learnMoreButton;
@property (nonatomic, strong) HyperlinksButton   *contactButton;
@property (nonatomic, strong) UILabel   *orLabel;
@property (nonatomic, strong) UIImageView *safeTipsImage;
@end

@implementation ZFOrderBottomTipsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.backgroundColor = ZFCOLOR(247, 247, 247, 1);
    [self addSubview:self.topLabel];
    [self addSubview:self.midelabel];
    [self addSubview:self.bottomView];
    [self.bottomView addSubview:self.learnMoreButton];
    [self.bottomView addSubview:self.orLabel];
    [self.bottomView addSubview:self.contactButton];
    [self addSubview:self.safeTipsImage];
}

- (void)zfAutoLayoutView {
    [self.topLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top).offset(8);
        make.centerX.mas_equalTo(self);
        make.height.mas_equalTo(16);
    }];
    
    [self.midelabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topLabel.mas_bottom).offset(2);
        make.centerX.mas_equalTo(self);
        make.height.mas_equalTo(16);
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.midelabel.mas_bottom).offset(2);
        make.centerX.mas_equalTo(self);
    }];
    
    [self.learnMoreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.bottomView);
        make.top.bottom.mas_equalTo(self.bottomView);
    }];
    
    [self.orLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.learnMoreButton.mas_trailing).offset(4);
        make.centerY.equalTo(self.bottomView);
    }];
    
    [self.contactButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.orLabel.mas_trailing).offset(4);
        make.trailing.centerY.equalTo(self.bottomView);
    }];
    
    [self.safeTipsImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bottomView.mas_bottom).mas_offset(4);
        make.centerX.mas_equalTo(self);
        make.bottom.mas_equalTo(self.mas_bottom).offset(-8);
    }];
}

#pragma mark - Button Action
- (void)webviewJumpButtonAction:(UIButton *)sender{
    NSString *url;
    if (sender.tag == 0) {
        url = self.model.learn_more_url;
    }else{
        NSString *appH5BaseURL = [YWLocalHostManager appH5BaseURL];
        url = [NSString stringWithFormat:@"%@privacy-policy/?app=1&lang=%@",appH5BaseURL, [ZFLocalizationString shareLocalizable].nomarLocalizable];
    }
    if (self.orderInfoH5Block) {
        self.orderInfoH5Block(url);
    }
}

+ (NSString *)queryReuseIdentifier
{
    return NSStringFromClass(self.class);
}

#pragma mark - Setter
-(void)setModel:(ZFOrderInfoFooterModel *)model {
    _model = model;
    self.topLabel.text = model.topTip;
    self.midelabel.text = model.midTip;
}

#pragma mark - getter
- (UILabel *)topLabel {
    if (!_topLabel) {
        _topLabel = [UILabel new];
        _topLabel.textColor = ZFCOLOR(153, 153, 153, 1);
        _topLabel.font = [UIFont systemFontOfSize:12.0];
        _topLabel.textAlignment = NSTextAlignmentCenter;
        _topLabel.numberOfLines = 1;
        _topLabel.preferredMaxLayoutWidth = KScreenWidth - 10;
    }
    return _topLabel;
}

- (UILabel *)midelabel {
    if (!_midelabel) {
        _midelabel = [UILabel new];
        _midelabel.textColor = ZFCOLOR(153, 153, 153, 1);
        _midelabel.font = [UIFont systemFontOfSize:12.0];
        _midelabel.textAlignment = NSTextAlignmentCenter;
        _midelabel.numberOfLines = 1;
        _midelabel.preferredMaxLayoutWidth = KScreenWidth - 10;
    }
    return _midelabel;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [UIView new];
        _bottomView.backgroundColor = ZFCOLOR(247, 247, 247, 1);
    }
    return _bottomView;
    
}

- (HyperlinksButton *)learnMoreButton {
    if (!_learnMoreButton) {
        _learnMoreButton = [HyperlinksButton buttonWithType:UIButtonTypeCustom];
        [_learnMoreButton setTitleColor:ZFCOLOR(45, 45, 45, 1) forState:UIControlStateNormal];
        [_learnMoreButton setTitleColor:ZFCOLOR(45, 45, 45, 1) forState:UIControlStateHighlighted];
        _learnMoreButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_learnMoreButton setTitle:ZFLocalizedString(@"ZFOrderList_Learn_more", nil) forState:UIControlStateNormal];
        [_learnMoreButton setColor:ZFCOLOR(153, 153, 153, 1.0)];
        _learnMoreButton.tag = 0;
        [_learnMoreButton addTarget:self action:@selector(webviewJumpButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _learnMoreButton;
}

- (HyperlinksButton *)contactButton {
    if (!_contactButton) {
        _contactButton = [HyperlinksButton buttonWithType:UIButtonTypeCustom];
        [_contactButton setTitleColor:ZFCOLOR(45, 45, 45, 1) forState:UIControlStateNormal];
        [_contactButton setTitleColor:ZFCOLOR(45, 45, 45, 1) forState:UIControlStateHighlighted];
        _contactButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_contactButton setTitle:ZFLocalizedString(@"Register_PrivacyPolicy", nil) forState:UIControlStateNormal];
        [_contactButton setColor:ZFCOLOR(153, 153, 153, 1.0)];
        _contactButton.tag = 1;
        [_contactButton addTarget:self action:@selector(webviewJumpButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _contactButton;
}


- (UILabel *)orLabel {
    if (!_orLabel) {
        _orLabel = [UILabel new];
        _orLabel.textColor = ZFCOLOR(153, 153, 153, 1);
        _orLabel.font = [UIFont systemFontOfSize:12.0];
        _orLabel.text = ZFLocalizedString(@"ZFOrderInfo_Or", nil);
    }
    return _orLabel;
}

- (UIImageView *)safeTipsImage
{
    if (!_safeTipsImage) {
        _safeTipsImage = ({
            UIImageView *img = [[UIImageView alloc] init];
            img.image = [UIImage imageNamed:@"pay_safe_logo"];
            img.contentMode = UIViewContentModeCenter;
            img;
        });
    }
    return _safeTipsImage;
}


@end
