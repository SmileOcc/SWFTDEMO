//
//  ZFSearchAlbumCell.m
//  ZZZZZ
//
//  Created by YW on 2018/9/18.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFSearchAlbumCell.h"
#import "UIView+LayoutMethods.h"
#import "UIColor+ExTypeChange.h"
#import "ZFLocalizationString.h"
#import "Masonry.h"

@interface ZFSearchAlbumCell()

@property (nonatomic, strong) UIView *moreView;

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation ZFSearchAlbumCell

+ (ZFSearchAlbumCell *)searchAlbumCell:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath {
    [collectionView registerClass:[ZFSearchAlbumCell class]  forCellWithReuseIdentifier:NSStringFromClass([ZFSearchAlbumCell class])];
    ZFSearchAlbumCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ZFSearchAlbumCell class]) forIndexPath:indexPath];
    return cell;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupView];
        [self layout];
    }
    return self;
}

- (void)setupView {
    [self.contentView addSubview:self.imageView];
}

- (void)layout {
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView);
    }];
}

- (void)configWithImage:(UIImage *)image type:(ZFPhotoCellType)type {
    if (self.moreView) {
        [self.moreView removeFromSuperview];
        self.moreView = nil;
    }
    
    switch (type) {
        case ZFPhotoCellTypeCamera:
            self.imageView.hidden       = YES;
            [self addMoreViewWithType:type image:image];
            self.moreView.backgroundColor = [UIColor colorWithHex:0x000000 alpha:0.2];
            break;
        case ZFPhotoCellTypeImage:
            self.imageView.hidden       = NO;
            self.imageView.image        = image;
            break;
        case ZFPhotoCellTypeMore:
            self.imageView.hidden         = YES;
            [self addMoreViewWithType:type image:image];
            self.moreView.backgroundColor = [UIColor colorWithHex:0x2d2d2d];
            break;
    }
}

#pragma mark - getter/setter
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

- (void)addMoreViewWithType:(ZFPhotoCellType)type image:(UIImage *)image {
    if (self.moreView == nil) {
        self.moreView = [[UIView alloc] init];
        [self addSubview:self.moreView];
        [self.moreView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.contentView);
        }];
        [self layoutIfNeeded];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.image = image;
        [self.moreView addSubview:imageView];
        CGFloat imageWidth = 32.0f;
        if (type == ZFPhotoCellTypeMore) {
            UILabel *label      = [[UILabel alloc] init];
            label.font          = [UIFont systemFontOfSize:14.0];
            label.textColor     = [UIColor whiteColor];
            label.textAlignment = NSTextAlignmentCenter;
            label.text          = ZFLocalizedString(@"Search_Tool_Morel", nil);
            [self.moreView addSubview:label];
            
            CGFloat topSpace  = (self.imageView.height - 32.0 - 17.0) / 2;
            [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.with.mas_equalTo(imageWidth);
                make.top.mas_equalTo(self.moreView).offset(topSpace);
                make.centerX.mas_equalTo(self.moreView.mas_centerX);
            }];
            
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(imageView.mas_bottom).offset(0.0);
                make.leading.trailing.mas_equalTo(self.moreView);
                make.height.mas_equalTo(17.0);
            }];
        } else if (type == ZFPhotoCellTypeCamera) {
            [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.with.mas_equalTo(imageWidth);
                make.center.mas_equalTo(self.moreView);
            }];
        }
    }
}

@end
