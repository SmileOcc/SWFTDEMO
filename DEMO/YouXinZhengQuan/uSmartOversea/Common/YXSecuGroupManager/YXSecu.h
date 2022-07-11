//
//  YXSecu.h
//  uSmartOversea
//
//  Created by ellison on 2018/12/6.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import "YXModel.h"
#import "YXSecuID.h"
#import "YXSecuProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface YXSecu : YXModel <YXSecuProtocol>
@property (nonatomic, assign) NSInteger level;
@property (nonatomic, assign) NSInteger jumpType;

+ (instancetype)secuWithSecuId:(YXSecuID *)secuId;

+ (instancetype)secuWithProtoclObject:(id<YXSecuProtocol>)secu;

@end

NS_ASSUME_NONNULL_END
