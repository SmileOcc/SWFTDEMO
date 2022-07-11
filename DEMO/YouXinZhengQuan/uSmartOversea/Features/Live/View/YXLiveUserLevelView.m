//
//  YXLiveUserLevelView.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/10/21.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXLiveUserLevelView.h"
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>

@interface YXLiveUserLevelView()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIButton *updateBtn;

@end

@implementation YXLiveUserLevelView


- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setUI];
    }
    return self;
}

#pragma mark - 设置UI
- (void)setUI {
    
    self.backgroundColor = UIColor.blackColor;
    [self addSubview:self.titleLabel];
    [self addSubview:self.updateBtn];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(64);
        make.centerX.equalTo(self);
        make.left.equalTo(self).offset(10);
        make.right.equalTo(self).offset(-10);
    }];
    
    [self.updateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self).offset(100);
        make.width.mas_equalTo(192);
        make.height.mas_equalTo(48);
    }];
}

- (void)setRequire_right:(int)require_right {
    _require_right = require_right;
    if (require_right == 1 || require_right == 2) {        
        self.titleLabel.text = [YXLanguageUtility kLangWithKey:@"live_update_pro_tip"];
    } else if (require_right == 4) {
        //pi
        self.titleLabel.text = [YXLanguageUtility kLangWithKey:@"live_update_pi_tip"];
    }
}

- (void)updateClick: (UIButton *)sender {
    if (self.updateCallBack) {
        self.updateCallBack();
    }
}


- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [UILabel labelWithText:@"--" textColor:UIColor.whiteColor textFont:[UIFont systemFontOfSize:16]];
        _titleLabel.numberOfLines = 0;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (UIButton *)updateBtn {
    if (_updateBtn == nil) {
        _updateBtn = [UIButton buttonWithType:UIButtonTypeCustom title:[YXLanguageUtility kLangWithKey:@"upgrade_immediately"] font:[UIFont systemFontOfSize:16 weight:UIFontWeightMedium] titleColor:[UIColor qmui_colorWithHexString:@"#633A00"] target:self action:@selector(updateClick:)];
                        
        // gradient
        CAGradientLayer *gl = [CAGradientLayer layer];
        gl.frame = CGRectMake(0,0,192,48);
        gl.startPoint = CGPointMake(0.5, 0);
        gl.endPoint = CGPointMake(0.5, 1);
        gl.colors = @[(__bridge id)[UIColor colorWithRed:240/255.0 green:215/255.0 blue:179/255.0 alpha:1.0].CGColor, (__bridge id)[UIColor colorWithRed:220/255.0 green:179/255.0 blue:122/255.0 alpha:1.0].CGColor];
        gl.locations = @[@(0), @(1.0f)];
        
        [_updateBtn.layer insertSublayer:gl atIndex:0];
        
        _updateBtn.layer.cornerRadius = 6;
        _updateBtn.clipsToBounds = YES;
    }
    return _updateBtn;
}

@end
