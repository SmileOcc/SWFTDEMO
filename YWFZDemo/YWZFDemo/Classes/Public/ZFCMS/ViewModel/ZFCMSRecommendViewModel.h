//
//  ZFCMSRecommendViewModel.h
//  ZZZZZ
//
//  Created by YW on 2019/6/13.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "BaseViewModel.h"
#import "ZFGoodsModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFCMSRecommendViewModel : BaseViewModel

/**
 * 请求CMS推荐商品数据
 * recommendType
 * parmaters: 可以是空字典，nil直接失败回调
 */
- (void)requestCmsRecommendData:(BOOL)firstPage
                      parmaters:(NSDictionary *)parmaters
                     completion:(void (^)(NSArray<ZFGoodsModel *> *array, NSDictionary *pageInfo))completion
                        failure:(void (^)(NSError *error))failure;
@end

NS_ASSUME_NONNULL_END
