//
//  OSSVPaymenteTipseAlertView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/17.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVPaymenteTipseAlertView.h"

#define topPadding 30
#define bottomPadding 30
#define padding 10

@interface OSSVPaymenteTipseAlertView ()
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIButton *cancelButton;
@end

@implementation OSSVPaymenteTipseAlertView

-(instancetype)init
{
    self = [super init];
    
    if (self) {
        [self initUI];
    }
    return self;
}

-(void)initUI
{
    self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    
    [self addSubview:self.maskView];
    [self addSubview:self.contentView];
    [self.contentView addSubview:self.contentLabel];
    [self.contentView addSubview:self.cancelButton];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self).mas_offset(30);
        make.trailing.mas_equalTo(self).mas_offset(-30);
        make.center.mas_equalTo(self);
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading);
        make.trailing.mas_equalTo(self.contentView.mas_trailing);
        make.top.mas_equalTo(self.contentView.mas_top).mas_offset(topPadding);
    }];
    
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top).mas_offset(padding);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).mas_offset(-padding);
        make.width.height.mas_offset(15);
    }];

    [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.contentLabel.mas_bottom).mas_offset(bottomPadding);
    }];
}

#pragma mark - public method

-(void)show
{
    if (!self.superview) {
        [WINDOW addSubview:self];
        self.maskView.alpha = 0.0;
        self.contentView.alpha = 1.0;
        self.contentView.transform = CGAffineTransformMakeScale(0.5, 0.5);
        [UIView animateWithDuration:.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:3 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.contentView.transform = CGAffineTransformIdentity;
            self.maskView.alpha = 0.5;
        } completion:^(BOOL finished) {
            
        }];
    }
}

-(void)hiddenView
{
    [UIView animateWithDuration:.2 animations:^{
        self.maskView.alpha = 0.0;
        self.contentView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - target

-(void)numButtonAction
{
    [self hiddenView];
}

-(void)cancelButtonAction
{
    [self hiddenView];
}

-(NSAttributedString *)handleTipsAttributedString
{
    NSString *string = STLLocalizedString_(@"Order_remaining_payment_time_message", nil);
    NSMutableParagraphStyle *parStyle = [[NSMutableParagraphStyle alloc] init];
    parStyle.lineSpacing = 3;
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:string];
    [attString addAttribute:NSParagraphStyleAttributeName value:parStyle range:NSMakeRange(0, string.length)];
    [attString addAttribute:NSForegroundColorAttributeName value:OSSVThemesColors.col_333333 range:NSMakeRange(0, string.length)];
//    NSRange range = [string rangeOfString:STLLocalizedString_(@"Within_1.5_hours", nil)];
//    [attString addAttribute:NSForegroundColorAttributeName value:OSSVThemesColors.col_FF6F00 range:range];
    return [attString copy];
}

#pragma mark - setter and getter

-(UIView *)maskView
{
    if (!_maskView) {
        _maskView = ({
            UIView *view = [[UIView alloc] init];
            view.frame = self.frame;
            view.backgroundColor = [UIColor blackColor];
            view.alpha = 0.5;
            view;
        });
    }
    return _maskView;
}

-(UIView *)contentView
{
    if (!_contentView) {
        _contentView = ({
            UIView *view = [[UIView alloc] init];
            view.backgroundColor = [UIColor whiteColor];
            view.layer.cornerRadius = 5;
            view;
        });
    }
    return _contentView;
}

-(UILabel *)contentLabel
{
    if (!_contentLabel) {
        _contentLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.attributedText = [self handleTipsAttributedString];
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont systemFontOfSize:13];
            label.numberOfLines = 0;
            label;
        });
    }
    return _contentLabel;
}

-(UIButton *)cancelButton
{
    if (!_cancelButton) {
        _cancelButton = ({
            UIButton *button = [[UIButton alloc] init];
            [button setImage:[UIImage imageNamed:@"detail_close"] forState:UIControlStateNormal];
            [button setTitleColor:OSSVThemesColors.col_333333 forState:UIControlStateNormal];
            [button addTarget:self action:@selector(cancelButtonAction) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
    }
    return _cancelButton;
}

@end
