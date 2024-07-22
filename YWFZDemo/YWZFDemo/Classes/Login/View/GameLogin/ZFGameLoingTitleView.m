//
//  ZFGameLoingTitleView.m
//  ZZZZZ
//
//  Created by YW on 2018/9/28.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFGameLoingTitleView.h"
#import "ZFThemeManager.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"

@interface ZFGameLoingTitleView ()

@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation ZFGameLoingTitleView

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
    self.frame = CGRectMake(0, 0, KScreenWidth, 44);
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.backButton];
    [self addSubview:self.titleLabel];
    
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self).mas_offset(8);
        make.centerY.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.mas_equalTo(self);
        make.height.mas_equalTo(self);
    }];
    
    UIView *line = [UIView new];
    line.backgroundColor = ZFCOLOR(221, 221, 221, 1);
    [self addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self);
        make.bottom.mas_equalTo(self.mas_bottom);
        make.height.mas_offset(1);
    }];
}

-(void)addtarget:(id)target action:(SEL)selector
{
    if (target) {
        [self.backButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    }
}

#pragma mark - setter and getter

-(void)setTitle:(NSString *)title
{
    _title = title;
    self.titleLabel.text = _title;
}

-(void)setImage:(UIImage *)image
{
    _image = image;
    [self.backButton setImage:image forState:UIControlStateNormal];
}

-(UIButton *)backButton
{
    if (!_backButton) {
        _backButton = ({
            UIButton *button = [[UIButton alloc] init];
            [button setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
            button;
        });
    }
    return _backButton;
}

-(UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [UIColor blackColor];
            label.font = [UIFont systemFontOfSize:16];
            label;
        });
    }
    return _titleLabel;
}

@end
