//
//  ZFFullLiveErrorView.h
//  ZZZZZ
//
//  Created by YW on 2019/12/19.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYWebImage/YYWebImage.h>
#import "Masonry.h"
#import "Constants.h"
#import "ZFThemeManager.h"
#import "YWCFunctionTool.h"
#import "UIView+ZFViewCategorySet.h"
#import "ZFLocalizationString.h"
#import "ZFFrameDefiner.h"
#import "ZFCommunityLiveRouteModel.h"
#import "ZFZegoLiveConstants.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFFullLiveErrorView : UIView


@property (nonatomic, copy) void (^refreshBlock)(void);
@property (nonatomic, copy) void (^changeRoteBlock)(ZFCommunityLiveRouteModel *roteModel);
@property (nonatomic, copy) void (^closeBlock)(void);

@property (nonatomic, strong) NSArray<ZFCommunityLiveRouteModel *> *rotes;

- (void)configurateRotes:(NSArray <ZFCommunityLiveRouteModel *> *)rotes;

- (void)updateLiveCoverState:(LiveZegoCoverState)coverState;

- (void)showError:(BOOL)show;
- (void)endLoading:(BOOL)success;
@end



NS_ASSUME_NONNULL_END
