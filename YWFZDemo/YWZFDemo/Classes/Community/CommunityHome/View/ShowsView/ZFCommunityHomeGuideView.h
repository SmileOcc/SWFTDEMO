//
//  ZFCommunityHomeGuideView.h
//  ZZZZZ
//
//  Created by YW on 2018/12/13.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZFCommunityHomeGuideView : UIView

+ (BOOL)isHadShowGuideView;
- (void)showViewThemeFrame:(CGRect)themeFrame;
- (void)hideView;
@end


@interface CommunityHomeGuideButton : UIButton

@end
NS_ASSUME_NONNULL_END
