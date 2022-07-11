//
//  STLThemeViewModel.h
// XStarlinkProject
//
//  Created by odd on 2021/4/1.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "BaseViewModel.h"
#import "OSSVThemesSpecialActiviyAip.h"
#import "OSSVThemesActivtyGoodAip.h"
#import "OSSVThemesSpecialsAip.h"
#import "OSSVCustomThemesChannelsGoodsAip.h"

#import "OSSVThemesMainsModel.h"
#import "OSSVHomeCThemeModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface OSSVThemesViewModel : BaseViewModel

@property (nonatomic, weak) UIView                    *contentView;
@property (nonatomic, assign) BOOL                    isShowLoad;

- (void)themeOldRequest:(id)parmaters completion:(void (^)(id result, BOOL isCache, BOOL isEqualData))completion failure:(void (^)(id))failure;

- (void)themeRequest:(id)parmaters completion:(void (^)(id result, BOOL isCache, BOOL isEqualData))completion failure:(void (^)(id))failure;
- (void)themeActivityGoodsRequest:(id)parmaters completion:(void (^)(id result, BOOL isRanking))completion failure:(void (^)(id))failure;

- (void)themeOldActivityGoodsRequest:(id)parmaters completion:(void (^)(id result, BOOL isRanking))completion failure:(void (^)(id))failure;

- (void)themeOldActivityGoodsRequestWithType:(id)parmaters completion:(void (^)(id result, BOOL isRanking, NSInteger ranking_type))completion failure:(void (^)(id))failure;
@end

NS_ASSUME_NONNULL_END
