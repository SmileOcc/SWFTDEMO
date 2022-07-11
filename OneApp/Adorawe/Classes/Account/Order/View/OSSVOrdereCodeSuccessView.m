//
//  OSSVOrdereCodeSuccessView.m
// XStarlinkProject
//
//  Created by odd on 2020/9/10.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVOrdereCodeSuccessView.h"

@interface OSSVOrdereCodeSuccessView ()

@property (nonatomic, strong) UIView      *container;
@property (nonatomic, strong) UIButton    *closeBtn;
@property (nonatomic, strong) UILabel     *title;
@property (nonatomic, strong) UILabel     *cotentTip;
@property (nonatomic, strong) UIButton    *confirmBtn;
@end

@implementation OSSVOrdereCodeSuccessView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        
        [self initViewWithFrame:frame];
    }
    return self;
}

- (void)initViewWithFrame:(CGRect)frame {
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    
    _container = [[UIView alloc] init];
    _container.backgroundColor = [OSSVThemesColors stlWhiteColor];
    _container.layer.cornerRadius = 5;
    _container.clipsToBounds = YES;
    [self addSubview:_container];
    
    [_container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mas_leading).mas_offset(38);
        make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-38);
        make.centerX.mas_equalTo(self.mas_centerX);
        make.centerY.mas_equalTo(self.mas_centerY);
    }];
    

    _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_closeBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [_closeBtn setImage:[UIImage imageNamed:@"detail_close"] forState:UIControlStateNormal];
    [_container addSubview:_closeBtn];
    
    [_closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_container.mas_top).mas_offset(15);
        make.trailing.mas_equalTo(_container.mas_trailing).mas_offset(-15);
        make.width.height.mas_equalTo(20);
    }];
    
    _title = [[UILabel alloc] init];
    _title.textColor = [OSSVThemesColors col_262626];
    _title.font = [UIFont boldSystemFontOfSize:14];
    _title.text = STLLocalizedString_(@"success", nil);
    [_container addSubview:_title];
    
    [_title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_container.mas_top).mas_offset(30);
        make.centerX.mas_equalTo(_container.mas_centerX);
    }];
        
    
    
    _cotentTip = [[UILabel alloc] init];
    _cotentTip.numberOfLines = 0;
    _cotentTip.textColor = [OSSVThemesColors col_333333];
    _cotentTip.font = [UIFont systemFontOfSize:12];
    
    NSString *hour48 = @"48";
    NSString *hour = STLLocalizedString_(@"codHour", nil);
    NSString *tips = STLLocalizedString_(@"codSuccessfulTip", nil);
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    [paragraphStyle setLineSpacing:13];
    
    NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc] initWithString:tips];
    [attriString addAttributes:@{NSForegroundColorAttributeName : OSSVThemesColors.col_666666} range:NSMakeRange(0, tips.length)];
    NSRange hourRange = [tips rangeOfString:hour];
    NSRange hour48Range = [tips rangeOfString:hour48];
    [attriString addAttributes:@{NSForegroundColorAttributeName : OSSVThemesColors.col_FA6730} range:hourRange];
    [attriString addAttributes:@{NSForegroundColorAttributeName : OSSVThemesColors.col_FA6730} range:hour48Range];
    _cotentTip.attributedText = attriString;
    
    [_container addSubview:_cotentTip];
    
    [_cotentTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_title.mas_bottom).mas_offset(24);
        make.centerX.mas_equalTo(_container.mas_centerX);
        make.leading.mas_equalTo(_container.mas_leading).mas_offset(24);
        make.trailing.mas_equalTo(_container.mas_trailing).mas_offset(-24);
    }];
    
    
    _confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _confirmBtn.layer.cornerRadius = 4.0;
    _confirmBtn.layer.masksToBounds = YES;
    if (APP_TYPE == 3) {
        [_confirmBtn setTitle:STLLocalizedString_(@"ok", @"ok") forState:UIControlStateNormal];
    } else {
        [_confirmBtn setTitle:STLLocalizedString_(@"ok", @"ok").uppercaseString forState:UIControlStateNormal];
    }
    [_confirmBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [_confirmBtn.titleLabel setFont:[UIFont systemFontOfSize:17]];
    [_confirmBtn setTitleColor:[OSSVThemesColors stlWhiteColor] forState:UIControlStateNormal];
    _confirmBtn.backgroundColor = [OSSVThemesColors col_262626];
    [_container addSubview:_confirmBtn];
    
    [_confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_cotentTip.mas_bottom).mas_offset(24);
        make.leading.mas_equalTo(_container.mas_leading).mas_offset(24);
        make.trailing.mas_equalTo(_container.mas_trailing).mas_offset(-24);
        make.height.mas_equalTo(44);
        make.bottom.mas_equalTo(_container.mas_bottom).offset(-24);
    }];
    
}

- (void)show{
    if (!self.superview) {
        [WINDOW addSubview:self];
    }
    self.hidden = NO;
    self.alpha = 0.0;
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1.0;
        [self.container mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.mas_centerY);
        }];
    }];
}


- (void)dismiss {
    CGRect contentFrame = self.container.frame;
    contentFrame.origin.y = SCREEN_HEIGHT;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0.5;
         [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.hidden = YES;
        if (self.superview) {
            [self removeFromSuperview];
        }
    }];

}


-(void)dealloc {

}

@end
