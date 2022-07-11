//
//  HotSearchHeaderView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/26.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVHotSearchsHeadeView.h"

@implementation OSSVHotSearchsHeadeView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.titleLabel];
        [self addSubview:self.lineView];

        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.offset(DSYSTEM_VERSION >= 11 ? 16 : 10);
            make.centerY.offset(0);
            make.trailing.offset(0);
            make.height.equalTo(self);
        }];
        
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.offset(DSYSTEM_VERSION >= 11 ? 16 : 10);
            make.trailing.offset(0);
            make.bottom.offset(-MIN_PIXEL * 2);
            make.height.equalTo(0.5);
        }];
        self.lineView.hidden = YES;

    }
    return self;
}

#pragma mark - LazyLoad

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = STLLocalizedString_(@"popularSearch", nil);
        _titleLabel.textColor = OSSVThemesColors.col_333333;
        _titleLabel.font = [UIFont boldSystemFontOfSize:14];
    }
    return _titleLabel;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = OSSVThemesColors.col_F1F1F1;
    }
    return _lineView;
}
@end
