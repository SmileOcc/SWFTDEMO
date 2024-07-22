//
//  ZFNativeBannerBranchCell.m
//  ZZZZZ
//
//  Created by YW on 1/8/18.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFNativeBannerBranchCell.h"
#import "ZFNativeBannerModel.h"
#import "ZFInitViewProtocol.h"
#import "ZFBannerTimeView.h"
#import "YouTuBePlayerView.h"
#import <YYWebImage/YYWebImage.h>
#import "UIView+LayoutMethods.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"

@interface ZFNativeBannerBranchCell ()<ZFInitViewProtocol>
@property (nonatomic, strong) YYAnimatedImageView     *branchBannerImageView;
@property (nonatomic, strong) YYAnimatedImageView     *couponImgView;
@property (nonatomic, strong) ZFBannerTimeView        *countDownView;
@property (nonatomic, strong) YouTuBePlayerView       *playerVideoView;
@property (nonatomic, strong) UIButton                *playerVideoBtn;
@end

@implementation ZFNativeBannerBranchCell

- (void)dealloc {
    if (_playerVideoView) {
        [self.playerVideoView stopVideo];
        [self.playerVideoView removePlyerViewFromSuperView];
        self.playerVideoView = nil;
    }
}

+ (ZFNativeBannerBranchCell *)branchBannerCellWith:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath {
    [collectionView registerClass:[ZFNativeBannerBranchCell class]  forCellWithReuseIdentifier:NSStringFromClass([self class])];
    return [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([self class]) forIndexPath:indexPath];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.branchBannerImageView yy_cancelCurrentImageRequest];
    self.branchBannerImageView.image = nil;
    self.playerVideoView.hidden = YES;
    self.playerVideoBtn.hidden = YES;
    [self.playerVideoView stopVideo];
    [self.countDownView removeFromSuperview];
    self.countDownView = nil;
}

#pragma mark - ZFInitViewProtocol
- (void)zfInitView {
    [self.contentView addSubview:self.playerVideoView];
    [self.contentView addSubview:self.branchBannerImageView];
    [self.contentView addSubview:self.playerVideoBtn];
}

- (void)zfAutoLayoutView {
    [self.playerVideoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView).insets(UIEdgeInsetsZero);
    }];

    [self.branchBannerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView).insets(UIEdgeInsetsZero);
    }];
    
    [self.playerVideoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.contentView.mas_centerX);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(50, 50));
    }];
}

#pragma mark - Setter
- (void)setBranchBannerModel:(ZFNativeBannerModel *)branchBannerModel {
    _branchBannerModel = branchBannerModel;
    
    [self.branchBannerImageView.layer removeAnimationForKey:@"fadeAnimation"];
    
    @weakify(self)
    [self.branchBannerImageView yy_setImageWithURL:[NSURL URLWithString:branchBannerModel.bannerImg]
                                      placeholder:[UIImage imageNamed:@"index_banner_loading"]
                                           options:YYWebImageOptionAvoidSetImage
                                        completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                                            @strongify(self)
                                            if (image && stage == YYWebImageStageFinished) {
                                                self.branchBannerImageView.image = image;
                                                if (from != YYWebImageFromMemoryCacheFast) {
                                                    CATransition *transition = [CATransition animation];
                                                    transition.duration = KImageFadeDuration;
                                                    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                                                    transition.type = kCATransitionFade;
                                                    [self.branchBannerImageView.layer addAnimation:transition forKey:@"fadeAnimation"];
                                                }
                                            }
                                        }];
    
    // 判断是否需要播放视频
    if (branchBannerModel.bannerType == ZFBannerTypeVideo) { //视频类型
        self.playerVideoBtn.hidden = NO;
        self.branchBannerImageView.hidden = (self.playerVideoView.hidden == NO);
    } else {
        self.branchBannerImageView.hidden = NO;
        self.playerVideoBtn.hidden = YES;
        self.playerVideoView.hidden = YES;
    }
    
    NSString *languageCode = [ZFLocalizationString shareLocalizable].currentLanguageName;
    NSString *lang = @"en";
    if ([languageCode hasPrefix:@"Es"]) {
        lang = @"es";
    } else if ([languageCode hasPrefix:@"Fr"]) {
        lang = @"fr";
    }
    [self.branchBannerImageView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    // 领取完  4
    if (branchBannerModel.couponStatuType == ZFBannerCouponStateTypeUsed) {
        [self addCouponImgView:[NSString stringWithFormat:@"coupon_used_%@",lang]];
    }
    
    // 已经领过 2
    if (branchBannerModel.couponStatuType == ZFBannerCouponStateTypeClaimed &&
        [AccountManager sharedManager].isSignIn) {
        [self addCouponImgView:[NSString stringWithFormat:@"coupon_claimed_%@",lang]];
    }
    
    if (!ZFIsEmptyString(branchBannerModel.bannerCountDown) && self.branch == 1 && [branchBannerModel.countdownShow boolValue]) {
        [self.contentView addSubview:self.countDownView];
        [self.countDownView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.contentView).offset(-12);
            make.centerX.mas_equalTo(self.contentView);
        }];
        
        //开启倒计时任务
        [self.countDownView startCountDownTimerStamp:branchBannerModel.bannerCountDown
                                        withTimerKey:branchBannerModel.nativeCountDownTimerKey];
    }
}

#pragma mark - Private method
- (void)addCouponImgView:(NSString *)name {
    UIImage *image = [UIImage imageNamed:name];
    [self.branchBannerImageView addSubview:self.couponImgView];
    
    CGFloat scale = self.contentView.width / KScreenWidth;
    if (scale == 0.0) {
        scale = 1.0;
    } else if (scale != 1.0) {
        scale = 0.5;
    }
    [self.couponImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(-16);
        make.centerY.equalTo(self.branchBannerImageView);
        make.size.mas_equalTo(CGSizeMake(image.size.width * scale, image.size.height * scale));
    }];
    self.couponImgView.image = image;
}

// 播放视频
- (void)playVideoAction {
    if (self.branchBannerModel.bannerType != ZFBannerTypeVideo ) return;
    
    if (self.branchBannerModel.deeplinkUri) {
        self.branchBannerImageView.hidden = YES;
        self.playerVideoBtn.hidden = YES;
        self.playerVideoView.hidden = NO;
        [self.playerVideoView basePlayVideoWithVideoID:self.branchBannerModel.deeplinkUri];
    } else {
        self.branchBannerImageView.hidden = NO;
        self.playerVideoBtn.hidden = NO;
        self.playerVideoView.hidden = YES;
    }
}
/**
 * 主动暂停视频播放
 */
- (void)pausePlayVideo {
    if (_playerVideoView && _playerVideoView.hidden == NO) {
        [self.playerVideoView pauseVideo];
    }
}

#pragma mark - Getter
- (YYAnimatedImageView *)branchBannerImageView {
    if (!_branchBannerImageView) {
        _branchBannerImageView = [YYAnimatedImageView new];
        _branchBannerImageView.contentMode = UIViewContentModeScaleAspectFill;
        _branchBannerImageView.clipsToBounds  = YES;
    }
    return _branchBannerImageView;
}

- (YYAnimatedImageView *)couponImgView {
    if (!_couponImgView) {
        _couponImgView = [YYAnimatedImageView new];
        _couponImgView.contentMode = UIViewContentModeScaleAspectFill;
        _couponImgView.clipsToBounds  = YES;
    }
    return _couponImgView;
}

- (ZFBannerTimeView *)countDownView {
    if (!_countDownView) {
        _countDownView = [[ZFBannerTimeView alloc] init];
    }
    return _countDownView;
}

- (YouTuBePlayerView *)playerVideoView {
    if(!_playerVideoView){
        _playerVideoView = [[YouTuBePlayerView alloc] init];
        _playerVideoView.backgroundColor = [UIColor blackColor];
        [_playerVideoView cancelSettingOperateView];
        _playerVideoView.hidden = YES;
        [_playerVideoView setVideoPlayStatusChange:^(PlayerState playerState){
            if (playerState == PlayerStatePaused) {
                showSystemStatusBar();
            }
        }];
    }
    return _playerVideoView;
}

- (UIButton *)playerVideoBtn {
    if(!_playerVideoBtn){
        _playerVideoBtn = [[UIButton alloc] init];
        [_playerVideoBtn setBackgroundImage:ZFImageWithName(@"community_home_play_big") forState:0];
        [_playerVideoBtn addTarget:self action:@selector(playVideoAction) forControlEvents:(UIControlEventTouchUpInside)];
        _playerVideoBtn.hidden = YES;
    }
    return _playerVideoBtn;
}

@end
