//
//  ZFDecimalNumberBehavior.h
//  ZZZZZ
//
//  Created by YW on 2018/8/10.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZFDecimalNumberBehavior : NSObject
<
    NSDecimalNumberBehaviors
>

+(instancetype)shareInstance;

///小数点后几位数
@property (nonatomic, assign) short behaviorNumberScale;
///向上or向下取整规则
@property (nonatomic, assign) NSRoundingMode behaviorRoundingMode;

@end
