//
//  STLHomeBottomBannerView.m
// XStarlinkProject
//
//  Created by Starlinke on 2021/7/17.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVHomesBottomAdvsView.h"
#import "UIButton+STLCategory.h"

@interface OSSVHomesBottomAdvsView()

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIImageView *disImgV;
@property (nonatomic, strong) UIButton *disBtn;
@property (nonatomic, strong) UILabel *tapLab;
@property (nonatomic, strong) UIButton *tapBtn;
@property (nonatomic, strong) UIImageView *rightImgV;

@end

@implementation OSSVHomesBottomAdvsView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.bgView];
        [self.bgView addSubview:self.contentView];
        [self.contentView addSubview:self.disImgV];
        [self.contentView addSubview:self.disBtn];
        [self.contentView addSubview:self.tapLab];
        [self.contentView addSubview:self.tapBtn];
        [self.contentView addSubview:self.rightImgV];
        
        [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.top.trailing.bottom.mas_equalTo(self);
        }];
        
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.bgView.mas_leading).offset(12);
            make.trailing.mas_equalTo(self.bgView.mas_trailing).offset(-12);
            make.top.mas_equalTo(self.bgView.mas_bottom);
            make.height.mas_equalTo(36);
        }];
        
        [self.disImgV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.contentView.mas_leading).offset(12);
            make.centerY.mas_equalTo(self.contentView.mas_centerY);
            make.width.height.mas_equalTo(18);
        }];
        
        [self.disBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.top.bottom.mas_equalTo(self.contentView);
            make.width.mas_equalTo(20);
        }];
        
        [self.rightImgV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
            make.centerY.mas_equalTo(self.contentView.mas_centerY);
            make.width.height.mas_equalTo(18);
        }];
        
        [self.tapBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.disBtn.mas_trailing).offset(8);
            make.centerY.mas_equalTo(self.contentView.mas_centerY);
            make.trailing.mas_equalTo(self.rightImgV.mas_leading);
            make.height.mas_equalTo(30);
        }];
        
        [self.tapLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.disImgV.mas_trailing).offset(8);
            make.centerY.mas_equalTo(self.contentView.mas_centerY);
            make.trailing.mas_equalTo(self.rightImgV.mas_leading).offset(-8);
            make.height.mas_equalTo(30);
        }];
        
        [self layoutIfNeeded];
        self.contentView.layer.cornerRadius = 18;
        self.rightImgV.layer.cornerRadius = 9;
    }
    return self;
}

- (void)setAdvEventModel:(OSSVAdvsEventsModel *)advEventModel{
    _advEventModel = advEventModel;
    if (STLJudgeNSDictionary(advEventModel.info)) {
        self.tapLab.text = STLToString([advEventModel.info objectForKey:@"text"]);
        self.rightImgV.backgroundColor = [UIColor colorWithHexString:[advEventModel.info objectForKey:@"arrow_bg_color"]];
        NSString *alphstr = STLToString([advEventModel.info objectForKey:@"bg_opacity"]);
        CGFloat alph = [alphstr integerValue] / 100.00;
        self.contentView.backgroundColor = [UIColor colorWithRed:0.051 green:0.051 blue:0.051 alpha:alph];
    }
    
}

- (void)show{
    
    [UIView animateWithDuration:0 animations:^{
        [self.bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.top.trailing.bottom.mas_equalTo(self);
        }];
        [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.bgView.mas_top);
        }];
        self.contentView.alpha = 1;
        [self layoutIfNeeded];
    }];
}

- (void)disMissWithBlock:(void(^)(void))disBlock{
    [UIView animateWithDuration:0.5 animations:^{
        [self.bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.top.trailing.bottom.mas_equalTo(self);
        }];
        [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.bgView.mas_bottom);
        }];
        self.contentView.alpha = 1;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if (disBlock) {
            disBlock();
        }
    }];
}

- (void)dismiss{
    [UIView animateWithDuration:0.2 animations:^{
        [self.bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.top.trailing.bottom.mas_equalTo(self);
        }];
        [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.bgView.mas_bottom);
        }];
        self.contentView.alpha = 1;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

//- (void)disBtnAction:(UIButton *)sender{
//    [self disMissWithBlock:nil];
//}


- (UIView *)bgView{
    if (!_bgView) {
        _bgView = [UIView new];
        _bgView.backgroundColor = [UIColor clearColor];
    }
    return _bgView;
}
- (UIView *)contentView{
    if (!_contentView) {
        _contentView = [UIView new];
        _contentView.backgroundColor = [UIColor colorWithRed:0.051 green:0.051 blue:0.051 alpha:0.8];
        _contentView.alpha = 0;
    }
    return _contentView;
}
- (UIButton *)disBtn{
    if (!_disBtn) {
        _disBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_disBtn setImage:[UIImage imageNamed:@"homeBottomClose"] forState:UIControlStateNormal];
        [_disBtn addTarget:self action:@selector(disBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [_disBtn setEnlargeEdgeWithTop:5 right:3 bottom:5 left:5];
    }
    return _disBtn;
}

- (UILabel *)tapLab{
    if (!_tapBtn) {
        _tapLab = [UILabel new];
        _tapLab.textColor = [UIColor whiteColor];
        _tapLab.font = FontWithSize(12);
        _tapLab.text = STLLocalizedString_(@"homeBottom", nil);
    }
    return _tapLab;
}

- (UIButton *)tapBtn{
    if (!_tapBtn) {
        _tapBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_tapBtn setTitle:STLLocalizedString_(@"homeBottom", nil) forState:UIControlStateNormal];
        _tapBtn.titleLabel.font = FontWithSize(12);
        [_tapBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [_tapBtn addTarget:self action:@selector(tapBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _tapBtn;
}
- (UIImageView *)rightImgV{
    if (!_rightImgV) {
        _rightImgV = [UIImageView new];
        UIImage *image =  [UIImage imageNamed:@"homeBottomArrow"];
        UIEdgeInsets insets = UIEdgeInsetsMake(0, -5, 0, 0);
        _rightImgV.image = [image resizableImageWithCapInsets:insets];
        _rightImgV.contentMode = UIViewContentModeCenter;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _rightImgV.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        }
    }
    return _rightImgV;
}

- (UIImageView *)disImgV{
    if (!_disImgV) {
        _disImgV = [UIImageView new];
        _disImgV.image =  [UIImage imageNamed:@"homeBottomClose"];
        _disImgV.userInteractionEnabled = YES;
    }
    return _disImgV;
}


- (void)disBtnAction:(UIButton *)button {
    [self dismiss];
    
    if (self.advDoActionBlock) {
        self.advDoActionBlock(nil,YES);
    }
}

- (void)tapBtnAction:(UIButton *)button {
    [self dismiss];
    
    if (self.advDoActionBlock) {
        self.advDoActionBlock(_advEventModel,NO);
    }
}

@end
