//
//  OSSVFlashSaleViewModel.h
// XStarlinkProject
//
//  Created by Kevin on 2020/11/5.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "BaseViewModel.h"


@interface OSSVFlashSaleViewModel : BaseViewModel

- (void)requestFlashSaleChannelWithParmater:(NSString *)channelId completion:(void (^)(id))completion failure:(void (^)(id))failure;

- (void)requestFlashGoodsWithParmater:(NSString *)activeId page:(NSInteger )page pageSize:(NSInteger )pageSize completion:(void (^)(id))completion failure:(void (^)(id))failure;

-(void)followSwitch:(NSInteger)followId success:(void(^)(void))success;
@end

