//
//  OSSVRecomendGoodViewModel.h
// XStarlinkProject
//
//  Created by odd on 2020/8/10.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "BaseViewModel.h"
#import "OSSVHomeGoodsListModel.h"

@interface OSSVRecomendGoodViewModel : BaseViewModel

@property (nonatomic, strong) NSMutableArray<OSSVHomeGoodsListModel*>    *dataArrays;

- (void)recommendRequest:(id)parmaters completion:(void (^)(id,NSString*))completion failure:(void (^)(id))failure;

@end

