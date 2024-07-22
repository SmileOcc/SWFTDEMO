//
//  ZFEmptyView.m
//  ZZZZZ
//
//  Created by YW on 2019/6/13.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFEmptyView.h"
#import "ZFInitViewProtocol.h"
#import "Masonry.h"
#import "YWCFunctionTool.h"
#import "ZFThemeManager.h"

@interface ZFEmptyView()<ZFInitViewProtocol>

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel     *msgLabel;

@end


@implementation ZFEmptyView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.labelTextColor = ZFC0x2D2D2D();
        self.labelFontSize = 16;
        self.labelNumberOfLines = 2;
        self.imageBottomCenterYSpace = 5;
        self.labelTopCenterYSpace = 5;
        self.labelLeadingSpace = 60;
        
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}


- (void)zfInitView {
    [self addSubview:self.imageView];
    [self addSubview:self.msgLabel];
}

- (void)zfAutoLayoutView {
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.mas_centerY).offset(self.imageBottomCenterYSpace);
        make.centerX.mas_equalTo(self.mas_centerX);
    }];
    
    [self.msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_centerY).offset(self.labelTopCenterYSpace);
        make.leading.mas_equalTo(self.mas_leading).offset(self.labelLeadingSpace);
        make.trailing.mas_equalTo(self.mas_trailing).offset(-self.labelLeadingSpace);
    }];
}

- (void)reloadView {
    
    self.msgLabel.numberOfLines = self.labelNumberOfLines;
    self.msgLabel.textColor = self.labelTextColor;
    self.msgLabel.font = [UIFont systemFontOfSize:self.labelFontSize];
    
    [self.imageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.mas_centerY).offset(self.imageBottomCenterYSpace);
    }];
    [self.msgLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_centerY).offset(self.labelTopCenterYSpace);
        make.leading.mas_equalTo(self.mas_leading).offset(self.labelLeadingSpace);
        make.trailing.mas_equalTo(self.mas_trailing).offset(-self.labelLeadingSpace);
    }];
    
}

#pragma mark - Property Method

- (void)setMsg:(NSString *)msg {
    _msg = msg;
    self.msgLabel.text = ZFToString(_msg);
}

- (void)setMsgImage:(UIImage *)msgImage {
    _msgImage = msgImage;
    self.imageView.image = _msgImage;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
    }
    return _imageView;
}

- (UILabel *)msgLabel {
    if (!_msgLabel) {
        _msgLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _msgLabel.numberOfLines = self.labelNumberOfLines;
        _msgLabel.textColor = self.labelTextColor;
        _msgLabel.font = [UIFont systemFontOfSize:self.labelFontSize];
        _msgLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _msgLabel;
}


@end
