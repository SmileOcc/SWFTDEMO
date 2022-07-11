//
//  OSSVAddresseAddeAip.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/7.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVBasesRequests.h"

@class OSSVAddresseBookeModel;

@interface OSSVAddresseAddeAip : OSSVBasesRequests
- (instancetype)initAddressAddRequestWithModel : (OSSVAddresseBookeModel *)model;
@end
