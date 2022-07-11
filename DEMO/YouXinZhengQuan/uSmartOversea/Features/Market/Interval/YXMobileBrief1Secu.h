//
//  YXMobileBrief1Secu.h
//  uSmartOversea
//
//  Created by ellison on 2019/1/7.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXSecu.h"
#import "YXSecuMobileBrief1Protocol.h"

NS_ASSUME_NONNULL_BEGIN

@class YXV2Quote;
@interface YXMobileBrief1Secu : YXSecu<YXSecuMobileBrief1Protocol>
- (instancetype)initWithV2Quote:(YXV2Quote *)quote;
@end

NS_ASSUME_NONNULL_END
