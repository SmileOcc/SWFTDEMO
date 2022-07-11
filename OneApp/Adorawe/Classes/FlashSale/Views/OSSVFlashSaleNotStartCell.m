//
//  OSSVFlashSaleNotStartCell.m
// XStarlinkProject
//
//  Created by odd on 2020/11/12.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVFlashSaleNotStartCell.h"
#import <JHChainableAnimations/JHChainableAnimations.h>


@interface OSSVFlashSaleNotStartCell ()
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic,weak) UILabel *animateLbl;
@property (nonatomic, strong) UIView *cellBgView;

@end

@implementation OSSVFlashSaleNotStartCell

-(void)setAnimateStrValue:(NSString *)animateStrValue{
    _animateStrValue = animateStrValue;
    _animateLbl.text = animateStrValue;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.cellBgView];
        [self.cellBgView addSubview:self.productImgView];
        [self.cellBgView addSubview:self.titleLabel];
        [self.cellBgView addSubview:self.priceLabel];
        [self.cellBgView addSubview:self.oldPirceLabel];
        [self.cellBgView addSubview:self.progressView];
        [self.progressView addSubview:self.progressLabel];
        [self.productImgView addSubview:self.activityStateView];
        
        UILabel *animateLbl = [UILabel new];
        animateLbl.text = @"+1";
        animateLbl.textColor = OSSVThemesColors.col_B62B21;
        animateLbl.alpha = 0;
        [self.contentView addSubview:animateLbl];
        _animateLbl = animateLbl;

        [self.cellBgView addSubview:self.collectButton];
        [self.cellBgView addSubview:self.userCountLabel];
        [self.cellBgView addSubview:self.lineView];

        
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
//    if (!_activityStateView.isHidden && _activityStateView.size.height > 0) {
//
////        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
////            [self.activityStateView.activityVerticalView stlAddCorners:UIRectCornerBottomLeft cornerRadii:CGSizeMake(4, 4)];
////        } else {
////            [self.activityStateView.activityVerticalView stlAddCorners:UIRectCornerBottomRight cornerRadii:CGSizeMake(4, 4)];
////        }
//    }
}

- (UIView *)cellBgView {
    if (!_cellBgView) {
        _cellBgView = [UIView new];
        _cellBgView.backgroundColor = [UIColor whiteColor];
    }
    return _cellBgView;
}

- (OSSVDetailsHeaderActivityStateView *)activityStateView {
    if (!_activityStateView) {
        _activityStateView = [[OSSVDetailsHeaderActivityStateView alloc] initWithFrame:CGRectZero showDirect:STLActivityDirectStyleNormal];
//        _activityStateView.samllImageShow = YES;
//        _activityStateView.flashImageSize = 12;
        _activityStateView.hidden = YES;
    }
    return _activityStateView;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [UIView new];
        _lineView.backgroundColor = OSSVThemesColors.col_EEEEEE;
    }
    return _lineView;
}

- (YYAnimatedImageView *)productImgView {
    if (!_productImgView) {
        _productImgView = [YYAnimatedImageView new];
        _productImgView.contentMode = UIViewContentModeScaleAspectFill;
        _productImgView.clipsToBounds = YES;
        _productImgView.layer.borderColor = OSSVThemesColors.col_EEEEEE.CGColor;
        _productImgView.layer.borderWidth = 1.f;
        _productImgView.layer.masksToBounds = YES;
        _productImgView.backgroundColor = [UIColor clearColor];
    }
    return _productImgView;
}



- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont systemFontOfSize:11];
        _titleLabel.numberOfLines = 2;
        _titleLabel.textColor = [OSSVThemesColors col_6C6C6C];
    }
    return _titleLabel;
}

- (UILabel *)priceLabel {
    if (!_priceLabel) {
        _priceLabel = [UILabel new];
        _priceLabel.textColor = OSSVThemesColors.col_B62B21;
        _priceLabel.font = [UIFont boldSystemFontOfSize:16];
    }
    return _priceLabel;
}

- (UILabel *)oldPirceLabel {
    if (!_oldPirceLabel) {
        _oldPirceLabel = [UILabel new];
        _oldPirceLabel.font = [UIFont systemFontOfSize:10];
        _oldPirceLabel.textColor = [OSSVThemesColors col_6C6C6C];
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:_oldPirceLabel.text];
        
        [attStr addAttributes:@{NSForegroundColorAttributeName:[OSSVThemesColors col_6C6C6C],
                                NSFontAttributeName:[UIFont systemFontOfSize:10],
                                NSStrikethroughStyleAttributeName:[NSNumber numberWithInteger:NSUnderlineStyleSingle],
                                NSBaselineOffsetAttributeName:@(NSUnderlineStyleSingle)
        } range:NSMakeRange(0, _oldPirceLabel.text.length)];

        _oldPirceLabel.attributedText = attStr;
    }
    return _oldPirceLabel;
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
        _progressView.backgroundColor = [OSSVThemesColors col_EEEEEE];
    }
    return _progressView;
}

- (UIButton *)collectButton {
    if (!_collectButton) {
        _collectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _collectButton.backgroundColor = OSSVThemesColors.col_0D0D0D;
        _collectButton.layer.cornerRadius = 2.f;
        _collectButton.layer.masksToBounds = YES;
        [_collectButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_collectButton setTitleColor:OSSVThemesColors.col_0D0D0D forState:UIControlStateSelected];
        if (APP_TYPE == 3) {
            [_collectButton setTitle:STLLocalizedString_(@"cancel",nil) forState:UIControlStateSelected];
            [_collectButton setTitle:STLLocalizedString_(@"Remind_Me",nil) forState:UIControlStateNormal];

        } else {
            [_collectButton setTitle:[STLLocalizedString_(@"Remind_Me",nil) uppercaseString] forState:UIControlStateNormal];
            [_collectButton setTitle:[STLLocalizedString_(@"cancel",nil) uppercaseString] forState:UIControlStateSelected];
        }
        
        [_collectButton addTarget:self action:@selector(collectionGood:) forControlEvents:UIControlEventTouchUpInside];
        _collectButton.backgroundColor = _collectButton.selected ? UIColor.whiteColor : OSSVThemesColors.col_0D0D0D;
        _collectButton.titleLabel.font = [UIFont boldSystemFontOfSize:11];
        
        _collectButton.layer.borderWidth = 1;
        _collectButton.layer.borderColor = OSSVThemesColors.col_EEEEEE.CGColor;
    }
    return _collectButton;
}

- (UILabel *)userCountLabel {
    if (!_userCountLabel) {
        _userCountLabel = [UILabel new];
        _userCountLabel.font = [UIFont systemFontOfSize:10];
        _userCountLabel.textColor = OSSVThemesColors.col_6C6C6C;
        _userCountLabel.textAlignment = NSTextAlignmentRight;
    }
    return _userCountLabel;
}

- (UILabel *)progressLabel {
    if (!_progressLabel) {
        _progressLabel = [UILabel new];
        _progressLabel.textColor = OSSVThemesColors.col_0D0D0D;
        _progressLabel.font = [UIFont systemFontOfSize:10];
    }
    return _progressLabel;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.cellBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(12);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
        make.top.mas_equalTo(self.contentView.mas_top);
        make.bottom.mas_equalTo(self.contentView.mas_bottom);
    }];

    [self.productImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.cellBgView.mas_leading).offset(12);
        make.top.mas_equalTo(self.cellBgView.mas_top).offset(12);
        make.bottom.mas_equalTo(self.cellBgView.mas_bottom).offset(-12);
        make.width.mas_equalTo(@(90*kScale_375));
//        make.height.mas_equalTo(@(120*kScale_375));
    }];
    
    [self.activityStateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.productImgView.mas_leading);
        make.top.mas_equalTo(self.productImgView.mas_top);
    }];

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.productImgView.mas_trailing).offset(8);
        make.top.mas_equalTo(self.productImgView.mas_top);
        make.trailing.mas_equalTo(self.cellBgView.mas_trailing).offset(-12);
    }];
    
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.titleLabel.mas_leading);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(8);
        make.height.mas_equalTo(@16);
        make.width.mas_equalTo(@(149*kScale_375));
    }];
    [self.progressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.progressView.mas_leading).offset(8);
        make.centerY.mas_equalTo(self.progressView.centerY);
    }];


    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.titleLabel.mas_leading);
        make.bottom.mas_equalTo(self.productImgView.mas_bottom);
        make.height.mas_equalTo(@20);
    }];
    
    [self.oldPirceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.priceLabel.mas_leading);
        make.bottom.mas_equalTo(self.priceLabel.mas_top).offset(-3);
        make.height.mas_equalTo(@13);
    }];
    
    [self.collectButton  mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.cellBgView.mas_trailing).offset(-8);
        make.bottom.mas_equalTo(self.priceLabel.mas_bottom);
        make.height.mas_equalTo(@24);
        make.width.mas_equalTo(@(80*kScale_375));
    }];

    

    [self.userCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
//        make.top.mas_equalTo(self.progressView.mas_top);
        make.height.mas_equalTo(13);
        make.trailing.mas_equalTo(self.collectButton.mas_trailing);
        make.bottom.mas_equalTo(self.collectButton.mas_top).offset(-8);
    }];
    
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.cellBgView.mas_leading).offset(12);
        make.trailing.mas_equalTo(self.cellBgView.mas_trailing).offset(-12);
        make.bottom.mas_equalTo(self.cellBgView.mas_bottom);
        make.height.mas_equalTo(@0.5);
    }];
    
    [self.animateLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.cellBgView.mas_centerX);
        make.centerY.mas_equalTo(self.cellBgView.mas_centerY);
    }];

}

-(void)collectionGood:(UIButton *)sender {
    ///不收藏 添加日历事件1.3.8闪购优化
    if (_delegate && [_delegate respondsToSelector:@selector(userAddReminder:sender:cell:)]) {
        [_delegate userAddReminder:self.model sender:sender cell:self];
    }
}

-(void)playAddAnimation{
    JHChainableAnimator *animator = [[JHChainableAnimator alloc] initWithView:self.animateLbl];
    self.animateLbl.alpha = 1.0;
    animator.moveY(-80).easeOut.makeOpacity(0.0).postAnimationBlock(^{
        self.animateLbl.alpha = 0;
        self.animateLbl.center = CGPointMake(self.animateLbl.center.x, self.animateLbl.center.y + 80);
    })
    .animate(0.5);
}

-(void)updateFollowCount{
    NSInteger count = STLToString(_model.followNum).integerValue;
    if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
        if (count > 999) {
            self.userCountLabel.text = [NSString stringWithFormat:@"999+ %@", STLLocalizedString_(@"Users_Follow", nil)];
        } else {
            self.userCountLabel.text = [NSString stringWithFormat:@"%@ %@",STLToString(_model.followNum),STLLocalizedString_(@"Users_Follow", nil)];
        }
    } else {
        if (count > 999) {
            self.userCountLabel.text = [NSString stringWithFormat:@"999+ %@",STLLocalizedString_(@"Users_Follow", nil)];
        } else {
            self.userCountLabel.text = [NSString stringWithFormat:@"%@ %@",STLToString(_model.followNum),STLLocalizedString_(@"Users_Follow", nil)];
        }
    }
}
@end
