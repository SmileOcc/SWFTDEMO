//
//  ZFCouponBaseTableViewCell.m
//  ZZZZZ
//
//  Created by YW on 2018/9/10.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFCouponBaseTableViewCell.h"
#import "UIColor+ExTypeChange.h"
#import "SystemConfigUtils.h"
#import "YWCFunctionTool.h"
#import "Masonry.h"
#import "ZFThemeManager.h"
#import "ZFFrameDefiner.h"

@interface ZFCouponBaseTableViewCell()

@end

@implementation ZFCouponBaseTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = ZFCOLOR_WHITE;
        [self zfInitView];
        [self zfAutoLayoutView];
        
        [self setBoardShadowTabCell];
    }
    return self;
}

//对self做投影
- (void)setBoardShadowTabCell {
    self.contentBackView.layer.shadowColor = ZFCOLOR(51, 51, 51, .5).CGColor;//阴影颜色
    self.contentBackView.layer.shadowOpacity = 0.2;//不透明度
    self.contentBackView.layer.shadowRadius = 3.0;//半径
    self.contentBackView.layer.shadowOffset = CGSizeMake(0, 0);//偏移距离
    self.contentBackView.layer.masksToBounds = NO; //裁剪
    self.contentBackView.layer.shouldRasterize = YES;//设置缓存 仅复用时设置此选项
    self.contentBackView.layer.rasterizationScale = KScale;//设置对应比例，防止cell出现模糊和锯齿
}

#pragma mark - ZFInitViewProtoclo
- (void)zfInitView {
    [self.contentView addSubview:self.contentBackView];
    
    [self.contentBackView addSubview:self.contentImageView];
    
    [self.contentImageView addSubview:self.codeLabel];
    [self.contentImageView addSubview:self.dateLabel];
    [self.contentImageView addSubview:self.selectedImageView];
    [self.contentImageView addSubview:self.tipButton];
    
    [self.contentImageView addSubview:self.invalidCouponIcon];
    [self.invalidCouponIcon addSubview:self.invalidText];
    
    [self.contentBackView addSubview:self.tagBtn];
    [self.contentBackView addSubview:self.expiresLabel];
    self.contentBackView.layer.cornerRadius = 5;
}

- (void)zfAutoLayoutView {
    [self.contentBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(10);
        make.leading.mas_equalTo(self.contentView).offset(16);
        make.trailing.mas_equalTo(self.contentView).offset(-16);
        make.bottom.mas_equalTo(self.contentView).offset(-2);
    }];
    
    [self.contentImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentBackView);
        make.leading.mas_equalTo(self.contentBackView);
        make.trailing.mas_equalTo(self.contentBackView);
    }];
    
    CGFloat leftPadding = 18.0;
    //优惠券优惠金额
    [self.codeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentImageView.mas_top).offset(10.0);
        make.leading.mas_equalTo(self.contentImageView.mas_leading).offset(leftPadding);
    }];
    
    //优惠券到期时间
    [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.codeLabel.mas_bottom).offset(5);
        make.leading.mas_equalTo(self.codeLabel.mas_leading);
        make.trailing.mas_equalTo(self.contentImageView.mas_trailing);
    }];
    
    //优惠券明细
    [self.expiresLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentImageView.mas_bottom).mas_offset(6);
        make.leading.mas_equalTo(self.codeLabel.mas_leading);
        make.trailing.mas_equalTo(self.tagBtn.mas_leading);
        make.bottom.mas_equalTo(self.contentBackView.mas_bottom).mas_offset(-6);
    }];
    
    [self.invalidCouponIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.contentImageView);
        make.bottom.mas_equalTo(self.contentImageView.mas_bottom).mas_offset(12);
        make.width.height.mas_offset(72);
    }];
    
    [self.invalidText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.invalidCouponIcon);
        make.trailing.leading.mas_equalTo(self.invalidCouponIcon);
    }];
    
    //展开明细arrow
    [self.tagBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.contentImageView.mas_trailing).offset(-10.0f);
        make.width.height.mas_offset(20);
        make.top.mas_equalTo(self.contentImageView.mas_bottom).mas_offset(3);
    }];
    
    //选择图片
    [self.selectedImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentImageView.mas_top).mas_offset(10);
        make.trailing.mas_equalTo(self.contentImageView.mas_trailing).mas_offset(-10);
        make.width.height.mas_equalTo(20.0f).priorityHigh();
    }];

    //问号提示按钮
    [self.tipButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentBackView).mas_offset(16);
        make.trailing.mas_equalTo(self.contentBackView.mas_trailing).offset(-10);
        make.width.height.mas_equalTo(22.0f);
    }];
}

#pragma mark - event
- (void)tipButtonAction {}

- (void)tagBtnAction {}

- (void)showAll {
    [UIView animateWithDuration:0.25 animations:^{
        CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI);
        [self.tagBtn.imageView setTransform:transform];
    }];
}

- (void)hiddenAll {
    [UIView animateWithDuration:0.25 animations:^{
        CGAffineTransform transform = CGAffineTransformIdentity;
        [self.tagBtn.imageView setTransform:transform];
    }];
}

#pragma mark - setter/getter
-(UIView *)contentBackView {
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
        _contentImageView = [[UIImageView alloc] init];
        _contentImageView.backgroundColor = [UIColor clearColor];
        _contentImageView.userInteractionEnabled = YES;
    }
    return _contentImageView;
}

- (UILabel *)codeLabel {
    if (!_codeLabel) {
        _codeLabel = [[UILabel alloc] init];
        _codeLabel.textColor = [UIColor whiteColor];
        _codeLabel.font = [UIFont boldSystemFontOfSize:18.0];
    }
    return _codeLabel;
}

- (UILabel *)dateLabel {
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc] init];
        _dateLabel.textColor = [UIColor whiteColor];
        _dateLabel.font = [UIFont systemFontOfSize:12.0];
    }
    return _dateLabel;
}

- (UILabel *)expiresLabel {
    if (!_expiresLabel) {
        _expiresLabel = [[UILabel alloc] init];
        _expiresLabel.textColor = [UIColor colorWithHexString:@"999999"];
        _expiresLabel.font = [UIFont systemFontOfSize:12.0];
        _expiresLabel.numberOfLines = 0;
    }
    return _expiresLabel;
}

- (UIImageView *)selectedImageView {
    if (!_selectedImageView) {
        _selectedImageView = [[UIImageView alloc] init];
        _selectedImageView.backgroundColor = [UIColor clearColor];
        NSString *imageName = @"order_coupon_unchoosed";
        if ([SystemConfigUtils isRightToLeftShow]) {
//            imageName = @"order_coupon_choosed_ar";
        }
        _selectedImageView.image = [UIImage imageNamed:imageName];
    }
    return _selectedImageView;
}

- (UIButton *)tagBtn {
    if (!_tagBtn) {
        _tagBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _tagBtn.backgroundColor = [UIColor clearColor];
        [_tagBtn setImage:[UIImage imageNamed:@"down_arrow"] forState:UIControlStateNormal];
        [_tagBtn addTarget:self action:@selector(tagBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _tagBtn;
}

- (UIButton *)tipButton {
    if (!_tipButton) {
        _tipButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_tipButton setImage:[UIImage imageNamed:@"order_coupon_tip"] forState:UIControlStateNormal];
        [_tipButton addTarget:self action:@selector(tipButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _tipButton;
}

- (UIImageView *)invalidCouponIcon {
    if (!_invalidCouponIcon) {
        _invalidCouponIcon = ({
            UIImageView *img = [[UIImageView alloc] init];
            img.image = ZFImageWithName(@"Coupon_tag");
            img;
        });
    }
    return _invalidCouponIcon;
}

-(UILabel *)invalidText {
    if (!_invalidText) {
        _invalidText = ({
            UILabel *label = [[UILabel alloc] init];
            label.numberOfLines = 0;
            label.text = @"";
            label.textColor = [UIColor colorWithHexString:@"CCCCCC"];
            label.font = [UIFont systemFontOfSize:12];
            label.textAlignment = NSTextAlignmentCenter;
            label;
        });
    }
    return _invalidText;
}

@end
