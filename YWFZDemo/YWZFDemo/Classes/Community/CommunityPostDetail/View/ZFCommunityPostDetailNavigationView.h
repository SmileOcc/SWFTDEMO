//
//  ZFCommunityPostDetailNavigationView.h
//  ZZZZZ
//
//  Created by YW on 2018/7/9.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 社区帖子详情导航栏
 */
@interface ZFCommunityPostDetailNavigationView : UIView

@property (nonatomic, copy) void (^backItemHandle)(void);
@property (nonatomic, copy) NSString       *title;
@property (nonatomic, strong) UIButton     *cartButton;

- (void)setRightItemButton:(NSArray <UIButton*> *)items cart:(UIButton *)cartButton;

- (void)setbackgroundAlpha:(CGFloat)alpha;

- (void)setCartBagValues;

- (UIButton *)currentIndexButton:(NSInteger )index;
- (CGRect)rectFrameToWindowIndexButton:(NSInteger)index;

@end
