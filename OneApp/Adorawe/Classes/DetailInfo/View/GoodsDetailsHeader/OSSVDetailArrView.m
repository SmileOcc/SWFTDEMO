//
//  OSSVDetailArrView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/14.
//  Copyright © 2017年 XStarlinkProject. All rights reserved.
//

#import "OSSVDetailArrView.h"

@interface OSSVDetailArrView ()

@property (nonatomic, strong) UILabel               *leftTitle;
@property (nonatomic, strong) UILabel               *rightTitle;

@property (nonatomic, strong) UIView                *lineView; //下面的分割宽线条
@end

#define SPACING_LEADING_TRAILING 14 // 距首部,尾部宽度

@implementation OSSVDetailArrView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = OSSVThemesColors.col_FFFFFF;
        [self initializeSubView];
    }
    return self;
}

- (void)setTitle:(NSString *)title isArrow:(BOOL)isArrow {
    _leftTitle.text = title;
    _rightArrow.hidden = !isArrow;
    if (_sizeIcon) {
        _sizeIcon.hidden = YES;
    }
}

- (void)setTitle:(NSString *)title sizeContent:(NSString *)content isArrow:(BOOL)isArrow {
    _leftTitle.text = title;
    _rightTitle.text = STLToString(content);
    _rightArrow.hidden = !isArrow;
    _sizeIcon.hidden = YES;
}


- (void)setAttributeTitle:(NSAttributedString *)title isArrow:(BOOL)isArrow {
    _leftTitle.attributedText = title;
    _rightArrow.hidden = !isArrow;
    if (_sizeIcon) {
        _sizeIcon.hidden = YES;
    }
}

- (void)initializeSubView {
    
    [self addSubview:self.rightArrow];
    [self.rightArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-SPACING_LEADING_TRAILING);
        make.size.mas_equalTo(CGSizeMake(12, 12));
        make.centerY.mas_equalTo(self.mas_centerY).offset(APP_TYPE == 3 ? -8 : 0);
    }];
    
    [self addSubview:self.storeIcon];
    [self.storeIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.rightArrow.mas_leading).offset(-5);
        make.centerY.equalTo(self.rightArrow);
        make.width.height.equalTo(18);
    }];
    
    [self addSubview:self.leftTitle];
    [self.leftTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mas_leading).mas_offset(SPACING_LEADING_TRAILING);
        make.trailing.mas_equalTo(self.storeIcon.mas_leading).mas_offset(-10);
        make.centerY.mas_equalTo(self.mas_centerY).offset(APP_TYPE == 3 ? -8 :0);
    }];
    
    
    [self addSubview:self.rightTitle];
    [self.rightTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.rightArrow.mas_leading);
        make.centerY.mas_equalTo(self.mas_centerY).offset(APP_TYPE == 3 ? -8 :0);
        make.height.mas_equalTo(30);
    }];
    
    
    [self addSubview:self.sizeIcon];
    [self.sizeIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.rightTitle.mas_leading).offset(-3);
        make.centerY.equalTo(self.rightArrow);
        make.width.height.equalTo(24);
    }];
    
    if (APP_TYPE == 3) {
        [self addSubview:self.lineView];

        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self);
            make.bottom.mas_equalTo(self.mas_bottom);
            make.height.equalTo(8);
        }];
    }
}

- (UILabel *)leftTitle {
    if (!_leftTitle) {
        _leftTitle = [[UILabel alloc] init];
        if (APP_TYPE == 3) {
            _leftTitle.font = [UIFont vivaiaRegularFont:18];
        } else {
            _leftTitle.font = [UIFont boldSystemFontOfSize:14];
        }
        _leftTitle.textColor = [OSSVThemesColors col_0D0D0D];
        _leftTitle.numberOfLines = 1;
        _leftTitle.preferredMaxLayoutWidth = SCREEN_WIDTH - SPACING_LEADING_TRAILING * 2 - 12 * 2 - 4 - 12;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _leftTitle.textAlignment = NSTextAlignmentRight;
        }
    }
    return _leftTitle;
}

- (YYAnimatedImageView *)rightArrow {
    if (!_rightArrow) {
        _rightArrow = [[YYAnimatedImageView alloc] init];
        _rightArrow.image = [UIImage imageNamed:@"goods_arrow"];
        [_rightArrow convertUIWithARLanguage];
        _rightArrow.hidden = YES;
    }
    return _rightArrow;
}

- (UIImageView *)storeIcon {
    if (!_storeIcon) {
        _storeIcon = [[UIImageView alloc] init];
        _storeIcon.image = [UIImage imageNamed:@"Store_icon"];
        _storeIcon.hidden = YES;
    }
    return _storeIcon;
}

- (UILabel *)rightTitle {
    if (!_rightTitle) {
        _rightTitle = [[UILabel alloc] init];
        _rightTitle.font = [UIFont systemFontOfSize:11];
        _rightTitle.textColor = [OSSVThemesColors col_6C6C6C];
        _rightTitle.numberOfLines = 1;
        _rightTitle.preferredMaxLayoutWidth = SCREEN_WIDTH - SPACING_LEADING_TRAILING * 2 - 12 * 2 - 4 - 12;
    }
    return _rightTitle;
}

- (UIImageView *)sizeIcon {
    if (!_sizeIcon) {
        _sizeIcon = [[UIImageView alloc] init];
        _sizeIcon.image = [UIImage imageNamed:@"detail_ruler"];
        _sizeIcon.hidden = YES;
    }
    return _sizeIcon;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [UIView new];
        _lineView.backgroundColor = OSSVThemesColors.col_F8F8F8;
    }
    return _lineView;
}
@end
