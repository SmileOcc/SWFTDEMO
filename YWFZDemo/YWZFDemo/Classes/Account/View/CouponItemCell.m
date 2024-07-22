//
//  CouponItemCell.m
//  ZZZZZ
//
//  Created by YW on 2017/6/12.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "CouponItemCell.h"
#import "CouponItemModel.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "UIColor+ExTypeChange.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "Masonry.h"
#import "Constants.h"

@interface CouponItemCell ()

@property (nonatomic, strong) UIButton *useitButton;

@end

@implementation CouponItemCell

#pragma mark - interface methods
+ (CouponItemCell *)couponItemCellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    //注册cell
    [tableView registerClass:[CouponItemCell class] forCellReuseIdentifier:NSStringFromClass([self class])];
    return [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([self class]) forIndexPath:indexPath];
}

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
}

#pragma mark - event
- (void)userItAction {
    if (self.userItActionHandle) {
        self.userItActionHandle();
    }
}

- (void)tagBtnAction {
    if (self.tagBtnActionHandle) {
        self.tagBtnActionHandle();
        self.tagBtn.selected = !self.tagBtn.selected;
        if (self.tagBtn.isSelected) {
            [self showAll];
        } else {
            [self hiddenAll];
        }
    }
}

#pragma mark - setter
-(void)setCouponModel:(CouponItemModel *)couponModel {
    _couponModel = couponModel;
    self.codeLabel.text      = couponModel.preferential_head;
    self.dateLabel.text      = couponModel.exp_time;
    self.invalidCouponIcon.hidden = YES;
    NSMutableString *youHuiString = [[NSMutableString alloc] initWithString:couponModel.youhui];
    if (couponModel.no_mail) {
        ///免邮优惠券
        [youHuiString appendFormat:@",%@", ZFLocalizedString(@"MyCoupon_Only_for_Standard_Shipping", nil)];
        self.codeLabel.text = ZFLocalizedString(@"MyCoupon_FREE_SHIPPING", nil);
    }
    NSArray *youhuiArray = [youHuiString componentsSeparatedByString:@","];
    if (couponModel.isShowAll && youhuiArray.count > 1) {
        [youHuiString replaceOccurrencesOfString:@"," withString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, youHuiString.length)];
        self.expiresLabel.text   = youHuiString;
        [self showAll];
    } else {
        self.expiresLabel.text   = couponModel.preferential_first;
        [self hiddenAll];
    }
    
    NSString *invalidTitle = nil;
    
    self.selectedImageView.hidden = YES;
    self.tipButton.hidden       = YES;
    self.tagBtn.hidden          = YES;
    self.useitButton.hidden      = YES;
    switch (self.couponType) {
        case CouponUsed: {
            self.invalidCouponIcon.hidden = NO;
            invalidTitle = ZFLocalizedString(@"Detail_CouponUsedUp", nil);
            self.codeLabel.textColor    = [UIColor colorWithHexString:@"CCCCCC"];
            self.dateLabel.textColor    = self.codeLabel.textColor;
            self.expiresLabel.textColor = self.codeLabel.textColor;
            self.contentImageView.image = ZFImageWithName(@"detail_couponNormalBg_disable");
            break;
        }
        case CouponExpired: {
            self.invalidCouponIcon.hidden = NO;
            self.codeLabel.textColor    = [UIColor colorWithHexString:@"CCCCCC"];
            self.dateLabel.textColor    = self.codeLabel.textColor;
            self.expiresLabel.textColor = self.codeLabel.textColor;
            self.contentImageView.image = ZFImageWithName(@"detail_couponNormalBg_disable");
            invalidTitle = ZFLocalizedString(@"Detail_CouponClaimed", nil);
            break;
        }
        case CouponUnused: {
            self.tagBtn.hidden        = youhuiArray.count < 2;
            self.useitButton.hidden    = NO;
            self.codeLabel.textColor = [UIColor whiteColor];
            self.dateLabel.textColor = [UIColor whiteColor];
            self.expiresLabel.textColor = [UIColor colorWithHexString:@"999999"];
            self.contentImageView.image = ZFImageWithName(@"detail_couponNormalBg");
            break;
        }
        default:
            break;
    }
    self.invalidText.text = invalidTitle;
}

- (void)receiveBtnAction
{
    if (self.userItActionHandle) {
        self.userItActionHandle();
    }
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
            [button setTitle:ZFLocalizedString(@"My_Coupon_UserIt", nil) forState:UIControlStateNormal];
            [button setContentEdgeInsets:UIEdgeInsetsMake(0, 18, 0, 18)];
            button;
        });
    }
    return _useitButton;
}

@end
