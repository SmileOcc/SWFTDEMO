//
//  ZFCategoryParentBannerCell.m
//  ZZZZZ
//
//  Created by YW on 2019/3/12.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCategoryParentBannerCell.h"
#import "UIImage+ZFExtended.h"
#import <YYWebImage/YYWebImage.h>
#import <YYWebImage/UIImageView+YYWebImage.h>
#import <YYImage/YYAnimatedImageView.h>
#import "Masonry.h"

@interface ZFCategoryParentBannerCell ()
@property (nonatomic, strong) YYAnimatedImageView *imageView;
@end

@implementation ZFCategoryParentBannerCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupView];
        [self layout];
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)setupView {
    [self.contentView addSubview:self.imageView];
}

- (void)layout {
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

- (void)configWithImageUrl:(NSString *)url {
//    [self.imageView yy_setImageWithURL:[NSURL URLWithString:url] placeholder:[UIImage imageNamed:@"index_loading"]];
    
    [self.imageView yy_setImageWithURL:[NSURL URLWithString:url]
    placeholder:[UIImage imageNamed:@"index_loading"]
        options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
       progress:nil
      transform:^UIImage *(UIImage *image, NSURL *url) {
          if ([image isKindOfClass:[YYImage class]]) {
              YYImage *showImage = (YYImage *)image;
              if (showImage.animatedImageType == YYImageTypeGIF || showImage.animatedImageData) {
                  return image;
              }
          }
          return [image zf_drawImageToOpaque];
        
    } completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
        if (image.size.height < 80) { //临时适配放大模式下的"文本小图"会显示不全的bug
            self.imageView.contentMode = UIViewContentModeScaleToFill;
        } else {
            self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        }
    }];
}

#pragma mark -------- getter/setter

- (YYAnimatedImageView *)imageView {
    if (!_imageView) {
        _imageView = [[YYAnimatedImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.backgroundColor = [UIColor clearColor];
    }
    return _imageView;
}

@end
