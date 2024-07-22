//
//  AnalyticsInjectManager.h
//  TestViewModel
//
//  Created by YW on 2018/9/25.
//  Copyright © 2018年 610715. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFAnalyticsInjectProtocol.h"
#import "ZFAppsflyerAnalytics.h"
#import <UIKit/UIKit.h>

@interface AnalyticsInjectManager : NSObject

+(instancetype)shareInstance;

/*
 *  注入方法
 *  @params fromObject AOP注入的目标类
 *  @params injectObject AOP注入后，实现方法的目标类
 */
-(void)analyticsInject:(NSObject *)fromObject injectObject:(id<ZFAnalyticsInjectProtocol>)injectObject;

@end
