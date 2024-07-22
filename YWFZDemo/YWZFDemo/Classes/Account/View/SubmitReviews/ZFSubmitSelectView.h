//
//  ZFSubmitSelectView.h
//  ZZZZZ
//
//  Created by YW on 2019/4/4.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//  右边带箭头的选择视图

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZFSubmitSelectView : UIView

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *placeHold;
@property (nonatomic, copy) NSString *sizeId;
@property (nonatomic, assign) BOOL enable;

- (void)reloadArrowStatus;

@end

NS_ASSUME_NONNULL_END
