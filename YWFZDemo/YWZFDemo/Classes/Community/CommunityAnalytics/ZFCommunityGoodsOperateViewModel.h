//
//  ZFCommunityGoodsOperateViewModel.h
//  ZZZZZ
//
//  Created by YW on 2019/5/24.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "BaseViewModel.h"


@interface ZFCommunityGoodsOperateViewModel : BaseViewModel

// 帖子相关商品点击
+ (void)requestGoodsTap:(id)parmaters
             completion:(void (^)(BOOL success))completion;
@end

