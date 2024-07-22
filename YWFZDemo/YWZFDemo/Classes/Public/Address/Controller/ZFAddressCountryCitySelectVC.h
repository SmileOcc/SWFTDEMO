//
//  ZFAddressCountryCitySelectVC.h
//  ZZZZZ
//
//  Created by YW on 2019/1/7.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFBaseViewController.h"
#import <Lottie/Lottie.h>


#import "ZFAddressLibraryCountryModel.h"
#import "ZFAddressLibraryStateModel.h"
#import "ZFAddressLibraryCityModel.h"
#import "ZFAddressLibraryTownModel.h"

@class ZFAddressCountryCitySelectTransitionDelegate;


/** 选择完成结果回调，没有的为 nil */
typedef void(^AddressCountryCitySelectCompletionHandler)(ZFAddressLibraryCountryModel *countryModel, ZFAddressLibraryStateModel *stateModel, ZFAddressLibraryCityModel *cityModel, ZFAddressLibraryTownModel *villageModel);


@interface ZFAddressCountryCitySelectVC : ZFBaseViewController

- (void)showParentController:(UIViewController *)parentViewController topGapHeight:(CGFloat)topGapHeight;

@property (nonatomic, strong) ZFAddressCountryCitySelectTransitionDelegate *transitionDelegate;


//@property (nonatomic, copy) NSString                    *selectCountryName;
//@property (nonatomic, copy) NSString                    *selectStateName;
//@property (nonatomic, copy) NSString                    *selectCityName;
//@property (nonatomic, copy) NSString                    *selectVillageName;

/**订单修改地址标识*/
@property (nonatomic, assign) BOOL                             isOrderUpdate;
@property (nonatomic, strong) ZFAddressLibraryCountryModel     *countryModel;
@property (nonatomic, strong) ZFAddressLibraryStateModel       *stateModel;
@property (nonatomic, strong) ZFAddressLibraryCityModel        *cityModel;
@property (nonatomic, strong) ZFAddressLibraryTownModel        *townModel;

@property (nonatomic, assign) NSInteger                 selectIndex;

@property (nonatomic, copy) AddressCountryCitySelectCompletionHandler       addressCountrySelectCompletionHandler;
//@property (nonatomic, copy) AddressCountryCitySelectRequestDataHandler      addressCountryCitySelectRequestDataHandler;


@end




#pragma mark - 自定义动画拦截器

@interface ZFAddressCountryCitySelectTransitionDelegate : NSObject <UIViewControllerTransitioningDelegate>

@property (nonatomic, assign) CGFloat height;

@end

#pragma mark - 自定义动画实现

@interface ZFAddressCountryCitySelectTransitionBegan : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) CGFloat height;

@end

@interface ZFAddressCountryCitySelectTransitionEnd : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) CGFloat height;

@end
