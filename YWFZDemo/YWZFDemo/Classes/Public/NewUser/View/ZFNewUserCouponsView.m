//
//  ZFNewUserCouponsView.m
//  ZZZZZ
//
//  Created by mac on 2019/1/9.
//  Copyright © 2019年 ZZZZZ. All rights reserved.
//

#import "ZFNewUserCouponsView.h"
#import "ZFNewUserHeckReceivingStatusModel.h"
#import "UILabel+HTML.h"
#import "YWLoginViewController.h"
#import "CouponViewController.h"
#import "Masonry.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "ZFLocalizationString.h"
#import "ZFNavigationController.h"
#import "ZFThemeManager.h"
#import "CouponRulesView.h"
#import "Constants.h"
#import "UIView+ZFViewCategorySet.h"
#import "UIButton+ZFButtonCategorySet.h"

@interface ZFNewUserCouponsView ()

/** 背景 */
@property (nonatomic, strong) UIImageView *bgImageView;
/** 背景 */
@property (nonatomic, strong) UIImageView *bgHeadImageView;
/** 头像 */
@property (nonatomic, strong) UIImageView *headImageView;
/** 内容背景 */
@property (nonatomic, strong) UIImageView *infobgImageView;
/** 标题 */
@property (nonatomic, strong) UILabel *titleLb;
/** 副标题 */
@property (nonatomic, strong) UILabel *desTitleLb;
/** 按键 */
@property (nonatomic, strong) UIButton *checkButton;
/** 提示 */
@property (nonatomic, strong) UILabel *pointOutLb;
/** 规则按键 */
@property (nonatomic, strong) UIButton *rulesButton;

@end

@implementation ZFNewUserCouponsView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self addSubview:self.bgImageView];
        [self addSubview:self.bgHeadImageView];
        [self.bgImageView addSubview:self.headImageView];
        [self.bgImageView addSubview:self.titleLb];
        [self.bgImageView addSubview:self.desTitleLb];
        [self.bgImageView addSubview:self.checkButton];
        [self.bgImageView addSubview:self.infobgImageView];
        [self.bgImageView addSubview:self.pointOutLb];
        [self.bgImageView addSubview:self.rulesButton];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self.bgHeadImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(self).offset(20);
        make.right.equalTo(self).offset(-20);
        make.height.mas_equalTo(100*ScreenWidth_SCALE);
    }];
    
    [self.headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bgImageView).offset(15);
        make.centerX.equalTo(self);
        make.width.height.mas_equalTo(30*ScreenWidth_SCALE);
    }];
    
    [self.titleLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headImageView.mas_bottom);
        make.left.equalTo(self).offset(15);
        make.right.equalTo(self).offset(-15);
        make.height.mas_equalTo(30*ScreenWidth_SCALE);
    }];
    
    [self.desTitleLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLb.mas_bottom);
        make.left.right.equalTo(self.titleLb);
        make.centerX.equalTo(self);
    }];
    
    [self.checkButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bgImageView).offset(100*ScreenWidth_SCALE);
        make.centerX.equalTo(self);
        make.width.mas_lessThanOrEqualTo(KScreenWidth - 30);
        make.height.mas_equalTo(30*ScreenWidth_SCALE);
    }];
    
    [self.infobgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.checkButton.mas_bottom).offset(6);
        make.centerX.equalTo(self);
        make.height.mas_equalTo(140*ScreenWidth_SCALE);
        make.width.mas_equalTo(320*ScreenWidth_SCALE);
    }];

    [self.pointOutLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.infobgImageView.mas_bottom).offset(6);
        make.centerX.equalTo(self);
        make.width.mas_lessThanOrEqualTo(KScreenWidth - 30);
        make.height.mas_lessThanOrEqualTo(60);
//        make.height.mas_equalTo(20*ScreenWidth_SCALE);
    }];
    
    [self.rulesButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.checkButton.mas_top);
        make.right.equalTo(self.bgImageView).offset(10);
        make.height.mas_equalTo(26*ScreenWidth_SCALE);
    }];
    
}

- (NSString *)textString:(NSAttributedString *)attributedText
{
    NSMutableAttributedString * resutlAtt = [[NSMutableAttributedString alloc]initWithAttributedString:attributedText];
    return resutlAtt.string;
}

- (void)setHeckReceivingStatusModel:(ZFNewUserHeckReceivingStatusModel *)heckReceivingStatusModel {
    _heckReceivingStatusModel = heckReceivingStatusModel;
    
    [self.titleLb zf_setHTMLFromString:heckReceivingStatusModel.title textColor:@"#FFFFFF"];
    self.desTitleLb.text = heckReceivingStatusModel.content;
    self.pointOutLb.font = [UIFont systemFontOfSize:12];
    // 因为这里Html标签有换行无法显示采用本地写, (安卓端是本地写死的)
    //[self.pointOutLb zf_setHTMLFromString:heckReceivingStatusModel.instructions textColor:@"#FFFFFF"];
    
    if (heckReceivingStatusModel.title.length == 0) {
        [self.titleLb mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
    }
    
    switch (self.heckReceivingStatusModel.status) {
        case 0:
            self.headImageView.image = ZFImageWithName(@"home_newuser_succee");
            [self.checkButton setTitle:ZFLocalizedString(@"newcomer_check_it", nil) forState:UIControlStateNormal];
            self.checkButton.hidden = NO;
            break;
        case 1:
            self.headImageView.image = ZFImageWithName(@"home_newuser_fail");
            self.checkButton.hidden = YES;
            break;
        case 2:
            self.headImageView.image = ZFImageWithName(@"home_newuser_get");
            [self.checkButton setTitle:ZFLocalizedString(@"newcomer_check_it", nil) forState:UIControlStateNormal];
            self.checkButton.hidden = NO;
            break;
        case 3:
            self.headImageView.image = ZFImageWithName(@"home_newuser_get");
            [self.checkButton setTitle:ZFLocalizedString(@"newcomer_no_login", nil) forState:UIControlStateNormal];
            self.checkButton.hidden = NO;
            break;
        case 4:
            self.headImageView.image = ZFImageWithName(@"home_newuser_get");
            [self.checkButton setTitle:ZFLocalizedString(@"newcomer_check_it", nil) forState:UIControlStateNormal];
            self.checkButton.hidden = NO;
            break;
        default:
            self.headImageView.image = ZFImageWithName(@"home_newuser_get");
            [self.checkButton setTitle:ZFLocalizedString(@"newcomer_check_it", nil) forState:UIControlStateNormal];
            self.checkButton.hidden = NO;
            break;
    }
}

- (void)checkButtonClick {
    switch (self.heckReceivingStatusModel.status) {
        case 0:
        case 2:
        case 4:
        case 5:{
            CouponViewController *couponVC = [[CouponViewController alloc] init];
            UIViewController *vc  = [UIViewController currentTopViewController];
            [vc.navigationController pushViewController:couponVC animated:YES];
        }
            break;
        case 3: {
            YWLoginViewController *loginVC = [[YWLoginViewController alloc] init];
            @weakify(self);
            loginVC.successBlock = ^{
                @strongify(self)
                if (self.successBlock) {
                    self.successBlock();
                }
            };
            loginVC.type = YWLoginEnterTypeRegister;
            ZFNavigationController *nav = [[ZFNavigationController alloc] initWithRootViewController:loginVC];
            UIViewController *vc  = [UIViewController currentTopViewController];
            [vc presentViewController:nav animated:YES completion:nil];
        }
            break;
        default:
            break;
    }
}

- (void)rulesButtonClick {
    
    CouponRulesView *view = [[CouponRulesView alloc] init];
    view.heckReceivingStatusModel = self.heckReceivingStatusModel;
    [view show];
}

- (UIImageView *)bgImageView {
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] init];
        _bgImageView.userInteractionEnabled = YES;
        _bgImageView.image = ZFImageWithName(@"home_newuser_bgview");
        [_bgImageView.image resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0) resizingMode:UIImageResizingModeStretch];
    }
    return _bgImageView;
}

- (UIImageView *)bgHeadImageView {
    if (!_bgHeadImageView) {
        _bgHeadImageView = [[UIImageView alloc] init];
        _bgHeadImageView.image = ZFImageWithName(@"home_newuser_bghead");
    }
    return _bgHeadImageView;
}

- (UIImageView *)headImageView {
    if (!_headImageView) {
        _headImageView = [[UIImageView alloc] init];
        _headImageView.image = ZFImageWithName(@"home_newuser_succee");
    }
    return _headImageView;
}

- (UIImageView *)infobgImageView {
    if (!_infobgImageView) {
        _infobgImageView = [[UIImageView alloc] init];
        _infobgImageView.image = ZFImageWithName(@"home_newuser_conpon");
    }
    return _infobgImageView;
}

- (UILabel *)titleLb {
    if (!_titleLb) {
        _titleLb = [[UILabel alloc] init];
        _titleLb.font = [UIFont boldSystemFontOfSize:18];
        _titleLb.textAlignment = NSTextAlignmentCenter;
        _titleLb.textColor = [UIColor whiteColor];
    }
    return _titleLb;
}

- (UILabel *)desTitleLb {
    if (!_desTitleLb) {
        _desTitleLb = [[UILabel alloc] init];
        _desTitleLb.font = [UIFont systemFontOfSize:16];
        _desTitleLb.textAlignment = NSTextAlignmentCenter;
        _desTitleLb.textColor = [UIColor whiteColor];
        _desTitleLb.numberOfLines = 2;
    }
    return _desTitleLb;
}

- (UIButton *)checkButton {
    if (!_checkButton) {
        _checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _checkButton.hidden = YES;
        _checkButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _checkButton.layer.cornerRadius = 4;
        _checkButton.layer.borderColor = [UIColor whiteColor].CGColor;
        _checkButton.layer.borderWidth = 1;
        _checkButton.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
        [_checkButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_checkButton setTitle:@"Log in and register now" forState:UIControlStateNormal];
        [_checkButton addTarget:self action:@selector(checkButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _checkButton;
}

- (UILabel *)pointOutLb {
    if (!_pointOutLb) {
        _pointOutLb = [[UILabel alloc] init];
        _pointOutLb.font = [UIFont systemFontOfSize:11];
        _pointOutLb.numberOfLines = 2;
        _pointOutLb.textColor = [UIColor whiteColor];
        _pointOutLb.text = ZFLocalizedString(@"newcomer_tips_coupons_valid_date", nil);
    }
    return _pointOutLb;
}

- (UIButton *)rulesButton {
    if (!_rulesButton) {
        _rulesButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _rulesButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _rulesButton.backgroundColor = ZFCOLOR(0, 0, 1, 0.3);
        [_rulesButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_rulesButton setTitleColor:[ZFCOLOR_WHITE colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
        [_rulesButton setImage:ZFImageWithName(@"account_zme") forState:(UIControlStateNormal)];
        [_rulesButton setTitle:ZFLocalizedString(@"Rules", nil) forState:UIControlStateNormal];
        [_rulesButton zfLayoutStyle:ZFButtonEdgeInsetsStyleRight imageTitleSpace:3];
        [_rulesButton convertUIWithARLanguage];
        
        _rulesButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_rulesButton addTarget:self action:@selector(rulesButtonClick) forControlEvents:UIControlEventTouchUpInside];
        _rulesButton.layer.cornerRadius = 13;
        _rulesButton.layer.masksToBounds = YES;
        _rulesButton.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 15);
    }
    return _rulesButton;
}

@end
