//
//  STLBindPhoneAPI.h
// XStarlinkProject
//
//  Created by fan wang on 2021/5/18.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVBasesRequests.h"

NS_ASSUME_NONNULL_BEGIN

@interface STLBindPhoneAPI : OSSVBasesRequests
-(instancetype)initWithParam:(NSDictionary *)param;
@property (strong,nonatomic) NSDictionary *params;
@property (assign,nonatomic) BOOL sentPhoneNum;
@end

NS_ASSUME_NONNULL_END
