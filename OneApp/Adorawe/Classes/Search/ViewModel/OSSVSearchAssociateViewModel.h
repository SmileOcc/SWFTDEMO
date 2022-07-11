//
//  OSSVSearchAssociateViewModel.h
// XStarlinkProject
//
//  Created by odd on 2020/10/12.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "BaseViewModel.h"
#import "OSSVSearchAssociateModel.h"


@interface OSSVSearchAssociateViewModel : BaseViewModel

- (void)associateRequest:(id)parmaters completion:(void (^)(id))completion failure:(void (^)(id))failure;

@end
