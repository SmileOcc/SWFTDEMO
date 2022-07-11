//
//  OSSVAnalyticInjectsManager.h
// XStarlinkProject
//
//  Created by odd on 2020/9/10.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSSVAnalyticInjectsProtocol.h"
#import "OSSVAnalyticsTool.h"

NS_ASSUME_NONNULL_BEGIN

@interface OSSVAnalyticInjectsManager : NSObject

+(instancetype)shareInstance;

/*
 *  注入方法
 *  @params fromObject AOP注入的目标类
 *  @params injectObject AOP注入后，实现方法的目标类
 */
-(void)analyticsInject:(NSObject *)fromObject injectObject:(id<OSSVAnalyticInjectsProtocol>)injectObject;

@end

NS_ASSUME_NONNULL_END
