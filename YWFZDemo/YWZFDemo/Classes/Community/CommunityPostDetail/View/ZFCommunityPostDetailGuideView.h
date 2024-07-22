//
//  ZFCommunityPostDetailGuideView.h
//  ZZZZZ
//
//  Created by YW on 2019/1/10.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ZFCommunityPostDetailGuideView : UIView


/**
 是否已经显示过

 @return YES:显示过
 */
+ (BOOL)hasShowGuideView;


/**
 显示视图

 @param completion 滑动操作回调
 */
- (void)showView:(void (^)(void))completion;

- (void)hideView;

@end

