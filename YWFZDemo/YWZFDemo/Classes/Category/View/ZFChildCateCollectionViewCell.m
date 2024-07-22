//
//  ZFChildCateCollectionViewCell.m
//  ZZZZZ
//
//  Created by YW on 2018/11/21.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import "ZFChildCateCollectionViewCell.h"
#import <YYWebImage/UIImageView+YYWebImage.h>
#import <YYImage/YYAnimatedImageView.h>
#import "Masonry.h"
#import "Constants.h"
#import "ZFThemeManager.h"

@interface ZFChildCateCollectionViewCell ()

@property (nonatomic, strong) YYAnimatedImageView *imageView;
@property (nonatomic, strong) UILabel *cateNameLabel;

@end

@implementation ZFChildCateCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupView];
        [self layout];
    }
    return self;
}

- (void)setupView {
    [self.contentView addSubview:self.imageView];
    [self.contentView addSubview:self.cateNameLabel];
}

- (void)layout {
    [self.cateNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.leading.trailing.mas_equalTo(self.contentView);
        make.height.mas_equalTo(40.0f);
    }];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.mas_equalTo(self.contentView);
        make.bottom.mas_equalTo(self.cateNameLabel.mas_top);
    }];
}

- (void)configWithImageUrl:(NSString *)url cateName:(NSString *)cateName {
    self.cateNameLabel.text = cateName;

    // 加载过程中 是 loading 失败是 goods_category_allview
    @weakify(self)
    [self.imageView yy_setImageWithURL:[NSURL URLWithString:url] placeholder:[UIImage imageNamed:@"loading_cat_list"] options:kNilOptions completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
        
        if (error) {
            @strongify(self)
            self.imageView.image = [UIImage imageNamed:@"goods_category_allview"];
        }
    }];
}

#pragma mark -------- getter/setter
- (YYAnimatedImageView *)imageView {
    if (!_imageView) {
        _imageView = [[YYAnimatedImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        _imageView.backgroundColor = [UIColor clearColor];
    }
    return _imageView;
}

- (UILabel *)cateNameLabel {
    if (!_cateNameLabel) {
        _cateNameLabel = [[UILabel alloc] init];
        _cateNameLabel.font = [UIFont systemFontOfSize:12.0];
        _cateNameLabel.textColor = ZFC0x2D2D2D();
        _cateNameLabel.textAlignment = NSTextAlignmentCenter;
        _cateNameLabel.numberOfLines = 2;
    }
    return _cateNameLabel;
}
@end
