//
//  ZFAnalyticsInjectProtocol.h
//  ZZZZZ
//
//  Created by YW on 2018/10/8.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ZFAnalyticsInjectProtocol <NSObject>

///after 注入事件
-(NSDictionary *)injectMenthodParams;

//- (void)module:(NSString*)moduleName
//      pageName:(NSString *)pageName
//      duration:(NSUInteger)duration
//          args:(NSDictionary *)args;

@optional

///before 注入事件
-(NSDictionary *)beforeInjectMenthodParams;

///过滤白名单断言
-(NSArray <NSString *> *)whiteListAssert;

///获取目标Aop类
- (void)gainCurrentAopClass:(id)currentAopClass;

@end

NS_ASSUME_NONNULL_END
