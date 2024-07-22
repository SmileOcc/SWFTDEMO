//
//  ZFOrderDetailBannerCell.m
//  ZZZZZ
//
//  Created by YW on 2019/4/10.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFOrderDetailBannerCell.h"
#import <Masonry/Masonry.h>
#import <YYWebImage/YYWebImage.h>

@interface ZFOrderDetailBannerCell ()

@property (nonatomic, strong) YYAnimatedImageView *bannerImage;

@end

@implementation ZFOrderDetailBannerCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self addSubview:self.bannerImage];
        
        [self.bannerImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
            make.height.mas_equalTo(self.bannerImage.mas_width).multipliedBy(0.24);
        }];
    }
    return self;
}

#pragma mark - Property Method


- (void)configurate:(NSString *)imageUrl scale:(CGFloat)scale {
    self.imageUrl = imageUrl;
    
    [self.bannerImage yy_setImageWithURL:[NSURL URLWithString:_imageUrl] placeholder:[UIImage imageNamed:@"loading_AdvertBg"]];
    
    if (scale <= 0) {
        scale = 0.24;
    }
    [self.bannerImage mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.bannerImage.mas_width).multipliedBy(scale);
    }];
}

- (YYAnimatedImageView *)bannerImage
{
    if (!_bannerImage) {
        _bannerImage = ({
            YYAnimatedImageView *img = [[YYAnimatedImageView alloc] init];
            img.contentMode = UIViewContentModeScaleAspectFill;
            img.layer.masksToBounds = YES;
            img;
        });
    }
    return _bannerImage;
}

@end
