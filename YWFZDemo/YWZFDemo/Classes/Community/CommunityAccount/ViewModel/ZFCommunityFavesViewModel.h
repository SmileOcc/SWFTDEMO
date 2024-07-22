//
//  ZFCommunityFavesViewModel.h
//  ZZZZZ
//
//  Created by YW on 2017/8/3.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "BaseViewModel.h"

@interface ZFCommunityFavesViewModel : BaseViewModel

- (void)requestFavesListData:(id)parmaters
                      userId:(NSString *)userId
                  completion:(void (^)(id obj, NSDictionary *pageDic))completion
                     failure:(void (^)(id obj))failure;

//点赞
- (void)requestLikeNetwork:(id)parmaters
                completion:(void (^)(id obj))completion
                   failure:(void (^)(id obj))failure;
@end
