//
//  ZFFullLiveStateCoverView.h
//  ZZZZZ
//
//  Created by YW on 2019/12/18.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFCommunityLiveWaitInfor.h"
#import "ZFZegoLiveConstants.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFFullLiveStateCoverView : UIView

@property (nonatomic, strong) ZFCommunityLiveWaitInfor *inforModel;

@property (nonatomic, assign) BOOL                     isRemind;
@property (nonatomic, assign) LiveZegoCoverState       coverState;
@property (nonatomic, assign) BOOL                     isThirdStream;


@property (nonatomic, copy) void (^remindBlock)(void);
@property (nonatomic, copy) void (^waitTimeBlock)(BOOL waiting);
@property (nonatomic, copy) void (^backBlock)(void);


@property (nonatomic, weak) UIView *commentView;

- (void)updateLiveCoverState:(LiveZegoCoverState)coverState;


- (void)stopTimer;
@end

NS_ASSUME_NONNULL_END
