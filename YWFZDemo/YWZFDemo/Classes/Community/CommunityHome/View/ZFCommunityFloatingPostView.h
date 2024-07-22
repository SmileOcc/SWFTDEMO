//
//  ZFCommunityFloatingPostView.h
//  ZZZZZ
//
//  Created by YW on 2019/7/3.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFInitViewProtocol.h"

NS_ASSUME_NONNULL_BEGIN

///浮窗按钮，扩散式动画
@interface ZFCommunityFloatingPostView : UIView
<ZFInitViewProtocol>

@property (nonatomic, copy) void (^showsBlock)(void);
@property (nonatomic, copy) void (^outfitsBlock)(void);
@property (nonatomic, copy) void (^animateStateBlock)(BOOL state);

- (void)showPostView;
- (void)hideCircleSmallerAnimation:(BOOL)animate;

@end

///浮窗按钮，普通
@interface ZFCommunityFloatingPostMenuView : UIView

@property (nonatomic, copy) void (^tapBlock)(void);

@end

NS_ASSUME_NONNULL_END
