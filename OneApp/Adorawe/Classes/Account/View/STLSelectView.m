//
//  OSSVCSelectsView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/20.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCSelectsView.h"

@interface OSSVCSelectsView ()
@property (nonatomic, strong) UIButton *clickButton;
@property (nonatomic, strong) UIImageView *arrowImage;
@property (nonatomic, copy) NSString *phone;
@end

@implementation OSSVCSelectsView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self initUI];
    }
    return self;
}

#pragma mark - private method

-(void)initUI
{
    self.layer.cornerRadius = 4;
    self.layer.borderColor = [STLThemeColor.col_D0D1D1 CGColor];
    self.layer.borderWidth = 0.5;
    self.backgroundColor = [UIColor whiteColor];
    self.status = SelectView_Default;
    [self addSubview:self.clickButton];
    [self addSubview:self.arrowImage];

    [self.clickButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.bottom.mas_equalTo(self);
        make.trailing.mas_equalTo(self.arrowImage.mas_leading);
    }];
    [self.arrowImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_lessThanOrEqualTo(self.mas_trailing);
        make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-5);
        make.centerY.mas_equalTo(self);
        make.leading.mas_equalTo(self.clickButton.mas_trailing);
        make.width.mas_offset(10);
        make.height.mas_offset(5);
    }];
}

#pragma mark - target

-(void)selectItemAction
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(STL_SelectViewDidClick)]) {
        [self.delegate STL_SelectViewDidClick]; 
    }
}

#pragma mark - public method

-(void)handleSelectContent:(NSString *)content
{
    self.status = SelectView_Selected;
    [self.clickButton setTitle:content forState:UIControlStateNormal];
}

-(NSString *)selectPhoneCode
{
    if (self.status == SelectView_Default) {
        return @"";
    }
    return self.clickButton.titleLabel.text;
}

-(void)setDefaultBorderColor
{
    self.layer.borderColor = [STLThemeColor.col_D0D1D1 CGColor];
}

#pragma mark - setter and getter

-(void)setStatus:(SelectViewStatus)status
{
    _status = status;
    
    if (_status == SelectView_Default) {
        [self.clickButton setTitle:@"" forState:UIControlStateNormal];
    }
}

-(void)setType:(SelectViewType)type
{
    _type = type;
    
    if (_type == SelectViewType_Open) {
        [UIView animateWithDuration:.3 animations:^{
            self.arrowImage.transform = CGAffineTransformMakeRotation(M_PI);
        }];
    }else{
        [UIView animateWithDuration:.3 animations:^{
            self.arrowImage.transform = CGAffineTransformMakeRotation(M_PI*2);
        }];
    }
}

-(UIButton *)clickButton
{
    if (!_clickButton) {
        _clickButton = ({
            UIButton *button = [[UIButton alloc] init];
            [button addTarget:self action:@selector(selectItemAction) forControlEvents:UIControlEventTouchUpInside];
            [button setTitleColor:STLThemeColor.col_333333 forState:UIControlStateNormal];
            button.titleLabel.adjustsFontSizeToFitWidth = YES;
            button.titleLabel.font = [UIFont systemFontOfSize:12];
            button;
        });
    }
    return _clickButton;
}

-(UIImageView *)arrowImage
{
    if (!_arrowImage) {
        _arrowImage = ({
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.image = [UIImage imageNamed:@"xl_button"];
            imageView.userInteractionEnabled = YES;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectItemAction)];
            [imageView addGestureRecognizer:tap];
            imageView;
        });
    }
    return _arrowImage;
}

@end
