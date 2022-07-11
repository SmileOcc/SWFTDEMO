//
//  YXLiveUserLevelView.h
//  uSmartOversea
//
//  Created by chenmingmao on 2020/10/21.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YXLiveUserLevelView : UIView

@property (nonatomic, copy) void (^updateCallBack)(void);

// -1:全部可见 1:proV1 2:proV2 4:PI (目前返回1和4，2为预留)"
@property (nonatomic, assign) int require_right;

@end

NS_ASSUME_NONNULL_END
