//
//  YXIntervalTypeView.h
//  uSmartOversea
//
//  Created by chenmingmao on 2020/10/29.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YXIntervalTypeView : UIView

@property (nonatomic, copy) void (^clickCallBack)(UIButton *sender);

@property (nonatomic, strong) UIButton *selectBtn;

@property (nonatomic, assign) NSInteger defalutSelect;

@end

NS_ASSUME_NONNULL_END
