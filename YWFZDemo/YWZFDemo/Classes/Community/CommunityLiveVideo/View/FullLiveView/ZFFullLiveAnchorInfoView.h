//
//  ZFFullLiveAnchorInfoView.h
//  ZZZZZ
//
//  Created by YW on 2019/12/18.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFCommunityLiveVideoRedNetModel.h"
#import "ZFCommunityLiveVideoActivityModel.h"
#import "ZFVideoLiveConfigureInfoUtils.h"

NS_ASSUME_NONNULL_BEGIN
/// 主播介绍
@interface ZFFullLiveAnchorInfoView : UIView

- (instancetype)initWithFrame:(CGRect)frame;

@property (nonatomic, copy) void (^liveVideoBlock)(NSString *deeplink);
@property (nonatomic, copy) void (^closeBlock)(void);


@property (nonatomic, strong) ZFCommunityLiveVideoActivityModel     *liveActivityViewModel;

- (void)zfViewWillAppear;
- (void)updateHotActivity:(NSArray <ZFCommunityLiveVideoRedNetModel*> *)activityModel;

- (void)showAnchorView:(BOOL)show;
@end

NS_ASSUME_NONNULL_END
