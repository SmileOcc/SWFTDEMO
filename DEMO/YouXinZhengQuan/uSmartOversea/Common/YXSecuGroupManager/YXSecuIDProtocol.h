//
//  YXSecuIDProtocol.h
//  uSmartOversea
//
//  Created by ellison on 2018/12/11.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class YXSecuID;

@protocol YXSecuIDProtocol <NSObject>

@required
/**
 市场类型，（sh, sz, hk, us）
 */
@property (nonatomic, copy) NSString *market;

/**
 证券代码
 */
@property (nonatomic, copy) NSString *symbol;

- (YXSecuID *)secuId;

@end

NS_ASSUME_NONNULL_END
