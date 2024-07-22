//
//  ZFLiveVideoPlayView.h
//  ZZZZZ
//
//  Created by YW on 2019/12/21.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "ZFThemeManager.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "UIView+ZFViewCategorySet.h"
#import "ZFLiveProgressLineView.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFLiveVideoPlayView : UIView

@property (nonatomic, copy) void (^dismissWindowBlock)(void);
@property (nonatomic, copy) void (^showWindowBlock)(void);
@property (nonatomic, copy) void (^stopPlayBlock)(void);
@property (nonatomic, copy) void (^tapBlock)(void);

@property (nonatomic, strong) UIView       *playView;
@property (nonatomic, strong) UIImageView  *previewImageView;
@property (nonatomic, strong) UIButton     *closeButton;

@property (nonatomic, strong) ZFLiveProgressLineView           *videoPorgressLineView;

/// 来源父视图
@property (nonatomic, weak) UIView                       *sourceView;
/// 平移手势
@property (nonatomic, strong) UIPanGestureRecognizer     *pan;
/// 点击手势
@property (nonatomic, strong) UITapGestureRecognizer     *tap;
/// 用于手势平移
@property (nonatomic, assign) BOOL                       isAnimating;

@property (nonatomic, assign) BOOL isShowPreviewImage;


- (void)showProgressLine:(BOOL )show;

- (void)showToWindow:(CGSize)size;

- (void)dissmissFromWindow:(BOOL)isPlaying;

- (void)updateProgress:(CGFloat)progress;

#pragma mark - 显示封面图
- (void)showPreviewView;

- (void)hidePreviewView;

- (UIImage *)snapshotVideoImage;
@end

NS_ASSUME_NONNULL_END
