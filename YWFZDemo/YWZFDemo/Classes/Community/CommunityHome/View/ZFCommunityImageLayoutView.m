//
//  ZFCommunityImageLayoutView.m
//  ZZZZZ
//
//  Created by YW on 2017/2/10.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityImageLayoutView.h"
//#import "FDStackView.h"
#import <YYWebImage/YYWebImage.h>
#import "NSArrayUtils.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"

#define FixedSpacing 10;

@interface ZFCommunityImageLayoutView ()

@end

@implementation ZFCommunityImageLayoutView

- (instancetype)init {
    if (self = [super init]) {
        self.leadingSpacing = FixedSpacing;
        self.trailingSpacing = FixedSpacing;
        self.fixedSpacing = FixedSpacing;
        self.contentWidth = KScreenWidth;
    }
    return self;
}

- (void)setImagePaths:(NSArray *)imagePaths {
    _imagePaths = imagePaths;
    
    if (self.contentWidth <= 0) {
        self.contentWidth = KScreenWidth;
    }
    CGFloat allWidth = self.contentWidth;
    
    //清除子视图防止二次创建
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj mas_remakeConstraints:^(MASConstraintMaker *make) {
        }];
        [obj removeFromSuperview];
    }];
    
    if (![NSArrayUtils isEmptyArray:imagePaths]) {
        if (imagePaths.count == 1) {
            YYAnimatedImageView *comtentImg = [YYAnimatedImageView new];
            comtentImg.backgroundColor = [UIColor whiteColor];
            comtentImg.contentMode = UIViewContentModeScaleAspectFill;
            comtentImg.clipsToBounds = YES;
            [comtentImg yy_setImageWithURL:[NSURL URLWithString:imagePaths.firstObject]
                               placeholder:[UIImage imageNamed:@"community_loading_product"]
                                   options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                                  progress:^(NSInteger receivedSize, NSInteger expectedSize) { }
                                 transform:^UIImage *(UIImage *image, NSURL *url) {
                                     image = [image yy_imageByResizeToSize:CGSizeMake(allWidth - self.leadingSpacing - self.trailingSpacing,allWidth - self.leadingSpacing - self.trailingSpacing) contentMode:UIViewContentModeScaleAspectFill];
                                     return image;
                                 }
                                completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
                                }];
            
            [self addSubview:comtentImg];
            
            [comtentImg mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(self).with.insets(UIEdgeInsetsMake(0, self.leadingSpacing, 0, self.trailingSpacing));
                make.height.mas_equalTo(allWidth - self.leadingSpacing - self.trailingSpacing);
            }];
        } else if (imagePaths.count == 2) {
            NSMutableArray *tempArray = [NSMutableArray array];
            
            [imagePaths enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                YYAnimatedImageView *comtentImg = [YYAnimatedImageView new];
                comtentImg.backgroundColor = [UIColor whiteColor];
                comtentImg.contentMode = UIViewContentModeScaleAspectFill;
                comtentImg.clipsToBounds = YES;
                [comtentImg yy_setImageWithURL:[NSURL URLWithString:obj]
                                   placeholder:[UIImage imageNamed:@"community_loading_product"]
                                       options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                                      progress:^(NSInteger receivedSize, NSInteger expectedSize) { }
                                     transform:^UIImage *(UIImage *image, NSURL *url) {
                                         image = [image yy_imageByResizeToSize:CGSizeMake((allWidth - self.leadingSpacing - self.trailingSpacing - (imagePaths.count - 1) * self.fixedSpacing) / imagePaths.count,(allWidth - self.leadingSpacing - self.trailingSpacing - (imagePaths.count - 1) * self.fixedSpacing) / imagePaths.count) contentMode:UIViewContentModeScaleAspectFill];
                                         return image;
                                     }
                                    completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
                                    }];
                [self addSubview:comtentImg];
                [tempArray addObject:comtentImg];
            }];
            
            [tempArray mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:self.fixedSpacing leadSpacing:self.leadingSpacing tailSpacing:self.trailingSpacing];
            
            [tempArray mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.mas_equalTo(self);
                make.height.mas_equalTo((allWidth - self.leadingSpacing - self.trailingSpacing - (imagePaths.count - 1) * self.fixedSpacing) / imagePaths.count);
            }];
            
        } else if (imagePaths.count == 3) {
            NSMutableArray *tempArray = [NSMutableArray array];
            
            [imagePaths enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                YYAnimatedImageView *comtentImg = [YYAnimatedImageView new];
                comtentImg.backgroundColor = [UIColor whiteColor];
                comtentImg.contentMode = UIViewContentModeScaleAspectFill;
                comtentImg.clipsToBounds = YES;
                [comtentImg yy_setImageWithURL:[NSURL URLWithString:obj]
                                   placeholder:[UIImage imageNamed:@"community_loading_product"]
                                       options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                                      progress:^(NSInteger receivedSize, NSInteger expectedSize) { }
                                     transform:^UIImage *(UIImage *image, NSURL *url) {
                                         image = [image yy_imageByResizeToSize:CGSizeMake((allWidth - self.leadingSpacing - self.trailingSpacing - (imagePaths.count - 1) * self.fixedSpacing) / imagePaths.count,(allWidth - self.leadingSpacing - self.trailingSpacing - (imagePaths.count - 1) * self.fixedSpacing) / imagePaths.count) contentMode:UIViewContentModeScaleAspectFill];
                                         return image;
                                     }
                                    completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
                                    }];
                [self addSubview:comtentImg];
                [tempArray addObject:comtentImg];
            }];
            
            [tempArray mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:self.fixedSpacing leadSpacing:self.leadingSpacing tailSpacing:self.trailingSpacing];
            [tempArray mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.mas_equalTo(self);
                make.height.mas_equalTo((allWidth - self.leadingSpacing - self.trailingSpacing - (imagePaths.count - 1) * self.fixedSpacing) / imagePaths.count);
            }];
            
        } else if (imagePaths.count == 4) {
            
            NSMutableArray *tempTopArray = [NSMutableArray array];
            NSMutableArray *tempBottomArray = [NSMutableArray array];
            
            UIView *tempTopView = [UIView new];
            UIView *tempBottomView = [UIView new];
            
            [imagePaths enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                YYAnimatedImageView *comtentImg = [YYAnimatedImageView new];
                comtentImg.backgroundColor = [UIColor whiteColor];
                comtentImg.contentMode = UIViewContentModeScaleAspectFill;
                comtentImg.clipsToBounds = YES;
                [comtentImg yy_setImageWithURL:[NSURL URLWithString:obj]
                                   placeholder:[UIImage imageNamed:@"community_loading_product"]
                                       options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                                      progress:^(NSInteger receivedSize, NSInteger expectedSize) { }
                                     transform:^UIImage *(UIImage *image, NSURL *url) {
                                         image = [image yy_imageByResizeToSize:CGSizeMake((allWidth - self.leadingSpacing - self.trailingSpacing - self.fixedSpacing) / 2,(allWidth - self.leadingSpacing - self.trailingSpacing - self.fixedSpacing) / 2) contentMode:UIViewContentModeScaleAspectFill];
                                         return image;
                                     }
                                    completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
                                    }];
                
                if (idx < 2) {
                    [tempTopView addSubview:comtentImg];
                    [tempTopArray addObject:comtentImg];
                } else {
                    [tempBottomView addSubview:comtentImg];
                    [tempBottomArray addObject:comtentImg];
                }
            }];
            
            [tempTopArray mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:self.fixedSpacing leadSpacing:self.leadingSpacing tailSpacing:self.trailingSpacing];
            [tempTopArray mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.mas_equalTo(tempTopView);
            }];
            
            [self addSubview:tempTopView];
            [tempTopView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.leading.trailing.mas_equalTo(self);
                make.height.mas_equalTo((allWidth - self.leadingSpacing - self.trailingSpacing - self.fixedSpacing) / 2);
            }];
            
            [tempBottomArray mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:self.fixedSpacing leadSpacing:self.leadingSpacing tailSpacing:self.trailingSpacing];
            [tempBottomArray mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.mas_equalTo(tempBottomView);
            }];
            
            [self addSubview:tempBottomView];
            [tempBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(tempTopView.mas_bottom).offset(self.fixedSpacing);
                make.bottom.leading.trailing.mas_equalTo(self);
                make.height.mas_equalTo((allWidth - self.leadingSpacing - self.trailingSpacing - self.fixedSpacing) / 2);
            }];
            
        } else if (imagePaths.count == 5) {
            NSMutableArray *tempTopArray = [NSMutableArray array];
            NSMutableArray *tempBottomArray = [NSMutableArray array];
            
            UIView *tempTopView = [UIView new];
            UIView *tempBottomView = [UIView new];
            
            [imagePaths enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                YYAnimatedImageView *comtentImg = [YYAnimatedImageView new];
                comtentImg.backgroundColor = [UIColor whiteColor];
                comtentImg.contentMode = UIViewContentModeScaleAspectFill;
                comtentImg.clipsToBounds = YES;
                [comtentImg yy_setImageWithURL:[NSURL URLWithString:obj]
                                    placeholder:[UIImage imageNamed:@"community_loading_product"]
                                       options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                                      progress:^(NSInteger receivedSize, NSInteger expectedSize) { }
                                     transform:^UIImage *(UIImage *image, NSURL *url) {
                                         image = [image yy_imageByResizeToSize:CGSizeMake((allWidth - self.leadingSpacing - self.trailingSpacing - self.fixedSpacing * 2) / 3,(allWidth - self.leadingSpacing - self.trailingSpacing - self.fixedSpacing * 2) / 3) contentMode:UIViewContentModeScaleAspectFill];
                                         return image;
                                     }
                                    completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
                                    }];
                if (idx < 3) {
                    [tempTopView addSubview:comtentImg];
                    [tempTopArray addObject:comtentImg];
                } else {
                    [tempBottomView addSubview:comtentImg];
                    [tempBottomArray addObject:comtentImg];
                }
            }];
            
            [tempTopArray mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:self.fixedSpacing leadSpacing:self.leadingSpacing tailSpacing:self.trailingSpacing];
            [tempTopArray mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.mas_equalTo(tempTopView);
            }];
            
            [self addSubview:tempTopView];
            [tempTopView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.leading.trailing.mas_equalTo(self);
                make.height.mas_equalTo((allWidth - self.leadingSpacing - self.trailingSpacing - self.fixedSpacing * 2) / 3);
            }];
            
            [tempBottomArray mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:self.fixedSpacing leadSpacing:self.leadingSpacing tailSpacing:self.trailingSpacing];
            [tempBottomArray mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.mas_equalTo(tempBottomView);
            }];
            
            [self addSubview:tempBottomView];
            [tempBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(tempTopView.mas_bottom).offset(self.fixedSpacing);
                make.bottom.leading.mas_equalTo(self);
                make.height.mas_equalTo((allWidth - self.leadingSpacing - self.trailingSpacing - self.fixedSpacing * 2) / 3);
                make.width.mas_equalTo(allWidth - (allWidth - self.leadingSpacing - self.trailingSpacing - self.fixedSpacing * 2) / 3 - self.fixedSpacing);
            }];
        } else {
            NSMutableArray *tempTopArray = [NSMutableArray array];
            NSMutableArray *tempBottomArray = [NSMutableArray array];
            
            UIView *tempTopView = [UIView new];
            UIView *tempBottomView = [UIView new];
            
            [imagePaths enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (idx == 5) {
                    *stop = YES;
                }
                YYAnimatedImageView *comtentImg = [YYAnimatedImageView new];
                comtentImg.backgroundColor = [UIColor whiteColor];
                comtentImg.contentMode = UIViewContentModeScaleAspectFill;
                comtentImg.clipsToBounds = YES;
                [comtentImg yy_setImageWithURL:[NSURL URLWithString:obj]
                                    placeholder:[UIImage imageNamed:@"community_loading_product"]
                                       options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                                      progress:^(NSInteger receivedSize, NSInteger expectedSize) { }
                                     transform:^UIImage *(UIImage *image, NSURL *url) {
                                         image = [image yy_imageByResizeToSize:CGSizeMake((allWidth - self.leadingSpacing - self.trailingSpacing - self.fixedSpacing * 2) / 3,(allWidth - self.leadingSpacing - self.trailingSpacing - self.fixedSpacing * 2) / 3) contentMode:UIViewContentModeScaleAspectFill];
                                         return image;
                                     }
                                    completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
                                    }];
                if (idx < 3) {
                    [tempTopView addSubview:comtentImg];
                    [tempTopArray addObject:comtentImg];
                } else {
                    [tempBottomView addSubview:comtentImg];
                    [tempBottomArray addObject:comtentImg];
                }
            }];
            
            [tempTopArray mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:self.fixedSpacing leadSpacing:self.leadingSpacing tailSpacing:self.trailingSpacing];
            [tempTopArray mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.mas_equalTo(tempTopView);
            }];
            
            [self addSubview:tempTopView];
            [tempTopView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.leading.trailing.mas_equalTo(self);
                make.height.mas_equalTo((allWidth - self.leadingSpacing - self.trailingSpacing - self.fixedSpacing * 2) / 3);
            }];
            
            [tempBottomArray mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:self.fixedSpacing leadSpacing:self.leadingSpacing tailSpacing:self.trailingSpacing];
            [tempBottomArray mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.mas_equalTo(tempBottomView);
            }];
            
            [self addSubview:tempBottomView];
            [tempBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(tempTopView.mas_bottom).offset(self.fixedSpacing);
                make.bottom.leading.trailing.mas_equalTo(self);
                make.height.mas_equalTo((allWidth - self.leadingSpacing - self.trailingSpacing - self.fixedSpacing * 2) / 3);
            }];
        }
    }
}


+ (CGFloat)heightContentImagePaths:(NSArray *)imagePaths contentWidth:(CGFloat)contentWidth leadSpace:(CGFloat)leadSpace trailSpace:(CGFloat)trailSpace fixedSpace:(CGFloat)fixedSpace {
    
    CGFloat tempWidth = contentWidth;
    if (tempWidth <= 0) {
        tempWidth = KScreenWidth;
    }
    
    CGFloat tempHeight = 0;
    if (![NSArrayUtils isEmptyArray:imagePaths]) {
        if (imagePaths.count == 1) {
            tempHeight = tempWidth - leadSpace - trailSpace;
            
        } else if (imagePaths.count == 2) {
            tempHeight = (tempWidth - leadSpace - trailSpace - (imagePaths.count - 1) * fixedSpace) / imagePaths.count;
            
        } else if (imagePaths.count == 3) {
            tempHeight = (tempWidth - leadSpace - trailSpace - (imagePaths.count - 1) * fixedSpace) / imagePaths.count;
            
        } else if (imagePaths.count == 4) {
            tempHeight = (tempWidth - leadSpace - trailSpace - fixedSpace) / 2.0 * 2.0 + fixedSpace;
            
        } else if (imagePaths.count == 5) {
            tempHeight = (tempWidth - leadSpace - trailSpace - fixedSpace * 2) / 3.0 * 2.0 + fixedSpace;
            
        } else {
            //最多显示6个的高度
            tempHeight = (tempWidth - leadSpace - trailSpace - fixedSpace * 2) / 3 * 2.0 + fixedSpace;
        }
    }
    return tempHeight;
}
@end
