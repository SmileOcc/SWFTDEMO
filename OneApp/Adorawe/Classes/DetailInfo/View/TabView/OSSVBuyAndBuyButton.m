//
//  OSSVBuyAndBuyButton.m
// XStarlinkProject
//
//  Created by fan wang on 2021/6/2.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVBuyAndBuyButton.h"
#import <JHChainableAnimations/JHChainableAnimations.h>
#import "STLPreference.h"

@interface OSSVBuyAndBuyButton ()
@property (weak,nonatomic) UILabel *titleLabel;
@property (weak,nonatomic) UIView *underLineView;
@property (weak,nonatomic) UIImageView *redDot;
@end

@implementation OSSVBuyAndBuyButton

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupSubViews];
    }
    return self;
}

-(void)setupSubViews{
    UILabel *lbl = [[UILabel alloc] init];
    [self addSubview:lbl];
    _titleLabel = lbl;
    [lbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top).offset(14);
        make.bottom.mas_equalTo(self.mas_bottom).offset(-14);
        make.height.mas_equalTo(16);
        make.centerX.mas_equalTo(self.mas_centerX);
    }];
    lbl.font = [UIFont boldSystemFontOfSize:13];
    
    UIView *underLineV = [[UIView alloc] init];
    [self addSubview:underLineV];
    _underLineView = underLineV;
    [underLineV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(lbl.mas_leading);
        make.trailing.mas_equalTo(lbl.mas_trailing);
        make.top.mas_equalTo(lbl.mas_bottom).offset(2);
        make.height.mas_equalTo(2);
    }];
    
    UIImageView *redDot = [[UIImageView alloc] init];
    //buy_and_buy_red_dot
    [redDot setImage:[UIImage imageNamed:@"buy_and_buy_red_dot"]];
    [self addSubview:redDot];
    _redDot = redDot;
    [redDot mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(8);
        make.bottom.mas_equalTo(lbl.mas_top);
        make.leading.mas_equalTo(lbl.mas_trailing);
    }];
    _redDot.hidden = YES;
}

-(void)setHeightLighted:(BOOL)heightLighted{
    _heightLighted = heightLighted;
    _underLineView.backgroundColor = heightLighted ? OSSVThemesColors.col_0D0D0D : [UIColor clearColor];
    _titleLabel.textColor = heightLighted ? OSSVThemesColors.col_0D0D0D : OSSVThemesColors.col_666666;
}

-(void)setRedDotShow:(BOOL)redDotShow{
    _redDotShow = redDotShow;
    _redDot.hidden = !redDotShow;
}


-(void)setTitle:(NSString *)title{
    _title = title;
    _titleLabel.text = title;
}
@end
