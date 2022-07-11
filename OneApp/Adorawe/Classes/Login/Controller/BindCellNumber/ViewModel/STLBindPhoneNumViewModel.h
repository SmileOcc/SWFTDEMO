//
//  STLBindPhoneNumViewModel.h
// XStarlinkProject
//
//  Created by fan wang on 2021/5/18.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseViewModel.h"
#import "STLBindCountryModel.h"
#import "STLBindCountryResultModel.h"
#import "STLBIndCountryGroup.h"

NS_ASSUME_NONNULL_BEGIN

@interface STLBindPhoneNumViewModel : BaseViewModel
@property (nonatomic,weak) UIViewController *controller;

-(void)requestInfo:(void (^)(id obj, NSString *msg))completion failure:(void (^)(_Nullable id obj, NSString *msg))failure;
-(void)sendPhoneNum:(id)parms completion:(void (^)(id obj, NSString *msg))completion failure:(void (^)(id obj, NSString *msg))failure;
-(void)checkPhoneNum:(id)parmaters completion:(void (^)(id obj, NSString *msg))completion failure:(void (^)( id obj, NSString *msg))failure;

@property (strong,nonatomic) STLBindCountryResultModel* countryModel;
@property (strong,nonatomic) NSArray<STLBIndCountryGroup *> *keyArr;
@end

NS_ASSUME_NONNULL_END
