//
//  ZFCommunityLikeGuideView.h
//  ZZZZZ
//
//  Created by YW on 2019/5/5.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZFCommunityLikeGuideView : UIView

+ (BOOL)isShowGuideView;
+ (void)saveGuideView;

- (void)firstShowLikeGuideView:(UIView *)superView;
- (void)hiddenView;

@end

NS_ASSUME_NONNULL_END
