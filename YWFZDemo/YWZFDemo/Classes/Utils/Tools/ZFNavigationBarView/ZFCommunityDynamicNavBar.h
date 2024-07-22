//
//  ZFCommunityDynamicNavBar.h
//  ZZZZZ
//
//  Created by YW on 2019/10/10.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ZFCommunityDynamicNavBar : UIView

@property (nonatomic, copy) void (^backItemHandle)(void);
@property (nonatomic, assign) BOOL isNotNeedSkin;
@property (nonatomic, assign) BOOL isHideBottomLine;
@property (nonatomic, assign) CGFloat      buttonHeight;



@property (nonatomic, copy) NSString       *title;

- (void)setRightItemButton:(NSArray <UIButton*> *)items;

- (void)setbackgroundAlpha:(CGFloat)alpha;

- (UIButton *)currentIndexButton:(NSInteger )index;

- (void)updateBackImage:(UIImage *)image;
@end

