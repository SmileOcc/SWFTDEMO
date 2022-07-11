//
//  OSSVMyCurrencysCell.m
// XStarlinkProject
//
//  Created by odd on 2020/8/4.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVMyCurrencysCell.h"

@implementation OSSVMyCurrencysCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self stlInitView];
        [self stlAutoLayoutView];
    }
    return self;
}

- (void)showLinew:(BOOL)show {
    self.lineView.hidden = !show;
}

- (void)stlInitView {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.contentView addSubview:self.accesoryImageView];
    [self.contentView addSubview:self.contentLabel];
    [self.contentView addSubview:self.lineView];
}

- (void)stlAutoLayoutView {
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 14, 0, 14));
        make.height.mas_equalTo(44);
    }];

    [self.accesoryImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-14);
        make.centerY.mas_equalTo(self.contentLabel);
        make.size.mas_equalTo(CGSizeMake(24, 24));
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(14);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-14);
        make.bottom.mas_equalTo(self.contentView.mas_bottom);
        make.height.mas_equalTo(0.5);
    }];
}

- (UIImageView *)accesoryImageView {
    if (!_accesoryImageView) {
        UIImage *image = [UIImage imageNamed:@"selected_mark_24"];
        _accesoryImageView = [[UIImageView alloc] initWithImage:image];
        _accesoryImageView.backgroundColor = [UIColor clearColor];
    }
    return _accesoryImageView;
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.font = [UIFont systemFontOfSize:14];
        _contentLabel.textColor = OSSVThemesColors.col_0D0D0D;
        _contentLabel.textAlignment = [OSSVSystemsConfigsUtils isRightToLeftShow] ? NSTextAlignmentRight : NSTextAlignmentLeft;;
    }
    return _contentLabel;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = OSSVThemesColors.col_EEEEEE;
    }
    return _lineView;
}

@end
