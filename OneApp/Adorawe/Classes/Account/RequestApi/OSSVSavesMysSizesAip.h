//
//  OSSVSavesMysSizesAip.h
// XStarlinkProject
//
//  Created by Starlinke on 2021/6/9.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVBasesRequests.h"

NS_ASSUME_NONNULL_BEGIN

/// 保存尺码信息
@interface OSSVSavesMysSizesAip : OSSVBasesRequests

- (instancetype)initWithSizeType:(NSInteger)sizeType gender:(NSInteger)gender height:(NSString *)height weight:(NSString *)weight;

@end

NS_ASSUME_NONNULL_END
