//
//  ModifyPorfileViewModel.h
//  ZZZZZ
//
//  Created by DBP on 17/2/14.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "BaseViewModel.h"

@class AccountModel;

@interface ModifyPorfileViewModel : BaseViewModel

- (void)requestSaveInfo:(id)parmaters completion:(void (^)(id))completion failure:(void (^)(id))failure;

@end
