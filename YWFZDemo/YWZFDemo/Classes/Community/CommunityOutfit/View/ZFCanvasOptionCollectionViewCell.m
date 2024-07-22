//
//  ZFCanvasOptionCollectionViewCell.m
//  ZZZZZ
//
//  Created by YW on 2018/5/23.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCanvasOptionCollectionViewCell.h"
#import "ZFThemeManager.h"
#import <YYWebImage/UIImageView+YYWebImage.h>
#import "Masonry.h"

@interface ZFCanvasOptionCollectionViewCell ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, assign) BOOL selecting;

@end

@implementation ZFCanvasOptionCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.contentView.clipsToBounds   = YES;
        self.contentView.backgroundColor = [UIColor whiteColor];
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

- (void)configWithImage:(UIImage *)image isSelected:(BOOL)isSelected {
    self.imageView.image = image;
    self.selecting       = isSelected;
}

- (void)configWithURL:(NSString *)imageURL isSelected:(BOOL)isSelected {
    [self.imageView yy_setImageWithURL:[NSURL URLWithString:imageURL]
                           placeholder:[UIImage imageNamed:@"index_loading"]];
    self.selecting       = isSelected;
}

- (void)zfInitView {
    [self.contentView addSubview:self.imageView];
}

- (void)zfAutoLayoutView {
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.mas_equalTo(self.contentView);
    }];
}

#pragma mark - getter/setter
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageView;
}

- (void)setSelecting:(BOOL)selecting {
    _selecting = selecting;
    if (selecting) {
        self.imageView.layer.borderWidth = 1.5f;
        self.imageView.layer.borderColor = ZFC0xFE5269().CGColor;
    } else {
        self.imageView.layer.borderWidth = 0.0f;
    }
}

@end
