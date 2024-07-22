//
//  ZFBottomToolView.h
//  ZZZZZ
//
//  Created by YW on 2017/8/29.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ZFBottomButtonBlock)(void);

@interface ZFBottomToolView : UIView
@property (nonatomic, assign) BOOL                  showTopShadowline; //默认显示投影线条
@property (nonatomic, strong) NSString              *bottomTitle;
@property (nonatomic, copy) ZFBottomButtonBlock     bottomButtonBlock;
@property (nonatomic, strong, readonly) UIButton    *bottomButton;
@property (nonatomic, strong) UIView                *topLine;
@end
