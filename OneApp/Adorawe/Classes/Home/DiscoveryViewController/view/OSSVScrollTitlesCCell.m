//
//  OSSVScrollTitlesCCell.m
// OSSVScrollTitlesCCell
//
//  Created by 10010 on 20/9/28.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVScrollTitlesCCell.h"

@interface OSSVScrollTitlesCCell ()

@property (nonatomic, strong) UILabel       *titleLabel;
@property (nonatomic, strong) UIImageView   *arrowView;
@property (nonatomic, strong) UILabel       *textLabel;
@property (nonatomic, strong) UIView        *bottomLine;

@end

@implementation OSSVScrollTitlesCCell
@synthesize model = _model;
@synthesize delegate = _delegate;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.titleLabel];
        [self addSubview:self.arrowView];
        [self addSubview:self.textLabel];
        [self addSubview:self.bottomLine];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.centerY.mas_equalTo(self);
        }];
        
        [self.arrowView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-15);
            make.centerY.mas_equalTo(self);
            make.width.mas_equalTo(6);
            make.height.mas_equalTo(12);
        }];
        
        [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.arrowView.mas_left).offset(-5);
            make.centerY.mas_equalTo(self);
        }];
        
        [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self).offset(15);
            make.right.mas_equalTo(self).offset(-15);
            make.bottom.mas_equalTo(self);
            make.height.mas_equalTo(0.5);
        }];
    }
    return self;
}

-(void)setModel:(OSSVScrollCCTitleViewModel *)model {
    _model = model;
    _titleLabel.text = STLLocalizedString_(@"Your Cart", nil);
    _textLabel.text = STLLocalizedString_(@"Checkout", nil);
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.textColor = OSSVThemesColors.col_212121;
        _titleLabel.font = [UIFont boldSystemFontOfSize:16];
        _titleLabel.numberOfLines = 0;
    }
    return _titleLabel;
}

- (UIImageView *)arrowView {
    if (!_arrowView) {
        _arrowView = [[UIImageView alloc] init];
        _arrowView.image = [UIImage imageNamed:@"arrows_into"];
    }
    return _arrowView;
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.textAlignment = NSTextAlignmentRight;
        _textLabel.textColor = OSSVThemesColors.col_FF9522;
        _textLabel.font = [UIFont systemFontOfSize:12];
        _textLabel.numberOfLines = 0;
    }
    return _textLabel;
}

- (UIView *)bottomLine{
    if (!_bottomLine) {
        _bottomLine = [[UIView alloc] init];
        _bottomLine.backgroundColor = [OSSVThemesColors col_EEEEEE];
        _bottomLine.hidden = YES;
    }
    return _bottomLine;
}

@end
