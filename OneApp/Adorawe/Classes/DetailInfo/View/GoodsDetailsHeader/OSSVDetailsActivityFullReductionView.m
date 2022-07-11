//
//  OSSVDetailsActivityFullReductionView.m
// XStarlinkProject
//
//  Created by odd on 2020/12/23.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVDetailsActivityFullReductionView.h"

@implementation OSSVDetailsActivityFullReductionView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.tempView];
        [self addSubview:self.backgroundView];
        [self addSubview:self.tipLabel];
        
        [self.tempView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading).offset(8);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-4);
        }];
        [self.backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.mas_equalTo(self);
            make.leading.mas_equalTo(self.mas_leading);
        }];
        
        [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.backgroundView.mas_leading).offset(8);
            make.trailing.mas_equalTo(self.backgroundView.mas_trailing).offset(-4);
            make.top.mas_equalTo(self.mas_top).offset(2);
            make.bottom.mas_equalTo(self.mas_bottom).offset(-2);
            make.width.mas_lessThanOrEqualTo(self.tempView.mas_width);
        }];
    }
    return self;
}

- (void)updateTipMasWidth:(BOOL)isFull {
    [self.tipLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        if (isFull) {
            make.width.mas_equalTo(self.tempView.mas_width);
        } else {
            make.width.mas_lessThanOrEqualTo(self.tempView.mas_width);
        }
    }];
}

- (void)setTipMessage:(NSString *)tipMessage {
    
    if (STLIsEmptyString(tipMessage)) {
        self.hidden = YES;
    } else {
        self.hidden = NO;
        self.tipLabel.text = [tipMessage uppercaseString];
    }
}

- (UIView *)tempView {
    if (!_tempView) {
        _tempView = [[UIView alloc] initWithFrame:CGRectZero];
        _tempView.backgroundColor = [UIColor clearColor];
    }
    return _tempView;
}

- (UIView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        if (APP_TYPE == 3) {
            _backgroundView.backgroundColor = [OSSVThemesColors stlWhiteColor];
            _backgroundView.layer.borderColor = [OSSVThemesColors col_F5EEE9].CGColor;
            _backgroundView.layer.borderWidth = 1;
        } else {
            _backgroundView.backgroundColor = [OSSVThemesColors col_FDF1F0];
        }
    }
    return _backgroundView;
}

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _tipLabel.font = [UIFont systemFontOfSize:10];
        _tipLabel.numberOfLines = 2;
        _tipLabel.textAlignment = NSTextAlignmentLeft;
        
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _tipLabel.textAlignment = NSTextAlignmentRight;
        }
        
        if (APP_TYPE == 3) {
            _tipLabel.textColor = OSSVThemesColors.col_9F5123;
        } else {
            _tipLabel.textColor = OSSVThemesColors.col_B62B21;
        }
    }
    return _tipLabel;
}
@end
