//
//  STLShareViewModel.h
// XStarlinkProject
//
//  Created by Starlinke on 2021/6/17.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "BaseViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface STLShareViewModel : BaseViewModel

- (void)requestShareAndEarnNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure;

@end

NS_ASSUME_NONNULL_END
