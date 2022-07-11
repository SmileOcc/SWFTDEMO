//
//  ModifyAddressRequest.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/6.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVBasesRequests.h"

@class OSSVAddresseBookeModel;
@interface OSSVModifyeAddresseAip : OSSVBasesRequests

- (instancetype)initEditAddressRequestWithModel : (OSSVAddresseBookeModel *)model;

@end
