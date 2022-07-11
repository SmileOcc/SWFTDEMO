
// Tencent is pleased to support the open source community by making Mars available.
// Copyright (C) 207 THL A29 Limited, a Tencent company. All rights reserved.
// Licensed under the MIT License (the "License"); you may not use this file except in 
// compliance with the License. You may obtain a copy of the License at
// http://opensource.org/licenses/MIT
// Unless required by applicable law or agreed to in writing, software distributed under the License is
// distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
// either express or implied. See the License for the specific language governing permissions and
// limitations under the License.
/*
 * appender-swift-bridge.mm
 *
 *  Created on: 2017-1-3
 *      Author: Jinkey
 */

#include <stdio.h>

#import "appender-swift-bridge.h"
#import <mars/xlog/appender.h>
#import <mars/xlog/xlogger.h>
#import <sys/xattr.h>
#import "LogUtil.h"

static inline TLogLevel TlogLevelFromXlogger(XloggerType xlogLevel) {
    TLogLevel level;
    
    switch (xlogLevel) {
        case XloggerTypeAll:
            level = kLevelAll;
            break;
        case XloggerTypeVerbose:
            level = kLevelVerbose;
            break;
        case XloggerTypeDebug:
            level = kLevelDebug;
            break;
        case XloggerTypeInfo:
            level = kLevelInfo;
            break;
        case XloggerTypeWarning:
            level = kLevelWarn;
            break;
        case XloggerTypeError:
            level = kLevelError;
            break;
        case XloggerTypeFatal:
            level = kLevelFatal;
            break;
        case XloggerTypeNone:
            level = kLevelNone;
            break;
        default:
            level = kLevelAll;
            break;
    }
    return level;
}

@implementation JinkeyMarsBridge

// 封装了初始化 Xlogger 方法
// initialize Xlogger
-(void)initXlogger: (XloggerType)debugLevel releaseLevel: (XloggerType)releaseLevel path: (NSString*)path prefix: (const char*)prefix{
    
    NSString* logPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:path];
    
    // set do not backup for logpath
    const char* attrName = "com.apple.MobileBackup";
    u_int8_t attrValue = 1;
    setxattr([logPath UTF8String], attrName, &attrValue, sizeof(attrValue), 0, 0);
    
    // init xlog
    #if DEBUG

    xlogger_SetLevel(TlogLevelFromXlogger(debugLevel));
    appender_set_console_log(true);
    #else
   
    xlogger_SetLevel(TlogLevelFromXlogger(releaseLevel));
    appender_set_console_log(false);
    #endif
    appender_open(kAppednerAsync, [logPath UTF8String], prefix, [LogUtil logPubKey]);
    
}

// 封装了关闭 Xlogger 方法
// deinitialize Xlogger
-(void)deinitXlogger {
    appender_close();
}

-(void)flush {
    appender_flush();
}

-(void)flushSync {
    appender_flush_sync();
}


// 利用微信提供的 LogUtil.h 封装了打印日志的方法
// print log using LogUtil.h provided by Wechat
- (void)log: (XloggerType) level tag: (const char*)tag content: (NSString*)content fileName: (NSString *)fileName function: (NSString *)function line: (NSInteger)line {
    NSString* levelDescription = @"";
    
    switch (level) {
        case XloggerTypeDebug:
            do {
                if ([LogHelper shouldLog:XloggerTypeDebug]) {
                    NSString *aMessage = [NSString stringWithFormat:@"%@%@", @"Debug:", [NSString stringWithFormat:@"%@", content]];
                    [LogHelper logWithLevel:XloggerTypeDebug moduleName:tag fileName:[fileName UTF8String] lineNumber:(int)line funcName:[function UTF8String] message:aMessage];
                } } while(0);
            levelDescription = @"Debug";
            break;
        case XloggerTypeInfo:
            do {
                if ([LogHelper shouldLog:XloggerTypeInfo]) {
                    NSString *aMessage = [NSString stringWithFormat:@"%@%@", @"Info:", [NSString stringWithFormat:@"%@", content]];
                    [LogHelper logWithLevel:XloggerTypeInfo moduleName:tag fileName:[fileName UTF8String] lineNumber:(int)line funcName:[function UTF8String] message:aMessage];
                } } while(0);
            levelDescription = @"Info";
            break;
        case XloggerTypeWarning:
            do {
                if ([LogHelper shouldLog:XloggerTypeWarning]) {
                    NSString *aMessage = [NSString stringWithFormat:@"%@%@", @"Warning:", [NSString stringWithFormat:@"%@", content]];
                    [LogHelper logWithLevel:XloggerTypeWarning moduleName:tag fileName:[fileName UTF8String] lineNumber:(int)line funcName:[function UTF8String] message:aMessage];
                } } while(0);
            levelDescription = @"Warn";
            break;
        case XloggerTypeError:
            do {
                if ([LogHelper shouldLog:XloggerTypeError]) {
                    NSString *aMessage = [NSString stringWithFormat:@"%@%@", @"Error:", [NSString stringWithFormat:@"%@", content]];
                    [LogHelper logWithLevel:XloggerTypeError moduleName:tag fileName:[fileName UTF8String] lineNumber:(int)line funcName:[function UTF8String] message:aMessage];
                } } while(0);
            levelDescription = @"Error";
            break;
        case XloggerTypeVerbose:
            do {
                if ([LogHelper shouldLog:XloggerTypeVerbose]) {
                    NSString *aMessage = [NSString stringWithFormat:@"%@%@", @"Verbose:", [NSString stringWithFormat:@"%@", content]];
                    [LogHelper logWithLevel:XloggerTypeVerbose moduleName:tag fileName:[fileName UTF8String] lineNumber:(int)line funcName:[function UTF8String] message:aMessage];
                } } while(0);
            levelDescription = @"Verbose";
            break;
        default:
            break;
    }
    
}

@end


