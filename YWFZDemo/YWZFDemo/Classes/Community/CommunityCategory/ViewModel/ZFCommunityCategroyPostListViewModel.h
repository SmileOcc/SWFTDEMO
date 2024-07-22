//
//  ZFCommunityCategroyPostListViewModel.h
//  ZZZZZ
//
//  Created by YW on 2018/8/15.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "BaseViewModel.h"
#import "ZFCommunityCategoryPostItemModel.h"

/** 社区帖子分类*/
@interface ZFCommunityCategroyPostListViewModel : BaseViewModel

-(void)requestCategroyWaterItemListData:(BOOL)firstPage catID:(NSString *)catID completion:(void (^)(NSArray *currentPageDataArr, NSDictionary *pageInfo))completion;

@end
