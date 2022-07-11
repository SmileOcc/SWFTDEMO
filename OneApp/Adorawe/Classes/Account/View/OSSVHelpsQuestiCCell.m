//
//  OSSVHelpsQuestiCCell.m
// XStarlinkProject
//
//  Created by odd on 2021/1/15.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVHelpsQuestiCCell.h"

@implementation OSSVHelpsQuestiCCell

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [OSSVThemesColors stlClearColor];
        
        [self.contentView addSubview:self.dotView];
        [self.contentView addSubview:self.arrowImageView];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.lineView];
        
        [self.dotView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading).offset(12);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(8, 8));
        }];
        
        [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.mas_trailing).offset(-12);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(24, 24));
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.dotView.mas_trailing).offset(8);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.trailing.mas_equalTo(self.arrowImageView.mas_leading);
        }];
        
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading).offset(12);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-12);
            make.height.mas_equalTo(0.5 * kScale_375);
            make.bottom.mas_equalTo(self.mas_bottom);
        }];
    }
    return self;
}

- (UIView *)dotView {
    if (!_dotView) {
        _dotView = [[UIView alloc] initWithFrame:CGRectZero];
        _dotView.backgroundColor = [OSSVThemesColors col_0D0D0D];
        _dotView.layer.cornerRadius = 4.0;
    }
    return _dotView;
}

- (UIImageView *)arrowImageView {
    if (!_arrowImageView) {
        _arrowImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _arrowImageView.image = [UIImage imageNamed:@"arrow_black_24"];
        [_arrowImageView convertUIWithARLanguage];
    }
    return _arrowImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textColor = [OSSVThemesColors col_0D0D0D];
        _titleLabel.font = [UIFont systemFontOfSize:13];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _titleLabel.textAlignment = NSTextAlignmentRight;
        }
    }
    return _titleLabel;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = [OSSVThemesColors col_EEEEEE];
    }
    return _lineView;
}
@end
