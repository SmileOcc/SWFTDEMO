//
//  ZFCommunityLiveWaitView.h
//  ZZZZZ
//
//  Created by YW on 2019/4/8.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFCommunityLiveWaitInfor.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFCommunityLiveWaitView : UIView

@property (nonatomic, strong) ZFCommunityLiveWaitInfor *inforModel;

@property (nonatomic, copy) void (^gobackBlock)(BOOL flag);
@property (nonatomic, copy) void (^cartBlock)(BOOL flag);



- (void)stopTimer;

@end
NS_ASSUME_NONNULL_END
