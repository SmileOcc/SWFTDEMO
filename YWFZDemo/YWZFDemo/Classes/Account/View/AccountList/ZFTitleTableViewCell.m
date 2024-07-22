//
//  ZFTitleTableViewCell.m
//  ZZZZZ
//
//  Created by YW on 2019/1/5.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFTitleTableViewCell.h"
#import "ZFThemeManager.h"
#import "Masonry.h"

@interface ZFTitleTableViewCell ()
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation ZFTitleTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - ZFInitViewProtocol
- (void)zfInitView {
    self.backgroundColor = ZFCOLOR_WHITE;
    [self.contentView addSubview:self.titleLabel];
}

- (void)zfAutoLayoutView {
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.contentView);
        make.width.lessThanOrEqualTo(self.contentView.mas_width);
    }];
}

#pragma mark - Setter
- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = title;
}

#pragma mark - Getter
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont boldSystemFontOfSize:16];
        _titleLabel.textColor = ZFCOLOR(45, 45, 45, 1);
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.backgroundColor = ZFCOLOR_WHITE;
    }
    return _titleLabel;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.titleLabel.text = nil;
}
@end
