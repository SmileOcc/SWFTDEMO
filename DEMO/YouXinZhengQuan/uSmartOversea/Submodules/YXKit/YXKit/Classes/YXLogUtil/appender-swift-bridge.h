// Tencent is pleased to support the open source community by making Mars available.
// Copyright (C) 2017 THL A29 Limited, a Tencent company. All rights reserved.
// Licensed under the MIT License (the "License"); you may not use this file except in 
// compliance with the License. You may obtain a copy of the License at
// http://opensource.org/licenses/MIT
// Unless required by applicable law or agreed to in writing, software distributed under the License is
// distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
// either express or implied. See the License for the specific language governing permissions and
// limitations under the License.
/*
 * appender-swift-bridge.h
 *
 *  Created on: 2017-1-3
 *      Author: Jinkey
 */

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, XloggerType){
    XloggerTypeAll,
    XloggerTypeVerbose,
    XloggerTypeDebug,
    XloggerTypeInfo,
    XloggerTypeWarning,
    XloggerTypeError,
    XloggerTypeFatal,
    XloggerTypeNone
};

@interface JinkeyMarsBridge: NSObject

- (void)initXlogger: (XloggerType)debugLevel releaseLevel: (XloggerType)releaseLevel path: (NSString*)path prefix: (const char*)prefix;
- (void)deinitXlogger;
- (void)flush;
- (void)flushSync;
- (void)log: (XloggerType) level tag: (const char*)tag content: (NSString*)content fileName: (NSString *)fileName function: (NSString *)function line: (NSInteger)line;



@end


