//
//  ZFCommunityPostViewModel.h
//  Yoshop
//
//  Created by YW on 16/7/20.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import "BaseViewModel.h"

@interface ZFCommunityPostViewModel : BaseViewModel
- (void)requestTabObtainNetwork:(id)parmaters completion:(void (^)(id))completion failure:(void (^)(id))failure;
- (void)requestPostNetwork:(id)parmaters completion:(void (^)(id))completion failure:(void (^)(id))failure;
@end
