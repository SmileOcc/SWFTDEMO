//
//  OSSVLanguaSettingsCell.m
// XStarlinkProject
//
//  Created by odd on 2020/7/10.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVLanguaSettingsCell.h"

@implementation OSSVLanguaSettingsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self stlInitView];
        [self stlAutoLayoutView];
    }
    return self;
}

- (void)stlInitView {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.contentView addSubview:self.accesoryImageView];
    [self.contentView addSubview:self.contentLabel];
}

- (void)stlAutoLayoutView {
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 16, 0, 16));
        make.height.mas_equalTo(44);
    }];

    [self.accesoryImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
        make.centerY.mas_equalTo(self.contentLabel);
    }];
}

- (UIImageView *)accesoryImageView {
    if (!_accesoryImageView) {
        UIImage *image = [UIImage imageNamed:@"pay_Selected"];
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
        _contentLabel.textColor = STLThemeColor.col_333333;
        _contentLabel.textAlignment = [SystemConfigUtils isRightToLeftShow] ? NSTextAlignmentRight : NSTextAlignmentLeft;;
    }
    return _contentLabel;
}


@end
