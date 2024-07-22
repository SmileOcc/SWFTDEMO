//
//  ZFGameLoingTitleView.h
//  ZZZZZ
//
//  Created by YW on 2018/9/28.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZFGameLoingTitleView : UIView

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImage *image;

- (void)addtarget:(id)target action:(SEL)selector;

@end

