//
//  OSSVAnalyticInjectsProtocol.h
// XStarlinkProject
//
//  Created by odd on 2020/9/10.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol OSSVAnalyticInjectsProtocol <NSObject>

///after 注入事件
-(NSDictionary *)injectMenthodParams;


@optional

///before 注入事件
-(NSDictionary *)beforeInjectMenthodParams;

///过滤白名单断言
-(NSArray <NSString *> *)whiteListAssert;

///获取目标Aop类
- (void)gainCurrentAopClass:(id)currentAopClass;

@end

