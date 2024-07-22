//
//  ZFSelectGenderView.m
//  ZZZZZ
//
//  Created by YW on 2018/8/13.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFSelectGenderView.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "SystemConfigUtils.h"
#import "Masonry.h"
#import "Constants.h"

@interface ZFSelectGenderView ()

@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIImageView *arrowImage;
@property (nonatomic, strong) UIView *bottomLine;

@end

@implementation ZFSelectGenderView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initUI];
    }
    return self;
}

-(void)initUI
{
    [self addSubview:self.title];
    [self addSubview:self.contentLabel];
    [self addSubview:self.arrowImage];
    [self addSubview:self.bottomLine];
    
    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self).mas_offset(15);
        make.top.mas_equalTo(self).mas_offset(10);
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.title);
        make.top.mas_equalTo(self.title.mas_bottom).mas_offset(6);
    }];
    
    [self.arrowImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-16);
        make.centerY.mas_equalTo(self.contentLabel);
    }];
    
    [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self).mas_offset(16);
        make.trailing.mas_equalTo(self).mas_offset(-16);
        make.bottom.mas_equalTo(self.mas_bottom);
        make.height.mas_offset(0.5);
    }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGender)];
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:tap];
}

-(void)tapGender
{
    if (self.handleClick) {
        self.handleClick(self);
    }
}

#pragma mark - setter and getter

-(void)setGender:(NSString *)gender
{
    _gender = gender;
    if (_gender) {
        self.contentLabel.text = gender;
        
        // 为了兼容gender里面有空格
        [self.contentLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.title).offset(-2);
            make.top.mas_equalTo(self.title.mas_bottom).mas_offset(6);
        }];
        
    } else{
        self.contentLabel.text = ZFLocalizedString(@"Register_ChooseGender", nil);
        
        // 复原位置
        [self.contentLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.title);
            make.top.mas_equalTo(self.title.mas_bottom).mas_offset(6);
        }];
    }
}

- (UILabel *)title
{
    if (!_title) {
        _title = ({
            UILabel *label = [[UILabel alloc] init];
            label.text = ZFLocalizedString(@"gender", nil);
            label.textAlignment = NSTextAlignmentLeft;
            label.textColor = ColorHex_Alpha(0x999999, 1);
            label.font = ZFFontSystemSize(14);
            label;
        });
    }
    return _title;
}

-(UILabel *)contentLabel
{
    if (!_contentLabel) {
        _contentLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.text = ZFLocalizedString(@"Register_ChooseGender", nil);
            label.textAlignment = NSTextAlignmentLeft;
            label.textColor = [UIColor blackColor];
            label.font = ZFFontSystemSize(14);
            label;
        });
    }
    return _contentLabel;
}

-(UIImageView *)arrowImage
{
    if (!_arrowImage) {
        _arrowImage = ({
            UIImageView *imageView = [[UIImageView alloc] init];
            NSString *imageName = @"size_arrow_right";
            if ([SystemConfigUtils isRightToLeftShow]) {
                imageName = @"size_arrow_left";
            }
            imageView.image = [UIImage imageNamed:imageName];
            imageView;
        });
    }
    return _arrowImage;
}

-(UIView *)bottomLine
{
    if (!_bottomLine) {
        _bottomLine = ({
            UIView *view = [[UIView alloc] init];
            view.backgroundColor = ColorHex_Alpha(0xdddddd, 1);
            view;
        });
    }
    return _bottomLine;
}

@end
