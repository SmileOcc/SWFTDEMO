//
//  ZFAccountBannerTableViewCell.m
//  ZZZZZ
//
//  Created by YW on 2018/4/28.
//  Copyright © 2018年 YW. All rights reserved.
//

/*
 * 备注：该Banner模块，设计成多分管样式。
 * 最多存在四分管，布局根据分管样式以及接口字段设计。
 * 布局逻辑采用等分宽度，确定左上角坐标点进行布局。
 * 每个小 banner 具备跳转BannerModel 链接。
 */

#import "ZFAccountBannerTableViewCell.h"
#import "ZFBannerModel.h"
#import "ZFThemeManager.h"
#import <YYWebImage/YYWebImage.h>
#import "UIView+ZFViewCategorySet.h"
#import "ZFFrameDefiner.h"
#import "Constants.h"

@interface ZFAccountBannerTableViewCell()
@end

@implementation ZFAccountBannerTableViewCell
#pragma mark - init methods
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = ZFCOLOR_WHITE;
        self.contentView.backgroundColor = ZFCOLOR(247, 247, 247, 1.f);
        self.clipsToBounds = YES;
    }
    return self;
}

#pragma mark - setter
- (void)setBanners:(NSArray<ZFBannerModel *> *)banners {
    _banners = banners;
    if (_banners.count <= 0) return ;
    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSInteger branch = _banners.count;
    [_banners enumerateObjectsUsingBlock:^(ZFBannerModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat offsetX = (KScreenWidth / branch) * idx;
        CGFloat width   = KScreenWidth / branch;
        CGFloat height  = width * [obj.banner_height floatValue] / [obj.banner_width floatValue];
        YYAnimatedImageView *bannerView = [[YYAnimatedImageView alloc] initWithFrame:CGRectMake(offsetX, 0, width, height)];
        bannerView.userInteractionEnabled = YES;
        bannerView.contentMode = UIViewContentModeScaleAspectFill;
        bannerView.clipsToBounds = YES;
        [bannerView yy_setImageWithURL:[NSURL URLWithString:obj.image]
                                        placeholder:[UIImage imageNamed:@"index_banner_loading"]
                                             options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                                            progress:nil
                                           transform:nil
                                          completion:nil];
        @weakify(self);
        [bannerView addTapGestureWithComplete:^(UIView * _Nonnull view) {
            @strongify(self);
            if (self.accountBannerActionCompletionHandler) {
                self.accountBannerActionCompletionHandler(obj);
            }
        }];
        [self.contentView addSubview:bannerView];
    }];
}

@end
