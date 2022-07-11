//
//  YXOptionalSecu.h
//  uSmartOversea
//
//  Created by ellison on 2018/12/6.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import "YXSecuIDProtocol.h"
#import "YXSecuProtocol.h"
#import "YXSecuMobileBrief1Protocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface YXOptionalSecu : NSObject<YXSecuProtocol>

- (instancetype)initWithSecu:(id<YXSecuProtocol>)secu;

@end

NS_ASSUME_NONNULL_END
