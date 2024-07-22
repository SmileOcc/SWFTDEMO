//
//  ZFOutfitSelectItemCollectionViewCell.m
//  ZZZZZ
//
//  Created by YW on 2018/5/23.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFOutfitSelectItemCollectionViewCell.h"
#import "ZFThemeManager.h"
#import <YYWebImage/YYWebImage.h>
#import "UIView+LayoutMethods.h"
#import "Masonry.h"

@interface ZFOutfitSelectItemCollectionViewCell() <CAAnimationDelegate>

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *animationView;

@end

@implementation ZFOutfitSelectItemCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

- (void)configDataWithImageURL:(NSString *)url isSelected:(BOOL)isSelected {
    [self.imageView yy_setImageWithURL:[NSURL URLWithString:url]
                           placeholder:[UIImage imageNamed:@"loading_cat_list"]];
    if (isSelected) {
        self.layer.borderWidth = 0.5f;
    } else {
        self.layer.borderWidth = 0.0f;
    }
}

- (void)zfInitView {
    self.contentView.clipsToBounds = YES;
    self.layer.borderWidth = 0.0f;
    self.layer.borderColor = ZFC0x2D2D2D().CGColor;
    [self.contentView addSubview:self.imageView];
}

- (void)zfAutoLayoutView {
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.mas_equalTo(self.contentView);
    }];
}

- (void)selectedAnimation {
    [self.contentView addSubview:self.animationView];
    self.animationView.frame  = CGRectMake(0.0, 0.0, self.contentView.height, self.contentView.height);
    self.animationView.layer.cornerRadius = self.animationView.height / 2;
    self.animationView.center = CGPointMake(self.contentView.bounds.size.width / 2, self.contentView.bounds.size.height / 2);
    
    CABasicAnimation *lightScaleAnimation  = [CABasicAnimation animation];
    lightScaleAnimation.keyPath            = @"transform.scale";
    lightScaleAnimation.fromValue          = @0.1;
    lightScaleAnimation.toValue            = @1.3;
    lightScaleAnimation.duration           = 0.12;
    lightScaleAnimation.delegate           = self;
    
    [self.animationView.layer addAnimation:lightScaleAnimation forKey:@"lightScale"];;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [self.animationView removeFromSuperview];
}

#pragma mark - getter/setter
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _imageView;
}

- (UIView *)animationView {
    if (!_animationView) {
        _animationView = [[UIView alloc] init];
        _animationView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.2];
    }
    return _animationView;
}

@end
