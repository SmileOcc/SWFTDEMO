//
//  YXSecu.m
//  uSmartOversea
//
//  Created by ellison on 2018/12/6.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import "YXSecu.h"


@implementation YXSecu
@synthesize market =_market;
@synthesize symbol = _symbol;
@synthesize name = _name;
@synthesize type1 = _type1;
@synthesize type2 = _type2;
@synthesize type3 = _type3;

- (instancetype)init {
    if (self = [super init]) {
        self.level = 1;
    }
    return self;
}

- (YXSecuID *)secuId {
   return [YXSecuID secuIdWithMarket:_market symbol:_symbol];
}

+ (instancetype)secuWithSecuId:(YXSecuID *)secuId {
    YXSecu* secu = [[[self class] alloc] init];
    secu.market = secuId.market;
    secu.symbol = secuId.symbol;
    
    return secu;
}

- (instancetype)initWithSecu:(id<YXSecuProtocol>)secu
{
    self = [self init];
    if (self) {
        self.market = secu.market;
        self.symbol = secu.symbol;
        self.name = secu.name;
        self.type1 = secu.type1;
        self.type2 = secu.type2;
        self.type3 = secu.type3;
    }
    return self;
}

+ (instancetype)secuWithProtoclObject:(id<YXSecuProtocol>)secu {
    return [[self alloc] initWithSecu:secu];
}

@end
