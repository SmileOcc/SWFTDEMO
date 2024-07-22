//
//  ZFCommunityLiveLlistHeaderView.m
//  ZZZZZ
//
//  Created by YW on 2019/4/2.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityLiveLlistHeaderView.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import <YYWebImage/YYWebImage.h>
#import "YWCFunctionTool.h"
#import "Masonry.h"
#import "Constants.h"


@interface  ZFCommunityLiveLlistHeaderView()<ZFInitViewProtocol>
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) YYAnimatedImageView *bgImageView;
@property (nonatomic, strong) YYAnimatedImageView *leftImageView;
@property (nonatomic, strong) YYAnimatedImageView *rightImageView;


@end

@implementation ZFCommunityLiveLlistHeaderView

+ (ZFCommunityLiveLlistHeaderView *)headWithCollectionView:(UICollectionView *)collectionView Kind:(NSString *)kind IndexPath:(NSIndexPath *)indexPath {
    [collectionView registerClass:[ZFCommunityLiveLlistHeaderView class] forSupplementaryViewOfKind:kind withReuseIdentifier:NSStringFromClass([self class])];
    return [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:NSStringFromClass([self class]) forIndexPath:indexPath];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = ZFC0xFFFFFF();
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - ZFInitViewProtocol
- (void)zfInitView {
    [self addSubview:self.titleLabel];
    [self addSubview:self.leftImageView];
    [self addSubview:self.rightImageView];
}

- (void)zfAutoLayoutView {
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.centerY.mas_equalTo(self.mas_centerY);
    }];
    
    [self.leftImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.titleLabel.mas_leading).offset(-16);
        make.centerY.mas_equalTo(self.mas_centerY);
    }];
    
    [self.rightImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.titleLabel.mas_trailing).offset(16);
        make.centerY.mas_equalTo(self.mas_centerY);
    }];
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = ZFToString(title);
}

- (void)updateLeftImage:(UIImage *)leftImage rightImage:(UIImage *)rightImage {
    self.leftImageView.image = leftImage;
    self.rightImageView.image = rightImage;
}
#pragma mark - getter
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont boldSystemFontOfSize:18];
        _titleLabel.textColor = ZFC0x030303();
        _titleLabel.text = @"";
    }
    return _titleLabel;
}

- (YYAnimatedImageView *)bgImageView {
    if(!_bgImageView){
        _bgImageView = [[YYAnimatedImageView alloc] init];
        _bgImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_bgImageView];
        [self insertSubview:_bgImageView atIndex:0];
        
        [_bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self).insets(UIEdgeInsetsZero);
        }];
    }
    return _bgImageView;
}


- (YYAnimatedImageView *)leftImageView {
    if(!_leftImageView){
        _leftImageView = [[YYAnimatedImageView alloc] init];
        _leftImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _leftImageView;
}

- (YYAnimatedImageView *)rightImageView {
    if(!_rightImageView){
        _rightImageView = [[YYAnimatedImageView alloc] init];
        _rightImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _rightImageView;
}
@end
