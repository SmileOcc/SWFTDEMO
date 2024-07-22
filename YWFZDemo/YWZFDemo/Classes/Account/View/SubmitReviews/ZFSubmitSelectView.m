//
//  ZFSubmitSelectView.m
//  ZZZZZ
//
//  Created by YW on 2019/4/4.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFSubmitSelectView.h"
#import "ZFThemeManager.h"
#import "SystemConfigUtils.h"
#import <Masonry/Masonry.h>

@interface ZFSubmitSelectView ()

@property (nonatomic, strong) UITextField *titleTextField;
@property (nonatomic, strong) UIImageView *arrowImage;
@property (nonatomic, assign) BOOL isArrowDown;

@end

@implementation ZFSubmitSelectView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI
{
    [self addSubview:self.titleTextField];
    [self addSubview:self.arrowImage];
    self.layer.borderColor = ZFC0xDDDDDD().CGColor;
    self.layer.borderWidth = 1;
    self.enable = YES;
    self.isArrowDown = YES;
}

-(void)layoutSubviews
{
    [self.titleTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mas_leading).mas_offset(12);
        make.top.bottom.mas_equalTo(self);
        make.trailing.mas_equalTo(self.arrowImage.mas_leading).mas_offset(5);
    }];
    
    [self.arrowImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-8);
        make.centerY.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(16, 16));
    }];
}

#pragma mark - Property

-(void)setEnable:(BOOL)enable
{
    _enable = enable;
    
    if (!_enable) {
        self.titleTextField.textColor = ZFC0x999999();
    } else {
        self.titleTextField.textColor = [UIColor blackColor];
    }
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    
    self.titleTextField.text = _title;
}

-(void)setPlaceHold:(NSString *)placeHold
{
    _placeHold = placeHold;
    
    self.titleTextField.placeholder = _placeHold;
}

- (void)reloadArrowStatus
{
    if (self.isArrowDown) {
        self.isArrowDown = NO;
        [UIView animateWithDuration:0.25f animations:^{
            self.arrowImage.transform = CGAffineTransformMakeRotation(M_PI);
        }];
    } else {
        self.isArrowDown = YES;
        [UIView animateWithDuration:0.25f animations:^{
            self.arrowImage.transform = CGAffineTransformMakeRotation(M_PI * 2);
        }];
    }
    
}

-(UITextField *)titleTextField
{
    if (!_titleTextField) {
        _titleTextField = ({
            UITextField *tf = [[UITextField alloc] init];
            tf.textColor = ZFC0x999999();
            tf.enabled = NO;
            tf.font = [UIFont systemFontOfSize:14];
            if ([SystemConfigUtils isRightToLeftShow]) {
                tf.textAlignment = NSTextAlignmentRight;
            } else {
                tf.textAlignment = NSTextAlignmentLeft;
            }
            tf;
        });
    }
    return _titleTextField;
}

-(UIImageView *)arrowImage
{
    if (!_arrowImage) {
        _arrowImage = ({
            UIImageView *image = [[UIImageView alloc] init];
            image.image = [UIImage imageNamed:@"reviews_arrow"];
            image;
        });
    }
    return _arrowImage;
}

@end
