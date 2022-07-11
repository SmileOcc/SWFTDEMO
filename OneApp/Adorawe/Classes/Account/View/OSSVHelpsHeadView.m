//
//  OSSVHelpsHeadView.m
// XStarlinkProject
//
//  Created by odd on 2021/1/15.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVHelpsHeadView.h"

@implementation OSSVHelpsHeadView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [OSSVThemesColors stlClearColor];
        [self addSubview:self.headViewTitleLabel];
        [self addSubview:self.lineView];
        
        [self.headViewTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading).offset(12);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-12);
            make.centerY.mas_equalTo(self.mas_centerY);
        }];
        
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading);
            make.trailing.mas_equalTo(self.mas_trailing);
            make.height.mas_equalTo(0.5 * kScale_375);
            make.bottom.mas_equalTo(self.mas_bottom);
        }];
    }
    return self;
}

- (UILabel *)headViewTitleLabel {
    if (!_headViewTitleLabel)
    {
        _headViewTitleLabel = [UILabel new];
        _headViewTitleLabel.textAlignment = NSTextAlignmentLeft;
        _headViewTitleLabel.font = [UIFont boldSystemFontOfSize:13];
        _headViewTitleLabel.textColor = [OSSVThemesColors col_0D0D0D];
        _headViewTitleLabel.textAlignment = [OSSVSystemsConfigsUtils isRightToLeftShow] ? NSTextAlignmentRight : NSTextAlignmentLeft;
    }
    return _headViewTitleLabel;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = [OSSVThemesColors col_EEEEEE];
    }
    return _lineView;
}
@end
