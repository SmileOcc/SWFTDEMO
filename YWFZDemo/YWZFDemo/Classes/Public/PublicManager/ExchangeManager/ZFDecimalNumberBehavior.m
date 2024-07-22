//
//  ZFDecimalNumberBehavior.m
//  ZZZZZ
//
//  Created by YW on 2018/8/10.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFDecimalNumberBehavior.h"

@implementation ZFDecimalNumberBehavior

+(instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    static ZFDecimalNumberBehavior *behavior = nil;
    dispatch_once(&onceToken, ^{
        behavior = [[ZFDecimalNumberBehavior alloc] init];
    });
    return behavior;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.behaviorNumberScale = 1;
        self.behaviorRoundingMode = NSRoundUp;
    }
    return self;
}

- (NSRoundingMode)roundingMode
{
    return self.behaviorRoundingMode;
}

- (short)scale
{
    return self.behaviorNumberScale;
}

- (nullable NSDecimalNumber *)exceptionDuringOperation:(SEL)operation error:(NSCalculationError)error leftOperand:(NSDecimalNumber *)leftOperand rightOperand:(nullable NSDecimalNumber *)rightOperand
{
    return nil;
}

@end
