//
//  Header.h
//  ZZZZZTests
//
//  Created by YW on 2019/5/31.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "Constants.h"

#ifndef Header_h
#define Header_h

//waitForExpectationsWithTimeout是等待时间，超过了就不再等待往下执行。
#define WAIT do {\
[self expectationForNotification:@"RSBaseTest" object:nil handler:nil];\
[self waitForExpectationsWithTimeout:300 handler:nil];\
} while (0);

#define NOTIFY \
[[NSNotificationCenter defaultCenter]postNotificationName:@"RSBaseTest" object:nil];



#define kTests_Current_time(start) NSTimeInterval start = CACurrentMediaTime();
#define kTests_End_time(start) CACurrentMediaTime() - (start >= 0 ? start : 0)


#define kTests_Result(keyMsg,obj,tiemKey) id jsonObj = [obj yy_modelToJSONObject];\
NSData *data = [NSJSONSerialization dataWithJSONObject:jsonObj ? jsonObj : @{} options:NSJSONWritingPrettyPrinted error:nil];\
NSString *tempStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];\
YWLog(@"====== 单元测试（%@）: %@",keyMsg,tempStr);\
YWLog(@"====== 单元测试（%@）: %lf",keyMsg, kTests_End_time(tiemKey));\
if ([keyMsg containsString:@"failure"]) {XCTFail(keyMsg);}


#endif /* Header_h */
