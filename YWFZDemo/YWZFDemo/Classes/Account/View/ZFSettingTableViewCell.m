//
//  ZFSettingTableViewCell.m
//  ZZZZZ
//
//  Created by YW on 2019/6/20.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFSettingTableViewCell.h"
#import "ZFThemeManager.h"
#import "SystemConfigUtils.h"
#import "ZFColorDefiner.h"
#import "Constants.h"
#import <Masonry/Masonry.h>

@interface ZFSettingTableViewCell ()
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *detailLabel;
@property (nonatomic, strong) UIImageView *arrowImageView;
@end

@implementation ZFSettingTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.iconImageView];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.detailLabel];
        [self.contentView addSubview:self.arrowImageView];
        [self.contentView addSubview:self.bottomLine];
        
        [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.contentView).mas_offset(15);
            make.centerY.mas_equalTo(self.contentView);
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.contentView).mas_offset(15);
            make.centerY.mas_equalTo(self.contentView);
        }];
        
        [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.contentView.mas_trailing).mas_offset(-10);
            make.centerY.mas_equalTo(self.contentView);
        }];
        
        [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.contentView.mas_trailing).mas_offset(-10);
            make.centerY.mas_equalTo(self.contentView);
        }];
        
        [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.titleLabel.mas_leading);
            make.trailing.bottom.mas_equalTo(0);
            make.height.mas_equalTo(0.5);
        }];
    }
    return self;
}

#pragma mark - Property Method

- (void)setIconImage:(UIImage *)iconImage {
    _iconImage = iconImage;
    self.iconImageView.hidden = NO;
    self.iconImageView.image = iconImage;
    
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.iconImageView.mas_trailing).mas_offset(15);
        make.centerY.mas_equalTo(self.contentView);
    }];
}

- (void)setTitle:(NSString *)title {
    _title = title;
    if ([title isKindOfClass:[NSString class]]) {
        self.titleLabel.attributedText = nil;
        self.titleLabel.text = title;
    }
}

- (void)setAttributedTitle:(NSAttributedString *)attributedTitle {
    _attributedTitle = attributedTitle;
    if ([attributedTitle isKindOfClass:[NSAttributedString class]]) {
        self.titleLabel.text = nil;
        self.titleLabel.attributedText = attributedTitle;
        self.titleLabel.numberOfLines = 0;
    }
}

- (void)setDetailTitleHidden:(BOOL)hidden {
    self.detailLabel.hidden = hidden;
}

-(void)setDetailTitle:(NSString *)detailTitle {
    _detailTitle = detailTitle;
    if ([detailTitle isKindOfClass:[NSString class]]) {
        [self.detailLabel setAttributedTitle:nil forState:UIControlStateNormal];
        [self.detailLabel setTitle:detailTitle forState:UIControlStateNormal];
    }
}

- (void)setAttributedDetailTitle:(NSAttributedString *)attributedDetailTitle {
    _attributedDetailTitle = attributedDetailTitle;
    if ([attributedDetailTitle isKindOfClass:[NSAttributedString class]]) {
        [self.detailLabel setTitle:nil forState:UIControlStateNormal];
        [self.detailLabel setAttributedTitle:attributedDetailTitle forState:UIControlStateNormal];
        self.detailLabel.titleLabel.numberOfLines = 0;
    }
}

-(void)setDetailTextColor:(UIColor *)detailTextColor {
    _detailTextColor = detailTextColor;
    [self.detailLabel setTitleColor:_detailTextColor forState:UIControlStateNormal];
}

- (void)setArrowImage:(UIImage *)arrowImage {
    _arrowImage = arrowImage;
    self.arrowImageView.image = arrowImage;
    self.arrowImageView.hidden = NO;
    
    [self.detailLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.arrowImageView.mas_leading).mas_offset(-10);
        make.centerY.mas_equalTo(self.contentView);
    }];
}

- (void)setHideBottomLine:(BOOL)hideBottomLine {
    _hideBottomLine = hideBottomLine;
    self.bottomLine.hidden = hideBottomLine;
}

- (void)setDetailBackgroundColor:(UIColor *)detailBackgroundColor {
    _detailBackgroundColor = detailBackgroundColor;
    
    if ([detailBackgroundColor isEqual:[UIColor redColor]]) {
        self.detailLabel.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);
    } else {
        self.detailLabel.contentEdgeInsets = UIEdgeInsetsZero;
    }
    [self.detailLabel setBackgroundColor:_detailBackgroundColor];
}

#pragma mark - Getter

-(UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = ({
            UIImageView *iconImageView = [[UIImageView alloc] init];
            iconImageView.hidden = YES;
            iconImageView;
        });
    }
    return _iconImageView;
}

-(UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.backgroundColor = [UIColor clearColor];
            label.font = ZFFontSystemSize(14);
            label.textColor = ColorHex_Alpha(0x2D2D2D, 1.0);
            label.textAlignment = [SystemConfigUtils isRightToLeftShow] ? NSTextAlignmentRight : NSTextAlignmentLeft;
            label;
        });
    }
    return _titleLabel;
}

- (UIButton *)detailLabel {
    if (!_detailLabel) {
        _detailLabel = ({
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.titleLabel.font = ZFFontSystemSize(14);
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;//需要右对齐
            // button.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);
            [button setTitleColor:ColorHex_Alpha(0x999999, 1.0) forState:UIControlStateNormal];
            button.enabled = NO;
            button;
        });
    }
    return _detailLabel;
}

-(UIImageView *)arrowImageView {
    if (!_arrowImageView) {
        _arrowImageView = ({
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.hidden = YES;
            imageView;
        });
    }
    return _arrowImageView;
}

- (UIView *)bottomLine {
    if (!_bottomLine) {
        _bottomLine = [[UIView alloc] init];
        _bottomLine.backgroundColor = ZFCOLOR(221, 221, 221, 1);
    }
    return _bottomLine;
}

@end
