
//
//  ZFAddressEditSetDefaultTableViewCell.m
//  ZZZZZ
//
//  Created by YW on 2017/8/31.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFAddressEditSetDefaultTableViewCell.h"
#import "ZFInitViewProtocol.h"
#import "YWLocalHostManager.h"
#import "ZFThemeManager.h"
#import "YYText.h"
#import "UIView+LayoutMethods.h"
#import "ZFLocalizationString.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"

typedef enum : NSUInteger {
    TreatyLinkAction_ProvacyPolicy,
    TreatyLinkAction_TermsUse,
} ZFTreatyLinkAction;


@interface ZFAddressEditSetDefaultTableViewCell () <ZFInitViewProtocol>

@property (nonatomic, strong) UIView            *topLineView;
@property (nonatomic, strong) UIView            *bottomLineView;
@property (nonatomic, strong) UIView            *layoutView;
@property (nonatomic, strong) UILabel           *defaulLabel;
@property (nonatomic, strong) YYLabel           *privacyAndTermsLabel;
@property (nonatomic, strong) UISwitch          *selectSwitch;
@end

@implementation ZFAddressEditSetDefaultTableViewCell
#pragma mark - init methods
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - action methods
- (void)selectSwitchAction:(UISwitch *)sender {
    [self baseSelectEvent:self.selectSwitch.isOn];
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.contentView.backgroundColor = ZFCOLOR(247, 247, 247, 1.f);
    [self.contentView addSubview:self.topLineView];
    [self.contentView addSubview:self.bottomLineView];
    [self.contentView addSubview:self.layoutView];
    [self.layoutView addSubview:self.selectSwitch];
    [self.layoutView addSubview:self.defaulLabel];
    [self.layoutView addSubview:self.privacyAndTermsLabel];
}

- (void)zfAutoLayoutView {
    [self.topLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.mas_equalTo(self.contentView);
        make.height.mas_equalTo(0);
    }];
    
    [self.bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.leading.trailing.mas_equalTo(self.contentView);
        make.height.mas_equalTo(0);
    }];
    
    [self.layoutView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.contentView);
        make.top.mas_equalTo(self.topLineView.mas_bottom);
        make.bottom.mas_equalTo(self.bottomLineView.mas_top);
    }];
    
    [self.defaulLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.layoutView.top).offset(14);
        make.leading.mas_equalTo(self.layoutView.mas_leading).offset(16);
    }];
    
    [self.privacyAndTermsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.defaulLabel.mas_bottom).offset(4);
        make.leading.mas_equalTo(self.defaulLabel.mas_leading);
    }];
    
    [self.selectSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.layoutView.mas_centerY);
        make.trailing.mas_equalTo(self.layoutView.mas_trailing).offset(-18);
    }];
}

#pragma mark - setter
- (void)updateInfo:(ZFAddressInfoModel *)infoModel typeModel:(ZFAddressEditTypeModel *)typeModel {
    self.infoModel = infoModel;
    self.selectSwitch.on = self.infoModel.is_default;
}


/**
 * fetchPrivacyAndTermsTitle
 */
- (NSAttributedString *)fetchPrivacyAndTermsTitle
{
    NSString *allString = ZFLocalizedString(@"Address_VC_PrivacyTerms", nil);
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:allString];
    content.yy_font = ZFFontSystemSize(10.0);
    content.yy_color = ZFCOLOR(193, 193, 193, 1);
    UIColor *linkTextColor = ZFCOLOR(193, 193, 193, 1);
    
    //Privacy Policy链接
    NSString *privacyStr = ZFLocalizedString(@"Register_PrivacyPolicy", nil);
    NSRange policyRange = [allString rangeOfString:privacyStr];
    [content yy_setColor:linkTextColor range:policyRange];
    [content yy_setUnderlineStyle:NSUnderlineStyleSingle range:policyRange];
    [content yy_setUnderlineColor:linkTextColor range:policyRange];
    
    @weakify(self)
    [content yy_setTextHighlightRange:policyRange color:linkTextColor backgroundColor:nil tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
        YWLog(@"点击了 Privacy Policy");
        @strongify(self)
        [self dealWithTreatyLinkAction:TreatyLinkAction_ProvacyPolicy];
    }];
    
    //Terms Of Use
    NSString *termsStr = ZFLocalizedString(@"Register_TermsUse",nil);
    NSRange termsRange = [allString rangeOfString:termsStr];
    [content yy_setColor:linkTextColor range:termsRange];
    [content yy_setUnderlineStyle:NSUnderlineStyleSingle range:termsRange];
    [content yy_setUnderlineColor:linkTextColor range:termsRange];
    [content yy_setTextHighlightRange:termsRange color:linkTextColor backgroundColor:nil tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
        YWLog(@"点击了 Terms Of Use");
        @strongify(self)
        [self dealWithTreatyLinkAction:TreatyLinkAction_TermsUse];
    }];
    return content;
}

/**
 * 处理协议弹框事件方法
 */
- (void)dealWithTreatyLinkAction:(ZFTreatyLinkAction)actionType
{
    NSString *title = nil;
    NSString *url = nil;
    NSString *appH5BaseURL = [YWLocalHostManager appH5BaseURL];
    switch (actionType) {
        case TreatyLinkAction_ProvacyPolicy:
        {
            title = ZFLocalizedString(@"Register_PrivacyPolicy",nil);
            url = [NSString stringWithFormat:@"%@privacy-policy/?app=1&lang=%@",appH5BaseURL, [ZFLocalizationString shareLocalizable].nomarLocalizable];
        }
            break;
        case TreatyLinkAction_TermsUse:
        {
            title = ZFLocalizedString(@"Login_Terms_Web_Title",nil);
            url = [NSString stringWithFormat:@"%@terms-of-use/?app=1&lang=%@",appH5BaseURL, [ZFLocalizationString shareLocalizable].nomarLocalizable];
        }
            break;
        default:
            break;
    }
    if (title && url) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"title"] = title;
        dic[@"link_url"] = url;
        [[UIViewController currentTopViewController] pushToViewController:@"ZFWebViewViewController" propertyDic:dic];
    }
}

#pragma mark - getter
- (UIView *)layoutView {
    if (!_layoutView) {
        _layoutView = [[UIView alloc] initWithFrame:CGRectZero];
        _layoutView.backgroundColor = ZFCOLOR_WHITE;
    }
    return _layoutView;
}

- (UIView *)topLineView {
    if (!_topLineView) {
        _topLineView = [[UIView alloc] initWithFrame:CGRectZero];
        _topLineView.backgroundColor = ZFCOLOR(247, 247, 247, 1);
    }
    return _topLineView;
}

- (UILabel *)defaulLabel {
    if (!_defaulLabel) {
        _defaulLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _defaulLabel.font = [UIFont systemFontOfSize:14];
        _defaulLabel.textColor = ColorHex_Alpha(0x2D2D2D, 1.0);
        _defaulLabel.text = ZFLocalizedString(@"ModifyAddress_Set_Default", nil);
    }
    return _defaulLabel;
}

- (YYLabel *)privacyAndTermsLabel {
    if (!_privacyAndTermsLabel) {
        _privacyAndTermsLabel = [[YYLabel alloc] init];
        _privacyAndTermsLabel.backgroundColor = [UIColor clearColor];
        _privacyAndTermsLabel.textColor = [UIColor blackColor];
        _privacyAndTermsLabel.numberOfLines = 0;
        _privacyAndTermsLabel.font = ZFFontSystemSize(10.f);
        _privacyAndTermsLabel.textAlignment = NSTextAlignmentCenter;
        _privacyAndTermsLabel.attributedText = [self fetchPrivacyAndTermsTitle];
        _privacyAndTermsLabel.preferredMaxLayoutWidth = KScreenWidth-15*2;
        _privacyAndTermsLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _privacyAndTermsLabel;
}

- (UISwitch *)selectSwitch {
    if (!_selectSwitch) {
        _selectSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        _selectSwitch.onTintColor = ZFC0xFE5269();
        [_selectSwitch addTarget:self action:@selector(selectSwitchAction:) forControlEvents:UIControlEventValueChanged];
    }
    return _selectSwitch;
}

- (UIView *)bottomLineView {
    if (!_bottomLineView) {
        _bottomLineView = [[UIView alloc] initWithFrame:CGRectZero];
        _bottomLineView.backgroundColor = ZFCOLOR(247, 247, 247, 1);
    }
    return _bottomLineView;
}

@end

