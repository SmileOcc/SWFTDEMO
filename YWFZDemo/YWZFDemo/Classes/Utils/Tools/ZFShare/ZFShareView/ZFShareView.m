//
//  ZFShareView.m
//  HyPopMenuView
//
//  Created by YW on 6/8/17.
//  Copyright © 2017年 ZZZZZ. All rights reserved.
//

#import "ZFShareView.h"
#import "ZFShareButton.h"
#import "UIColor+ImageGetColor.h"
#import <pop/POP.h>
#import "ZFThemeManager.h"
#import "UIView+ZFViewCategorySet.h"
#import "UIView+LayoutMethods.h"
#import "ZFLocalizationString.h"
#import "ZFFrameDefiner.h"
#import "Constants.h"
#import "ZFShareManager.h"
#import "NSStringUtils.h"

#define KBottomViewHeight        (277.0f + kiphoneXHomeBarHeight)
#define KBottomContentViewHeight        (237.0f + kiphoneXHomeBarHeight)
static CGFloat kButtonHeight     = 93.0f;
static CGFloat KCloseButtonWidth = 16.0f;

@interface ZFShareView ()
@property (nonatomic, strong) UIVisualEffectView   *blurView;    // 模糊视图
@property (nonatomic, strong) UIView               *titleView;
@property (nonatomic, strong) UILabel              *titleLabel;

@property (nonatomic, strong) UIView               *bottomView;  // 底部视图
@property (nonatomic, strong) UIScrollView         *itemScrollView;  // 底部视图
@property (nonatomic, strong) CALayer              *line;
@property (nonatomic, strong) UIButton             *closeButton;
@end

@implementation ZFShareView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setFrame:[UIScreen mainScreen].bounds];
        self.backgroundColor = [UIColor clearColor];
        self.popMenuSpeed = 8.0f;
        [self initSubViews];
        //配置按钮数据
        [self configButtonData];
    }
    return self;
}

- (void)initSubViews {
    [[UIButton appearance] setExclusiveTouch:true];
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    if (!window) {
        window = [[[UIApplication sharedApplication] delegate] window];
    }
    [window addSubview:self];
    
    self.blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    self.blurView.frame = self.bounds;
    [self addSubview:self.blurView];
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    [self.blurView addGestureRecognizer:tap];
    
    
    self.titleView = [[UIView alloc] initWithFrame:CGRectMake(0, self.blurView.height - KBottomViewHeight, KScreenWidth, 40)];
    self.titleView.backgroundColor = ZFCOLOR(255, 255, 255, 1);
    [self.titleView zfAddCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(8, 8)];
    [self.blurView.contentView addSubview:self.titleView];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.blurView.height - KBottomViewHeight, KScreenWidth, 40)];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont systemFontOfSize:14];
    self.titleLabel.textColor = ZFC0x2D2D2D();
    self.titleLabel.backgroundColor = ZFCClearColor();
    self.titleLabel.text = @"Share to your friends";
    [self.blurView.contentView addSubview:self.titleLabel];

    CGRect bottomRect = CGRectMake(0, self.blurView.height - KBottomContentViewHeight, KScreenWidth, KBottomContentViewHeight);
    self.bottomView = [[UIView alloc] initWithFrame:bottomRect];
    self.bottomView.backgroundColor = ZFCOLOR(255, 255, 255, 1);
    [self.blurView.contentView addSubview:self.bottomView];
    
    
    CGFloat bottomLineH = (48 + kiphoneXHomeBarHeight);
    CGRect itemScrollRect = CGRectMake(0, self.blurView.height - KBottomContentViewHeight, KScreenWidth, self.bottomView.height-bottomLineH);
    self.itemScrollView = [[UIScrollView alloc] initWithFrame:itemScrollRect];
    self.itemScrollView.backgroundColor = ZFCOLOR(255, 255, 255, 1);
    self.itemScrollView.showsHorizontalScrollIndicator = NO;
    self.itemScrollView.clipsToBounds = NO;
    self.itemScrollView.scrollEnabled = NO;
    [self.blurView.contentView addSubview:self.itemScrollView];
    
    
    self.line = [CALayer layer];
    self.line.frame = CGRectMake(0, KScreenHeight - bottomLineH, KScreenWidth, 0.5);
    self.line.backgroundColor = ZFCOLOR(221, 221, 221, 1).CGColor;
    self.line.hidden = YES;
    [self.blurView.contentView.layer addSublayer:self.line];
    
    
    self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.closeButton.adjustsImageWhenHighlighted = NO;
    [self.closeButton setBackgroundImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [self.closeButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    self.closeButton.frame = CGRectMake((KScreenWidth - KCloseButtonWidth)/2, KScreenHeight - KCloseButtonWidth * 2 - kiphoneXHomeBarHeight, KCloseButtonWidth, KCloseButtonWidth);
    [self.blurView.contentView addSubview:self.closeButton];
}

/**
 * 配置按钮数据
 */
- (void)configButtonData {
    NSString *copyTitle = [NSStringUtils firstCharactersCapitalized:ZFLocalizedString(@"Share_CopyLinkTitle",nil)];
    NSString *moreTitle = [NSStringUtils firstCharactersCapitalized:ZFLocalizedString(@"community_post_simalar_more",nil)];
    
    NSArray *imgArray = @[@"Messenger", @"Share_whatsapp", @"Facebook",@"VKontakte", @"Share_Pinterest", @"Link",  @"more"];
    NSArray *titleArray = @[@"Messenger", @"Whatsapp", @"Facebook",@"VKontakte", @"Pinterest", copyTitle,  moreTitle];
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:1];
    
    for (NSInteger i = 0 ; i < titleArray.count; i ++) {
        NSString *titleString = titleArray[i];
        
        ZFShareButtonTransitionType type = ZFShareButtonTransitionTypeCircle;
        if ([titleString isEqualToString:copyTitle]) {
            type = ZFShareButtonTransitionTypeWave;
        }
        ZFShareButton *button = [ZFShareButton buttonWithImage:imgArray[i] Title:titleString TransitionType:type];
        [button addTarget:self action:@selector(selectedItemAnimation:) forControlEvents:UIControlEventTouchUpInside];
        [tempArray addObject:button];
        [self.itemScrollView addSubview:button];
    }
    self.dataSource = tempArray;
}

- (void)selectedItemAnimation:(ZFShareButton *)sender {
    for (ZFShareButton *button in self.dataSource) {
        if (sender != button) {
            [button cancelAnimation];
        }
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [sender selectdAnimation];
    });
    
    NSString *copyTitle = [NSStringUtils firstCharactersCapitalized:ZFLocalizedString(@"Share_CopyLinkTitle",nil)];
    NSString *moreTitle = [NSStringUtils firstCharactersCapitalized:ZFLocalizedString(@"community_post_simalar_more",nil)];
    
    @weakify(self)
    NSUInteger idx = [self.dataSource indexOfObject:sender];
    sender.completionAnimation = ^(ZFShareButton *button){
        @strongify(self)
        
        NSString *title = button.titleLabel.text;
        YWLog(@"== %@",title);
        ZFShareType shareType = ZFShareTypeMessenger;
        if ([button.titleLabel.text isEqualToString:@"Messenger"]) {
            shareType = ZFShareTypeMessenger;
            
        } else if([button.titleLabel.text isEqualToString:@"Whatsapp"]) {
            shareType = ZFShareTypeWhatsApp;
            
        } else if([button.titleLabel.text isEqualToString:@"Facebook"]) {
            shareType = ZFShareTypeFacebook;

        } else if([button.titleLabel.text isEqualToString:copyTitle]) {
            shareType = ZFShareTypeCopy;

        } else if([button.titleLabel.text isEqualToString:@"Pinterest"]) {
            shareType = ZFShareTypePinterest;

        } else if([button.titleLabel.text isEqualToString:moreTitle]) {
            shareType = ZFShareTypeMore;
            
        }  else if([button.titleLabel.text isEqualToString:@"VKontakte"]) {
            shareType = ZFShareTypeVKontakte;
        }
        
        
        if ([self.delegate respondsToSelector:@selector(zfShsreView:didSelectItemAtIndex:)]) {
            [self.delegate zfShsreView:self didSelectItemAtIndex:shareType];
        }
        
        [UIView animateWithDuration:0.35 animations:^{
            self.alpha = 0.0;
            self.closeButton.alpha = 0.0;
            self.closeButton.transform = CGAffineTransformMakeRotation(0);
        } completion:^(BOOL finished) { // 复原所有动画
            for (ZFShareButton *button in self.dataSource) {
                [button resetAllAnimation];
            }
        }];
    };
}

- (void)open {
    [self.blurView.contentView bringSubviewToFront:self.itemScrollView];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 1.0;
        self.line.opacity = 1.0;
        self.closeButton.alpha = 1.0;
        self.closeButton.transform = CGAffineTransformMakeRotation((M_PI / 2));
    }];
    [self showItemAnimation:YES];
}

- (void)dismiss {
    [self showItemAnimation:NO];
    [UIView animateWithDuration:0.2 animations:^{
        self.line.opacity = 0.0;
        self.closeButton.alpha = 0.0;
        self.closeButton.transform = CGAffineTransformMakeRotation(0);
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.6 animations:^{
            self.alpha = 0.0;
        } completion:^(BOOL finished) {
            if ([self.delegate respondsToSelector:@selector(zfDidTapBgDismissShareView)]) {
                [self.delegate zfDidTapBgDismissShareView];
            }
        }];
    }];
}

- (void)showItemAnimation:(BOOL)show {
    [self.dataSource enumerateObjectsUsingBlock:^(ZFShareButton *button, NSUInteger idx, BOOL* _Nonnull stop) {
        CFTimeInterval delay = 0.0;
        CGRect toRect = CGRectZero;
        CGRect fromRect = CGRectZero;
        
        if (show) {
            button.alpha = 0.0f;
            toRect   = [self getFrameAtIndex:idx];
            button.imageRect = [button adjustImageRect];
            button.titleRect = [button adjustTitleRect];
            
            double dy = idx * 0.035f;
            delay = dy + CACurrentMediaTime();
            fromRect = CGRectMake(CGRectGetMinX(toRect),
                                  CGRectGetMinY(toRect) + (KScreenHeight - CGRectGetMinY(toRect)),
                                  toRect.size.width,
                                  toRect.size.height);
            
        } else {
            double d = self.dataSource.count * 0.04;
            double dy = d - idx * 0.04;
            delay = dy + CACurrentMediaTime();
            fromRect = [self getFrameAtIndex:idx];
            toRect = CGRectMake(CGRectGetMinX(fromRect),
                                CGRectGetMinY(fromRect) + (KScreenHeight - CGRectGetMinY(fromRect)),
                                fromRect.size.width,
                                fromRect.size.height);
        }
        
        [self startViscousAnimationFormValue:fromRect
                                     ToValue:toRect
                                       Delay:delay
                                      Object:button
                                 HideDisplay:!show];
    }];
}

- (void)startViscousAnimationFormValue:(CGRect)fromValue
                               ToValue:(CGRect)toValue
                                 Delay:(CFTimeInterval)delay
                                Object:(UIView*)obj
                           HideDisplay:(BOOL)hideDisplay {
    CGFloat toV, fromV;
    CGFloat springBounciness = 5.f;
    toV = !hideDisplay;
    fromV = hideDisplay;
    
    if (hideDisplay) {
        POPBasicAnimation* basicAnimationCenter = [POPBasicAnimation animationWithPropertyNamed:kPOPViewCenter];
        basicAnimationCenter.toValue = [NSValue valueWithCGPoint:CGPointMake(CGRectGetMidX(toValue), CGRectGetMidY(toValue))];
        basicAnimationCenter.fromValue = [NSValue valueWithCGPoint:CGPointMake(CGRectGetMidX(fromValue), CGRectGetMidY(fromValue))];
        basicAnimationCenter.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        basicAnimationCenter.beginTime = delay;
        basicAnimationCenter.duration = 0.18;
        [obj pop_addAnimation:basicAnimationCenter forKey:basicAnimationCenter.name];
        
        POPBasicAnimation* basicAnimationScale = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleX];
        basicAnimationScale.removedOnCompletion = YES;
        basicAnimationScale.beginTime = delay;
        basicAnimationScale.toValue = @(0.7);
        basicAnimationScale.fromValue = @(1);
        basicAnimationScale.duration = 0.18;
        basicAnimationScale.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        [obj.layer pop_addAnimation:basicAnimationScale forKey:basicAnimationScale.name];
        
    } else {
        
        POPSpringAnimation* basicAnimationCenter = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
        basicAnimationCenter.beginTime = delay;
        basicAnimationCenter.springSpeed = _popMenuSpeed;
        basicAnimationCenter.springBounciness = springBounciness;
        basicAnimationCenter.toValue = [NSValue valueWithCGPoint:CGPointMake(CGRectGetMidX(toValue), CGRectGetMidY(toValue)+0)];
        basicAnimationCenter.fromValue = [NSValue valueWithCGPoint:CGPointMake(CGRectGetMidX(fromValue), CGRectGetMidY(fromValue))];
        
        POPBasicAnimation* basicAnimationScale = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleX];
        basicAnimationScale.beginTime = delay;
        basicAnimationScale.toValue = @(1);
        basicAnimationScale.fromValue = @(0.7);
        basicAnimationScale.duration = 0.3f;
        basicAnimationScale.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        [obj.layer pop_addAnimation:basicAnimationScale forKey:basicAnimationScale.name];
        
        POPBasicAnimation* basicAnimationAlpha = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
        basicAnimationAlpha.removedOnCompletion = YES;
        basicAnimationAlpha.duration = 0.1f;
        basicAnimationAlpha.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        basicAnimationAlpha.beginTime = delay;
        basicAnimationAlpha.toValue = @(toV);
        basicAnimationAlpha.fromValue = @(fromV);
        
        [obj pop_addAnimation:basicAnimationAlpha forKey:basicAnimationAlpha.name];
        [obj pop_addAnimation:basicAnimationCenter forKey:basicAnimationCenter.name];
    }
}

- (CGRect)getFrameAtIndex:(NSUInteger)index {
    CGFloat buttonViewY = (self.itemScrollView.height / 2.0 - kButtonHeight)/2;
    CGFloat kwidth = KScreenWidth / 4.0;
    if (index > 3) {
        index = index % 4;
        buttonViewY += self.itemScrollView.height / 2.0;
    }
    
    CGFloat x = index * kwidth;
    CGFloat y = buttonViewY;
    CGRect rect = CGRectMake(x, y, kwidth, kButtonHeight);

    return rect;
}

- (void)setTopView:(ZFShareTopView *)topView {
    if (_topView) {
        [_topView removeFromSuperview];
    }
    _topView = topView;
    
    if (_topView) {
        [self.blurView.contentView addSubview:_topView];
    }
    [self refreshCustomFrame];
}

/**
 * 商详页面Item上面显示感叹号
 */
- (void)setShareHeaderView:(UIView *)shareHeaderView {
    if (_shareHeaderView) {
        [_shareHeaderView removeFromSuperview];
    }
    _shareHeaderView = shareHeaderView;

    if (_shareHeaderView) {
        [self.blurView.contentView addSubview:_shareHeaderView];
    }
    [self refreshCustomFrame];
}

/**
 * 刷新子视图位置
 */
- (void)refreshCustomFrame {
    if (self.shareHeaderView) {
        self.shareHeaderView.y = KScreenHeight - KBottomViewHeight - CGRectGetHeight(self.shareHeaderView.frame);
    }

    //居中顶部视图
    if (self.topView) {
        CGFloat kTopViewW = 200 * (KScreenWidth / 375.0);
        CGFloat kTopViewH = 267 * (KScreenWidth / 375.0);
        CGFloat topViewCenterY = self.shareHeaderView ? self.shareHeaderView.y/2 : (KScreenHeight - KBottomViewHeight)/2;
        self.topView.size = CGSizeMake(kTopViewW, kTopViewH);
        self.topView.center = CGPointMake(KScreenWidth/2, topViewCenterY);
    }
    
    
}

- (void)layoutSubviews{
    [super layoutSubviews];
//    UIView *showView = self.shareHeaderView;
//    if (!showView) {
//        showView = self.bottomView;
//    }
//    [showView addDropShadowWithOffset:CGSizeMake(0, -5)
//                               radius:15
//                                color:ZFCOLOR(153, 153, 153, 1)
//                              opacity:0.1];
}

- (void)dealloc {
    YWLog(@"%s",__func__);
}

@end
