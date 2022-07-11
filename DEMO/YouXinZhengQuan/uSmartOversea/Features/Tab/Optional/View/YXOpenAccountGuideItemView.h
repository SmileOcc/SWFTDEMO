//
//  YXOpenAccountGuideItemView.h
//  uSmartOversea
//
//  Created by chenmingmao on 2020/3/13.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^updateBlock)(void);

NS_ASSUME_NONNULL_BEGIN

@interface YXOpenAccountGuideItemView : UIView

- (instancetype)initWithFrame:(CGRect)frame andClickCallBack:(updateBlock)callback;

@property (nonatomic, strong) QMUIMarqueeLabel *label;


@end

NS_ASSUME_NONNULL_END
