//
//  OSSVServiceeTipseAlertView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/17.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVServiceeTipseAlertView.h"

#define topPadding 30
#define bottomPadding 30
#define padding 10

@interface OSSVServiceeTipseAlertView ()
<
    MBProgressHUDDelegate
>
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UILabel *topsLabel;
@property (nonatomic, strong) UIImageView *phoneIcon;
@property (nonatomic, strong) UILabel *phoneName;
@property (nonatomic, strong) UILabel *phoneNum;
@property (nonatomic, strong) UIButton *numButton;
@property (nonatomic, strong) UILabel *tipslLabel;
@property (nonatomic, strong) UIButton *cancelButton;
@end

@implementation OSSVServiceeTipseAlertView

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
    [self.contentView addSubview:self.topsLabel];
    [self.contentView addSubview:self.tipslLabel];
    [self.contentView addSubview:self.cancelButton];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self).mas_offset(30);
        make.trailing.mas_equalTo(self).mas_offset(-30);
        make.center.mas_equalTo(self);
    }];
    
    [self.topsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).mas_offset(topPadding);
        make.leading.mas_equalTo(self.contentView);
        make.trailing.mas_equalTo(self.contentView);
    }];
    
    UIView *tempCenterView = [[UIView alloc] init];
    [tempCenterView addSubview:self.phoneIcon];
    [tempCenterView addSubview:self.phoneName];
    [self.contentView addSubview:tempCenterView];
    
    [tempCenterView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.contentView);
        make.top.mas_equalTo(self.topsLabel.mas_bottom).mas_offset(padding);
    }];
    
    [self.phoneIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_offset(16);
        make.centerY.mas_equalTo(tempCenterView);
        make.leading.mas_equalTo(tempCenterView.mas_leading);
        make.trailing.mas_equalTo(self.phoneName.mas_leading).mas_offset(-padding);
    }];
    
    [self.phoneName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.phoneIcon.mas_trailing).mas_offset(padding);
        make.trailing.mas_equalTo(tempCenterView.mas_trailing);
        make.top.mas_equalTo(tempCenterView.mas_top);
        make.bottom.mas_equalTo(tempCenterView.mas_bottom);
    }];
    
    UIView *tempCenterView1 = [UIView new];
    [tempCenterView1 addSubview:self.phoneNum];
    [tempCenterView1 addSubview:self.numButton];
    [self.contentView addSubview:tempCenterView1];
    
    [tempCenterView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.contentView);
        make.top.mas_equalTo(tempCenterView.mas_bottom).mas_offset(padding);
    }];
    
    [self.phoneNum mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(tempCenterView1);
        make.leading.mas_equalTo(tempCenterView1.mas_leading);
        make.trailing.mas_equalTo(self.numButton.mas_leading).mas_offset(-padding);
    }];
    
    [self.numButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_offset(18);
        make.leading.mas_equalTo(self.phoneNum.mas_trailing).mas_offset(padding);
        make.trailing.mas_equalTo(tempCenterView1.mas_trailing);
        make.top.mas_equalTo(tempCenterView1.mas_top);
        make.bottom.mas_equalTo(tempCenterView1.mas_bottom);
    }];
    
    [self.tipslLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.contentView);
        make.top.mas_equalTo(tempCenterView1.mas_bottom).mas_offset(padding);
        make.leading.mas_equalTo(self.contentView);
    }];
    
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top).mas_offset(padding);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).mas_offset(-padding);
        make.width.height.mas_offset(15);
    }];
    
    [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.tipslLabel.mas_bottom).mas_offset(bottomPadding);
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
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:self.phoneNum.text];
    
//    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
//    hud.mode = MBProgressHUDModeCustomView;
//    hud.detailsLabelText = STLLocalizedString_(@"Copy_success", nil);
//    hud.margin = 20.f;
//    // 改变背景框颜色
//    hud.blur = NO;
//    hud.color = [UIColor blackColor];
//    hud.removeFromSuperViewOnHide = YES;
//    hud.delegate = self;
//    [hud hide:YES afterDelay:2];
    [HUDManager showHUDWithMessage:STLLocalizedString_(@"Copy_success", nil) completionBlock:^{
        [self hiddenView];
    }];
}

-(void)cancelButtonAction
{
    [self hiddenView];
}

- (void)hudWasHidden:(MBProgressHUD *)hud
{
    [self hiddenView];
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

-(UILabel *)topsLabel
{
    if (!_topsLabel) {
        _topsLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.text = STLLocalizedString_(@"You_can_contact_us_by", nil);
            label.textColor = OSSVThemesColors.col_333333;
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont systemFontOfSize:13];
            label;
        });
    }
    return _topsLabel;
}

-(UIImageView *)phoneIcon
{
    if (!_phoneIcon) {
        _phoneIcon = ({
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.image = [UIImage imageNamed:@"phone"];
            imageView;
        });
    }
    return _phoneIcon;
}

-(UILabel *)phoneName
{
    if (!_phoneName) {
        _phoneName = ({
            UILabel *label = [[UILabel alloc] init];
            label.text = STLLocalizedString_(@"WhatsApp", nil);
            label.textColor = [UIColor blackColor];
            label.font = [UIFont systemFontOfSize:12];
            label;
        });
    }
    return _phoneName;
}

-(UILabel *)phoneNum
{
    if (!_phoneNum) {
        _phoneNum = ({
            UILabel *label = [[UILabel alloc] init];
            label.text = STLLocalizedString_(@"971507506413", nil);
            label.textColor = OSSVThemesColors.col_FF6F00;
            label.font = [UIFont systemFontOfSize:21];
            label;
        });
    }
    return _phoneNum;
}

-(UIButton *)numButton
{
    if (!_numButton) {
        _numButton = ({
            UIButton *button = [[UIButton alloc] init];
            [button setImage:[UIImage imageNamed:@"copy"] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(numButtonAction) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
    }
    return _numButton;
}

-(UILabel *)tipslLabel
{
    if (!_tipslLabel) {
        _tipslLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.textAlignment = NSTextAlignmentCenter;
            NSString *tipsString = STLLocalizedString_(@"Our_support_center_will_reply_you_within_24_hours", nil);
            NSString *hoursString = STLLocalizedString_(@"24_hours", nil);
            NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:tipsString];
            NSRange hoursRange = [tipsString rangeOfString:hoursString];
            [attrString addAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]} range:NSMakeRange(0, attrString.length)];
            [attrString addAttributes:@{NSForegroundColorAttributeName : OSSVThemesColors.col_FF6F00} range:hoursRange];
            label.attributedText = attrString;
            label.font = [UIFont systemFontOfSize:12];
            label;
        });
    }
    return _tipslLabel;
}

-(UIButton *)cancelButton
{
    if (!_cancelButton) {
        _cancelButton = ({
            UIButton *button = [[UIButton alloc] init];
            [button setImage:[UIImage imageNamed:@"detail_close"] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(cancelButtonAction) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
    }
    return _cancelButton;
}

@end
