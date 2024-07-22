//
//  ZFCommunityAccountOutfitsViewModel.h
//  ZZZZZ
//
//  Created by YW on 2017/8/4.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "BaseViewModel.h"

@interface ZFCommunityAccountOutfitsViewModel : BaseViewModel


- (void)requestOutfitsListData:(id)parmaters
                    completion:(void (^)(id obj, NSInteger totalPage))completion
                       failure:(void (^)(id))failure;

//点赞
- (void)requestLikeNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure;
@end
