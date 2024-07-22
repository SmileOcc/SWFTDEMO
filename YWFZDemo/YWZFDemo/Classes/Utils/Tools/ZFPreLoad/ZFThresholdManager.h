//
//  ZFThresholdManager.h
//  ZFThresholdManager
//
//  Created by Tsang_Fa on 2018/3/27.
//  Copyright © 2018年. All rights reserved.
//

/**
 * 列表页数据预加载阈值管理器
 * 原理：根据当前 UITableView 的所在位置，除以目前整个 UITableView.contentView 的高度，判断是否提前触发请求
 * 引入动态的Threshold (知乎客户端就是这种方式处理)
 */

typedef void(^reloadAction)(void);

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "YJNSAspectOrientProgramming.h"

@interface ZFThresholdManager : NSObject

/**
 初始化helper的方法 （pageSize需要和reloadaction里面添加的个数相等）
 @param threshold 加载的百分比
 @param pageSize 每次加载数据的个数
 @param reloadAction 刷新的方法
 @return helper
 */
- (instancetype)initWithThreshold:(CGFloat)threshold
                    everyPageSize:(NSInteger)pageSize
                           contol:(id)control
                     scrollerView:(UIScrollView*)scrollerView
                     reloadAction:(reloadAction)reloadAction;

/**
 初始化helper的方法 （pageSize需要和reloadaction里面添加的个数相等）
 @param threshold 加载的百分比
 @param pageSize 每次加载数据的个数
 @param reloadAction 刷新的方法
 @return helper
 @return needDelegateRollBack 代理回滚到页面.不需要在这个类里实现
 */
- (instancetype)  initWithThreshold:(CGFloat)threshold
                      everyPageSize:(NSInteger)pageSize
                             contol:(id)control
                       scrollerView:(UIScrollView*)scrollerView
                       reloadAction:(reloadAction)reloadAction
                   DelegateRollBack:(BOOL)needDelegateRollBack;

/**
 结束刷新的时候需要调用（必须要调用一下这个方法也就是reloadAction里结束的时候需要调用一下）
 */
- (void)endLoadDatas;

@property (nonatomic, assign) BOOL needDelegateRollBack;


// 判断是否正在加载
@property(nonatomic,getter=isloading) BOOL loading;

@property (nonatomic,assign) CGFloat        threshold;
@property (nonatomic,assign) NSInteger      currentPage;
@property (nonatomic,assign) NSInteger      itemPerpage;
@property (nonatomic,copy)   reloadAction   action;
@property (nonatomic,strong) YJNSAspectOrientProgramming *aopDelegate;


@end
