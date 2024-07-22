//
//  ZFGoodsDetailCouponCell.m
//  ZZZZZ
//
//  Created by YW on 2018/8/20.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFGoodsDetailCouponCell.h"
#import "ZFGoodsDetailCouponModel.h"
#import "UIImage+ZFExtended.h"
#import "ZFThemeManager.h"
#import "ZFProgressHUD.h"
#import "UIColor+ExTypeChange.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "Masonry.h"
#import "Constants.h"

@interface ZFGoodsDetailCouponCell()

@property (nonatomic, strong) UIButton *useitButton;

@end

@implementation ZFGoodsDetailCouponCell

- (void)zfInitView
{
    [super zfInitView];
    [self.contentBackView addSubview:self.useitButton];
}

-(void)zfAutoLayoutView
{
    [super zfAutoLayoutView];
    
    //使用label
    [self.useitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentImageView.mas_centerY);
        make.trailing.mas_equalTo(self.contentImageView.mas_trailing).mas_offset(-18);
        make.height.mas_offset(28);
    }];
    self.useitButton.layer.cornerRadius = 14;
    
    //问号标签
    [self.tipButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.codeLabel.mas_trailing).offset(5);
        make.centerY.mas_equalTo(self.codeLabel);
        make.width.height.mas_equalTo(22.0f);
    }];
}

#pragma mark -===========领劵事件===========

- (void)receiveBtnAction {
    if (self.receiveCouponBlock) {
        self.receiveCouponBlock(self.couponModel);
    }
}

- (void)tipButtonAction;
{
    ShowToastToViewWithText(nil, ZFLocalizedString(@"MyCoupon_Only_for_Standard_Shipping", nil));
}

#pragma mark - setter
- (void)setCouponModel:(ZFGoodsDetailCouponModel *)couponModel {
    _couponModel = couponModel;
    
    self.codeLabel.text = ZFToString(couponModel.preferentialHead);
    self.dateLabel.text = ZFToString(couponModel.endTime);
    self.expiresLabel.text = ZFToString(couponModel.discounts);

    self.useitButton.hidden = YES;
    self.selectedImageView.hidden = YES;
    self.tipButton.hidden = YES;
    self.invalidCouponIcon.hidden = YES;
    self.tagBtn.hidden = YES;
    
    NSString *invalidTitle = nil;
    
    //免邮优惠券
    if (couponModel.noMail) {
        self.codeLabel.text = ZFLocalizedString(@"MyCoupon_FREE_SHIPPING", nil);
        //显示一个问号
        self.tipButton.hidden = NO;
        UIImage *originImage = [UIImage imageNamed:@"order_coupon_tip"];
        if (couponModel.couponStats == 1) {
            UIImage *convertImage = [originImage imageWithColor:ZFCOLOR_WHITE];
            [self.tipButton setImage:convertImage forState:UIControlStateNormal];
        }else{
            UIImage *convertImage = [originImage imageWithColor:[UIColor grayColor]];
            [self.tipButton setImage:convertImage forState:UIControlStateNormal];
        }
    }
    
    // coupon状态；1:可领取;2:已领取;3:已领取完
    if (couponModel.couponStats == 1) {
        self.useitButton.hidden = NO;
        self.codeLabel.textColor = [UIColor whiteColor];
        self.expiresLabel.textColor = [UIColor colorWithHexString:@"999999"];
        self.dateLabel.textColor = [UIColor whiteColor];
        self.contentImageView.image = ZFImageWithName(@"detail_couponNormalBg");
    } else if (couponModel.couponStats == 2) {
        self.invalidCouponIcon.hidden = NO;
        self.codeLabel.textColor = [UIColor colorWithHexString:@"CCCCCC"];
        self.expiresLabel.textColor = [UIColor colorWithHexString:@"CCCCCC"];
        self.dateLabel.textColor = [UIColor colorWithHexString:@"CCCCCC"];
        invalidTitle = ZFLocalizedString(@"Detail_CouponClaimed", nil);
        self.contentImageView.image = ZFImageWithName(@"detail_couponNormalBg_disable");
    } else {
        self.invalidCouponIcon.hidden = NO;
        self.codeLabel.textColor = [UIColor colorWithHexString:@"CCCCCC"];
        self.expiresLabel.textColor = [UIColor colorWithHexString:@"CCCCCC"];
        self.dateLabel.textColor = [UIColor colorWithHexString:@"CCCCCC"];
        invalidTitle = ZFLocalizedString(@"Detail_CouponUsedUp", nil);
        self.contentImageView.image = ZFImageWithName(@"detail_couponNormalBg_disable");
    }
    self.invalidText.text = invalidTitle;
//    self.tipsImage.image = receiveBtnImage;
//    self.couponBgImageView.image = couponBgImage;
//    [self.receiveBtn setImage:receiveBtnImage forState:UIControlStateNormal];
//    [self.receiveBtn setTitle:receiveBtnTitle forState:UIControlStateNormal];
}

#pragma mark - getter

-(UIButton *)useitButton
{
    if (!_useitButton) {
        _useitButton = ({
            UIButton *button = [[UIButton alloc] init];
            [button addTarget:self action:@selector(receiveBtnAction) forControlEvents:UIControlEventTouchUpInside];
            button.backgroundColor = ZFCOLOR_WHITE;
            [button setTitleColor:[UIColor colorWithHexString:@"FF6E81"] forState:UIControlStateNormal];
            button.titleLabel.font = ZFFontSystemSize(14);
            [button setTitle:ZFLocalizedString(@"Detail_ReceiveCouponTitle", nil) forState:UIControlStateNormal];
            [button setContentEdgeInsets:UIEdgeInsetsMake(0, 18, 0, 18)];
            button;
        });
    }
    return _useitButton;
}

@end
