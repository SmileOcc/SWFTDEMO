//
//  HotSearchCollectionCell.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/24.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVHotSearchCCCell.h"

@interface OSSVHotSearchCCCell ()


@property (nonatomic, strong) UIView *bottomLineView;

@end

@implementation OSSVHotSearchCCCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        
        if (APP_TYPE == 3) {
            self.layer.borderColor = OSSVThemesColors.col_E1E1E1.CGColor;
            self.layer.borderWidth = 0.5;
        }else{
            self.layer.cornerRadius = 16.0;
            self.clipsToBounds = YES;
        }
        
        [self addSubview:self.hotImageView];
        [self addSubview:self.titleLabel];
        [self addSubview:self.lineView];
    }
    return self;
}

- (void)setIs_hot:(NSInteger)is_hot{
    _is_hot = is_hot;
    if (_is_hot == 1) {
        
        self.backgroundColor = [OSSVThemesColors col_FDF1F0];
        self.titleLabel.textColor = OSSVThemesColors.col_B62B21;
        [self.hotImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.offset(12);
            make.centerY.offset(0);
            make.width.height.equalTo(12);
        }];
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.hotImageView.mas_trailing).offset(4);
            make.centerY.offset(0);
            make.trailing.offset(-12);
            make.height.equalTo(self);
        }];
    }else{
        self.backgroundColor = [OSSVThemesColors col_F5F5F5];
        self.titleLabel.textColor = OSSVThemesColors.col_666666;
        [self.hotImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.offset(0);
            make.centerY.offset(0);
            make.width.height.equalTo(0);
        }];
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.offset(0);
            make.centerY.offset(0);
            make.trailing.offset(0);
            make.height.equalTo(self);
        }];
    }
    
    if (APP_TYPE == 3) {
        self.backgroundColor = [OSSVThemesColors col_FFFFFF];
        self.titleLabel.textColor = _is_hot == 1 ? [OSSVThemesColors col_000000:1.0] : [OSSVThemesColors col_000000:0.7];
    }
    
    [self.lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.titleLabel.mas_leading);
        make.trailing.mas_equalTo(self.titleLabel.mas_trailing);
        make.bottom.offset(-MIN_PIXEL * 2);
        make.height.equalTo(0.5);
    }];
    
}

#pragma mark - LazyLoad
- (YYAnimatedImageView *)hotImageView{
    if (!_hotImageView) {
        _hotImageView = [YYAnimatedImageView new];
        _hotImageView.image = STLImageWithName(@"sold_hot");
    }
    return  _hotImageView;
}


- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [OSSVThemesColors col_999999];
        _titleLabel.font = [UIFont systemFontOfSize:11];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = OSSVThemesColors.col_F1F1F1;
        _lineView.hidden = YES;
    }
    return _lineView;
}
@end
