//
//  NSArray+safe.h
//  uSmartOversea
//
//  Created by rrd on 2018/7/19.
//Copyright © 2018年 RenRenDai. All rights reserved.
//

#import <Foundation/Foundation.h>

#if _SEQUENCE_SAFE_ENABLED

/**
 主要用来防止数组越界
 */
@interface NSArray (safe)

@end
#endif
