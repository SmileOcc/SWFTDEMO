//
//  OSSVCategoryFiltersHeadView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/17.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCategoryFiltersHeadView.h"

@interface OSSVCategoryFiltersHeadView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIImageView *tagImageView;

@end

@implementation OSSVCategoryFiltersHeadView


#pragma mark - public method

- (void)setTitle:(NSString *)title
{
    CGSize size = [title sizeWithAttributes:@{NSFontAttributeName: self.titleLabel.font}];
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(size.width + 1); // 小数位误差
    }];
    self.titleLabel.text = title;
}

- (void)setContent:(NSString *)content
{
    self.contentLabel.text = content;
}


#pragma mark - life cycle

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor whiteColor];
        [self addtapGesture];
        [self setupView];
        [self subViewLayout];
    }
    return self;
}


#pragma mark -private methods

- (void)addtapGesture
{
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
    [tapGesture addTarget:self action:@selector(didTouch:)];
    [self addGestureRecognizer:tapGesture];
}

- (void)setupView
{
    [self addSubview:self.titleLabel];
    [self addSubview:self.contentLabel];
    [self addSubview:self.tagImageView];
}

- (void)subViewLayout
{
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(self);
        make.leading.mas_equalTo(self).offset(15.0);
        make.width.mas_equalTo(0.0f);
    }];
    
    [self.tagImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self).offset(-15.0f);
        make.height.mas_equalTo(self.tagImageView.image.size.height);
        make.width.mas_equalTo(self.tagImageView.image.size.width);
        make.centerY.mas_equalTo(self.mas_centerY);
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.tagImageView.mas_leading).offset(-5.0f);
        make.top.bottom.mas_equalTo(self);
        make.leading.mas_greaterThanOrEqualTo(self.titleLabel.mas_trailing).offset(15.0f);
    }];
    
    UIView *lineView  = [[UIView alloc] init];
    lineView.backgroundColor = OSSVThemesColors.col_EBEBEB;
    [self addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.trailing.mas_equalTo(self);
        make.height.mas_equalTo(1.0);
    }];
}

#pragma mark - user event

- (void)didTouch:(UITapGestureRecognizer *)tap
{
    self.isShow = !self.isShow;
    if (self.unfoldAction)
    {
        self.unfoldAction();
    }
}

#pragma mark - getter/setter

- (UILabel *)titleLabel
{
    if (!_titleLabel)
    {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font      = [UIFont systemFontOfSize:14.0];
        _titleLabel.textColor = OSSVThemesColors.col_333333;
    }
    return _titleLabel;
}

- (UILabel *)contentLabel
{
    if (!_contentLabel)
    {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.font      = [UIFont systemFontOfSize:14.0];
        _contentLabel.textColor = OSSVThemesColors.col_FEA235;
        _contentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _contentLabel;
}

- (UIImageView *)tagImageView
{
    if (!_tagImageView)
    {
        _tagImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"category_down_arrow"]];
    }
    return _tagImageView;
}

- (void)setIsShow:(BOOL)isShow
{
    _isShow = isShow;
    if (isShow)
    {
        self.tagImageView.transform = CGAffineTransformMakeRotation(M_PI);
    }
    else
    {
        self.tagImageView.transform = CGAffineTransformIdentity;
    }
}

@end
