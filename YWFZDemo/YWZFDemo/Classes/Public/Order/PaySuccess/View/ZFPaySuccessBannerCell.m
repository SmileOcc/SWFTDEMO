//
//  ZFPaySuccessBannerCell.m
//  ZZZZZ
//
//  Created by YW on 7/6/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFPaySuccessBannerCell.h"
#import "ZFBannerModel.h"
#import "ZFThemeManager.h"
#import <YYWebImage/YYWebImage.h>
#import "UIView+ZFViewCategorySet.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Constants.h"
#import "Masonry.h"

@implementation ZFPaySuccessBannerCell

+ (instancetype)bannerCellWith:(UITableView *)tableView {
    [tableView registerClass:[self class] forCellReuseIdentifier:NSStringFromClass([self class])];
    return [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([self class])];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = ZFCOLOR_WHITE;
        self.selectionStyle = UITableViewCellSeparatorStyleNone;
    }
    return self;
}

- (void)setBanners:(NSArray<ZFBannerModel *> *)banners {
    _banners = banners;
    if (_banners.count <= 0) return ;
    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSInteger branch = _banners.count;
    ZFBannerModel *model = banners.firstObject;
    BOOL isValid = !ZFIsEmptyString(model.banner_height) && !ZFIsEmptyString(model.banner_width);
    CGFloat scale = isValid ? [model.banner_width floatValue] / [model.banner_height floatValue] : 0;
    CGFloat bannerWidth = KScreenWidth / branch;
    CGFloat bannerHeight = scale > 0 ?  (bannerWidth / scale) : 0.1;
    
    [_banners enumerateObjectsUsingBlock:^(ZFBannerModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        YYAnimatedImageView *bannerView = [[YYAnimatedImageView alloc] initWithFrame:CGRectMake((KScreenWidth / branch) * idx, 0, KScreenWidth / branch, bannerHeight)];
        bannerView.userInteractionEnabled = YES;
        bannerView.contentMode = UIViewContentModeScaleAspectFill;
        [bannerView.layer removeAnimationForKey:@"fadeAnimation"];
        [bannerView yy_setImageWithURL:[NSURL URLWithString:obj.image]
                                          placeholder:[UIImage imageNamed:@"index_banner_loading"]
                                               options:YYWebImageOptionAvoidSetImage
                                            completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                                                if (image && stage == YYWebImageStageFinished) {
                                                    bannerView.image = image;
                                                    if (from != YYWebImageFromMemoryCacheFast) {
                                                        CATransition *transition = [CATransition animation];
                                                        transition.duration = KImageFadeDuration;
                                                        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                                                        transition.type = kCATransitionFade;
                                                        [bannerView.layer addAnimation:transition forKey:@"fadeAnimation"];
                                                    }
                                                }
                                            }];
        @weakify(self);
        [bannerView addTapGestureWithComplete:^(UIView * _Nonnull view) {
            @strongify(self);
            if (self.paySuccessBannerHandler) {
                self.paySuccessBannerHandler(obj, idx);
            }
        }];
        [self.contentView addSubview:bannerView];
    }];
    // 由外部设置高度,不能设置约束,否则无法点击
//    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.height.mas_offset(bannerHeight);
//    }];
}

@end
