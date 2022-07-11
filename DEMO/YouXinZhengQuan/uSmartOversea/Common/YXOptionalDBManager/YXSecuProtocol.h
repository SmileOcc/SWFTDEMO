//
//  YXSecuProtocol.h
//  uSmartOversea
//
//  Created by ellison on 2018/12/7.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import "YXSecuIDProtocol.h"
#import "Secu.pbobjc.h"

NS_ASSUME_NONNULL_BEGIN

@protocol YXSecuProtocol<YXSecuIDProtocol>


@required
/**
 证券中文简称
 */
@property(nonatomic, copy) NSString *name;

/**
 证券一级分类，
 */
@property(nonatomic, assign) int type1;

/**
 证券二级分类，
 */
@property(nonatomic, assign) int type2;

/**
 证券三级分类，
 */
@property(nonatomic, assign) int type3;


@end

NS_ASSUME_NONNULL_END
