//
//  ZFCommunityLiveVideoCouponCCell.m
//  ZZZZZ
//
//  Created by YW on 2019/4/19.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityLiveVideoCouponCCell.h"

#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import <YYWebImage/YYWebImage.h>
#import "YWCFunctionTool.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFFrameDefiner.h"
#import "ZFLocalizationString.h"
#import "ExchangeManager.h"
#import "UIColor+ExTypeChange.h"


@interface ZFCommunityLiveVideoCouponCCell ()

///背景视图
@property (nonatomic, strong) UIView        *contentBackView;
///背景图片
@property (nonatomic, strong) UIImageView   *contentImageView;
///优惠金额或者优惠折扣label
@property (nonatomic, strong) UILabel       *codeLabel;
///时间label
@property (nonatomic, strong) UILabel       *dateLabel;
///优惠明细label
@property (nonatomic, strong) UILabel       *expiresLabel;
///标签button
@property (nonatomic, strong) UIButton      *receiveBtn;

///优惠券失效视图
@property (nonatomic, strong) UIImageView *invalidCouponIcon;
/////优惠券失效文字
@property (nonatomic, strong) UILabel *invalidText;
@end

@implementation ZFCommunityLiveVideoCouponCCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}


- (void)zfInitView {
    
    [self.contentView addSubview:self.contentBackView];
    [self.contentBackView addSubview:self.contentImageView];
    
    [self.contentImageView addSubview:self.invalidCouponIcon];
    [self.invalidCouponIcon addSubview:self.invalidText];
    
    [self.contentView addSubview:self.codeLabel];
    [self.contentView addSubview:self.dateLabel];
    [self.contentView addSubview:self.expiresLabel];
    
    [self.contentView addSubview:self.receiveBtn];

}

- (void)zfAutoLayoutView {
    
    [self.contentBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView);
        make.leading.mas_equalTo(self.contentView);
        make.trailing.mas_equalTo(self.contentView);
        make.bottom.mas_equalTo(self.contentView);
    }];
    
    [self.contentImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentBackView);
        make.bottom.mas_equalTo(self.contentBackView.mas_bottom);
        make.leading.mas_equalTo(self.contentBackView);
        make.trailing.mas_equalTo(self.contentBackView);
    }];
    
    
    CGFloat leftPadding = 18.0;
    //优惠券优惠金额
    [self.codeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentImageView.mas_top).offset(6.0);
        make.leading.mas_equalTo(self.contentImageView.mas_leading).offset(leftPadding);
    }];
    
    [self.receiveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.contentBackView.mas_trailing).mas_offset(-18);
        make.centerY.mas_equalTo(self.codeLabel.mas_centerY).offset(2);
        make.height.mas_offset(28);
    }];
    self.receiveBtn.layer.cornerRadius = 14;

    //优惠券到期时间
    [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.codeLabel.mas_bottom).offset(2);
        make.leading.mas_equalTo(self.codeLabel.mas_leading);
        make.trailing.mas_equalTo(self.contentBackView.mas_trailing);
    }];
    
    //优惠券明细
    [self.expiresLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.codeLabel.mas_leading);
        make.trailing.mas_equalTo(self.receiveBtn.mas_leading);
        make.bottom.mas_equalTo(self.contentBackView.mas_bottom).mas_offset(-10);
    }];
    
    [self.invalidCouponIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.contentImageView).mas_offset(-leftPadding);
        make.bottom.mas_equalTo(self.contentImageView.mas_bottom).mas_offset(12);
        make.width.height.mas_offset(72);
    }];
    
    [self.invalidText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.invalidCouponIcon);
        make.trailing.leading.mas_equalTo(self.invalidCouponIcon);
    }];
    
    
    [self.expiresLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [self.receiveBtn setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [self.receiveBtn setContentHuggingPriority:260 forAxis:UILayoutConstraintAxisHorizontal];
}

#pragma mark - action

- (void)receiveAction{
    if (self.receiveCouponBlock) {
        self.receiveCouponBlock(self.couponModel);
    }
}

#pragma mark - Property Method

#pragma mark - setter
- (void)setCouponModel:(ZFGoodsDetailCouponModel *)couponModel {
    _couponModel = couponModel;
    
    self.codeLabel.text = ZFToString(couponModel.preferentialHead);
    self.dateLabel.text = ZFToString(couponModel.endTime);
    self.expiresLabel.text = ZFToString(couponModel.discounts);
    self.receiveBtn.hidden = YES;

    self.invalidCouponIcon.hidden = YES;
    NSString *invalidTitle = nil;
    
    //免邮优惠券
    if (couponModel.noMail) {
        self.codeLabel.text = ZFLocalizedString(@"MyCoupon_FREE_SHIPPING", nil);
//        //显示一个问号
//        self.tipButton.hidden = NO;
//        UIImage *originImage = [UIImage imageNamed:@"order_coupon_tip"];
//        if (couponModel.couponStats == 1) {
//            UIImage *convertImage = [originImage imageWithColor:ZFCOLOR_WHITE];
//            [self.tipButton setImage:convertImage forState:UIControlStateNormal];
//        }else{
//            UIImage *convertImage = [originImage imageWithColor:[UIColor grayColor]];
//            [self.tipButton setImage:convertImage forState:UIControlStateNormal];
//        }
    }
    
    // coupon状态；1:可领取;2:已领取;3:已领取完
    if (couponModel.couponStats == 1) {
        self.receiveBtn.hidden = NO;
        self.codeLabel.textColor = [UIColor whiteColor];
        self.expiresLabel.textColor = [UIColor whiteColor];
        self.dateLabel.textColor = [UIColor whiteColor];
        self.contentImageView.image = ZFImageWithName(@"video_couponNormalBg");
    } else {
        self.invalidCouponIcon.hidden = NO;
        self.codeLabel.textColor = ZFC0xAAAAAA();
        self.expiresLabel.textColor = ZFC0xAAAAAA();
        self.dateLabel.textColor = ZFC0xAAAAAA();
        self.contentImageView.image = ZFImageWithName(@"video_couponNormalBg_disable");

        if (couponModel.couponStats == 2) {
            invalidTitle = ZFLocalizedString(@"Detail_CouponClaimed", nil);
        } else if (couponModel.couponStats == 4) {
            invalidTitle = ZFLocalizedString(@"MyCoupon_Coupon_Expired", nil);
        } else {
            invalidTitle = ZFLocalizedString(@"Detail_CouponUsedUp", nil);
        }
    }
    self.invalidText.text = invalidTitle;
}


-(UIView *)contentBackView
{
    if (!_contentBackView) {
        _contentBackView = ({
            UIView *view = [[UIView alloc] init];
            view.backgroundColor = [UIColor whiteColor];
            view;
        });
    }
    return _contentBackView;
}

- (UIImageView *)contentImageView {
    if (!_contentImageView) {
        _contentImageView                 = [[UIImageView alloc] init];
        _contentImageView.backgroundColor = [UIColor clearColor];
        _contentImageView.userInteractionEnabled = YES;
    }
    return _contentImageView;
}

- (UILabel *)codeLabel {
    if (!_codeLabel) {
        _codeLabel = [[UILabel alloc] init];
        _codeLabel.textColor = [UIColor whiteColor];
        _codeLabel.font = [UIFont boldSystemFontOfSize:22.0];
    }
    return _codeLabel;
}

- (UILabel *)dateLabel {
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc] init];
        _dateLabel.textColor = [UIColor whiteColor];
        _dateLabel.font = [UIFont systemFontOfSize:11.0];
    }
    return _dateLabel;
}

- (UILabel *)expiresLabel {
    if (!_expiresLabel) {
        _expiresLabel = [[UILabel alloc] init];
        _expiresLabel.textColor = ZFC0xAAAAAA();
        _expiresLabel.font = [UIFont systemFontOfSize:14.0];
        _expiresLabel.numberOfLines = 2;
    }
    return _expiresLabel;
}

- (UIImageView *)invalidCouponIcon
{
    if (!_invalidCouponIcon) {
        _invalidCouponIcon = ({
            UIImageView *img = [[UIImageView alloc] init];
            img.image = ZFImageWithName(@"Coupon_tag");
            img;
        });
    }
    return _invalidCouponIcon;
}

-(UILabel *)invalidText
{
    if (!_invalidText) {
        _invalidText = ({
            UILabel *label = [[UILabel alloc] init];
            label.numberOfLines = 0;
            label.text = @"";
            label.textColor = ZFC0xAAAAAA();
            label.font = [UIFont systemFontOfSize:12];
            label.textAlignment = NSTextAlignmentCenter;
            label;
        });
    }
    return _invalidText;
}

- (UIButton *)receiveBtn {
    if (!_receiveBtn) {
        _receiveBtn = ({
            UIButton *button = [[UIButton alloc] init];
            [button addTarget:self action:@selector(receiveAction) forControlEvents:UIControlEventTouchUpInside];
            button.backgroundColor = ZFCOLOR_WHITE;
            [button setTitleColor:ZFC0xFF6E81() forState:UIControlStateNormal];
            button.titleLabel.font = ZFFontSystemSize(14);
            [button setTitle:ZFLocalizedString(@"Detail_ReceiveCouponTitle", nil) forState:UIControlStateNormal];
            [button setContentEdgeInsets:UIEdgeInsetsMake(0, 18, 0, 18)];
            button;
        });
    }
    return _receiveBtn;
}

@end
