//
//  EmptyCustomViewManage.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/8.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  此处分三种情况
 1、隐藏 View，固定
 2、显示 NO Net View 固定  ===> 同时需要返回一个 点击事件
 3、显示 NO Data View 自定义 ===> 传一个View 进入。
 */

#pragma mark - EmptyCustomViewManager
typedef void (^EmptyRefreshOperationBlock)();

@interface EmptyCustomViewManager : NSObject

//+ (instancetype)sharedInstance;

@property (nonatomic, copy) EmptyRefreshOperationBlock emptyRefreshOperationBlock;
@property (nonatomic, strong) UIView *customNoDataView; // 我们传入的自定义 NoDataView

- (UIView *)accordingToTypeReBackView:(EmptyViewShowType)emptyViewShowType;

@end

#pragma mark - EmptyCustomNoNetView
@protocol EmptyCustomNoNetViewDelegate;

@interface EmptyCustomNoNetView : UIView

@property (nonatomic, weak) id <EmptyCustomNoNetViewDelegate> delegate;

@end

#pragma mark - EmptyCustomNoNetViewDelegate

@protocol EmptyCustomNoNetViewDelegate <NSObject>

- (void)emptyRefreshAction;

@end
