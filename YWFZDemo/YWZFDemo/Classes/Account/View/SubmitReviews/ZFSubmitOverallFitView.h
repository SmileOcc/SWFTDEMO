//
//  ZFSubmitOverallFitView.h
//  ZZZZZ
//
//  Created by YW on 2019/4/8.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//  提交评论选择尺码视图

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ZFSubmitOverallFitViewDelegate <NSObject>

- (void)ZFSubmitOverallFitViewDidClick:(NSInteger)index content:(NSString *)content;

@end

@interface ZFSubmitOverallFitView : UIView

@property (nonatomic, weak) id<ZFSubmitOverallFitViewDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
