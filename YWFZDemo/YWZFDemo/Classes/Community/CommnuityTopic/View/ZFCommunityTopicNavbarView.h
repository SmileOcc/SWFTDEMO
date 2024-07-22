//
//  ZFCommunityTopicNavbarView.h
//  ZZZZZ
//
//  Created by YW on 2018/9/18.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZFCommunityTopicNavbarView : UIView

@property (nonatomic, copy) void (^backItemHandle)(void);
@property (nonatomic, copy) void (^rightItemHandle)(void);
@property (nonatomic, copy) NSString  *title;
- (void)setbackgroundAlpha:(CGFloat)alpha;
- (void)setRightItemImage:(UIImage *)image isHidden:(BOOL)isHidden;
- (void)hideBottomLine;

@end
