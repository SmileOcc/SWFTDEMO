//
//  ZFCommunityOutfitsListViewModel.h
//  ZZZZZ
//
//  Created by YW on 2018/7/11.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "BaseViewModel.h"
#import "ZFCommunityOutfitsModel.h"

@interface ZFCommunityOutfitsListViewModel : BaseViewModel

- (void)requestOutfitsListData:(BOOL)firstPage
                    completion:(void (^)(NSArray <ZFCommunityOutfitsModel *> *outfitsListArray, NSDictionary *pageInfo))completion;

- (void)requestLikeNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure;

@end
