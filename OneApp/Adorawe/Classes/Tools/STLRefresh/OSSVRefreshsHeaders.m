//
//  OSSVRefreshsHeaders.m
// XStarlinkProject
//
//  Created by odd on 2020/9/24.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVRefreshsHeaders.h"
#import "YYText.h"

/** 刷新控件的状态 */
typedef NS_ENUM(NSInteger, RefreshState) {
    /** 松开就可以进行刷新的状态 */
    RefreshStateBannerPulling=10,
    /** Banner即将刷新的状态 */
    RefreshStateBannerWillRefresh,
    /** 触发 下拉banner */
    RefreshStateDropBannerTriggered,
    /** 显示 下拉banner,类似淘宝二楼效果 */
    RefreshStateDropBannerShowing
};

@interface OSSVRefreshsHeaders ()
//@property (nonatomic,strong) LOTAnimationView       *startAnimView;
//@property (nonatomic,strong) LOTAnimationView       *loadingAnimView;
@property (nonatomic, strong) YYLabel               *tipLabel;
@property (nonatomic, strong) YYAnimatedImageView   *bannerView;
@property (nonatomic, assign) BOOL                  hideTitle;
@end

@implementation OSSVRefreshsHeaders

#pragma mark 初始化配置（添加子控件）
- (void)prepare {
    [super prepare];
    
    self.backgroundColor = [UIColor clearColor];
    self.startViewOffsetY = 5;
    
    // 设置控件的高度
    self.mj_h = 66;
    
    // 第一阶段动画 (从小变大)
//    self.startAnimView = [LOTAnimationView animationNamed:@"header_loading_uploadingstart"];
//    self.startAnimView.contentMode = UIViewContentModeScaleAspectFill;
//    [self addSubview:self.startAnimView];
//    self.startAnimView.loopAnimation = YES;
    
    // 第二阶段动画 (填充转圈)
//    self.loadingAnimView = [LOTAnimationView animationNamed:@"header_loading_uploading"];
//    self.loadingAnimView.contentMode = UIViewContentModeScaleAspectFill;
//    [self addSubview:self.loadingAnimView];
//    [self.loadingAnimView stop];
//    self.loadingAnimView.loopAnimation = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    STLLog(@"释放OSSVRefreshsHeaders动画");
}

- (void)appDidBecomeActive {
    if (self.state == MJRefreshStateRefreshing) {
//        [self.loadingAnimView play];
        STLLog(@"激活OSSVRefreshsHeaders动画");
    }
}

-(void)setIsCommunityRefresh:(BOOL)isCommunityRefresh{
    _isCommunityRefresh = isCommunityRefresh;
    
    [self addSubview:self.tipLabel];
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-15);
        make.centerX.mas_equalTo(self);
        make.height.mas_equalTo(12);
        make.width.lessThanOrEqualTo(self.mas_width);
    }];
}

- (void)setBannerModel:(OSSVAdvsEventsModel *)bannerModel{
    _bannerModel = bannerModel;
    
    self.hideTitle = STLIsEmptyString(_bannerModel.imageURL);
    
    if (!self.scrollView.showDropBanner || STLIsEmptyString(_bannerModel.imageURL))  {
        [_bannerView removeFromSuperview];
        self.bannerView = nil;

        self.tipLabel.attributedText = nil;
        self.tipLabel.font = [UIFont systemFontOfSize:12];
        self.tipLabel.textColor = OSSVThemesColors.col_999999;
        self.tipLabel.text = STLLocalizedString_(@"community_showoutfit_title", nil);
        self.tipLabel.textAlignment = NSTextAlignmentCenter;
        return;
    }
    
    [self addSubview:self.bannerView];
    [self sendSubviewToBack:self.bannerView];
    [self.bannerView yy_setImageWithURL:[NSURL URLWithString:bannerModel.imageURL]
                            placeholder:[UIImage imageNamed:@"index_banner_loading"]
                                options:YYWebImageOptionSetImageWithFadeAnimation
                             completion:nil];
    
    if ([bannerModel.banner_width floatValue] > 0) {
        
        [self.bannerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.bottom.offset(0);
            make.height.mas_equalTo([bannerModel.banner_height floatValue] * SCREEN_WIDTH /[bannerModel.banner_width floatValue]);
        }];
    }
    
    if (!self.isCommunityRefresh) {
        [self addSubview:self.tipLabel];
        [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(-15);
            make.centerX.mas_equalTo(self);
            make.height.mas_equalTo(12);
            make.width.lessThanOrEqualTo(self.mas_width);
        }];
    }

    self.mj_h = 66;
    
    [self layoutIfNeeded];
}

- (NSMutableAttributedString *)queryTitleAttribute:(NSString *)title {
    NSMutableAttributedString *titleAttribute = [[NSMutableAttributedString alloc] initWithString:title];
    titleAttribute.yy_font = [UIFont systemFontOfSize:12];
    titleAttribute.yy_color = OSSVThemesColors.col_FFFFFF;
    titleAttribute.yy_alignment = NSTextAlignmentCenter;
    YYTextShadow *shadow = [YYTextShadow new];
    shadow.color = [OSSVThemesColors col_000000:0.3];
    shadow.offset = CGSizeMake(0, 0);
    shadow.radius = 4;
    titleAttribute.yy_textShadow = shadow;
    return titleAttribute;
}

#pragma mark 设置子控件的位置和尺寸
- (void)placeSubviews {
    [super placeSubviews];
    
    if (self.startViewOffsetY == 0) {
        self.startViewOffsetY = 5;
    }
    
//    [self.startAnimView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.size.mas_equalTo(CGSizeMake(44, 44));
//        make.centerX.equalTo(self);
//        make.top.mas_equalTo(self.startViewOffsetY);
//    }];
    
//    [self.loadingAnimView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.size.mas_equalTo(CGSizeMake(44, 44));
//        make.centerX.equalTo(self);
//        make.top.mas_equalTo(self.startViewOffsetY);
//    }];
}

- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change {
    
    CGFloat offsetY = self.scrollView.mj_offsetY;
    CGFloat dropBannerOffsetY = -90;

    if (self.scrollView.showDropBanner) {
        if ([self.scrollView isDragging]) {
            if (self.state == MJRefreshStatePulling && offsetY < dropBannerOffsetY) {
                STLLog(@"触发下拉banner");
                self.state = RefreshStateDropBannerTriggered;
            } else if (self.state == RefreshStateDropBannerTriggered && offsetY >= dropBannerOffsetY) {
                self.state = MJRefreshStateIdle;
            }
        }else{
            if (self.state == RefreshStateDropBannerTriggered) {
                self.state = RefreshStateDropBannerShowing;
            }else if (self.state == RefreshStateDropBannerShowing) {
                self.state = MJRefreshStateIdle;
            }
        }
    }
    
    [super scrollViewContentOffsetDidChange:change];
}

#pragma mark 监听控件的刷新状态
- (void)setState:(MJRefreshState)state {
    MJRefreshCheckState;
    
    NSMutableAttributedString *attribute = nil;
    
    switch (state) {
        case MJRefreshStateIdle:
        {
//            [self.startAnimView stop];
//            [self.loadingAnimView stop];

            if (self.isCommunityRefresh && !self.hideTitle) {
                attribute = [self queryTitleAttribute:STLLocalizedString_(@"refresh_pull_down", nil)];
            }else{
                if (!self.hideTitle) {
                    attribute = [self queryTitleAttribute:STLLocalizedString_(@"refresh_pull_down", nil)];
                }
            }
            
            if (!self.hideTitle) {
                self.tipLabel.attributedText = attribute;
            }
            
//            [UIView animateWithDuration:0.3 animations:^{
//                self.loadingAnimView.alpha = 0;
//            }];
        }
            break;
        case MJRefreshStatePulling:
        {
//            [self.startAnimView pause];
//            [self.loadingAnimView pause];

            if (self.isCommunityRefresh && !self.hideTitle) {
                attribute = [self queryTitleAttribute:STLLocalizedString_(@"refresh_pull_down", nil)];
            }else{
                if (!self.hideTitle) {
                    attribute = [self queryTitleAttribute:STLLocalizedString_(@"refresh_pull_down", nil)];
                }
            }
            
            if (!self.hideTitle) {
                self.tipLabel.attributedText = attribute;
            }
            
            if (self.refreshDropPullingBlock) {
                self.refreshDropPullingBlock();
            }
            
//            [UIView animateWithDuration:0.3 animations:^{
//                self.loadingAnimView.alpha = 0;
//            }];
        }
            break;
        case MJRefreshStateRefreshing:
        {
//            [self.startAnimView stop];
            
            if (self.isCommunityRefresh && !self.hideTitle) {
                attribute = [self queryTitleAttribute:STLLocalizedString_(@"refresh_loading", nil)];
            }else{
                if (!self.hideTitle) {
                    attribute = [self queryTitleAttribute:STLLocalizedString_(@"refresh_loading", nil)];
                }
            }
            
            if (!self.hideTitle) {
                self.tipLabel.attributedText = attribute;
            }

//            [UIView animateWithDuration:0.25 animations:^{
//                self.loadingAnimView.alpha = 1;
//            }];
//            [self.loadingAnimView play];
        }
            break;
        case RefreshStateDropBannerTriggered:
        {
            if (self.isCommunityRefresh && !self.hideTitle) {
                attribute = [self queryTitleAttribute:STLLocalizedString_(@"refresh_release", nil)];
            }else{
                if (!self.hideTitle) {
                    attribute = [self queryTitleAttribute:STLLocalizedString_(@"refresh_release", nil)];
                }
            }
            
            if (!self.hideTitle) {
                self.tipLabel.attributedText = attribute;
            }
        }
            break;
        case RefreshStateDropBannerShowing:
        {
            if (self.refreshDropBannerBlock) {
                
                //震动反馈
                //STLPlaySystemQuake();
                
                self.refreshDropBannerBlock();
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark 监听拖拽比例（控件被拖出来的比例）
- (void)setPullingPercent:(CGFloat)pullingPercent {
    [super setPullingPercent:pullingPercent];
    if (self.state != MJRefreshStateIdle) return;
//    self.startAnimView.animationProgress = pullingPercent;
}

#pragma mark - Getter
- (YYAnimatedImageView *)bannerView{
    if (!_bannerView) {
        _bannerView = [[YYAnimatedImageView alloc] init];
        _bannerView.contentMode =  UIViewContentModeScaleAspectFill;
        _bannerView.clipsToBounds = YES;
    }
    return _bannerView;
}

- (YYLabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[YYLabel alloc] init];
        _tipLabel.backgroundColor = [UIColor clearColor];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _tipLabel;
}


@end
