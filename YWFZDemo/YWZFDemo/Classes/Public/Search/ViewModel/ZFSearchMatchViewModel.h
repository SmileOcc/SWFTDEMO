//
//  ZFSearchMatchViewModel.h
//  ZZZZZ
//
//  Created by YW on 2017/12/23.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "BaseViewModel.h"

@interface ZFSearchMatchViewModel : BaseViewModel

- (void)requestGetHotWordData:(id)parmaters completion:(void (^)(id))completion failure:(void (^)(id))failure;

@end
