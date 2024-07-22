//
//  ZFGameEmailLoginView.h
//  ZZZZZ
//
//  Created by YW on 2019/6/11.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YWLoginModel.h"
#import "YWLoginTypeEmailView.h"

NS_ASSUME_NONNULL_BEGIN

@class ZFGameEmailLoginView;
@protocol ZFGameEmailLoginViewDelegate <NSObject>

- (void)ZFGameEmailLoginViewDidClickClose:(ZFGameEmailLoginView *)view;

- (void)ZFGameEmailLoginViewDidClickContinue:(ZFGameEmailLoginView *)view;

- (void)ZFGameEmailLoginViewDidClickJumpLogin:(ZFGameEmailLoginView *)view;

@end

@interface ZFGameEmailLoginView : UIView

@property (nonatomic, weak) id<ZFGameEmailLoginViewDelegate>delegate;

@property (nonatomic, weak) YWLoginModel *loginModel;

- (void)emailBecomeFirstResponder;

- (NSString *)gainEmail;

@end

NS_ASSUME_NONNULL_END
