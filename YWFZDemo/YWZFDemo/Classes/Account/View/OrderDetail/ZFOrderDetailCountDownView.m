//
//  ZFOrderDetailCountDownView.m
//  ZZZZZ
//
//  Created by YW on 2018/11/22.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import "ZFOrderDetailCountDownView.h"
#import "ZFBannerTimeView.h"
#import "ZFTimerManager.h"
#import "ZFLocalizationString.h"
#import "SystemConfigUtils.h"
#import "YWCFunctionTool.h"
#import "Masonry.h"
#import "ZFCountDownView.h"

@interface ZFOrderDetailCountDownView ()

//图标
@property (nonatomic, strong) UIImageView *iconImage;
//文字
@property (nonatomic, strong) UILabel *countDownLabel;
//倒计时
@property (nonatomic, strong) ZFCountDownView *countDownView;
//背景图片
@property (nonatomic, strong) UIImageView *backgroundImage;
//浮动箭头
@property (nonatomic, strong) UIImageView *floatImage;
@end

@implementation ZFOrderDetailCountDownView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.backgroundImage];
        [self addSubview:self.iconImage];
        [self addSubview:self.countDownLabel];
        [self addSubview:self.countDownView];
        [self addSubview:self.floatImage];
        self.backgroundColor = [UIColor clearColor];
        [self mas_layoutSubviews];
    }
    return self;
}

- (void)mas_layoutSubviews
{
    [self.iconImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.leading.mas_equalTo(self.mas_leading).mas_offset(7);
        make.size.mas_equalTo(CGSizeMake(18, 18));
    }];
    
    CGFloat leftPadding = -12;
    if ([SystemConfigUtils isRightToLeftShow]) {
        leftPadding = 6;
    }
    [self.countDownLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.iconImage.mas_trailing).mas_offset(5);
        make.centerY.mas_equalTo(self.iconImage);
//        make.trailing.mas_equalTo(self.mas_trailing).mas_offset(leftPadding);
    }];
    
    [self.countDownView mas_makeConstraints:^(MASConstraintMaker *make) {
        //因为里面一个控件有8的间距，所以-10，靠近一点
        CGFloat padding = 6;
        CGFloat leftPadding = -12;
        make.leading.mas_equalTo(self.countDownLabel.mas_trailing).mas_offset(padding);
        make.centerY.mas_equalTo(self.iconImage);
        make.trailing.mas_equalTo(self.mas_trailing).mas_offset(leftPadding);
    }];
   
    [self.backgroundImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
}

- (void)showCountTimePositionView:(UIView *)view countDownKey:(nonnull NSString *)key
{
    if (!view) {
        return;
    }
    UIView *superView = view.superview;
    if (!superView) {
        return;
    }
    superView.clipsToBounds = NO;
    [superView addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(view.superview.mas_top);
        make.trailing.mas_equalTo(superView.mas_trailing).mas_offset(-12);
        make.height.mas_offset(32);
    }];
    [self.countDownView startTimerWithStamp:self.countDownTime timerKey:key];
    [self.floatImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.backgroundImage.mas_bottom);
        make.centerX.mas_equalTo(view.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(16, 8));
    }];
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)stopCountTime:(NSString *)key
{
    [[ZFTimerManager shareInstance] stopTimer:key];
    [self removeFromSuperview];
}

- (NSString *)countDownKey:(NSString *)customId
{
    return [NSString stringWithFormat:@"%@%@", kZFCountDownKey, ZFToString(customId)];
}

#pragma mark - setter

- (UIImageView *)iconImage
{
    if (!_iconImage) {
        _iconImage = ({
            UIImageView *img = [[UIImageView alloc] init];
            img.image = ZFImageWithName(@"clock_white");
            img;
        });
    }
    return _iconImage;
}

- (UIImageView *)backgroundImage
{
    if (!_backgroundImage) {
        _backgroundImage = ({
            UIImageView *img = [[UIImageView alloc] init];
            UIImage *oldImage = ZFImageWithName(@"orderDetailbubbo");
            CGFloat left = oldImage.size.width / 2;
            CGFloat top = oldImage.size.height / 2;
            UIImage *newImage = [oldImage stretchableImageWithLeftCapWidth:left - oldImage.leftCapWidth - 10 topCapHeight:top - oldImage.topCapHeight];
            img.image = newImage;
            img;
        });
    }
    return _backgroundImage;
}

-(UILabel *)countDownLabel
{
    if (!_countDownLabel) {
        _countDownLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.numberOfLines = 0;
            NSString *text = [NSString stringWithFormat:@"%@", ZFLocalizedString(@"OrderDetail_CancelOrderTips", nil)];
            label.text = text;
            label.textColor = [UIColor whiteColor];
            label.font = [UIFont systemFontOfSize:14];
            label;
        });
    }
    return _countDownLabel;
}

-(ZFCountDownView *)countDownView
{
    if (!_countDownView) {
        _countDownView = ({
            ZFCountDownView *countDown = [[ZFCountDownView alloc] initWithFrame:CGRectZero tierSizeHeight:18 showDay:NO];
            countDown.timerBackgroundColor = [UIColor clearColor];
            countDown.timerTextColor = [UIColor whiteColor];
            countDown.timerDotColor = [UIColor whiteColor];
            countDown.timerTextBackgroundColor = [UIColor clearColor];
            countDown.fontSize = 14.0;
            countDown.dotPadding = 2;
            countDown;
        });
    }
    return _countDownView;
}

- (UIImageView *)floatImage
{
    if (!_floatImage) {
        _floatImage = ({
            UIImageView *img = [[UIImageView alloc] init];
            img.image = ZFImageWithName(@"orderDetailbubbofloatArrow");
            img;
        });
    }
    return _floatImage;
}

@end
