//
//  YXSecuID.m
//  YXKit_Example
//
//  Created by ellison on 2019/4/23.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

#import "YXSecuID.h"
#import "YXSecuGroupManager.h"

@implementation YXSecuID
@synthesize market = _market;
@synthesize symbol = _symbol;

+ (instancetype)secuIdWithMarket:(NSString *)market symbol:(NSString *)symbol {
    YXSecuID *secuId = [[self alloc] init];
    secuId.market = market;
    secuId.symbol = symbol;
    
    return secuId;
}

+ (instancetype)secuIdWithString:(NSString *)string {
    YXSecuID *secuId = [[self alloc] init];
    
    NSArray *reverseArray = [[kYXAllMarket reverseObjectEnumerator] allObjects];
    for (NSString *market in reverseArray) {
        if ([string hasPrefix:market]) {
            secuId.market = market;
            secuId.symbol = [string substringFromIndex:market.length];
            break;
        }
    }
    
    return secuId;
}

- (NSString *)marketIcon {
    return [self.market lowercaseString];
}

- (YXMarketType)marketType {
    NSArray *markets = kYXAllMarket;
    NSInteger index = [markets indexOfObject:self.marketIcon];
    YXMarketType type = YXMarketTypeNone;
    switch (index) {
        case 0:
            type = YXMarketTypeHongKong;
            break;
        case 1:
        case 4:
            type = YXMarketTypeUnitedStates;
            break;
        case 2:
        case 3:
            type = YXMarketTypeChina;
            break;
        case 5:
            type = YXMarketTypeSingapore;
            break;
        default:
            break;
    }
    return type;
}

- (YXSecuType)secuType {
    if ([[self.market lowercaseString] containsString:@"option"]) {
        return YXSecuTypeOption;
    }
    return YXSecuTypeStock;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@%@", self.market, self.symbol];
}

- (NSString *)ID {
    char *buffer;
    asprintf(&buffer, "%s%s", [self.market UTF8String], [self.symbol UTF8String]);
    NSString *fullName = [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
    free(buffer);
    return fullName;//[NSString stringWithFormat:@"%@%@", self.market, self.symbol];
}

- (BOOL)isEqualToSecuID:(YXSecuID *)secuId {
    if (!secuId) {
        return NO;
    }
    
    BOOL isMarketEqual = (!self.market && !secuId.market) || [self.market isEqualToString:secuId.market];
    BOOL isCodeEqual = (!self.symbol && !secuId.symbol) || [self.symbol isEqualToString:secuId.symbol];
    
    return isMarketEqual && isCodeEqual;
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[YXSecuID class]]) {
        return NO;
    }
    
    return [self isEqualToSecuID:(YXSecuID *)object];
}

- (NSUInteger)hash {
    return [self.market hash] ^ [self.symbol hash];
}

- (YXSecuID *)secuId {
    return self;
}

@end
