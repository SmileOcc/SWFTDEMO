
//
//  ZFMyOrderListGoodsImageView.m
//  ZZZZZ
//
//  Created by YW on 2018/4/26.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFMyOrderListGoodsImageView.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import <YYWebImage/UIImageView+YYWebImage.h>
#import <YYImage/YYImage.h>
#import "Masonry.h"

@interface ZFMyOrderListGoodsImageView() <ZFInitViewProtocol>
@property (nonatomic, strong) YYAnimatedImageView           *imageView;
@property (nonatomic, strong) UILabel               *numberLabel;
@property (nonatomic, strong) UILabel               *leaveCountLabel;

@end

@implementation ZFMyOrderListGoodsImageView
#pragma mark - init methods
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.backgroundColor = ZFCOLOR_WHITE;
    [self addSubview:self.imageView];
    [self.imageView addSubview:self.numberLabel];
    [self.imageView addSubview:self.leaveCountLabel];
}

- (void)zfAutoLayoutView {
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self).insets(UIEdgeInsetsZero);
    }];
    
    [self.numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(self.imageView);
        make.height.mas_equalTo(15);
    }];
    
    [self.leaveCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.imageView).insets(UIEdgeInsetsZero);
    }];
}

#pragma mark - setter
- (void)setImageUrl:(NSString *)imageUrl {
    _imageUrl = imageUrl;
    [self.imageView yy_setImageWithURL:[NSURL URLWithString:_imageUrl]
                               placeholder:[UIImage imageNamed:@"loading_cat_list"]
                                    options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                                   progress:nil
                                  transform:nil
                                 completion:nil];
}

- (void)setGoodsNumber:(NSString *)goodsNumber {
    _goodsNumber = goodsNumber;
    if ([_goodsNumber integerValue] <= 1) {
        self.numberLabel.hidden = YES;
        return ;
    }
    self.numberLabel.hidden = NO;
    self.numberLabel.text = [NSString stringWithFormat:@"x%@", _goodsNumber];
    
}

- (void)setLeaveCount:(NSString *)leaveCount {
    _leaveCount = leaveCount;
    if ([_leaveCount integerValue] > 0) {
        self.numberLabel.hidden = YES;
        self.leaveCountLabel.hidden = NO;
        self.leaveCountLabel.text = [NSString stringWithFormat:@"+%@", _leaveCount];
    } else {
        self.leaveCountLabel.hidden = YES;
    }
}


#pragma mark - getter
- (YYAnimatedImageView *)imageView {
    if (!_imageView) {
        _imageView = [[YYAnimatedImageView alloc] initWithFrame:CGRectZero];
        _imageView.image = [UIImage imageNamed:@"loading_cat_list"];
        _imageView.userInteractionEnabled = YES;
    }
    return _imageView;
}

- (UILabel *)numberLabel {
    if (!_numberLabel) {
        _numberLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _numberLabel.textColor = ZFCOLOR_WHITE;
        _numberLabel.font = [UIFont systemFontOfSize:12];
        _numberLabel.textAlignment = NSTextAlignmentCenter;
        _numberLabel.hidden = YES;
        _numberLabel.backgroundColor = ZFCOLOR(0, 0, 0, .3f);
        _numberLabel.layer.masksToBounds = YES;
    }
    return _numberLabel;
}

- (UILabel *)leaveCountLabel {
    if (!_leaveCountLabel) {
        _leaveCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _leaveCountLabel.textColor = ZFCOLOR_WHITE;
        _leaveCountLabel.font = [UIFont systemFontOfSize:12];
        _leaveCountLabel.textAlignment = NSTextAlignmentCenter;
        _leaveCountLabel.hidden = YES;
        _leaveCountLabel.backgroundColor = ZFCOLOR(0, 0, 0, .3f);
        _leaveCountLabel.layer.masksToBounds = YES;
    }
    return _leaveCountLabel;
}

@end
