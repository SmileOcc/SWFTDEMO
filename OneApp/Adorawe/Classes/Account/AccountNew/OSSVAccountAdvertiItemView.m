//
//  OSSVAccountAdvertiItemView.m
// XStarlinkProject
//
//  Created by fan wang on 2021/6/10.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVAccountAdvertiItemView.h"

@interface OSSVAccountAdvertiItemView ()
@property (weak,nonatomic) YYAnimatedImageView *backgroundImg;
@end

@implementation OSSVAccountAdvertiItemView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setUpViews];
    }
    return self;
}

-(void)setUpViews{
    YYAnimatedImageView *imageV = [[YYAnimatedImageView alloc] init];
    [self addSubview:imageV];
    [imageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    _backgroundImg = imageV;
    _backgroundImg.contentMode = UIViewContentModeScaleAspectFill;
    _backgroundImg.layer.masksToBounds = YES;
}

-(void)setDefaultbgImg:(UIImage *)defaultbgImg{
    _defaultbgImg = defaultbgImg;
    self.backgroundImg.image = defaultbgImg;
}

-(void)setBgUrl:(NSString *)bgUrl{
    _bgUrl = bgUrl;
//    self.backgroundImg.yy_imageURL = nil;
    
    @weakify(self)
    [self.backgroundImg yy_setImageWithURL:[NSURL URLWithString:bgUrl] placeholder:nil options:kNilOptions completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
        @strongify(self)
        
        self.backgroundImg.image = image;
        if (self.backgroundImg.image) {
            self.backgroundColor = [UIColor clearColor];
        }else{
            self.backgroundColor = OSSVThemesColors.col_EEEEEE;
        }
        
    }];
}

@end
