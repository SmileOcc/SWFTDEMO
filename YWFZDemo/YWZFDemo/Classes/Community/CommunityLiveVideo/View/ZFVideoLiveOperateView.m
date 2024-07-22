//
//  ZFVideoLiveOperateView.m
//  ZZZZZ
//
//  Created by YW on 2019/7/25.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFVideoLiveOperateView.h"
#import "ZFProgressHUD.h"
#import "ZFBranchAnalytics.h"
#import "ZFAppsflyerAnalytics.h"
#import <AppsFlyerLib/AppsFlyerTracker.h>
#import "ZFAnalytics.h"
#import "SystemConfigUtils.h"
#import "UIView+ZFViewCategorySet.h"
#import "YWCFunctionTool.h"
#import "UIView+ZFViewCategorySet.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "ZFBaseViewController.h"
#import "ZFFireBaseAnalytics.h"
#import "ZFTitleArrowTipView.h"
#import "ZFGrowingIOAnalytics.h"

NSString * const kZFVideoLiveOperateAddCartTip  = @"kZFVideoLiveOperateAddCartTip";


@interface ZFVideoLiveOperateView ()
<ZFGoodsDetailAttributeSmallViewDelegate,
UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView        *topView;
@property (nonatomic, strong) UIView        *bottomView;
@property (nonatomic, strong) UIButton      *playButton;

@property (nonatomic, strong) UIButton      *backButton;
@property (nonatomic, strong) UIButton      *goodsButton;
@property (nonatomic, strong) UIButton      *cartButton;


@property (nonatomic, strong) UIImageView   *eyesImageView;
@property (nonatomic, strong) UILabel       *viewsLabel;
@property (nonatomic, strong) UILabel       *startTimeLabel;
@property (nonatomic, strong) UILabel       *endTimeLabel;
@property (nonatomic, strong) UIButton      *fullPlayButton;


@property (nonatomic, strong) ZFCommunityLiveRecommendGoodsView   *goodsListView;
@property (nonatomic, strong) ZFGoodsDetailAttributeSmallView     *attributeView;
@property (nonatomic, strong) ZFVideoLiveGoodsAlertView           *goodsAlertView;
@property (nonatomic, strong) ZFVideoLiveCouponAlertView          *couponAlertView;
@property (nonatomic, strong) ZFVideoLiveZegoCoverStateView       *zegoCoverStateView;

/// 评论视图
@property (nonatomic, strong) ZFVideoLiveCommentOperateView       *commentOperateView;

@property (nonatomic, strong) ZFTitleArrowTipView                 *cartTipView;

@property (nonatomic, strong) ZFGoodsDetailViewModel              *goodsDetailViewModel;
@property (nonatomic, strong) ZFGoodsModel                        *currentSelectSimilarGoodsModel;

@property (nonatomic, assign) NSInteger                           autoHideBottomViewCount;


@property (nonatomic, strong) ZFCommunityVideoLiveGoodsModel      *alertLiveGoodsModel;
@property (nonatomic, strong) ZFGoodsDetailCouponModel            *alertCouponModel;


@property (nonatomic, strong) UIView                              *tempTapView;




@end

@implementation ZFVideoLiveOperateView

//播放器销毁
- (void)dealloc {
    YWLog(@"---------- ZFVideoLiveOperateView dealloc");

}

- (void)clearAllSeting {
    if (_commentOperateView) {
        [_commentOperateView clearAllSeting];
    }
    if (_zegoCoverStateView) {
        [_zegoCoverStateView stopTimer];
    }
}

- (void)setIsNeedComment:(BOOL)isNeedComment {
    _isNeedComment = isNeedComment;
    if (_isNeedComment) {
        if (!_commentOperateView) {
            [self insertSubview:self.commentOperateView atIndex:0];
            
            
            CGFloat deviceW = KScreenWidth;
            CGFloat deviceH = KScreenHeight;
            CGFloat commentH = MIN(deviceW, deviceH) / 2.0  + 20;
            
            [self.commentOperateView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self.mas_leading);
                make.trailing.mas_equalTo(self.mas_trailing);
                make.bottom.mas_equalTo(self.mas_bottom);
                make.height.mas_equalTo(commentH);
            }];
        }
    } else {
        if (_commentOperateView) {
            [_commentOperateView removeFromSuperview];
            _commentOperateView = nil;
        }
    }
}

- (void)setInforModel:(ZFVideoLiveZegoCoverWaitInfor *)inforModel {
    _inforModel = inforModel;
    self.bottomView.hidden = YES;
    
    if (!_zegoCoverStateView) {
        [self insertSubview:self.zegoCoverStateView belowSubview:self.commentOperateView];
        [self.zegoCoverStateView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
    }
    
    _zegoCoverStateView.inforModel = inforModel;
    self.zegoCoverStateView.hidden = NO;
    self.playButton.hidden = YES;
    self.tempTapView.hidden = YES;
    self.bottomView.hidden = YES;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.layer.masksToBounds = YES;
        [self zfAutoLayoutView];
    }
    return self;
}

- (void)zfAutoLayoutView {
    
    [self addSubview:self.topView];
    [self addSubview:self.bottomView];
    [self addSubview:self.playButton];
    [self addSubview:self.goodsListView];
    [self addSubview:self.attributeView];
    
    [self.topView addSubview:self.backButton];
    [self.topView addSubview:self.goodsButton];
    [self.topView addSubview:self.cartButton];
    
    [self.bottomView addSubview:self.eyesImageView];
    [self.bottomView addSubview:self.viewsLabel];
    [self.bottomView addSubview:self.startTimeLabel];
    [self.bottomView addSubview:self.progressSlider];
    [self.bottomView addSubview:self.endTimeLabel];
    [self.bottomView addSubview:self.fullPlayButton];

    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.mas_equalTo(self);
        make.height.mas_equalTo(44);
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.leading.trailing.mas_equalTo(self);
        make.height.mas_equalTo(44);
    }];
    
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    
    [self.goodsListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mas_trailing);
        make.top.bottom.mas_equalTo(self);
        make.width.mas_equalTo(300);
    }];
    
    [self.attributeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.mas_trailing);
        make.top.bottom.mas_equalTo(self);
        make.width.mas_equalTo(300);
    }];
    
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.topView.mas_leading).offset(16);
        make.centerY.mas_equalTo(self.topView.mas_centerY);
        make.width.mas_equalTo(44);
        make.height.mas_equalTo(44);
    }];
    
    [self.cartButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.backButton.mas_centerY);
        make.trailing.mas_equalTo(self.topView.mas_trailing).offset(-16);
        make.width.mas_equalTo(44);
        make.height.mas_equalTo(44);
    }];
    
    [self.goodsButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.cartButton.mas_leading).offset(-5);
        make.centerY.mas_equalTo(self.cartButton.mas_centerY);
    }];
    
    [self.startTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.bottomView.mas_leading).offset(24);
        make.centerY.mas_equalTo(self.bottomView.mas_centerY);
    }];
    
    [self.fullPlayButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.bottomView.mas_trailing).offset(-24);
        make.centerY.mas_equalTo(self.bottomView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(24, 24));
    }];
    
    
    [self.endTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.fullPlayButton.mas_leading).offset(-5);
        make.centerY.mas_equalTo(self.bottomView.mas_centerY);
    }];
    
    [self.progressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.startTimeLabel.mas_trailing).offset(5);
        make.trailing.mas_equalTo(self.endTimeLabel.mas_leading).offset(-5);
        make.height.mas_equalTo(10);
        make.centerY.mas_equalTo(self.bottomView.mas_centerY);
    }];
    
    [self.eyesImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.startTimeLabel.mas_top).offset(-5);
        make.leading.mas_equalTo(self.startTimeLabel.mas_leading);
    }];
    
    [self.viewsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.eyesImageView.mas_trailing).offset(2);
        make.centerY.mas_equalTo(self.eyesImageView.mas_centerY);
    }];
    
    [self.startTimeLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [self.startTimeLabel setContentHuggingPriority:260 forAxis:UILayoutConstraintAxisHorizontal];
    
    [self.endTimeLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [self.endTimeLabel setContentHuggingPriority:260 forAxis:UILayoutConstraintAxisHorizontal];
    
    
    //TODO: occ测试数据 图层有问题（阿语的时候）
    CAGradientLayer *topLayer = [CAGradientLayer new];
    topLayer.colors=@[(__bridge id)ColorHex_Alpha(0x000000, 0.4).CGColor,(__bridge id)ColorHex_Alpha(0x000000, 0.0).CGColor];
    topLayer.startPoint = CGPointMake(0.5, 0);
    topLayer.endPoint = CGPointMake(0.5, 1);
    topLayer.frame = CGRectMake(0, 0, KScreenHeight, 44);

    [self.topView.layer insertSublayer:topLayer atIndex:0];

    CAGradientLayer *bottomLayer = [CAGradientLayer new];
    bottomLayer.colors=@[(__bridge id)ColorHex_Alpha(0x000000, 0.0).CGColor,(__bridge id)ColorHex_Alpha(0x000000, 0.4).CGColor];
    bottomLayer.startPoint = CGPointMake(0.5, 0);
    bottomLayer.endPoint = CGPointMake(0.5, 1);
    bottomLayer.frame = CGRectMake(0, 0, KScreenHeight, 44);
    [self.bottomView.layer insertSublayer:bottomLayer atIndex:0];
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTap:)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    
    for (Class aClass in [NSSet setWithObjects:[UIControl class],[UINavigationBar class], nil]) {
        if ([[touch view] isKindOfClass:aClass]) {
            return NO;//点击的是一些操作控件，则不处理 『点击外部消失手势』
        }
    }
    
    if ([self.goodsListView pointInside:[touch locationInView:self.goodsListView] withEvent:nil] && !self.goodsListView.isHidden) {
        return NO;
    }
    
    if (_attributeView) {
        if ([_attributeView pointInside:[touch locationInView:_attributeView] withEvent:nil] && !_attributeView.isHidden) {
            return NO;
        }
    }
    
    if (_goodsAlertView) {
        if ([_goodsAlertView pointInside:[touch locationInView:_goodsAlertView] withEvent:nil] && !_goodsAlertView.isHidden) {
            return NO;
        }
    }
    
    if (_couponAlertView) {
        if ([_couponAlertView pointInside:[touch locationInView:_couponAlertView] withEvent:nil] && !_couponAlertView.isHidden) {
            return NO;
        }
    }
    
    if (_commentOperateView) {
        if ([_commentOperateView.commentListView pointInside:[touch locationInView:_commentOperateView.commentListView] withEvent:nil] && !_commentOperateView.commentListView.isHidden && !_commentOperateView.isHidden) {
            return NO;
        }
        
        if ([_commentOperateView.commentBottomView pointInside:[touch locationInView:_commentOperateView.commentBottomView] withEvent:nil] && !_commentOperateView.commentBottomView.isHidden && !_commentOperateView.isHidden) {
            return NO;
        }
    }
    
    if ([self.topView pointInside:[touch locationInView:self.topView] withEvent:nil] && !_topView.isHidden) {
        return NO;
    }
    
    if ([self.bottomView pointInside:[touch locationInView:self.bottomView] withEvent:nil] && !_bottomView.isHidden) {
        return NO;
    }
    return YES;
}

#pragma mark -

- (NSString *)fromartTime:(NSString *)timeStr {
    
    NSInteger time = [ZFToString(timeStr) integerValue];
    //重新计算 时/分/秒
    NSString *str_hour = [NSString stringWithFormat:@"%02ld",time/3600];
    NSString *str_minute = [NSString stringWithFormat:@"%02ld",(time%3600)/60];
    NSString *str_second = [NSString stringWithFormat:@"%02ld",time%60];
    
    NSString *format_time = [NSString stringWithFormat:@"%@:%@:%@",str_hour,str_minute,str_second];
    if ([str_hour isEqualToString:@"00"]) {
        format_time = [NSString stringWithFormat:@"%@:%@",str_minute,str_second];
    }
    return format_time;
}

- (void)lookNumbers:(NSString *)num {
    self.viewsLabel.text = [NSString stringWithFormat:@"%@ %@",ZFToString(num),ZFLocalizedString(@"Community_Lives_Live_Views", nil)];
}

- (void)startTime:(NSString *)startTime endTime:(NSString *)endTime isEnd:(BOOL)isEnd {
    
    bool touch = self.progressSlider.touchInside;
    
    
    if (isEnd) {
        if (!touch) {
            self.startTimeLabel.text = self.endTimeLabel.text;
            self.progressSlider.value = self.progressSlider.maximumValue;
        }
    } else {
        if (!ZFIsEmptyString(startTime)) {
            if (!touch) {
                self.startTimeLabel.text = [self fromartTime:startTime];
                self.progressSlider.value = [startTime floatValue] + 1.0f;
                //设置播放时，自动隐藏滑块栏
                [self autoHideOperateView];
            }
        }
        if (!ZFIsEmptyString(endTime)) {
            self.endTimeLabel.text = [self fromartTime:endTime];
            self.progressSlider.maximumValue = [endTime floatValue];
        }
    }
}

//设置播放时，自动隐藏滑块栏
- (void)autoHideOperateView {
    
    if (!self.bottomView.isHidden) {
        self.autoHideBottomViewCount++;
        // FB的时间不是以S间隔
        NSInteger count = self.videoType == ZFVideoTypeFB ? 10 : 5;
        if (self.autoHideBottomViewCount >= count) {
            YWLog(@"---------- 自动隐藏滑块栏 %i",self.autoHideBottomViewCount);

            self.tempTapView.hidden = YES;
            self.bottomView.hidden = YES;
            self.playButton.hidden = YES;
            self.backButton.hidden = YES;
            self.cartButton.hidden = YES;
            [self.playButton setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
            self.autoHideBottomViewCount = 0;
            
            [self showCommentView:YES];
        }
    }
}

- (void)hideBottomOperateView:(BOOL)hide {
    self.bottomView.hidden = hide;
}

- (void)hiddenGoodsListView:(BOOL)hidden {
    self.goodsListView.hidden = hidden;
}

- (void)forceGoodsItemShow:(BOOL)show {
    
    if (ZFJudgeNSArray(self.recommendGoods)) {
        [self.goodsListView updateGoodsData:self.recommendGoods];
        
        if (self.isFullScreen) {
            if (self.recommendGoods.count > 0) {
                self.goodsButton.hidden = NO;
            } else {
                self.goodsButton.hidden = YES;
            }
        } else {
            self.goodsButton.hidden = YES;
        }
    }
}


- (void)progressMin:(float)min max:(float)max {
    self.progressSlider.maximumValue = max;
    self.progressSlider.minimumValue = 0;
    
}


- (void)similarGoods:(ZFGoodsModel *)goodsModel {
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoLiveOperateView:similarGoods:)]) {
        [self.delegate videoLiveOperateView:self similarGoods:goodsModel];
    }
}


- (void)fullScreen:(BOOL)isFull {
    
    self.isFullScreen = isFull;
    self.goodsListView.hidden = YES;
    self.attributeView.hidden = YES;
    
    self.userInteractionEnabled = YES;
    if (isFull) {
        [self.fullPlayButton setImage:[UIImage imageNamed:@"video_screen_small"] forState:UIControlStateNormal];
        [self.goodsListView updateGoodsData:self.recommendGoods];
        
        self.goodsButton.hidden = self.recommendGoods.count > 0 ? NO : YES;
        
        [self showCart:NO];
        [self showCartTipView:NO];
        
        if (self.bottomView.isHidden) {
            [self showCommentView:YES];
        }
        
    } else {
        
        [self showGoodsView:NO];
        [self.fullPlayButton setImage:[UIImage imageNamed:@"video_screen_full"] forState:UIControlStateNormal];
        self.goodsButton.hidden = YES;
        [self showCart:YES];
        
        [self showCartTipView:YES];
        [self showCommentView:NO];
    }
}

- (void)videoIsCanPlay {
    [self showCartTipView:YES];
}

- (void)actionFullScreen:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoLiveOperateView:tapScreenFull:)]) {
        [self.delegate videoLiveOperateView:self tapScreenFull:!self.isFullScreen];
    }
}

- (void)dissmissGoodsAlertView {
    if (self.goodsAlertView) {
        self.goodsAlertView.hidden = YES;
        [self.goodsAlertView removeFromSuperview];
        self.goodsAlertView = nil;
    }
}

- (void)dissmissCouponAlertView {
    if (self.couponAlertView) {
        self.couponAlertView.hidden = YES;
        [self.couponAlertView removeFromSuperview];
        self.couponAlertView = nil;
    }
}

- (void)showGoodsAlertView:(ZFCommunityVideoLiveGoodsModel *)goodsModel {
    
    if (self.hideAllAlertTipView) {
        return;
    }
    
    if (!ZFIsEmptyString(goodsModel.goods_sn)) {
        [self.recommendGoods enumerateObjectsUsingBlock:^(ZFGoodsModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            // 消息推荐商品，优先匹配推荐商品列表里的价格
            if ([obj.goods_sn isEqualToString:goodsModel.goods_sn]) {
                goodsModel.shop_price = ZFToString(obj.shop_price);
                goodsModel.price = ZFToString(obj.market_price);
                *stop = YES;
            }
        }];
        
        self.alertLiveGoodsModel = goodsModel;
        
        [self dissmissGoodsAlertView];
        [self dissmissCouponAlertView];
        
        CGRect alertFrame = self.isFullScreen ? CGRectMake(0, 0, 230, 116) : CGRectMake(0, 0, 180, 76);
        CGSize alertCloseSize = self.isFullScreen ? CGSizeMake(28, 28) : CGSizeMake(21, 21);
        ZFVideoLiveGoodsAlertItemView *alertView = [[ZFVideoLiveGoodsAlertItemView alloc] initFrame:alertFrame goodsModel:goodsModel];
        [alertView updateCloseSize:alertCloseSize];
        
        @weakify(self)
        alertView.addCartBlock = ^(ZFCommunityVideoLiveGoodsModel * _Nonnull goodsModel) {
            @strongify(self)
            ZFGoodsModel *model = [[ZFGoodsModel alloc] init];
            model.goods_id = ZFToString(goodsModel.goods_id);
            model.goods_sn = ZFToString(goodsModel.goods_sn);
            if (self.isFullScreen) {
                [self addCartGoods:model];
            } else {
                if (self.delegate && [self.delegate respondsToSelector:@selector(videoLiveOperateView:tapAlertCart:)]) {
                    [self.delegate videoLiveOperateView:self tapAlertCart:model];
                }
                
            }
        };
        
        alertView.closeBlock = ^(BOOL flag) {
            @strongify(self)
            [self dissmissGoodsAlertView];
        };
        
        
        if (self.isFullScreen) {
            self.goodsAlertView = [[ZFVideoLiveGoodsAlertView alloc] initTipArrowOffset:30 leadingSpace:0 trailingSpace:0 direct:[SystemConfigUtils isRightToLeftShow] ? ZFTitleArrowTipDirectUpLeft : ZFTitleArrowTipDirectUpRight contentView:alertView];
            [self.goodsAlertView hideViewWithTime:5 complectBlock:nil];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(alertGoodsTap:)];
            [self.goodsAlertView addGestureRecognizer:tap];
            
            [self insertSubview:self.goodsAlertView belowSubview:self.goodsListView];
            
            [self.goodsAlertView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.trailing.mas_equalTo(self.goodsButton.mas_trailing);
                make.top.mas_equalTo(self.goodsButton.mas_bottom).offset(2);
                make.width.mas_lessThanOrEqualTo(KScreenWidth - 24);
            }];
        } else {
            self.goodsAlertView = [[ZFVideoLiveGoodsAlertView alloc] initTipArrowOffset:30 leadingSpace:0 trailingSpace:0 direct:[SystemConfigUtils isRightToLeftShow] ? ZFTitleArrowTipDirectDownRight : ZFTitleArrowTipDirectDownLeft contentView:alertView];
            [self.goodsAlertView hideViewWithTime:5 complectBlock:nil];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(alertGoodsTap:)];
            [self.goodsAlertView addGestureRecognizer:tap];
            
            [self insertSubview:self.goodsAlertView belowSubview:self.goodsListView];
            
            [self.goodsAlertView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self.mas_leading).offset(12);
                make.bottom.mas_equalTo(self.mas_bottom).offset(-2);
                make.width.mas_lessThanOrEqualTo(KScreenWidth - 24);
            }];
        }
    }
}

- (void)showCouponAlertView:(ZFGoodsDetailCouponModel *)couponModel {
    if (!ZFIsEmptyString(couponModel.couponId)) {
        
        self.alertCouponModel = couponModel;
        
        [self dissmissGoodsAlertView];
        [self dissmissCouponAlertView];
        
        CGFloat alertW = self.isFullScreen ? MAX(KScreenHeight, KScreenWidth) : MIN(KScreenHeight, KScreenWidth);
        CGFloat alertY = self.isFullScreen ? -200 : 400;
        
        CGRect alertFrame = self.isFullScreen ? CGRectMake(alertW - 230 - 16, alertY, 230, 116) : CGRectMake(12, alertY, 180, 76);
        self.couponAlertView = [[ZFVideoLiveCouponAlertView alloc] initWithFrame:alertFrame couponModel:couponModel];
        self.couponAlertView.backgroundColor = ZFCClearColor();
        [self.couponAlertView hideViewWithTime:5 complectBlock:nil];
        [self insertSubview:self.couponAlertView belowSubview:self.goodsListView];
        
        @weakify(self)
        self.couponAlertView.receiveCouponBlock = ^(ZFGoodsDetailCouponModel *couponModel) {
            @strongify(self)
            [self receiveCoupon:couponModel];
        };
        
        
        if (self.isFullScreen) {
            [self.couponAlertView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.trailing.mas_equalTo(self.mas_trailing).offset(-12);
                make.top.mas_equalTo(self.goodsButton.mas_bottom).offset(-200);
            }];
            
            [UIView animateWithDuration:0.25 animations:^{
                [self.couponAlertView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_equalTo(self.goodsButton.mas_bottom).offset(2);
                }];
                [self layoutIfNeeded];
            } completion:^(BOOL finished) {
                
            }];
            
        } else {
            [self.couponAlertView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self.mas_leading).offset(12);
                make.bottom.mas_equalTo(self.mas_bottom).offset(200);
            }];
            
            [UIView animateWithDuration:0.25 animations:^{
                [self.couponAlertView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.bottom.mas_equalTo(self.mas_bottom).offset(-2);
                }];
                [self layoutIfNeeded];
            } completion:^(BOOL finished) {
                
            }];
        }
    }
}

- (void)playViewState:(BOOL)play {
    if (play) {
        [self.playButton setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
        self.playButton.hidden = YES;
        self.playState = ZFVideoPlayStatePlay;
    } else {
        self.playButton.hidden = NO;
        [self.playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        self.playState = ZFVideoPlayStatePause;
        
        // 显示封面提示的时候
        if (!self.zegoCoverStateView.isHidden) {
            self.playButton.hidden = YES;
        }
    }
}

/**
 显示推荐商品模块动画
 
 @param isShow
 */
- (void)showGoodsView:(BOOL)isShow {
    if (self.hideAllAlertTipView) {
        return;
    }
    //弹出商品时，需要隐藏，收起时对应的显示
    if (_commentOperateView) {
        [_commentOperateView shieldCommentLimitShow:isShow ? NO : YES];
    }

    CGFloat leadingX = 0;
    if (isShow) {
        leadingX = -300;
        self.goodsListView.hidden = NO;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        [self.goodsListView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_trailing).offset(leadingX);
        }];
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.goodsButton.enabled = YES;
        if (!isShow) {
            self.goodsListView.hidden = YES;
        }
    }];
}

- (void)actionSliderValurChanged:(UISlider*)slider forEvent:(UIEvent*)event {
    self.startTimeLabel.text = [self fromartTime:[NSString stringWithFormat:@"%f",slider.value]];
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoLiveOperateView:sliderValue:)]) {
        [self.delegate videoLiveOperateView:self sliderValue:slider.value];
    }
}

- (void)showCartTipView:(BOOL)isShow {
    
    if (self.hideAllAlertTipView) {
        return;
    }
    
    if (!isShow) {
        if (_cartTipView) {
            [_cartTipView hideView];;
        }
        return;
    }
    
    BOOL isShowAddCartTip = [GetUserDefault(kZFVideoLiveOperateAddCartTip) boolValue];
    if (!_cartTipView && !isShowAddCartTip && !self.isFullScreen) {

        SaveUserDefault(kZFVideoLiveOperateAddCartTip, @(YES));
        [self addSubview:self.cartTipView];
        
        CGRect sourceFrame = [ZFTitleArrowTipView sourceViewFrameToWindow:self.cartButton];
        CGFloat space = 5;
        CGFloat offsetSpace = 16 - 5;
        [self.cartTipView updateTipArrowOffset:CGRectGetWidth(sourceFrame) / 2.0 + offsetSpace
                                           direct:[SystemConfigUtils isRightToLeftShow] ? ZFTitleArrowTipDirectUpLeft : ZFTitleArrowTipDirectUpRight
                                           cotent:nil];
        
        [self.cartTipView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.mas_trailing).offset(-space);
            make.top.mas_equalTo(self.goodsButton.mas_bottom).offset(2);
            make.width.mas_lessThanOrEqualTo(KScreenWidth - 24);
        }];
        [self.cartTipView hideViewWithTime:4.5 complectBlock:nil];
    }
}

- (void)showCommentView:(BOOL)isShow {
    
    if (self.hideAllAlertTipView) {
        return;
    }
    
    if (self.videoType != ZFVideoTypeZG || !_commentOperateView) {
        return;
    }
    
    if (!isShow) {
        self.commentOperateView.hidden = YES;
        return;
    }
    
    if (self.isFullScreen) {
        self.commentOperateView.hidden = NO;
        [self.commentOperateView reloadView];
    } else {
        self.commentOperateView.hidden = YES;
    }
   
}

#pragma mark - 优惠券

- (void)receiveCoupon:(ZFGoodsDetailCouponModel *)couponModel {
    
    @weakify(self)
    [self isOperateLoginBlock:^{
        @strongify(self)
        // 领取优惠券
        ShowLoadingToView(self.viewController.view);
        
        // 1. 调取领劵接口
        @weakify(self)
        [ZFCommunityLiveVideoGoodsModel requestGetGoodsCoupon:couponModel.couponId completion:^(BOOL success, NSInteger couponStatus) {
            @strongify(self)

            // 1:领劵成功;2:领券Coupon不存在;3:已领券;4:没到领取时间;5:已过期;6:coupon已领取完;7:赠送coupon失败
            // 默认提示已领完
            NSString *tiptext = ZFLocalizedString(@"Detail_ReceiveCouponFail", nil);
            
            // 注意界面显示状态 // coupon状态；1:可领取;2:已领取;3:已领取完
            if (success) {
                if (couponStatus == 1) {
                    tiptext = ZFLocalizedString(@"Detail_ReceiveCouponSuccess", nil);
                    couponModel.couponStats = 2;
                    self.couponAlertView.couponModel = couponModel;
                } else if (couponStatus == 6) {
                    tiptext = ZFLocalizedString(@"Detail_ReceiveCouponUsedUp", nil);
                    couponModel.couponStats = 3;
                    self.couponAlertView.couponModel = couponModel;
                }
                
                ShowToastToViewWithText(self.viewController.view, tiptext);
            } else {
                ShowToastToViewWithText(self.viewController.view, tiptext);
            }
        }];
    }];
}

- (void)isOperateLoginBlock:(void (^)(void))completion {
    
    if ([AccountManager sharedManager].isSignIn) {
        if (completion) {
            completion();
        }
        
    } else {
        
        UIViewController *ctrl = self.viewController;
        if ([ctrl isKindOfClass:[ZFBaseViewController class]]) {
            ZFBaseViewController *baseCtrl = (ZFBaseViewController *)ctrl;
            if (baseCtrl.navigationController) {
                ZFNavigationController *nav = (ZFNavigationController *)baseCtrl.navigationController;
                if (nav.interfaceOrientation == UIInterfaceOrientationLandscapeRight || nav.interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
                    
                    [baseCtrl forceOrientation:AppForceOrientationPortrait];
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        
                        baseCtrl.isStatusBarHidden = NO;
                        [self.viewController judgePresentLoginVCCompletion:^{
                            baseCtrl.isStatusBarHidden = YES;
                            if (completion) {
                                completion();
                            }
                        } cancelCompetion:^{
                            baseCtrl.isStatusBarHidden = YES;
                        }];
                    });
                    
                    
                } else {
                    
                    baseCtrl.isStatusBarHidden = NO;
                    [self.viewController judgePresentLoginVCCompletion:^{
                        baseCtrl.isStatusBarHidden = YES;
                        if (completion) {
                            completion();
                        }
                    } cancelCompetion:^{
                        baseCtrl.isStatusBarHidden = YES;
                    }];
                }
            }
        }
    }
}

#pragma mark - ZFGoodsDetailAttributeSmallViewDelegate

- (void)goodsDetailAttribute:(ZFGoodsDetailAttributeSmallView *)attributeView showState:(BOOL)isShow {
    [attributeView bottomCartViewEnable:YES];
}

- (void)goodsDetailAttribute:(ZFGoodsDetailAttributeSmallView *)attributeView tapCart:(BOOL)tapCart {
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoLiveOperateView:tapCart:)]) {
        [self.delegate videoLiveOperateView:self tapCart:YES];
    }
}

- (void)goodsDetailAttribute:(ZFGoodsDetailAttributeSmallView *)attributeView selectGoodsId:(NSString *)goodsId {
    [self changeGoodsAttribute:goodsId];
}

- (void)goodsDetailAttribute:(ZFGoodsDetailAttributeSmallView *)attributeView addCartGoodsId:(NSString *)goodsId count:(NSInteger)count {
    
    [attributeView bottomCartViewEnable:NO];
    [self addGoodsToCartOption:goodsId goodsCount:count];
}

// 切换属性
- (void)changeGoodsAttribute:(NSString *)goodsId {
    if (self.currentSelectSimilarGoodsModel) {
        self.currentSelectSimilarGoodsModel.selectSkuCount += 1;
    }
    //获取商品详情接口
    @weakify(self)
    [self requestGoodsDetailInfo:ZFToString(goodsId) successBlock:^(GoodsDetailModel *goodsDetailInfo) {
        @strongify(self)
        self.attributeView.model = goodsDetailInfo;
    }];
}

// 加购商品按钮触发
- (void)addCartGoods:(ZFGoodsModel *)goodsModel {
    [self bringSubviewToFront:self.attributeView];
    
    self.currentSelectSimilarGoodsModel = goodsModel;
    //获取商品详情接口
    @weakify(self)
    NSString *goosID = ZFToString(goodsModel.goods_id);
    [self requestGoodsDetailInfo:goosID successBlock:^(GoodsDetailModel *goodsDetailInfo) {
        @strongify(self)
        self.attributeView.model = goodsDetailInfo;
        [self.attributeView openSelectTypeView];
    }];
}

/**
 获取商品详情
 */
- (void)requestGoodsDetailInfo:(NSString *)goodsId successBlock:(void(^)(GoodsDetailModel *goodsDetailInfo))successBlock{
    if (ZFIsEmptyString(goodsId)) {
        return;
    }
    NSDictionary *dict = @{@"manzeng_id"  : @"",
                           @"goods_id"    : ZFToString(goodsId)};
    
    ShowLoadingToView(self.attributeView);
    if(!self.goodsDetailViewModel) {
        self.goodsDetailViewModel = [[ZFGoodsDetailViewModel alloc] init];
    }
    @weakify(self);
    [self.goodsDetailViewModel requestGoodsDetailData:dict completion:^(GoodsDetailModel *detaidlModel) {
        @strongify(self);
        HideLoadingFromView(self.attributeView);
        
        if (detaidlModel.detailMainPortSuccess && [detaidlModel isKindOfClass:[GoodsDetailModel class]]) {
            if (successBlock) {
                successBlock(detaidlModel);
            }
        }
    } failure:^(NSError *error) {
        @strongify(self)
        HideLoadingFromView(self);
    }];
}

//添加购物车
- (void)addGoodsToCartOption:(NSString *)goodsId goodsCount:(NSInteger)goodsCount {
    
    @weakify(self);
    [self.goodsDetailViewModel requestAddToCart:ZFToString(goodsId) loadingView:self goodsNum:goodsCount completion:^(BOOL isSuccess) {
        @strongify(self);
        
        if (isSuccess) {
            ShowToastToViewWithText(self, ZFLocalizedString(@"Success", nil));
            [self changeCartNumAction];
            
            //添加商品至购物车事件统计
            self.attributeView.model.buyNumbers = goodsCount;
            NSString *goodsSN = self.attributeView.model.goods_sn;
            NSString *spuSN = @"";
            if (goodsSN.length > 7) {  // sn的前7位为同款id
                spuSN = [goodsSN substringWithRange:NSMakeRange(0, 7)];
            }else{
                spuSN = goodsSN;
            }
            
            NSMutableDictionary *valuesDic = [NSMutableDictionary dictionary];
            valuesDic[AFEventParamContentId] = ZFToString(goodsSN);
            valuesDic[@"af_spu_id"] = ZFToString(spuSN);
            valuesDic[AFEventParamPrice] = ZFToString(self.attributeView.model.shop_price);
            valuesDic[AFEventParamQuantity] = [NSString stringWithFormat:@"%zd",goodsCount];
            valuesDic[AFEventParamContentType] = @"product";
            valuesDic[@"af_content_category"] = ZFToString(self.attributeView.model.long_cat_name);
            valuesDic[AFEventParamCurrency] = @"USD";
            
            valuesDic[@"af_inner_mediasource"] = [ZFAppsflyerAnalytics sourceStringWithType:ZFAppsflyerInSourceTypeZMeLiveDetail sourceID:ZFToString(self.videoDetailID)];
            
            valuesDic[@"af_changed_size_or_color"] = (self.currentSelectSimilarGoodsModel.selectSkuCount > 0) ? @"1" : @"0";
            valuesDic[BigDataParams]           = @[[self.attributeView.model gainAnalyticsParams]];
            valuesDic[@"af_purchase_way"]      = @"1";//V5.0.0增加, 判断是否为一键购买(0)还是正常加购(1)
            
            [ZFAnalytics appsFlyerTrackEvent:@"af_add_to_bag" withValues:valuesDic];
            [ZFGrowingIOAnalytics ZFGrowingIOAddCart:self.attributeView.model];
            //Branch
            [[ZFBranchAnalytics sharedManager] branchAddToCartWithProduct:self.attributeView.model number:goodsCount];
            [ZFFireBaseAnalytics addToCartWithGoodsModel:self.attributeView.model];
            
            [self.attributeView bottomCartViewEnable:YES];
        } else {
            @strongify(self);
            [self.attributeView bottomCartViewEnable:YES];
            [self changeCartNumAction];
        }
    }];
}

- (void)changeCartNumAction {
    [self.attributeView changeCartNumberInfo];
}

#pragma mark - Action

- (void)actionBack:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoLiveOperateView:tapBlack:)]) {
        [self.delegate videoLiveOperateView:self tapBlack:YES];
    }
}

- (void)actionPlay:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoLiveOperateView:play:)]) {
        [self.delegate videoLiveOperateView:self play:YES];
    }
}

- (void)actionCart:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoLiveOperateView:tapCart:)]) {
        [self.delegate videoLiveOperateView:self tapCart:YES];
    }
}


- (void)actionGoods:(UIButton *)sender {
    sender.enabled = NO;
    if (self.goodsListView.isHidden) {
        [self showGoodsView:YES];
    } else {
        [self showGoodsView:NO];
    }
}


- (void)actionTap:(UITapGestureRecognizer *)tap {
    
    // 显示评论 及弹窗推荐商品时
    if (_commentOperateView) {
        if (!_commentOperateView.isHidden) {
            
            if (!_goodsListView.isHidden) {
                [self showGoodsView:NO];
                return;
            }
        }
    }
    
    if (_zegoCoverStateView) {
        if (!_zegoCoverStateView.isHidden) {
            self.bottomView.hidden = YES;
            self.playButton.hidden = YES;
        }
    }
    
    if (self.tempTapView.isHidden) {

        self.bottomView.hidden = NO;
        self.playButton.hidden = NO;
        self.backButton.hidden = NO;
        self.tempTapView.hidden = NO;
        
        if (_zegoCoverStateView && !_zegoCoverStateView.isHidden) {
            if (_zegoCoverStateView.state == LiveZegoCoverStateNetworkNrror
                || _zegoCoverStateView.state == LiveZegoCoverStateJustLive
                || _zegoCoverStateView.state == LiveZegoCoverStateEnd
                || _zegoCoverStateView.state == LiveZegoCoverStateWillStart) {
                self.playButton.hidden = YES;
                self.bottomView.hidden = YES;
            }
        }
        
        
        [self showCart:YES];
        [self showCommentView:NO];
        
    } else {
        self.bottomView.hidden = YES;
        self.playButton.hidden = YES;
        self.backButton.hidden = YES;
        self.cartButton.hidden = YES;
        self.tempTapView.hidden = YES;
        
        if (_zegoCoverStateView && !_zegoCoverStateView.isHidden) {
            if (_zegoCoverStateView.state == LiveZegoCoverStateNetworkNrror
                || _zegoCoverStateView.state == LiveZegoCoverStateJustLive
                || _zegoCoverStateView.state == LiveZegoCoverStateEnd
                || _zegoCoverStateView.state == LiveZegoCoverStateWillStart) {
                self.backButton.hidden = NO;

            }
        }
        
        [self showCart:NO];
        [self showCommentView:YES];
    }
    
    
    if (!self.goodsListView.isHidden) {
        self.goodsListView.hidden = YES;
    }
    
    if (!self.attributeView.isHidden) {
        self.attributeView.hidden = YES;
    }
}

- (void)showCart:(BOOL)isShowCart {
    
    //全屏时不显示购车标识
    if (self.isFullScreen) {
        self.cartButton.hidden = YES;
        [self.cartButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(0);
        }];
        return;
    }
    
    if (isShowCart) {
        if (ZFJudgeNSArray(self.recommendGoods)) {
            if (self.recommendGoods.count > 0) {
                
                self.cartButton.hidden = NO;
                self.userInteractionEnabled = NO;
                [UIView animateWithDuration:0.25 animations:^{
                    [self.cartButton mas_updateConstraints:^(MASConstraintMaker *make) {
                        make.width.mas_equalTo(44);
                    }];
                    [self layoutIfNeeded];
                } completion:^(BOOL finished) {
                    self.userInteractionEnabled = YES;
                }];
            }
        }

    } else {
        if (ZFJudgeNSArray(self.recommendGoods)) {
            if (self.recommendGoods.count > 0) {
                
                self.userInteractionEnabled = NO;
                [UIView animateWithDuration:0.25 animations:^{
                    [self.cartButton mas_updateConstraints:^(MASConstraintMaker *make) {
                        make.width.mas_equalTo(self.isFullScreen ? 0 : 44);
                    }];
                    [self layoutIfNeeded];
                } completion:^(BOOL finished) {
                    self.userInteractionEnabled = YES;
                }];
            }
        }
    }
}

///点击弹窗商品
- (void)alertGoodsTap:(UITapGestureRecognizer *)tap {
    if (self.alertLiveGoodsModel) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(videoLiveOperateView:tapGoods:)]) {
            
            ZFGoodsModel *goodsModel = [[ZFGoodsModel alloc] init];
            goodsModel.goods_id = ZFToString(self.alertLiveGoodsModel.goods_id);
            goodsModel.goods_sn = ZFToString(self.alertLiveGoodsModel.goods_sn);
            [self.delegate videoLiveOperateView:self tapGoods:goodsModel];
        }
    }
}

- (void)updateLiveCoverState:(LiveZegoCoverState)coverState {
    
    if (coverState == LiveZegoCoverStateEndRefresh) {
        if (_zegoCoverStateView) {
            [_zegoCoverStateView endCoverStateRefresh:LiveZegoCoverStateEndRefresh];
        }
        return;
    }
    
    if (!_zegoCoverStateView) {
        [self insertSubview:self.zegoCoverStateView belowSubview:self.commentOperateView];
        [self.zegoCoverStateView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
    }
    
    self.zegoCoverStateView.hidden = YES;
    [self.zegoCoverStateView updateCoverState:coverState];
    
    if (coverState == LiveZegoCoverStateJustLive
        || coverState == LiveZegoCoverStateEnd
        || coverState == LiveZegoCoverStateNetworkNrror
        || coverState == LiveZegoCoverStateWillStart) {
        
        self.zegoCoverStateView.hidden = NO;
        self.playButton.hidden = YES;
        self.tempTapView.hidden = YES;
        self.bottomView.hidden = YES;
    }
}

#pragma mark - 基础设置

- (void)setHideEyesNumsView:(BOOL)hideEyesNumsView {
    _hideEyesNumsView = hideEyesNumsView;
    self.eyesImageView.hidden = _hideEyesNumsView;
    self.viewsLabel.hidden = _hideEyesNumsView;
}

- (void)setHideTopOperateView:(BOOL)hideTopOperateView {
    _hideTopOperateView = hideTopOperateView;
    self.topView.hidden = _hideTopOperateView;
}

- (void)setHideFullScreenView:(BOOL)hideFullScreenView {
    _hideFullScreenView = hideFullScreenView;
    self.fullPlayButton.hidden = _hideFullScreenView;
    
    [self.fullPlayButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(hideFullScreenView ? CGSizeZero : CGSizeMake(24, 24));
    }];
}

- (void)setHideTopBottomLayerView:(BOOL)hideTopBottomLayerView {
    _hideTopBottomLayerView = hideTopBottomLayerView;
    
    NSArray *subsTopsLayers = self.topView.layer.sublayers;
    NSArray *subsBottomsLayers = self.bottomView.layer.sublayers;
    
    for (CALayer *layer in subsTopsLayers) {
        if ([layer isKindOfClass:[CAGradientLayer class]]) {
            layer.hidden = hideTopBottomLayerView ? YES : NO;
        }
    }
    
    for (CALayer *layer in subsBottomsLayers) {
        if ([layer isKindOfClass:[CAGradientLayer class]]) {
            layer.hidden = hideTopBottomLayerView ? YES : NO;
        }
    }
}
#pragma mark - Property Method

- (void)setIsZegoHistoryComment:(BOOL)isZegoHistoryComment {
    _isZegoHistoryComment = isZegoHistoryComment;
    if (isZegoHistoryComment) {
        [self.commentOperateView addRefreshView:YES];
    } else {
        [self.commentOperateView addRefreshView:NO];
    }
}

- (void)setRecommendGoods:(NSArray *)recommendGoods {
    _recommendGoods = recommendGoods;
    [self forceGoodsItemShow:YES];
}

- (UIView *)topView {
    if (!_topView) {
        _topView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _topView;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _bottomView;
}

- (UIButton *)playButton {
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        [_playButton addTarget:self action:@selector(actionPlay:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playButton;
}

- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setImage:[UIImage imageNamed:@"camera_back"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(actionBack:) forControlEvents:UIControlEventTouchUpInside];
        _backButton.contentEdgeInsets = UIEdgeInsetsMake(5, 10, 5, 10);
        [_backButton convertUIWithARLanguage];
    }
    return _backButton;
}

- (UIButton *)goodsButton {
    if (!_goodsButton) {
        _goodsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_goodsButton setImage:[UIImage imageNamed:@"double_arrow"] forState:UIControlStateNormal];
        [_goodsButton setTitle:ZFLocalizedString(@"Community_Lives_Live_Goods", nil) forState:UIControlStateNormal];
        [_goodsButton zfLayoutStyle:ZFButtonEdgeInsetsStyleLeft imageTitleSpace:2];
        [_goodsButton addTarget:self action:@selector(actionGoods:) forControlEvents:UIControlEventTouchUpInside];
        [_goodsButton convertUIWithARLanguage];
        _goodsButton.hidden = YES;
    }
    return _goodsButton;
}


- (UIButton *)cartButton {
    if (!_cartButton) {
        _cartButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cartButton setImage:[UIImage imageNamed:@"cart_bag_white"] forState:UIControlStateNormal];
        [_cartButton addTarget:self action:@selector(actionCart:) forControlEvents:UIControlEventTouchUpInside];
        _cartButton.contentEdgeInsets = UIEdgeInsetsMake(5, 10, 5, 10);

    }
    return _cartButton;
}


- (UIImageView *)eyesImageView {
    if (!_eyesImageView) {
        _eyesImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_eyesImageView setImage:[UIImage imageNamed:@"video_eyes"]];
    }
    return _eyesImageView;
}

- (UILabel *)viewsLabel {
    if (!_viewsLabel) {
        _viewsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _viewsLabel.textColor = ZFC0xFFFFFF();
        _viewsLabel.font = [UIFont systemFontOfSize:12];
    }
    return _viewsLabel;
}

- (UILabel *)startTimeLabel {
    if (!_startTimeLabel) {
        _startTimeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _startTimeLabel.text = @"00:00";
        _startTimeLabel.textColor = ZFC0xFFFFFF();
        _startTimeLabel.font = [UIFont systemFontOfSize:10];
    }
    return _startTimeLabel;
}

- (UISlider *)progressSlider {
    if (!_progressSlider) {
        _progressSlider = [[UISlider alloc] initWithFrame:CGRectZero];
        _progressSlider.maximumTrackTintColor = ZFC0xFFFFFF();
        _progressSlider.minimumTrackTintColor = ZFC0xFE5269();
        [_progressSlider setThumbImage:[UIImage imageNamed:@"slider_tap"] forState:UIControlStateNormal];
        [_progressSlider addTarget:self action:@selector(actionSliderValurChanged:forEvent:) forControlEvents:UIControlEventValueChanged];
    }
    return _progressSlider;
}

- (UILabel *)endTimeLabel {
    if (!_endTimeLabel) {
        _endTimeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _endTimeLabel.text = @"00:00";
        _endTimeLabel.textColor = ZFC0xFFFFFF();
        _endTimeLabel.font = [UIFont systemFontOfSize:10];
    }
    return _endTimeLabel;
}

- (UIButton *)fullPlayButton {
    if (!_fullPlayButton) {
        _fullPlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fullPlayButton setImage:[UIImage imageNamed:@"video_screen_full"] forState:UIControlStateNormal];
        [_fullPlayButton addTarget:self action:@selector(actionFullScreen:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fullPlayButton;
}


- (ZFCommunityLiveRecommendGoodsView *)goodsListView {
    if (!_goodsListView) {
        _goodsListView = [[ZFCommunityLiveRecommendGoodsView alloc] initWithFrame:CGRectZero];
        @weakify(self)
        _goodsListView.recommendGoodsBlock = ^(ZFGoodsModel * _Nonnull goodsModel) {
            @strongify(self)
            if (self.delegate && [self.delegate respondsToSelector:@selector(videoLiveOperateView:tapGoods:)]) {
                [self.delegate videoLiveOperateView:self tapGoods:goodsModel];
            }
        };
        
        _goodsListView.addCartBlock = ^(ZFGoodsModel * _Nonnull goodsModel) {
            @strongify(self)
            [self addCartGoods:goodsModel];
        };
        
        _goodsListView.similarGoodsBlock = ^(ZFGoodsModel * _Nonnull goodsModel) {
            @strongify(self)
            [self similarGoods:goodsModel];
        };
        
        _goodsListView.closeBlock = ^(BOOL flag) {
            @strongify(self)
            [self showGoodsView:NO];
        };
        _goodsListView.hidden = YES;
    }
    return _goodsListView;
}


- (ZFGoodsDetailAttributeSmallView *)attributeView {
    if (!_attributeView) {
        _attributeView = [[ZFGoodsDetailAttributeSmallView alloc] initWithFrame:CGRectZero showCart:YES alpha:0.1];
        _attributeView.delegate = self;
        _attributeView.hidden = YES;
        _attributeView.chooseNumebr = 1;
    }
    return _attributeView;
}


- (ZFTitleArrowTipView *)cartTipView {
    if (!_cartTipView) {
        _cartTipView = [[ZFTitleArrowTipView alloc] initTipArrowOffset:-1 direct:-1 content:ZFLocalizedString(@"Video_Live_Cart_Tip", nil)];
    }
    return _cartTipView;
}


- (ZFVideoLiveCommentOperateView *)commentOperateView {
    if (!_commentOperateView) {
        _commentOperateView = [[ZFVideoLiveCommentOperateView alloc] initWithFrame:CGRectZero];
        _commentOperateView.hidden = YES;
        [_commentOperateView.commentListView startMessageTimer];
    }
    return _commentOperateView;
}

- (ZFVideoLiveZegoCoverStateView *)zegoCoverStateView {
    if (!_zegoCoverStateView) {
        _zegoCoverStateView = [[ZFVideoLiveZegoCoverStateView alloc] initWithFrame:CGRectZero];
        
        @weakify(self)
        _zegoCoverStateView.zegoEndBlock = ^(LiveZegoCoverState coverState) {
            @strongify(self)
            if (self.delegate && [self.delegate respondsToSelector:@selector(videoLiveOperateView:liveCoverStateBlack:)]) {
                [self.delegate videoLiveOperateView:self liveCoverStateBlack:coverState];
            }
        };
    }
    return _zegoCoverStateView;
}

- (UIView *)tempTapView {
    if (!_tempTapView) {
        _tempTapView = [[UIView alloc] init];
    }
    return _tempTapView;
}
@end
