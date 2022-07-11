//
//  OSSVPaymentsStatussViewModel.h
// XStarlinkProject
//
//  Created by fan wang on 2021/5/22.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseViewModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface OSSVPaymentsStatussViewModel : BaseViewModel
-(void)checkOrderStatus:(id)parmaters completion:(void (^)(id obj, NSString *msg))completion failure:(void (^)(id obj, NSString *msg))failure;
@end

NS_ASSUME_NONNULL_END
