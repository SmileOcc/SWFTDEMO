//
//  ZFMyCouponTableViewCell.m
//  ZZZZZ
//
//  Created by YW on 2017/12/1.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFMyCouponTableViewCell.h"
#import "ZFMyCouponModel.h"
#import "ZFCouponTipView.h"
#import "ZFProgressHUD.h"
#import "UIColor+ExTypeChange.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "Constants.h"

@interface ZFMyCouponTableViewCell() {
    ZFMyCouponModel *_couponModel;
}
@end

@implementation ZFMyCouponTableViewCell

+ (ZFMyCouponTableViewCell *)couponItemCellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    //注册cell
    [tableView registerClass:[ZFMyCouponTableViewCell class] forCellReuseIdentifier:NSStringFromClass([self class])];
    return [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([self class]) forIndexPath:indexPath];
}

-(void)zfAutoLayoutView {
    [super zfAutoLayoutView];
}

- (void)configWithModel:(ZFMyCouponModel *)model {
    _couponModel = model;
    self.codeLabel.text = model.preferential_head;
    self.dateLabel.text = model.exp_time;
    self.expiresLabel.text = model.preferential_first;
    self.invalidCouponIcon.hidden = YES;
    NSMutableString *youHuiString = [[NSMutableString alloc] initWithString:model.preferential_all];
    
    if (model.no_mail) {
        ///免邮优惠券
        [youHuiString appendFormat:@",%@", ZFLocalizedString(@"MyCoupon_Only_for_Standard_Shipping", nil)];
        self.codeLabel.text = ZFLocalizedString(@"MyCoupon_FREE_SHIPPING", nil);
    }
    
    NSArray *youhuiArray = [youHuiString componentsSeparatedByString:@","];
    if (model.isShowAll && youhuiArray.count > 1) {
        [youHuiString replaceOccurrencesOfString:@"," withString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, youHuiString.length)];
        self.expiresLabel.text   = youHuiString;
        [self showAll];
    } else {
        self.expiresLabel.text   = model.preferential_first;
        [self hiddenAll];
    }
        
    switch (self.couponType) {
        case CouponAvailable: {
            self.tagBtn.hidden            = youhuiArray.count < 2;
            self.codeLabel.textColor      = [UIColor whiteColor];
            self.expiresLabel.textColor   = [UIColor colorWithHexString:@"999999"];
            self.dateLabel.textColor      = [UIColor whiteColor];
            self.tipButton.hidden         = YES;
            self.contentImageView.image   = ZFImageWithName(@"detail_couponNormalBg");
            
            NSString *imageName = model.isSelected ? @"order_coupon_choosed" : @"order_coupon_unchoosed";
            self.selectedImageView.image  = [UIImage imageNamed:imageName];
            self.selectedImageView.hidden = NO;
            break;
        }
            
        case CouponDisabled: {
            self.invalidCouponIcon.hidden = YES;
            self.invalidText.text         = ZFLocalizedString(@"Detail_CouponUsedUp", nil);
            self.tagBtn.hidden            = youhuiArray.count < 2;
            self.codeLabel.textColor      = [UIColor colorWithHexString:@"CCCCCC"];
            self.expiresLabel.textColor   = self.codeLabel.textColor;
            self.dateLabel.textColor      = self.codeLabel.textColor;
            self.tipButton.hidden         = NO;
            self.selectedImageView.hidden = YES;
            self.contentImageView.image   = ZFImageWithName(@"detail_couponNormalBg_disable");
            break;
        }
        default:
            break;
    }
}

#pragma mark - event
- (void)tipButtonAction {
    if (_couponModel.pcode_msg.length > 0) {
        self.tipButton.selected = !self.tipButton.selected;
        ShowToastToViewWithText(nil, _couponModel.pcode_msg);
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

@end
