//
//  OSSVPaymentsStatusAip.h
// XStarlinkProject
//
//  Created by fan wang on 2021/5/22.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STLBaseRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface OSSVPaymentsStatusAip : STLBaseRequest
-(instancetype)initWithParam:(NSDictionary *)param;
@property (strong,nonatomic) NSDictionary *params;
@end

NS_ASSUME_NONNULL_END
