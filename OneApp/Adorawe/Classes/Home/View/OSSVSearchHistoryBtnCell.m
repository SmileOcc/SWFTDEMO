//
//  SearchHistoryButtonCell.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/19.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVSearchHistoryBtnCell.h"

@implementation OSSVSearchHistoryBtnCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        
        if (APP_TYPE == 3) {
            self.layer.borderColor = OSSVThemesColors.col_E1E1E1.CGColor;
            self.layer.borderWidth = 0.5;
            self.textLab.textColor = [OSSVThemesColors col_000000:0.7];
        }else{
            self.backgroundColor = [OSSVThemesColors col_F5F5F5];
            self.layer.cornerRadius = 16.0;
            self.clipsToBounds = YES;
            self.selectedBackgroundView = self.bgView;
        }
        
        

        [self.contentView addSubview:self.textLab];
        
        [self.textLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView).insets(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
    }
    return self;
}

- (void)prepareForReuse{
    [super prepareForReuse];
    self.textLab.text = nil;
    self.selected = NO;
}

#pragma mark - LazyLoad

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = OSSVThemesColors.col_EDEDED;
    }
    return _bgView;
}

- (UILabel *)textLab {
    if (!_textLab) {
        _textLab = [[UILabel alloc] init];
        _textLab.font = [UIFont systemFontOfSize:12];
        _textLab.textColor = [OSSVThemesColors col_999999];
        _textLab.textAlignment = NSTextAlignmentCenter;
    }
    return _textLab;
}

@end
