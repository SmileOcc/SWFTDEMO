//
//  STLSendCodeApi.h
// XStarlinkProject
//
//  Created by Starlinke on 2021/8/3.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVBasesRequests.h"

NS_ASSUME_NONNULL_BEGIN

@interface STLSendCodeApi : OSSVBasesRequests

-(instancetype)initWithParam:(NSDictionary *)param;
@property (strong,nonatomic) NSDictionary *params;


@end

NS_ASSUME_NONNULL_END
