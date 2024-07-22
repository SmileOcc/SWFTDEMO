//
//  ZFDetailStyleValueTableViewCell.m
//  ZZZZZ
//
//  Created by YW on 2019/10/11.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFDetailStyleValueTableViewCell.h"
#import "ZFThemeManager.h"
#import <Masonry/Masonry.h>

@interface ZFDetailStyleValueTableViewCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailTitleLabel;

@end

@implementation ZFDetailStyleValueTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self addSubview:self.titleLabel];
        [self addSubview:self.detailTitleLabel];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self).mas_offset(12);
            make.top.mas_equalTo(self).mas_offset(5);
            make.bottom.mas_equalTo(self).mas_offset(-5);
        }];
        
        [self.detailTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self).mas_offset(-12);
            make.centerY.mas_equalTo(self.titleLabel);
            make.leading.mas_equalTo(self.titleLabel.mas_trailing).offset(5);
        }];
        
        [self.titleLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        [self.detailTitleLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
        [self.detailTitleLabel setContentHuggingPriority:260 forAxis:UILayoutConstraintAxisHorizontal];
    }
    return self;
}

#pragma mark - Property Method

- (void)setTitleAttribute:(NSAttributedString *)titleAttribute
{
    _titleAttribute = titleAttribute;
    self.titleLabel.attributedText = _titleAttribute;
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    self.titleLabel.text = _title;
}

- (void)setDetailTitle:(NSString *)detailTitle
{
    _detailTitle = detailTitle;
    self.detailTitleLabel.text = detailTitle;
}

-(UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.numberOfLines = 1;
            label.textColor = ZFC0x3D76B9();
            label.font = [UIFont systemFontOfSize:14];
            label;
        });
    }
    return _titleLabel;
}

-(UILabel *)detailTitleLabel
{
    if (!_detailTitleLabel) {
        _detailTitleLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.numberOfLines = 1;
            label.textColor = ZFC0xCCCCCC();
            label.font = [UIFont systemFontOfSize:12];
            label;
        });
    }
    return _detailTitleLabel;
}

@end
