//
//  ZFCategroyWaterfallItemViewModel.h
//  ZZZZZ
//
//  Created by YW on 2018/8/15.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "BaseViewModel.h"
#import "ZFCommunityCategoryPostModel.h"

@interface ZFCommunityCategroyPostViewModel : BaseViewModel

-(void)requestCategroyWaterData:(id)parmaters Completion:(void (^)(ZFCommunityCategoryPostModel *postModel))completion failure:(void (^)(id obj))failure;




@end
