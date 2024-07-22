//
//  ZFLiveVideoPlayOperateView.h
//  ZZZZZ
//
//  Created by YW on 2019/12/20.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "ZFThemeManager.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "UIView+ZFViewCategorySet.h"
NS_ASSUME_NONNULL_BEGIN

@interface ZFLiveVideoPlayOperateView : UIView

@property (nonatomic, strong) UIButton        *playButton;
@property (nonatomic, strong) UIButton        *fullPlayButton;

@property (nonatomic, strong) UILabel         *startTimeLabel;
@property (nonatomic, strong) UILabel         *endTimeLabel;
@property (nonatomic, strong) UISlider        *progressSlider;

@property (nonatomic, assign) BOOL            isFull;
@property (nonatomic, assign) BOOL            isPlay;

@property (nonatomic, assign) NSInteger       autoHideBottomViewCount;


@property (nonatomic, copy) void (^playStateBlock)(BOOL isPlay);

@property (nonatomic, copy) void (^fullPlayBlock)(BOOL isFull);

@property (nonatomic, copy) void (^sliderValueBlock)(CGFloat value);

@property (nonatomic, copy) void (^autoHideBlock)(void);


- (void)showFullButton:(BOOL)show;

- (void)startTime:(NSString *)startTime endTime:(NSString *)endTime isEnd:(BOOL)isEnd;

@end

NS_ASSUME_NONNULL_END
