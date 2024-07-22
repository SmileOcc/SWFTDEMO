//
//  ZFZegoMessageInfo.m
//  ZZZZZ
//
//  Created by YW on 2019/8/20.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFZegoMessageInfo.h"

@implementation ZFZegoMessageInfo

- (ZegoMessageInfoType)infoType {
    
    if ([self.type isEqualToString:@"-1"]) {
        return ZegoMessageInfoTypeUser;
    } else if ([self.type isEqualToString:@"1"]) {
        return ZegoMessageInfoTypeGoods;
    } else if([self.type isEqualToString:@"2"]) {
        return ZegoMessageInfoTypeCoupon;
    } else if([self.type isEqualToString:@"3"]) {
        return ZegoMessageInfoTypeLike;
    } else if([self.type isEqualToString:@"4"]) {
        return ZegoMessageInfoTypeComment;
    } else if([self.type isEqualToString:@"5"]) {
        return ZegoMessageInfoTypeCart;
    } else if([self.type isEqualToString:@"6"]) {
        return ZegoMessageInfoTypeOrder;
    } else if([self.type isEqualToString:@"7"]) {
        return ZegoMessageInfoTypePay;
    } else if([self.type isEqualToString:@"8"]) {
        return ZegoMessageInfoTypeSystem;
    } else if([self.type isEqualToString:@"9"]) {
        return ZegoMessageInfoTypeLiveEnd;
    }
    return ZegoMessageInfoTypeUnknow;
}
@end
