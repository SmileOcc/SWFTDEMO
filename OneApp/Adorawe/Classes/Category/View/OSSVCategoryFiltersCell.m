//
//  OSSVCategoryFiltersCell.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/17.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCategoryFiltersCell.h"

@interface OSSVCategoryFiltersCell()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *tagImageView;

@end

@implementation OSSVCategoryFiltersCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.contentView.backgroundColor  =OSSVThemesColors.col_FAFAFA;
        [self setupView];
        [self subViewLayout];
    }
    return self;
}

- (void)setupView
{
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.tagImageView];
}

- (void)subViewLayout
{
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView).offset(30.0f);
        make.top.bottom.mas_equalTo(self.contentView);
    }];
    
    [self.tagImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.contentView).offset(-15.0f);
        make.height.mas_equalTo(self.tagImageView.image.size.height);
        make.width.mas_equalTo(self.tagImageView.image.size.width);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
    }];
    
    UIView *lineView  = [[UIView alloc] init];
    lineView.backgroundColor = OSSVThemesColors.col_EBEBEB;
    [self.contentView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.trailing.mas_equalTo(self.contentView);
        make.leading.mas_equalTo(self.contentView).offset(30.0f);
        make.height.mas_equalTo(1.0);
    }];
}

- (void)configWithTitle:(NSString *)title
{
    self.titleLabel.text = title;
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

- (UIImageView *)tagImageView
{
    if (!_tagImageView)
    {
        _tagImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"category_chosed"]];
        _tagImageView.hidden = YES;
    }
    return _tagImageView;
}

- (void)setIsSelected:(BOOL)isSelected
{
    _isSelected = isSelected;
    self.tagImageView.hidden = !isSelected;
}

@end
