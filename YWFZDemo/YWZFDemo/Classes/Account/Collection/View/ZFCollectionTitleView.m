//
//  ZFCollectionTitleView.m
//  ZZZZZ
//
//  Created by YW on 2019/6/11.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCollectionTitleView.h"
#import "Masonry.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"

@interface ZFCollectionTitleView()

@property (nonatomic, strong) UIControl             *leftControl;
@property (nonatomic, strong) UIControl             *rightControl;

@property (nonatomic, strong) UILabel               *leftLabel;
@property (nonatomic, strong) UILabel               *rightLabel;
@property (nonatomic, strong) UIView                *redDotView;
@property (nonatomic, strong) UIView                *slideView;

@end

@implementation ZFCollectionTitleView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.leftLabel.text = ZFLocalizedString(@"Collection_title_items", nil);
        self.rightLabel.text = ZFLocalizedString(@"Collection_title_posts", nil);

        [self addSubview:self.leftControl];
        [self addSubview:self.rightControl];
        [self addSubview:self.slideView];
        [self.leftControl addSubview:self.leftLabel];
        [self.rightControl addSubview:self.rightLabel];
        [self.rightLabel addSubview:self.redDotView];
        
        [self.leftControl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.top.bottom.mas_equalTo(self);
            make.width.mas_greaterThanOrEqualTo(120);
        }];
        [self.rightControl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.top.bottom.mas_equalTo(self);
            make.leading.mas_equalTo(self.leftControl.mas_trailing);
            make.width.mas_greaterThanOrEqualTo(120);
        }];
        
        [self.leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.leftControl.mas_trailing).offset(-20);
            make.top.mas_equalTo(self.leftControl.mas_top).offset(4);
            make.bottom.mas_equalTo(self.leftControl.mas_bottom).offset(-4);
            make.width.mas_lessThanOrEqualTo(100);
        }];
        
        [self.rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.rightControl.mas_leading).offset(20);
            make.top.mas_equalTo(self.rightControl.mas_top).offset(4);
            make.bottom.mas_equalTo(self.rightControl.mas_bottom).offset(-4);
            make.width.mas_lessThanOrEqualTo(100);
        }];
        
        [self.slideView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.mas_bottom);
            make.height.mas_equalTo(3);
            make.width.mas_equalTo(self.leftLabel.mas_width);
            make.centerX.mas_equalTo(self.leftLabel.mas_centerX);
        }];
        
        [self.redDotView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.rightLabel.mas_top).offset(4);
            make.centerX.mas_equalTo(self.rightLabel.mas_trailing).offset(2);
            make.size.mas_equalTo(CGSizeMake(8, 8));
        }];
    }
    return self;
}

#pragma mark - Action

- (void)actionLeft:(UIControl *)control {
    if (self.indexBlock) {
        self.indexBlock(0);
    }
    [self reResetSliderView:0];
}

- (void)actionRight:(UIControl *)control {
    if (self.indexBlock) {
        self.indexBlock(1);
    }
    [self reResetSliderView:1];
    [self showReadDot:NO];
}

- (void)reResetSliderView:(NSInteger)index {
    [self.slideView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.mas_bottom);
        make.height.mas_equalTo(3);
        if (index == 0) {
            make.width.mas_equalTo(self.leftLabel.mas_width);
            make.centerX.mas_equalTo(self.leftLabel.mas_centerX);
        } else {
            make.width.mas_equalTo(self.rightLabel.mas_width);
            make.centerX.mas_equalTo(self.rightLabel.mas_centerX);
        }
    }];
    if (index == 0) {
        self.leftLabel.textColor = ZFC0x2D2D2D();
        self.rightLabel.textColor = ZFC0x999999();
    } else {
        self.leftLabel.textColor = ZFC0x999999();
        self.rightLabel.textColor = ZFC0x2D2D2D();
    }
}

- (void)showReadDot:(BOOL)show {
    self.redDotView.hidden = !show;
}

#pragma mark - Property Method

- (UIControl *)leftControl {
    if (!_leftControl) {
        _leftControl = [[UIControl alloc] initWithFrame:CGRectZero];
        [_leftControl addTarget:self action:@selector(actionLeft:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leftControl;
}

- (UIControl *)rightControl {
    if (!_rightControl) {
        _rightControl = [[UIControl alloc] initWithFrame:CGRectZero];
        [_rightControl addTarget:self action:@selector(actionRight:) forControlEvents:UIControlEventTouchUpInside];

    }
    return _rightControl;
}

- (UILabel *)leftLabel {
    if (!_leftLabel) {
        _leftLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _leftLabel.textAlignment = NSTextAlignmentCenter;
        _leftLabel.textColor = ZFC0x2D2D2D();
        _leftLabel.font = [UIFont boldSystemFontOfSize:18];
    }
    return _leftLabel;
}

- (UILabel *)rightLabel {
    if (!_rightLabel) {
        _rightLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _rightLabel.textAlignment = NSTextAlignmentCenter;
        _rightLabel.textColor = ZFC0x999999();
        _rightLabel.font = [UIFont boldSystemFontOfSize:18];
    }
    return _rightLabel;
}

- (UIView *)redDotView {
    if (!_redDotView) {
        _redDotView = [[UIView alloc] initWithFrame:CGRectZero];
        _redDotView.layer.cornerRadius = 4;
        _redDotView.layer.masksToBounds = YES;
        _redDotView.backgroundColor = ZFC0xFE5269();
        _redDotView.hidden = YES;
    }
    return _redDotView;
}

- (UIView *)slideView {
    if (!_slideView) {
        _slideView = [[UIView alloc] initWithFrame:CGRectZero];
        _slideView.backgroundColor = ZFC0x2D2D2D();
    }
    return _slideView;
}
@end
