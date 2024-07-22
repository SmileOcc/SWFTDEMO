//
//  ZFFullLiveSendMessageView.m
//  ZZZZZ
//
//  Created by YW on 2019/12/18.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFFullLiveSendMessageView.h"
#import "Constants.h"
#import "Masonry.h"
#import "ZFZegoHelper.h"
#import "YWCFunctionTool.h"
#import "ZFThemeManager.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "UIView+ZFViewCategorySet.h"
#import "ZFProgressHUD.h"
#import "ZFLocalizationString.h"
#import "ZFFrameDefiner.h"


static CGFloat kFullLiveMessageItemWidth = 36;

@implementation ZFFullLiveSendMessageView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.isExpandEnable = YES;
        self.isShowExpandUtils = YES;
        self.backgroundColor = ZFCClearColor();
        
        [self addSubview:self.expandCollapseView];
        [self addSubview:self.expandCollapseButton];
        
        [self addSubview:self.goodsView];
        [self addSubview:self.goodsImageView];
        [self addSubview:self.goodsButton];
        
        [self addSubview:self.couponView];
        [self addSubview:self.couponImageView];
        [self addSubview:self.couponButton];
        
        [self addSubview:self.commentView];
        [self addSubview:self.commentButton];
        
        [self addSubview:self.likeView];
        [self addSubview:self.likeButton];
        [self addSubview:self.likeNumsButton];
        
        [self addSubview:self.textView];
        [self addSubview:self.textButton];
        [self.textView addSubview:self.textPlaceLabel];
        
        
        [self.expandCollapseView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading).offset(12);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(kFullLiveMessageItemWidth, kFullLiveMessageItemWidth));
        }];
        
        [self.expandCollapseButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.expandCollapseView.mas_centerX);
            make.centerY.mas_equalTo(self.expandCollapseView.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(45, 45));
        }];
        
        [self.goodsView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading).offset(12);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(kFullLiveMessageItemWidth, kFullLiveMessageItemWidth));
        }];
        
        [self.goodsImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.goodsView.mas_centerX);
            make.centerY.mas_equalTo(self.goodsView.mas_centerY).offset(-5);
            make.size.mas_equalTo(CGSizeMake(45, 45));
        }];
        
        [self.goodsButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.goodsView.mas_centerX);
            make.centerY.mas_equalTo(self.goodsView.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(45, 45));
        }];
        
        [self.couponView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.goodsView.mas_trailing).offset(12);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(kFullLiveMessageItemWidth, kFullLiveMessageItemWidth));
        }];
        
        [self.couponImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.couponView.mas_centerX);
            make.centerY.mas_equalTo(self.couponView.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(36, 36));
        }];
        
        [self.couponButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.couponView.mas_centerX);
            make.centerY.mas_equalTo(self.couponView.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(45, 45));
        }];
        
        [self.likeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.mas_trailing).offset(-12);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(36, 36));
        }];
        
        [self.likeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.likeView.mas_centerX);
            make.centerY.mas_equalTo(self.likeView.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(36, 36));
        }];
        
        [self.likeNumsButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.likeButton.mas_bottom).offset(-9);
            make.centerX.mas_equalTo(self.likeButton.mas_centerX);
            make.width.mas_greaterThanOrEqualTo(26);
            make.height.mas_equalTo(12);
        }];
        
        [self.commentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.likeView.mas_leading).offset(-12);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(36, 36));
        }];
        
        [self.commentButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.commentView.mas_centerX);
            make.centerY.mas_equalTo(self.commentView.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(36, 36));
        }];
        
        CGFloat spaceX = 36 + 12 + 12;
        CGFloat minWidth = MIN(KScreenWidth, KScreenHeight);
        [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.expandCollapseView.mas_trailing).offset(spaceX);
            make.height.mas_equalTo(36);
            make.width.mas_equalTo(minWidth - kFullLiveMessageItemWidth * 3 - 12 * 5);
            make.centerY.mas_equalTo(self.mas_centerY);
        }];
        
        [self.textPlaceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.textView.mas_leading).offset(10);
            make.centerY.mas_equalTo(self.textView.mas_centerY);
            make.trailing.mas_equalTo(self.textView.mas_trailing).offset(-10);
        }];
        
        [self.textButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.textView.mas_leading);
            make.trailing.mas_equalTo(self.textView.mas_trailing);
            make.height.mas_equalTo(36);
            make.centerY.mas_equalTo(self.mas_centerY);
        }];
        
        //        [self.textView setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        //        [self.likeButton setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
        //        [self.likeButton setContentHuggingPriority:260 forAxis:UILayoutConstraintAxisHorizontal];
    }
    return self;
}

- (void)updateCommentContnet:(NSString *)text {
    
    if (!ZFIsEmptyString(text)) {
        self.textPlaceLabel.hidden = YES;
        self.textView.text = text;
        [ZFVideoLiveCommentUtils sharedInstance].inputText = text;
    } else {
        self.textPlaceLabel.hidden = NO;
        self.textView.text = @"";
        [ZFVideoLiveCommentUtils sharedInstance].inputText = @"";
    }
}

- (void)showLandscapeView:(BOOL)showLandscape {
    
    if (showLandscape) {
        self.goodsView.hidden = YES;
        self.goodsImageView.hidden = YES;
        self.goodsButton.hidden = YES;
        
        self.couponView.hidden = YES;
        self.couponImageView.hidden = YES;
        self.couponButton.hidden = YES;
        self.textView.hidden = !self.isShowExpandUtils;
        self.textButton.hidden = !self.isShowExpandUtils;
        self.likeView.hidden = !self.isShowExpandUtils;
        self.likeButton.hidden = !self.isShowExpandUtils;
        
        if (self.likeNums > 0) {
            self.likeNumsButton.hidden = !self.isShowExpandUtils;
        }
        
        self.expandCollapseView.hidden = NO;
        self.expandCollapseButton.hidden = NO;
                
        [self.textView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.expandCollapseView.mas_trailing).offset(12);
            make.width.mas_equalTo(210);
        }];
    } else {
        
        self.goodsView.hidden = NO;
        self.goodsImageView.hidden = NO;
        self.goodsButton.hidden = NO;
        
        self.couponView.hidden = NO;
        self.couponImageView.hidden = NO;
        self.couponButton.hidden = NO;
        self.likeView.hidden = NO;
        self.likeButton.hidden = NO;
        self.textView.hidden = NO;
        self.textButton.hidden = NO;
        
        if (self.likeNums > 0) {
            self.likeNumsButton.hidden = NO;
        } else {
            self.likeNumsButton.hidden = YES;
        }
        self.expandCollapseView.hidden = YES;
        self.expandCollapseButton.hidden = YES;
        
        CGFloat spaceX = 36 + 12 + 12;
        CGFloat minWidth = MIN(KScreenWidth, KScreenHeight);
        [self.textView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.expandCollapseView.mas_trailing).offset(spaceX);
            make.width.mas_equalTo(minWidth - kFullLiveMessageItemWidth * 3 - 12 * 5);
        }];
    }
}
- (void)showCommentView:(BOOL)show {

    self.commentView.hidden = !show;
    self.commentButton.hidden = !show;
    
    
    
    //occ测试数据v5.8.0
    //v5.6.0暂时不做
//    self.commentView.hidden = YES;
//    self.commentButton.hidden = YES;
    
    if (show) {
        self.textView.hidden = YES;
        self.textButton.hidden = YES;
    } else {
        self.textView.hidden = NO;
        self.textButton.hidden = NO;
    }
}

/// 隐藏、显示事件单元
- (void)hideEventView {
    
    if (self.isExpandEnable) {
        self.isExpandEnable = NO;
        self.isShowExpandUtils = !self.isShowExpandUtils;
        
        if (self.isShowExpandUtils) {
            [UIView animateWithDuration:0.25 animations:^{
                CGAffineTransform transform = CGAffineTransformIdentity;
                [self.expandCollapseButton.imageView setTransform:transform];
                self.isExpandEnable = YES;
            }];
        } else {
            [UIView animateWithDuration:0.25 animations:^{
                CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI);
                [self.expandCollapseButton.imageView setTransform:transform];
                self.isExpandEnable = YES;
            }];
        }
        
        BOOL hide = !self.isShowExpandUtils;
        
        self.textView.hidden = hide;        
        self.likeView.hidden = hide;
        self.likeButton.hidden = hide;
        self.likeNumsButton.hidden = hide;
        
        if (self.expandBlock) {
            self.expandBlock(self.isShowExpandUtils);
        }
    }
}

- (void)liveLikeEvent {
    self.likeNums ++;
}

- (void)setLikeNums:(NSInteger)likeNums {
    _likeNums = likeNums;
    if (likeNums > 0) {
        NSString *numTitle = [ZFVideoLiveCommentUtils formatNumberStr:[NSString stringWithFormat:@"%ld",(long)likeNums]];
        [self.likeNumsButton setTitle:numTitle forState:UIControlStateNormal];
        self.likeNumsButton.hidden = NO;
    } else {
        self.likeNumsButton.hidden = YES;
    }
}

- (void)setStopGoodsAnimate:(BOOL)stopGoodsAnimate {
    if(stopGoodsAnimate) {
        self.goodsImageView.image = [UIImage imageNamed:@"live_goods_cart.png"];
        CGFloat width = CGRectGetWidth(self.goodsImageView.frame);
        if (width > 36) {
            [self.goodsImageView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(36, 36));
                make.centerY.mas_equalTo(self.goodsView.mas_centerY);
            }];
            [self layoutIfNeeded];
        }
    } else {
        self.goodsImageView.image = [YYImage imageNamed:@"live_goods_cart_animation.gif"];
        CGFloat width = CGRectGetWidth(self.goodsImageView.frame);
        if (width < 45) {
            [self.goodsImageView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(45, 45));
                make.centerY.mas_equalTo(self.goodsView.mas_centerY).offset(-5);
            }];
            [self layoutIfNeeded];
        }
    }
}

- (void)setStopCouponAnimate:(BOOL)stopCouponAnimate {
    if(stopCouponAnimate) {
        self.couponImageView.image = [UIImage imageNamed:@"live_coupon_btn.png"];
//        CGFloat width = CGRectGetWidth(self.couponImageView.frame);
//        if (width > 36) {
//            [self.couponImageView mas_updateConstraints:^(MASConstraintMaker *make) {
//                make.size.mas_equalTo(CGSizeMake(36, 36));
//                make.centerY.mas_equalTo(self.couponView.mas_centerY);
//            }];
//            [self layoutIfNeeded];
//        }
    } else {
        self.couponImageView.image = [YYImage imageNamed:@"live_coupon_animation.gif"];
//        CGFloat width = CGRectGetWidth(self.couponImageView.frame);
//        if (width < 45) {
//            [self.couponImageView mas_updateConstraints:^(MASConstraintMaker *make) {
//                make.size.mas_equalTo(CGSizeMake(45, 45));
//                make.centerY.mas_equalTo(self.couponView.mas_centerY).offset(-5);
//            }];
//            [self layoutIfNeeded];
//        }
    }
}

#pragma mark - Action

- (void)actionExpand:(UIButton *)sender {
    [self hideEventView];
}

- (void)actionGoods:(UIButton *)sender {
    if (self.goodsBlock) {
        self.goodsBlock();
    }
}

- (void)actionCoupon:(UIButton *)sender {
    if (self.couponBlock) {
        self.couponBlock();
    }
}

- (void)actionComment:(UIButton *)sender {
    if (self.commentBlock) {
        self.commentBlock();
    }
}

- (void)actionLike:(UIButton *)sender {
    if (self.likeBlock) {
        self.likeBlock();
    }
    
    [sender.imageView.layer addAnimation:[sender.imageView zfAnimationFavouriteScaleMax:1.1] forKey:@"Liked"];

}

- (void)actionText:(UIButton *)sender {
    if (self.textBlock) {
        self.textBlock();
    }
}
#pragma mark - Property Method


- (UIView *)expandCollapseView {
    if (!_expandCollapseView) {
        _expandCollapseView = [[UIView alloc] initWithFrame:CGRectZero];
        _expandCollapseView.backgroundColor = ZFCClearColor();
        _expandCollapseView.hidden = YES;
    }
    return _expandCollapseView;
}

- (UIButton *)expandCollapseButton {
    if (!_expandCollapseButton) {
        _expandCollapseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _expandCollapseButton.hidden = YES;
        [_expandCollapseButton addTarget:self action:@selector(actionExpand:) forControlEvents:UIControlEventTouchUpInside];
        [_expandCollapseButton setImage:[UIImage imageNamed:@"live_video_comment_hide"] forState:UIControlStateNormal];
        [_expandCollapseButton setImage:[UIImage imageNamed:@"live_video_comment_hide"] forState:UIControlStateSelected];
        
    }
    return _expandCollapseButton;
}

- (UIView *)goodsView {
    if (!_goodsView) {
        _goodsView = [[UIView alloc] initWithFrame:CGRectZero];
        _goodsView.backgroundColor = ZFC0x000000_A(0.2);
        _goodsView.layer.cornerRadius = 18.0;
        _goodsView.layer.masksToBounds = YES;
    }
    return _goodsView;
}

- (YYAnimatedImageView *)goodsImageView {
    if (!_goodsImageView) {
        _goodsImageView = [[YYAnimatedImageView alloc] initWithFrame:CGRectZero];
        _goodsImageView.backgroundColor = ZFCClearColor();
        _goodsImageView.image = [YYImage imageNamed:@"live_goods_cart_animation.gif"];
    }
    return _goodsImageView;
}

- (UIButton *)goodsButton {
    if (!_goodsButton) {
        _goodsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_goodsButton addTarget:self action:@selector(actionGoods:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _goodsButton;
}


- (UIView *)couponView {
    if (!_couponView) {
        _couponView = [[UIView alloc] initWithFrame:CGRectZero];
        _couponView.backgroundColor = ZFC0x000000_A(0.2);
        _couponView.layer.cornerRadius = 18.0;
        _couponView.layer.masksToBounds = YES;
    }
    return _couponView;
}

- (YYAnimatedImageView *)couponImageView {
    if (!_couponImageView) {
        _couponImageView = [[YYAnimatedImageView alloc] initWithFrame:CGRectZero];
        _couponImageView.backgroundColor = ZFCClearColor();
        _couponImageView.image = [YYImage imageNamed:@"live_coupon_animation.gif"];
    }
    return _couponImageView;
}

- (UIButton *)couponButton {
    if (!_couponButton) {
        _couponButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_couponButton addTarget:self action:@selector(actionCoupon:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _couponButton;
}

- (UIView *)commentView {
    if (!_commentView) {
        _commentView = [[UIView alloc] initWithFrame:CGRectZero];
        _commentView.backgroundColor = ZFCClearColor();

//        _commentView.backgroundColor = ZFC0x000000_A(0.2);
//        _commentView.layer.cornerRadius = 18.0;
//        _commentView.layer.masksToBounds = YES;
        _commentView.hidden = YES;
    }
    return _commentView;
}

- (UIButton *)commentButton {
    if (!_commentButton) {
        _commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_commentButton addTarget:self action:@selector(actionComment:) forControlEvents:UIControlEventTouchUpInside];
        _commentButton.hidden = YES;
        //occ测试数据
        _commentButton.backgroundColor = ZFRandomColor();
        [_commentButton setImage:[UIImage imageNamed:@"live_video_like"] forState:UIControlStateNormal];

    }
    return _commentButton;
}

- (UIView *)likeView {
    if (!_likeView) {
        _likeView = [[UIView alloc] initWithFrame:CGRectZero];
        _likeView.backgroundColor = ZFCClearColor();
//        _likeView.backgroundColor = ZFC0x000000_A(0.2);
//        _likeView.layer.cornerRadius = 18.0;
//        _likeView.layer.masksToBounds = YES;
    }
    return _likeView;
}

- (UIButton *)likeButton {
    if (!_likeButton) {
        _likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_likeButton setImage:[UIImage imageNamed:@"live_like"] forState:UIControlStateNormal];
        _likeButton.titleLabel.font = [UIFont systemFontOfSize:9];
        [_likeButton setTitleColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
        [_likeButton addTarget:self action:@selector(actionLike:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _likeButton;
}

- (UIButton *)likeNumsButton {
    if (!_likeNumsButton) {
        _likeNumsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _likeNumsButton.titleLabel.font = [UIFont systemFontOfSize:8];
        [_likeNumsButton setTitleColor:ZFC0xFFFFFF() forState:UIControlStateNormal];
        _likeNumsButton.layer.borderColor = ZFC0xFFFFFF().CGColor;
        _likeNumsButton.layer.cornerRadius = 6;
        _likeNumsButton.layer.borderWidth = 1;
        _likeNumsButton.layer.masksToBounds = YES;
        _likeNumsButton.backgroundColor = ZFC0xFE5269();
        _likeNumsButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        _likeNumsButton.contentEdgeInsets = UIEdgeInsetsMake(0, 2, 0, 2);
        _likeNumsButton.userInteractionEnabled = NO;
        _likeNumsButton.hidden = YES;
    }
    return _likeNumsButton;
}

- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] initWithFrame:CGRectZero];
        _textView.backgroundColor = ZFC0x000000_A(0.2);
        _textView.layer.cornerRadius = 18.0;
        _textView.layer.masksToBounds = YES;
        _textView.textColor = ZFC0xCCCCCC();
        _textView.font = [UIFont systemFontOfSize:14];
        _textView.editable = NO;
    }
    return _textView;
}

- (UILabel *)textPlaceLabel {
    if (!_textPlaceLabel) {
        _textPlaceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _textPlaceLabel.textColor = ZFC0x999999();
        _textPlaceLabel.font = [UIFont systemFontOfSize:14];
        _textPlaceLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _textPlaceLabel.text = ZFLocalizedString(@"Live_Review_Input_tip", nil);
    }
    return _textPlaceLabel;
}



- (UIButton *)textButton {
    if (!_textButton) {
        _textButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_textButton addTarget:self action:@selector(actionText:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _textButton;
}
@end
