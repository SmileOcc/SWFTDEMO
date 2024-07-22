//
//  ZFCommunityHomeGuideView.m
//  ZZZZZ
//
//  Created by YW on 2018/12/13.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import "ZFCommunityHomeGuideView.h"
#import "ZFThemeManager.h"
#import "UIView+ZFViewCategorySet.h"
#import "ZFLocalizationString.h"
#import "SystemConfigUtils.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"

NSString *const kZFCommunityHomeGuideViewTip  = @"kZFCommunityHomeGuideViewTip";

@interface ZFCommunityHomeGuideView()

@property (nonatomic, strong) UIView                          *firstGuideView;
@property (nonatomic, strong) UIImageView                     *firstArrowImageView;
@property (nonatomic, strong) UILabel                         *firstTitleLabel;
@property (nonatomic, strong) CommunityHomeGuideButton        *firstButton;

@property (nonatomic, strong) UIView                          *themeGuideView;
@property (nonatomic, strong) UIImageView                     *themeArrowImageView;
@property (nonatomic, strong) UILabel                         *themeTitleLabel;
@property (nonatomic, strong) CommunityHomeGuideButton        *themeButton;

@property (nonatomic, assign) CGRect                          themeRect;
@property (nonatomic, assign) CGRect                          edgeThemeRect;
@property (nonatomic, strong) CAShapeLayer                    *bgShapeLayer;
@end

@implementation ZFCommunityHomeGuideView


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight);
    }
    return self;
}

+ (BOOL)isHadShowGuideView {
    return [GetUserDefault(kZFCommunityHomeGuideViewTip) boolValue];
}

- (void)hideView {
    if (self.superview) {
        [self removeFromSuperview];
    }
    self.hidden = YES;
}


- (void)showViewThemeFrame:(CGRect)themeFrame {
    self.themeRect = themeFrame;
    
    UIViewController *topCtrl = [UIViewController currentTopViewController];
    if ([topCtrl isKindOfClass:NSClassFromString(@"ZFCommunityHomeVC")]) {
        if (!self.superview) {
            
            NSArray *subViews = WINDOW.subviews;
            if (subViews.count > 1) {
                YWLog(@"---ccccccc Window views: %@",subViews);
                return;
            }
            [WINDOW addSubview:self];

            SaveUserDefault(kZFCommunityHomeGuideViewTip, @(YES));
            
            [self addSubview:self.firstGuideView];
            [self addSubview:self.firstArrowImageView];
            [self addSubview:self.firstTitleLabel];
            [self addSubview:self.firstButton];
            
            CGRect firstRect = CGRectMake((KScreenWidth - 94) / 2.0, KScreenHeight - kiphoneXHomeBarHeight - 55, 94, 55);

            [self.firstGuideView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(self.mas_bottom).offset(-kiphoneXHomeBarHeight);
                make.centerX.mas_equalTo(self.mas_centerX);
                make.size.mas_equalTo(CGSizeMake(94, 55));
            }];
            
            [self.firstArrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self.firstGuideView.mas_leading).offset(22);
                make.bottom.mas_equalTo(self.firstGuideView.mas_top).offset(5);
            }];
            
            [self.firstTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(self.firstArrowImageView.mas_top).offset(-8);
                make.leading.mas_equalTo(self.mas_leading).offset(20);
                make.trailing.mas_equalTo(self.mas_trailing).offset(-80);
            }];
            
            [self.firstButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.trailing.mas_equalTo(self.mas_trailing).offset(-20);
                make.bottom.mas_equalTo(self.firstTitleLabel.mas_top).offset(-10);
            }];
            
            if (!CGRectIsEmpty(self.themeRect)) {
                
                //扩大范围
                self.themeRect = CGRectMake(CGRectGetMinX(self.themeRect) - 8, CGRectGetMinY(self.themeRect) - 8, CGRectGetWidth(self.themeRect) + 16, CGRectGetHeight(self.themeRect) + 8);
                self.edgeThemeRect = self.themeRect;
                
                self.themeGuideView.frame = self.themeRect;
                [self addSubview:self.themeGuideView];
                [self addSubview:self.themeArrowImageView];
                [self addSubview:self.themeTitleLabel];
                [self addSubview:self.themeButton];
                
                CGFloat topY = CGRectGetMinY(self.themeRect);
                CGFloat bottomY = CGRectGetMaxY(self.themeRect);
                
                if (topY < (kiphoneXTopOffsetY + 44 + 100)) {//提示靠下
                    
                    [self.themeArrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.trailing.mas_equalTo(self.themeGuideView.mas_centerX).offset(-10);
                        make.top.mas_equalTo(self.themeGuideView.mas_bottom).offset(-5);
                    }];
                    
                    [self.themeTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.top.mas_equalTo(self.themeArrowImageView.mas_bottom).offset(-10);
                        make.leading.mas_equalTo(self.mas_leading).offset(34);
                        make.trailing.mas_equalTo(self.themeArrowImageView.mas_leading).offset(-10);
                    }];
                    
                    [self.themeButton mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.top.mas_equalTo(self.themeTitleLabel.mas_bottom);
                        make.trailing.mas_equalTo(self.mas_trailing).offset(-34);
                    }];
                    
                    if ([SystemConfigUtils isRightToLeftShow]) {
                        self.themeArrowImageView.transform = CGAffineTransformMakeScale(-1.0,1.0);
                    }
                    
                } else {//提示靠上
                    
                    if(bottomY > (KScreenHeight - TabBarHeight - 49 - 50)) { //不显示提示
                        self.themeRect = CGRectZero;
                    }
                    
                    [self.themeArrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.trailing.mas_equalTo(self.themeGuideView.mas_centerX).offset(-10);
                        make.bottom.mas_equalTo(self.themeGuideView.mas_top).offset(5);
                    }];
                    
                    [self.themeTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.bottom.mas_equalTo(self.themeArrowImageView.mas_top).offset(10);
                        make.leading.mas_equalTo(self.mas_leading).offset(34);
                        make.trailing.mas_equalTo(self.themeArrowImageView.mas_leading).offset(-10);
                    }];
                    
                    [self.themeButton mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.bottom.mas_equalTo(self.themeTitleLabel.mas_top).offset(-5);
                        make.trailing.mas_equalTo(self.mas_trailing).offset(-20);
                    }];
                    
                    
                    if ([SystemConfigUtils isRightToLeftShow]) {
                        [self.themeArrowImageView convertUIWithARLanguage];
                    } else {
                        self.themeArrowImageView.image = [UIImage imageNamed:@"community_Home_guide_arrow_up"];
                        self.themeArrowImageView.transform = CGAffineTransformMakeScale(-1.0,1.0);
                    }
                }
            }
            
            [self.themeArrowImageView setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
            [self.themeArrowImageView setContentHuggingPriority:260 forAxis:UILayoutConstraintAxisHorizontal];
            [self.themeTitleLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
            
            
            self.bgShapeLayer = [CAShapeLayer layer];
            self.bgShapeLayer.frame = self.frame;
            //  设置虚线颜色为
            [self.bgShapeLayer setStrokeColor:ColorHex_Alpha(0xFFFFFF, 1.0).CGColor];
            
            //  设置虚线宽度
            [self.bgShapeLayer setLineWidth:1];
            [self.bgShapeLayer setLineJoin:kCALineJoinRound];
            
            //  设置线宽，线间距
            [self.bgShapeLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:3], [NSNumber numberWithInt:3], nil]];
            
            [self.layer addSublayer:self.bgShapeLayer];
            
            //设置路径的填充模式为两个图形的非交集
            self.bgShapeLayer.fillColor = ColorHex_Alpha(0x000000, 0.6).CGColor;
            self.bgShapeLayer.fillRule = kCAFillRuleEvenOdd;
            
            //背景
            UIBezierPath *pOtherPath = [UIBezierPath bezierPathWithRect:CGRectMake(CGRectGetMinX(self.frame)-1, CGRectGetMinY(self.frame)-1, CGRectGetWidth(self.frame)+2, CGRectGetHeight(self.frame) + 2)];
            
            //目标空心
            UIBezierPath *pPath = [UIBezierPath bezierPathWithOvalInRect:firstRect];
            [pOtherPath appendPath:pPath];
            
            self.bgShapeLayer.path = pOtherPath.CGPath;
            
            
            
            if (!CGRectIsEmpty(self.themeRect)) {
                [self.firstButton setTitle:ZFLocalizedString(@"Next_Step", nil) forState:UIControlStateNormal];
            } else {
                [self.firstButton setTitle:ZFLocalizedString(@"Confirm", nil) forState:UIControlStateNormal];
            }
            
            [self bringSubviewToFront:self.firstTitleLabel];
            [self bringSubviewToFront:self.firstArrowImageView];
            [self bringSubviewToFront:self.firstButton];
        }
    }
}

#pragma mark - action

- (void)actionFirst:(UIButton *)sender {
    if (!CGRectIsEmpty(self.themeRect) && _themeButton) {
        
        self.themeGuideView.hidden = YES;
        self.themeTitleLabel.hidden = NO;
        self.themeButton.hidden = NO;
        self.themeArrowImageView.hidden = NO;
        
        self.firstGuideView.hidden = YES;
        self.firstTitleLabel.hidden = YES;
        self.firstButton.hidden = YES;
        self.firstArrowImageView.hidden = YES;
        
        //背景
        UIBezierPath *pOtherPath = [UIBezierPath bezierPathWithRect:CGRectMake(CGRectGetMinX(self.frame)-1, CGRectGetMinY(self.frame)-1, CGRectGetWidth(self.frame)+2, CGRectGetHeight(self.frame) + 2)];
        
        //目标空心
        UIBezierPath *pPath = [UIBezierPath bezierPathWithOvalInRect:self.edgeThemeRect];
        
        [pOtherPath appendPath:pPath];
        
        self.bgShapeLayer.path = pOtherPath.CGPath;
        
        [self bringSubviewToFront:self.themeTitleLabel];
        [self bringSubviewToFront:self.themeArrowImageView];
        [self bringSubviewToFront:self.themeButton];
        
    } else {
        [self hideView];
    }
}

- (void)actionTheme:(UIButton *)sender {
    [self hideView];
}


#pragma mark - setter/getter

- (UIView *)firstGuideView {
    if (!_firstGuideView) {
        _firstGuideView = [[UIView alloc] initWithFrame:CGRectZero];
        _firstGuideView.hidden = YES;
    }
    return _firstGuideView;
}

- (UIImageView *)firstArrowImageView {
    if (!_firstArrowImageView) {
        _firstArrowImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _firstArrowImageView.image = [UIImage imageNamed:@"community_Home_guide_arrow_up"];
    }
    return _firstArrowImageView;
}

- (UILabel *)firstTitleLabel {
    if (!_firstTitleLabel) {
        _firstTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _firstTitleLabel.text = ZFLocalizedString(@"community_Home_Z-Me_Guide", nil);
        _firstTitleLabel.numberOfLines = 0;
        _firstTitleLabel.textColor = ColorHex_Alpha(0xffffff, 1.0);
        _firstTitleLabel.font = ZFFontSystemSize(16);
    }
    return _firstTitleLabel;
}

- (CommunityHomeGuideButton *)firstButton {
    if (!_firstButton) {
        _firstButton = [CommunityHomeGuideButton buttonWithType:UIButtonTypeCustom];
        [_firstButton setTitle:ZFLocalizedString(@"Next_Step", nil) forState:UIControlStateNormal];
        _firstButton.titleLabel.font = ZFFontSystemSize(16);
        [_firstButton addTarget:self action:@selector(actionFirst:) forControlEvents:UIControlEventTouchUpInside];
        [_firstButton setContentEdgeInsets:UIEdgeInsetsMake(6, 10, 6, 10)];
    }
    return _firstButton;
}

- (UIView *)themeGuideView {
    if (!_themeGuideView) {
        _themeGuideView = [[UIView alloc] initWithFrame:CGRectZero];
        _themeGuideView.hidden = YES;
    }
    return _themeGuideView;
}

- (UIImageView *)themeArrowImageView {
    if (!_themeArrowImageView) {
        _themeArrowImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _themeArrowImageView.image = [UIImage imageNamed:@"community_Home_guide_arrow_down"];
        _themeArrowImageView.hidden = YES;
    }
    return _themeArrowImageView;
}

- (UILabel *)themeTitleLabel {
    if (!_themeTitleLabel) {
        _themeTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _themeTitleLabel.text = ZFLocalizedString(@"community_Home_Topic_Guide", nil);
        _themeTitleLabel.numberOfLines = 0;
        _themeTitleLabel.hidden = YES;
        _themeTitleLabel.textColor = ColorHex_Alpha(0xffffff, 1.0);
        _themeTitleLabel.font = ZFFontSystemSize(16);
    }
    return _themeTitleLabel;
}

- (CommunityHomeGuideButton *)themeButton {
    if (!_themeButton) {
        _themeButton = [CommunityHomeGuideButton buttonWithType:UIButtonTypeCustom];
        [_themeButton setTitle:ZFLocalizedString(@"Confirm", nil) forState:UIControlStateNormal];
        _themeButton.titleLabel.font = ZFFontSystemSize(16);
        [_themeButton addTarget:self action:@selector(actionTheme:) forControlEvents:UIControlEventTouchUpInside];
        [_themeButton setContentEdgeInsets:UIEdgeInsetsMake(6, 10, 6, 10)];
        _themeButton.hidden = YES;
    }
    return _themeButton;
}


@end


@implementation CommunityHomeGuideButton


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        UIImageView  *limeImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        limeImageView.image = [UIImage imageNamed:@"community_guide_bottom"];
        [self addSubview:limeImageView];
        
        [limeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self);
            make.top.mas_equalTo(self.mas_bottom).offset(-4);
            make.height.mas_equalTo(12);
        }];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {

    CAShapeLayer *border = [CAShapeLayer layer];

    //虚线的颜色
    border.strokeColor = ColorHex_Alpha(0xFFFFFF, 1.0).CGColor;
    //填充的颜色
    border.fillColor = [UIColor clearColor].CGColor;

    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:8];

    //设置路径
    border.path = path.CGPath;

    border.frame = self.bounds;
    //虚线的宽度
    border.lineWidth = 1.f;

    //设置线条的样式
    //    border.lineCap = @"square";
    //虚线的间隔
    border.lineDashPattern = @[@3, @2, @3, @2];

    self.layer.cornerRadius = 8.f;
    //self.layer.masksToBounds = YES;

    [self.layer addSublayer:border];
}
@end
