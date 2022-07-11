//
//  OSSVSortItemsView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/28.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVSortItemsView.h"
#import "UIImage+STLCategory.h"

@implementation OSSVSortItemsView

#pragma mark - public methods
- (void)showMark:(BOOL)mark {
    
    if (mark) {//想选择中，判断处理
        self.selectState = !self.selectState;
    } else {//取消选中
        self.selectState = mark;
    }
    
    UIColor *color = [OSSVThemesColors col_0D0D0D];
    NSString *imgName = self.selectState ? @"filter_arrow_up" : @"filter_arrow_down";
    self.arrowImageView.image = [[UIImage imageNamed:imgName] imageWithColor:color];
}

#pragma  mark - life cycle

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self addSubview:self.contentView];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.arrowImageView];
        
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top);
            make.bottom.mas_equalTo(self.mas_bottom);
            make.centerX.mas_equalTo(self.mas_centerX);
            make.width.mas_lessThanOrEqualTo((SCREEN_WIDTH / 2.0 - 10));
        }];
        
        
        //暂时只有一个，特殊处理
        [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.contentView.mas_trailing);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(24, 24));
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.arrowImageView.mas_leading).mas_offset(-2);
            make.leading.mas_equalTo(self.contentView.mas_leading);
            make.centerY.mas_equalTo(self.contentView.mas_centerY);
        }];
    }
    return self;
}

#pragma mark - setters and getters

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:CGRectZero];
        _contentView.backgroundColor = [OSSVThemesColors stlWhiteColor];
        _contentView.userInteractionEnabled = NO;
    }
    return _contentView;
}
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textColor = [OSSVThemesColors col_0D0D0D];
        _titleLabel.font = [UIFont boldSystemFontOfSize:13];
    }
    return _titleLabel;
}

- (UIImageView *)arrowImageView {
    if (!_arrowImageView){
        _arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"filter_arrow_down"]];
    }
    return _arrowImageView;
}


@end
