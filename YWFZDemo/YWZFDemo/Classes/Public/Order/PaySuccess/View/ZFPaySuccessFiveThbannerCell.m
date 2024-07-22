//
//  ZFPaySuccessFiveThbannerCell.m
//  ZZZZZ
//
//  Created by YW on 2019/5/6.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFPaySuccessFiveThbannerCell.h"
#import "ZFBannerModel.h"
#import "ZFThemeManager.h"
#import <YYWebImage/YYWebImage.h>
#import "UIView+ZFViewCategorySet.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Constants.h"
#import "Masonry.h"

@interface ZFPaySuccessFiveThbannerCell ()
@property (nonatomic, strong) YYAnimatedImageView *bannerView;
@end

@implementation ZFPaySuccessFiveThbannerCell

+ (instancetype)bannerCellWith:(UITableView *)tableView {
    [tableView registerClass:[self class] forCellReuseIdentifier:NSStringFromClass([self class])];
    return [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([self class])];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = ZFCOLOR_WHITE;
        self.selectionStyle = UITableViewCellSeparatorStyleNone;
        [self.contentView addSubview:self.bannerView];
        [self.bannerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(12, 12, 12, 12));
        }];
    }
    return self;
}

- (void)setBannerModel:(ZFBannerModel *)bannerModel {
    _bannerModel = bannerModel;
    
    [self.bannerView.layer removeAnimationForKey:@"fadeAnimation"];
    [self.bannerView yy_setImageWithURL:[NSURL URLWithString:bannerModel.image]
                       placeholder:[UIImage imageNamed:@"index_banner_loading"]
                           options:YYWebImageOptionAvoidSetImage
                        completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                            if (image && stage == YYWebImageStageFinished) {
                                self.bannerView.image = image;
                                if (from != YYWebImageFromMemoryCacheFast) {
                                    CATransition *transition = [CATransition animation];
                                    transition.duration = KImageFadeDuration;
                                    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                                    transition.type = kCATransitionFade;
                                    [self.bannerView.layer addAnimation:transition forKey:@"fadeAnimation"];
                                }
                            }
                        }];
}

- (YYAnimatedImageView *)bannerView {
    if (!_bannerView) {
        _bannerView = [[YYAnimatedImageView alloc] initWithFrame:CGRectZero];
        _bannerView.userInteractionEnabled = YES;
        _bannerView.contentMode = UIViewContentModeScaleAspectFit;
        _bannerView.clipsToBounds = YES;
        @weakify(self);
        [_bannerView addTapGestureWithComplete:^(UIView * _Nonnull view) {
            @strongify(self);
            if (self.payBannerHandler) {
                self.payBannerHandler(self.bannerModel);
            }
        }];
    }
    return _bannerView;
}

@end
