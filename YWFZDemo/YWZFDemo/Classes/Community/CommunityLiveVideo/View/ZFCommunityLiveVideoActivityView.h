//
//  ZFCommunityLiveVideoActivityView.h
//  ZZZZZ
//
//  Created by YW on 2019/4/2.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFCommunityLiveVideoRedNetModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFCommunityLiveVideoActivityView : UIView

- (instancetype)initWithFrame:(CGRect)frame cateName:(NSString *)cateName cateID:(NSString *)cateID;

@property (nonatomic, copy) void (^liveVideoBlock)(NSString *deeplink);

- (void)zfViewWillAppear;
- (void)fullScreen:(id)isFull;
- (void)updateHotActivity:(NSArray <ZFCommunityLiveVideoRedNetModel*> *)activityModel;
@end

NS_ASSUME_NONNULL_END
