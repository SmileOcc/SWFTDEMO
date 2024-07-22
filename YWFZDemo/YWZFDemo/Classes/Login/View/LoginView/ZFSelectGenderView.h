//
//  ZFSelectGenderView.h
//  ZZZZZ
//
//  Created by YW on 2018/8/13.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//  注册时选择性别的视图

#import <UIKit/UIKit.h>

@class ZFSelectGenderView;
typedef void(^ZFSelectGenderHandle)(ZFSelectGenderView *genderView);

@interface ZFSelectGenderView : UIView

@property (nonatomic, copy) ZFSelectGenderHandle handleClick;

@property (nonatomic, copy) NSString *gender;

@end
