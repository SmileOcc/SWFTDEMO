//
//  ZFSuperCateViewCell.m
//  ZZZZZ
//
//  Created by YW on 2018/11/21.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import "ZFSuperCateViewCell.h"
#import "ZFThemeManager.h"
#import "UIColor+ExTypeChange.h"
#import "Masonry.h"

@interface ZFSuperCateViewCell ()

@property (nonatomic, strong) UIView *tagView;
@property (nonatomic, strong) UILabel *cateNameLabel;

@end

@implementation ZFSuperCateViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        [self setupView];
        [self layout];
    }
    return self;
}

- (void)setupView {
    [self.contentView addSubview:self.tagView];
    [self.contentView addSubview:self.cateNameLabel];
}

- (void)layout {
    [self.tagView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(3, 24));
    }];
    
    [self.cateNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(self.contentView);
        make.leading.mas_equalTo(self.tagView.mas_trailing).offset(12.0);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12.0);
    }];
}

- (void)configData:(NSString *)cateName isSelected:(BOOL)isSelected {
    self.cateNameLabel.text = cateName;
    self.contentView.backgroundColor = isSelected ? [UIColor whiteColor] : [UIColor clearColor];
    _cateNameLabel.font = isSelected ? [UIFont boldSystemFontOfSize:12] : [UIFont systemFontOfSize:12];
    _cateNameLabel.textColor = isSelected ? [UIColor colorWithRed:45/255.0 green:45/255.0 blue:45/255.0 alpha:1] : [UIColor colorWithHex:0x666666];
    self.tagView.hidden = !isSelected;
}

#pragma mark -------- getter/setter
- (UIView *)tagView {
    if (!_tagView) {
        _tagView = [[UIView alloc] init];
        _tagView.backgroundColor = ZFC0x2D2D2D();
        _tagView.layer.cornerRadius = 1.5;
        _tagView.hidden = YES;
    }
    return _tagView;
}

- (UILabel *)cateNameLabel {
    if (!_cateNameLabel) {
        _cateNameLabel = [[UILabel alloc] init];
        _cateNameLabel.font = [UIFont systemFontOfSize:12.0];
        _cateNameLabel.textColor = [UIColor colorWithHex:0x999999];
//        _cateNameLabel.textAlignment = NSTextAlignmentCenter;
        _cateNameLabel.numberOfLines = 2;
    }
    return _cateNameLabel;
}

@end
