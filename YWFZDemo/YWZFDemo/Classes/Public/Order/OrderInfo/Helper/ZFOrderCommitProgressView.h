//
//  ZFOrderCommitProgressView.h
//  ZZZZZ
//
//  Created by YW on 2019/2/22.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger) {
    ZFProgressViewType_Request, //由外部调用结束方法结束
    ZFProgressViewType_Fixed, //程序内部提供一个固定时间调用结束方法
}ZFProgressViewType;

@protocol ZFOrderCommitProgressViewDelegate <NSObject>

@optional
/*
 ad_params
 //0--代表新版本，添加安全支付提示
 //1--代表老流程，无安全支付提示
 */
- (void)ZFOrderCommitProgressViewShowProgressView;

//停止动画回调
- (void)ZFOrderCommitProgressViewDidStopProgress;

//不显示progress回调
- (void)ZFOrderCommitProgressViewNoShow;

@end

@interface ZFOrderCommitProgressView : UIView

+ (void)showProgressViewType:(ZFProgressViewType)type delegate:(id<ZFOrderCommitProgressViewDelegate>)delegate;

+ (void)hiddenProgressView:(void(^)(void))block;

+ (void)cancelProgressView;

@end

NS_ASSUME_NONNULL_END
