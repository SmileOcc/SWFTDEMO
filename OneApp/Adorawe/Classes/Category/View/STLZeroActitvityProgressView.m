//
//  OSSVZerosActitvitysProgresssView.m
// XStarlinkProject
//
//  Created by Starlinke on 2021/7/13.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVZerosActitvitysProgresssView.h"

@interface OSSVZerosActitvitysProgresssView();

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIView *progressView;
@property (nonatomic, strong) UILabel *titLab;

@end

@implementation OSSVZerosActitvitysProgresssView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupView];
    }
    return self;
}

- (void)setupView{
    [self addSubview:self.bgView];
    [self.bgView addSubview:self.progressView];
    [self.bgView addSubview:self.titLab];
    
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.bottom.mas_equalTo(self.bgView);
        make.width.mas_equalTo(0);
    }];
    
    [self.titLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.bgView.mas_leading).offset(6);
        make.centerY.mas_equalTo(self.bgView.mas_centerY);
    }];
}

- (UIView *)bgView{
    if (!_bgView) {
        _bgView = [UIView new];
        _bgView.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.2];
    }
    return _bgView;
}

- (UIView *)progressView{
    if (!_progressView) {
        _progressView = [UIView new];
        _progressView.backgroundColor = STLThemeColor.col_B62B21;
    }
    return _progressView;
}

- (UILabel *)titLab{
    if (!_titLab) {
        _titLab = [UILabel new];
        _titLab.font = FontWithSize(10);
        _titLab.textColor = [UIColor whiteColor];
    }
    return _titLab; 
}



- (void)setValue:(NSInteger)value{
    if (value == 100) {
//        [UIView animateWithDuration:0.5 animations:^{
            [self.progressView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(self.bgView.mas_width);
                make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
            }];
            [self.bgView layoutIfNeeded];
//        }];
    }else{
        CGFloat bili = 100.00f/value;
//        [UIView animateWithDuration:0.5 animations:^{
            [self.progressView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.top.bottom.mas_equalTo(self.bgView);
                make.width.mas_equalTo(self.bgView.mas_width).dividedBy(bili);
            }];
            [self.bgView layoutIfNeeded];
//        }];
    }
    
    
    
}

- (void)setTitStr:(NSString *)titStr{
    _titLab.text = STLToString(titStr);
}

@end
