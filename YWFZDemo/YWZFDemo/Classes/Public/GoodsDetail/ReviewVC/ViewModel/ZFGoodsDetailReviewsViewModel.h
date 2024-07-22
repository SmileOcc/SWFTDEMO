//
//  ZFGoodsDetailReviewsViewModel.h
//  ZZZZZ
//
//  Created by YW on 2017/11/25.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "BaseViewModel.h"

@interface ZFGoodsDetailReviewsViewModel : BaseViewModel

+ (void)requestReviewsData:(id)parmaters
                completion:(void (^)(id))completion
                   failure:(void (^)(id))failure;

@end
