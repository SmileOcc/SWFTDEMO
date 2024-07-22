//
//  ZFVideoLiveCouponAlertView.m
//  ZZZZZ
//
//  Created by YW on 2019/8/12.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFVideoLiveCouponAlertView.h"
#import "ZFThemeManager.h"
#import "YWCFunctionTool.h"
#import "Masonry.h"
#import "Constants.h"
#import "UIView+ZFViewCategorySet.h"
#import "ZFLocalizationString.h"
#import "ZFInitViewProtocol.h"

@interface ZFVideoLiveCouponAlertView ()<ZFInitViewProtocol>

///背景视图
@property (nonatomic, strong) UIView        *contentBackView;
///背景图片
@property (nonatomic, strong) UIImageView   *contentImageView;
///优惠金额或者优惠折扣label
@property (nonatomic, strong) UILabel       *codeLabel;
///优惠明细label
@property (nonatomic, strong) UILabel       *expiresLabel;
///标签button
@property (nonatomic, strong) UIButton      *receiveBtn;

@property (nonatomic, strong) UIButton      *closeButton;


///优惠券失效视图
@property (nonatomic, strong) UIImageView   *invalidCouponIcon;
/////优惠券失效文字
@property (nonatomic, strong) UILabel       *invalidText;
@end

@implementation ZFVideoLiveCouponAlertView

- (instancetype)initWithFrame:(CGRect)frame couponModel:(ZFGoodsDetailCouponModel *)couponModel {
    self = [super initWithFrame:frame];
    if (self) {
        
        [self zfInitView];
        [self zfAutoLayoutView];
        self.couponModel = couponModel;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame couponModel:(ZFGoodsDetailCouponModel *)couponModel isNew:(BOOL)isNew {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.isNewAlert = isNew;
        [self zfInitView];
        [self zfAutoLayoutView];
        self.couponModel = couponModel;
    }
    return self;
}

- (void)zfInitView {
    
    [self addSubview:self.contentImageView];
    [self addSubview:self.codeLabel];
    [self addSubview:self.expiresLabel];
    [self addSubview:self.receiveBtn];
    [self addSubview:self.closeButton];
    
    [self.contentImageView addSubview:self.invalidCouponIcon];
    [self.invalidCouponIcon addSubview:self.invalidText];

}

- (void)zfAutoLayoutView {
    [self.contentImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(164, 70));
    }];
    
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(22, 22));
    }];
    
    if (self.isNewAlert) {
        [self.receiveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.mas_trailing).offset(-8);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.height.mas_equalTo(20);
        }];
    } else {
        [self.receiveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top).offset(10);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-8);
            make.height.mas_equalTo(20);
        }];
    }
    
    
    [self.codeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mas_leading).offset(5);
        make.top.mas_equalTo(self.closeButton.mas_bottom).offset(-7);
        make.trailing.mas_equalTo(self.receiveBtn.mas_leading).offset(-5);
    }];
    
    [self.expiresLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mas_leading).offset(5);
        make.top.mas_equalTo(self.codeLabel.mas_bottom).offset(4);
        make.trailing.mas_equalTo(self.contentImageView.mas_trailing).offset(-10);
    }];
    
    [self.invalidCouponIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.contentImageView);
        make.bottom.mas_equalTo(self.contentImageView.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(53, 46));
    }];
    
    [self.invalidText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.invalidCouponIcon).offset(4);
        make.centerX.mas_equalTo(self.invalidCouponIcon.mas_centerX);
        make.trailing.leading.mas_equalTo(self.invalidCouponIcon);
    }];
    
    [self.codeLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [self.receiveBtn setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [self.receiveBtn setContentHuggingPriority:260 forAxis:UILayoutConstraintAxisHorizontal];
}

#pragma mark - Action

- (void)actionClose:(UIButton *)sender {
    self.hidden = YES;
    if (self.closeBlock) {
        self.closeBlock();
    }
    if (self.superview) {
        [self removeFromSuperview];
    }
}

- (void)receiveAction:(UIButton *)sender {
    if (self.receiveCouponBlock) {
        self.receiveCouponBlock(self.couponModel);
    }
}

- (void)hideViewWithTime:(NSInteger)time complectBlock:(void (^)(void))completion{
    if (time < 0) {
        time = 3;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.hidden = YES;
        if (completion) {
            completion();
        }
    });
}

#pragma mark - Property Method

- (void)setCouponModel:(ZFGoodsDetailCouponModel *)couponModel {
    _couponModel = couponModel;
    
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineSpacing = -3;
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    [attributes setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
    
    self.codeLabel.attributedText = [[NSAttributedString alloc] initWithString:ZFToString(couponModel.discounts) attributes:attributes];
    
    self.expiresLabel.attributedText = [[NSAttributedString alloc] initWithString:ZFToString(couponModel.preferentialHead) attributes:attributes];;
    
    //免邮优惠券
    if (couponModel.noMail) {
        self.expiresLabel.text = ZFLocalizedString(@"MyCoupon_FREE_SHIPPING", nil);
    }
    
    self.invalidCouponIcon.hidden = YES;
    NSString *invalidTitle = nil;
    self.receiveBtn.hidden = YES;
    
    // coupon状态；1:可领取;2:已领取;3:已领取完
    if (couponModel.couponStats == 1) {
        self.receiveBtn.hidden = NO;
        self.codeLabel.textColor = [UIColor whiteColor];
        self.expiresLabel.textColor = [UIColor whiteColor];
        
        if (self.isNewAlert) {
            self.contentImageView.image = ZFImageWithName(@"live_coupon_small_bg");
        } else {
            self.contentImageView.image = ZFImageWithName(@"live_alert_coupon_bg");
        }
    } else if (couponModel.couponStats == 2) {
        self.invalidCouponIcon.hidden = NO;
        self.codeLabel.textColor = ZFC0xAAAAAA();
        self.expiresLabel.textColor = ZFC0xAAAAAA();
        invalidTitle = ZFLocalizedString(@"Detail_CouponClaimed", nil);
        
        if (self.isNewAlert) {
            self.contentImageView.image = ZFImageWithName(@"live_coupon_small_bggray");
        } else {
            self.contentImageView.image = ZFImageWithName(@"live_alert_coupon_bg_gray");
        }
    } else {
        self.invalidCouponIcon.hidden = NO;
        self.codeLabel.textColor = ZFC0xAAAAAA();
        self.expiresLabel.textColor = ZFC0xAAAAAA();
        invalidTitle = ZFLocalizedString(@"Detail_CouponUsedUp", nil);
        
        if (self.isNewAlert) {
            self.contentImageView.image = ZFImageWithName(@"live_coupon_small_bggray");
        } else {
            self.contentImageView.image = ZFImageWithName(@"live_alert_coupon_bg_gray");
        }
    }
    self.invalidText.text = invalidTitle;
}

- (UIImageView *)contentImageView {
    if (!_contentImageView) {
        _contentImageView = [[UIImageView alloc] initWithImage:ZFImageWithName(@"ve_alert_coupon_bg")];
        _contentImageView.backgroundColor = [UIColor clearColor];
    }
    return _contentImageView;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:ZFImageWithName(@"live_coupon_close") forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(actionClose:) forControlEvents:UIControlEventTouchUpInside];
        [_closeButton convertUIWithARLanguage];
    }
    return _closeButton;
}

- (UILabel *)codeLabel {
    if (!_codeLabel) {
        _codeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _codeLabel.textColor = ZFC0xFFFFFF();
        _codeLabel.font = [UIFont systemFontOfSize:15];
        _codeLabel.numberOfLines = 1;
    }
    return _codeLabel;
}

- (UILabel *)expiresLabel {
    if (!_expiresLabel) {
        _expiresLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _expiresLabel.textColor = ZFC0xFFFFFF();
        _expiresLabel.font = [UIFont systemFontOfSize:10];
        _expiresLabel.numberOfLines = 2;
    }
    return _expiresLabel;
}

- (UIButton *)receiveBtn {
    if (!_receiveBtn) {
        _receiveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_receiveBtn addTarget:self action:@selector(receiveAction:) forControlEvents:UIControlEventTouchUpInside];
        _receiveBtn.backgroundColor = ZFCOLOR_WHITE;
        [_receiveBtn setTitleColor:ZFC0xFF6E81() forState:UIControlStateNormal];
        _receiveBtn.titleLabel.font = ZFFontSystemSize(10);
        [_receiveBtn setTitle:ZFLocalizedString(@"Detail_ReceiveCouponTitle", nil) forState:UIControlStateNormal];
        [_receiveBtn setContentEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
        _receiveBtn.layer.cornerRadius = 10.0;

    }
    return _receiveBtn;
}

- (UIImageView *)invalidCouponIcon {
    if (!_invalidCouponIcon) {
        _invalidCouponIcon = [[UIImageView alloc] init];
        _invalidCouponIcon.image = ZFImageWithName(@"live_coupon_gray");
    }
    return _invalidCouponIcon;
}

-(UILabel *)invalidText {
    if (!_invalidText) {
        _invalidText = [[UILabel alloc] init];
        _invalidText.numberOfLines = 0;
        _invalidText.text = @"";
        _invalidText.textColor = ZFC0xAAAAAA();
        _invalidText.font = [UIFont systemFontOfSize:10];
        _invalidText.textAlignment = NSTextAlignmentCenter;
    }
    return _invalidText;
}
@end
