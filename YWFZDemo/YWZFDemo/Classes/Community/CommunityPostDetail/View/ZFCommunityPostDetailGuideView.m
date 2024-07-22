//
//  ZFCommunityPostDetailGuideView.m
//  ZZZZZ
//
//  Created by YW on 2019/1/10.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityPostDetailGuideView.h"
#import <YYWebImage/YYWebImage.h>
#import <Masonry/Masonry.h>
#import "ZFThemeManager.h"
#import "ZFFrameDefiner.h"
#import "Constants.h"
#import "SystemConfigUtils.h"
#import "ZFLocalizationString.h"

NSString * const kZFCommunityPostDetailGuideViewTip  = @"kZFCommunityPostDetailGuideViewTip";

@interface ZFCommunityPostDetailGuideView ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) YYAnimatedImageView       *showImageView;
@property (nonatomic, strong) UILabel                   *messageLabel;
@property (nonatomic, strong) UIPanGestureRecognizer    *panGetsute;


@property (nonatomic, copy) void (^operateBlock)(void);




@end
@implementation ZFCommunityPostDetailGuideView



#pragma mark - Life Cycle
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight);
        self.backgroundColor = ZFC0x2D2D2D_06();
        [self addSubview:self.showImageView];
        [self addSubview:self.messageLabel];
        
        
        [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading).offset(72);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-72);
            make.centerY.mas_equalTo(self.mas_centerY).mas_offset(-80);
        }];
        
        [self.showImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.mas_centerX);
            make.bottom.mas_equalTo(self.messageLabel.mas_top).offset(-3);
            make.width.mas_equalTo(125);
            make.height.mas_equalTo(self.showImageView.mas_width).multipliedBy(150 / 250.0);
        }];
        
        self.panGetsute = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(actionPan:)];
        self.panGetsute.delegate = self;

        [self addGestureRecognizer:self.panGetsute];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTap:)];
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}


#pragma mark -  Action


- (void)actionTap:(UITapGestureRecognizer *)tapGesture {
    
    [self hideView];
    
    if (self.operateBlock) {
        self.operateBlock();
    }
}
- (void)actionPan:(UIPanGestureRecognizer *)panGesture {

    if (panGesture.state == UIGestureRecognizerStateChanged) {
        [self commitTranslation:[panGesture translationInView:self]];
    }
}

/**
 *   判断手势方向
 *
 *  @param translation translation description
 */
- (void)commitTranslation:(CGPoint)translation
{

    CGFloat absX = fabs(translation.x);
    CGFloat absY = fabs(translation.y);

    // 设置滑动有效距离
    if (MAX(absX, absY) < 40) {
        return;
    }

    if (absX > absY ) {
        self.panGetsute.enabled = NO;
        [self hideView];

        if (self.operateBlock) {
            self.operateBlock();
        }
        if (translation.x<0) {
            //向左滑动
        }else{
            //向右滑动
        }

    } else if (absY > absX) {
        if (translation.y<0) {
            //向上滑动
        }else{
            //向下滑动
        }
    }


}

#pragma mark - Public Method

+ (BOOL)hasShowGuideView {
    return [GetUserDefault(kZFCommunityPostDetailGuideViewTip) boolValue];
}

- (void)showView:(void (^)(void))completion {
    if (self.superview) {
        [self removeFromSuperview];
    }
    [WINDOW addSubview:self];
    
    self.panGetsute.enabled = YES;
    if (completion) {
        self.operateBlock = completion;
    }
}

- (void)hideView {
    if (self.superview) {
        [self removeFromSuperview];
    }
    SaveUserDefault(kZFCommunityPostDetailGuideViewTip, @(YES));
}


#pragma mark - Property Method

- (YYAnimatedImageView *)showImageView {
    if (!_showImageView) {
        _showImageView = [[YYAnimatedImageView alloc] init];
        _showImageView.image = [YYImage imageNamed:@"community_post_detail_Guide.gif"];
        
        if ([SystemConfigUtils isRightToLeftShow]) {
            _showImageView.transform = CGAffineTransformMakeScale(-1.0,1.0);
        }
    }
    return _showImageView;
}

- (UILabel *)messageLabel {
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _messageLabel.textColor = ZFC0xFFFFFF();
        _messageLabel.font = ZFFontSystemSize(16);
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.numberOfLines = 0;
        _messageLabel.text = ZFLocalizedString(@"community_post_detail_swipe_guide", nil);
    }
    return _messageLabel;
}


@end
