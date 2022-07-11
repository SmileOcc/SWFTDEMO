//
//  YXOptionalSecu.m
//  uSmartOversea
//
//  Created by ellison on 2018/12/6.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import "YXOptionalSecu.h"
#import "YXOptionalSecu+WCTTableCoding.h"

@implementation YXOptionalSecu
@synthesize market =_market;
@synthesize symbol = _symbol;
@synthesize name = _name;
@synthesize type1 = _type1;
@synthesize type2 = _type2;
@synthesize type3 = _type3;


WCDB_IMPLEMENTATION(YXOptionalSecu)
WCDB_SYNTHESIZE(YXOptionalSecu, market)
WCDB_SYNTHESIZE(YXOptionalSecu, symbol)
WCDB_SYNTHESIZE(YXOptionalSecu, name)
WCDB_SYNTHESIZE(YXOptionalSecu, type1)
WCDB_SYNTHESIZE(YXOptionalSecu, type2)
WCDB_SYNTHESIZE(YXOptionalSecu, type3)


WCDB_MULTI_PRIMARY(YXOptionalSecu, "MultiPrimaryConstraint", market)
WCDB_MULTI_PRIMARY(YXOptionalSecu, "MultiPrimaryConstraint", symbol)

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


@end
