//
//  ZFCateBannerCollectionViewCell.m
//  ZZZZZ
//
//  Created by YW on 2018/12/6.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import "ZFCateBannerCollectionViewCell.h"
#import <YYWebImage/UIImageView+YYWebImage.h>
#import <YYImage/YYAnimatedImageView.h>
#import "Masonry.h"

@interface ZFCateBannerCollectionViewCell ()

@property (nonatomic, strong) YYAnimatedImageView *imageView;

@end

@implementation ZFCateBannerCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.imageView];
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.contentView);
        }];
    }
    return self;
}

- (void)configWithImageURL:(NSString *)url {
    [self.imageView yy_setImageWithURL:[NSURL URLWithString:url] placeholder:[UIImage imageNamed:@"index_banner_loading"]];
}

#pragma mark - getter/setter
- (YYAnimatedImageView *)imageView {
    if (!_imageView) {
        _imageView = [[YYAnimatedImageView alloc] init];
    }
    return _imageView;
}

@end
