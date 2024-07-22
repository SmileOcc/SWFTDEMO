//
//  ZFBottomToolView.m
//  ZZZZZ
//
//  Created by YW on 2017/8/29.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFBottomToolView.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "UIView+ZFViewCategorySet.h"
#import "UIView+LayoutMethods.h"
#import "UIColor+ExTypeChange.h"
#import "Masonry.h"
#import "UIButton+ZFButtonCategorySet.h"

@interface ZFBottomToolView () <ZFInitViewProtocol>
@property (nonatomic, strong) UIButton          *bottomButton;
@end

@implementation ZFBottomToolView
#pragma mark - init methods
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.showTopShadowline = YES;
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

- (void)setBottomTitle:(NSString *)bottomTitle {
    _bottomTitle = bottomTitle;
    [self.bottomButton setTitle:bottomTitle forState:UIControlStateNormal];
}

#pragma mark - action methods
- (void)bottomButtonAction:(UIButton *)sender {
    if (self.bottomButtonBlock) {
        self.bottomButtonBlock();
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
//    self.topLine.hidden = self.showTopShadowline;
    if (self.showTopShadowline) {
        [self addDropShadowWithOffset:CGSizeMake(0, -2)
                               radius:2
                                color:[UIColor blackColor]
                              opacity:0.1];
    } else {
        self.layer.shadowColor = [UIColor clearColor].CGColor;
    }
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.backgroundColor = ZFCOLOR_WHITE;
    [self addSubview:self.topLine];
    [self addSubview:self.bottomButton];
}

- (void)zfAutoLayoutView {
    [self.topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.mas_equalTo(self);
        make.height.mas_equalTo(0.5);
    }];
    
    [self.bottomButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(8, 16, 8, 16));
        // 高度UI统计应该为40,由外部设置当前视图总高度(56)来适应按钮高度
    }];
}

- (UIView *)topLine {
    if(!_topLine){
        _topLine = [[UIView alloc] init];
        _topLine.backgroundColor = [UIColor colorWithHex:0xdddddd];
        _topLine.hidden = YES;
    }
    return _topLine;
}

#pragma mark - getter
- (UIButton *)bottomButton {
    if (!_bottomButton) {
        _bottomButton = [UIButton buttonWithType:UIButtonTypeCustom];
        //_bottomButton.backgroundColor = ColorHex_Alpha(0xCE0E61, 1);
        [_bottomButton setBackgroundColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
        [_bottomButton setBackgroundColor:ZFC0x2D2D2D_08() forState:UIControlStateHighlighted];
        [_bottomButton setBackgroundColor:ZFCOLOR(204, 204, 204, 1) forState:UIControlStateDisabled];
        [_bottomButton setTitleColor:ZFCOLOR_WHITE forState:UIControlStateNormal];
        _bottomButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
        _bottomButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        [_bottomButton addTarget:self action:@selector(bottomButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _bottomButton.layer.masksToBounds = YES;
        _bottomButton.layer.cornerRadius = 3;
    }
    return _bottomButton;
}

@end
