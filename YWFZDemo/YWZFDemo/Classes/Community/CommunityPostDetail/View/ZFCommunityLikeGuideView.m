//
//  ZFCommunityLikeGuideView.m
//  ZZZZZ
//
//  Created by YW on 2019/5/5.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityLikeGuideView.h"
#import <Masonry/Masonry.h>
#import "Constants.h"
#import "ZFThemeManager.h"
#import "ZFFrameDefiner.h"
#import "ZFLocalizationString.h"
#import <YYWebImage/YYWebImage.h>

@interface ZFCommunityLikeGuideView()

@property (nonatomic, strong) YYAnimatedImageView       *likeImageView;

@property (nonatomic, strong) UILabel                   *descLabel;


@end

@implementation ZFCommunityLikeGuideView


+ (BOOL)isShowGuideView {
    return [GetUserDefault(@"kZFCommunityLikeFirstGuideTip") boolValue];
}
+ (void)saveGuideView {
    SaveUserDefault(@"kZFCommunityLikeFirstGuideTip", @(YES));
}

- (void)firstShowLikeGuideView:(UIView *)superView {
    
    if (superView) {
        self.frame = WINDOW.bounds;
        self.backgroundColor = ZFC0x2D2D2D_06();
        
        [self addSubview:self.likeImageView];
        [self addSubview:self.descLabel];
        [superView addSubview:self];
        
        [self.likeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.mas_centerX);
            make.centerY.mas_equalTo(self.mas_centerY).mas_offset(-80);
            make.width.mas_equalTo(80);
            make.height.mas_equalTo(self.likeImageView.mas_width).multipliedBy(360.0/300.0);
        }];
        
        [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.likeImageView.mas_bottom).offset(20);
            make.width.mas_equalTo(KScreenWidth - 40);
            make.centerX.mas_equalTo(self.mas_centerX);
        }];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTip)];
        [self addGestureRecognizer:tap];
    }
}

- (void)actionTip {
    [self hiddenView];
}

- (void)hiddenView {
    
    if (self.superview) {
        [self removeFromSuperview];
    }
    if (self.descLabel.superview) {
        [self.descLabel removeFromSuperview];
    }
    if (self.likeImageView.superview) {
        self.likeImageView.hidden = YES;
        [self.likeImageView removeFromSuperview];
    }
}


- (YYAnimatedImageView *)likeImageView {
    if (!_likeImageView) {
        _likeImageView = [[YYAnimatedImageView alloc] init];
        _likeImageView.image = [YYImage imageNamed:@"community_post_like_guide.gif"];
    }
    return _likeImageView;
}

- (UILabel *)descLabel {
    if (!_descLabel) {
        _descLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _descLabel.textColor = ZFC0xFFFFFF();
        _descLabel.font = [UIFont systemFontOfSize:14];
        _descLabel.numberOfLines = 2;
        _descLabel.textAlignment = NSTextAlignmentCenter;
        _descLabel.text = ZFLocalizedString(@"Community_story_likes_guide_msg", nil);
    }
    return _descLabel;
}
@end
