//
//  OSSVTransportTimeCell.m
// XStarlinkProject
//
//  Created by Kevin on 2021/3/26.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVTransportTimeCell.h"

@interface OSSVTransportTimeCell ()
@end


@implementation OSSVTransportTimeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.numLabel];
        [self.contentView addSubview:self.contentLabel];
        [self.contentView addSubview:self.timeLabel];
    }
    return self;
 
}


- (void)layoutSubviews {
    [super layoutSubviews];
    [self.numLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.top.mas_equalTo(self.contentView);
        make.width.equalTo(45);
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.bottom.top.mas_equalTo(self.contentView);
        make.width.equalTo(120);
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.numLabel.mas_trailing);
        make.trailing.mas_equalTo(self.timeLabel.mas_leading);
        make.top.bottom.mas_equalTo(self.contentView);
    }];
}
- (UILabel *)numLabel {
    if (!_numLabel) {
        _numLabel = [UILabel new];
        _numLabel.textColor = OSSVThemesColors.col_0D0D0D;
        _numLabel.font      = [UIFont systemFontOfSize:11];
        _numLabel.layer.borderColor = OSSVThemesColors.col_EEEEEE.CGColor;
        _numLabel.layer.borderWidth = 0.5f;
        _numLabel.backgroundColor = [UIColor clearColor];
        _numLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _numLabel;
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [UILabel new];
        _contentLabel.textColor = OSSVThemesColors.col_0D0D0D;
        _contentLabel.font      = [UIFont systemFontOfSize:11];
        _contentLabel.layer.borderColor = OSSVThemesColors.col_EEEEEE.CGColor;
        _contentLabel.layer.borderWidth = 0.5f;
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.textAlignment = NSTextAlignmentLeft;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _contentLabel.textAlignment = NSTextAlignmentRight;
        }
    }
    return _contentLabel;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [UILabel new];
        _timeLabel.textColor = OSSVThemesColors.col_0D0D0D;
        _timeLabel.font      = [UIFont systemFontOfSize:11];
        _timeLabel.layer.borderColor = OSSVThemesColors.col_EEEEEE.CGColor;
        _timeLabel.layer.borderWidth = 0.5f;
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.textAlignment = NSTextAlignmentLeft;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _timeLabel.textAlignment = NSTextAlignmentRight;
        }

    }
    return _timeLabel;
}
@end
