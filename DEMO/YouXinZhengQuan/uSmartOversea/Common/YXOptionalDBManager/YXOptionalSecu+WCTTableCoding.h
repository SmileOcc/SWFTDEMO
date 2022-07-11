//
//  YXOptionalSecu+WCTTableCoding.h
//  uSmartOversea
//
//  Created by ellison on 2018/12/7.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#ifdef __cplusplus

#import "YXOptionalSecu.h"
#import <WCDB/WCDB.h>
@interface YXOptionalSecu (WCTTableCoding)<WCTTableCoding>
WCDB_PROPERTY(market)
WCDB_PROPERTY(symbol)
WCDB_PROPERTY(enName)
WCDB_PROPERTY(name)
WCDB_PROPERTY(type1)
WCDB_PROPERTY(type2)
WCDB_PROPERTY(type3)

WCDB_PROPERTY(priceBase)
WCDB_PROPERTY(now)
WCDB_PROPERTY(change)
WCDB_PROPERTY(roc)

@end

#endif
