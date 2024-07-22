//
//  ZFUserInfoPointsInfoView.m
//  ZZZZZ
//
//  Created by YW on 2020/1/9.
//  Copyright © 2020 ZZZZZ. All rights reserved.
//

#import "ZFUserInfoPointsInfoView.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "Masonry.h"
#import "Constants.h"

@implementation ZFUserInfoPointsInfoView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = ZFC0xFFEFF1();
        
        [self addSubview:self.imageView];
        [self addSubview:self.pointsMessageLabel];
        
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading).offset(16);
            make.centerY.mas_equalTo(self.mas_centerY);
        }];
        
        [self.pointsMessageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.imageView.mas_trailing).offset(6);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-16);
            make.top.mas_equalTo(self.mas_top).offset(8);
            make.bottom.mas_equalTo(self.mas_bottom).offset(-8);
            make.height.mas_greaterThanOrEqualTo(18);
        }];
    }
    return self;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imageView.image = [UIImage imageNamed:@"account_points"];
    }
    return _imageView;
}

- (UILabel *)pointsMessageLabel {
    if (!_pointsMessageLabel) {
        _pointsMessageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _pointsMessageLabel.textColor = ZFC0xFE5269();
        _pointsMessageLabel.font = [UIFont systemFontOfSize:14];
        _pointsMessageLabel.numberOfLines = 0;
        _pointsMessageLabel.text = @"Complete personal info to get 100 Z-Points";
    }
    return _pointsMessageLabel;
}
@end
