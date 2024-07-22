//
//  ZFLangugeSettingCell.m
//  ZZZZZ
//
//  Created by 602600 on 2020/1/10.
//  Copyright © 2020 ZZZZZ. All rights reserved.
//

#import "ZFLangugeSettingCell.h"
#import "UIImage+ZFExtended.h"
#import "ZFColorDefiner.h"
#import "ZFThemeManager.h"
#import "SystemConfigUtils.h"
#import "Masonry.h"

@interface ZFLangugeSettingCell ()

@end

@implementation ZFLangugeSettingCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

- (void)zfInitView {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.contentView addSubview:self.accesoryImageView];
    [self.contentView addSubview:self.contentLabel];
    [self.contentView addSubview:self.link];
}

- (void)zfAutoLayoutView {
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 16, 0, 16));
        make.height.mas_equalTo(44);
    }];
    
    [self.link mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentLabel.mas_leading);
        make.trailing.bottom.mas_equalTo(0);
        make.height.mas_equalTo(1);
    }];
    
    [self.accesoryImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(-16);
        make.centerY.mas_equalTo(self.contentLabel);
    }];
}

- (UIImageView *)accesoryImageView {
    if (!_accesoryImageView) {
        UIImage *image = [[UIImage imageNamed:@"refine_select"] imageWithColor:ZFC0xFE5269()];
        _accesoryImageView = [[UIImageView alloc] initWithImage:image];
        _accesoryImageView.backgroundColor = [UIColor clearColor];
        _accesoryImageView.frame = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
    }
    return _accesoryImageView;
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.font = [UIFont systemFontOfSize:14];
        _contentLabel.textColor = ZFC0x2D2D2D();
        _contentLabel.textAlignment = [SystemConfigUtils isRightToLeftShow] ? NSTextAlignmentRight : NSTextAlignmentLeft;;
    }
    return _contentLabel;
}

- (UIView *)link {
    if (!_link) {
        _link = [[UIView alloc] init];
        _link.backgroundColor = ZFC0xDDDDDD();
    }
    return _link;
}

@end
