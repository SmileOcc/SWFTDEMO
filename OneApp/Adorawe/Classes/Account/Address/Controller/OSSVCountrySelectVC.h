//
//  OSSVCountrySelectVC.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/8.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "STLBaseCtrl.h"
@class OSSVCountryeViewModel;
@class CountryModel;


typedef void(^countrySelectBlock)(CountryModel *model);

@interface OSSVCountrySelectVC : STLBaseCtrl

@property (nonatomic, strong) OSSVCountryeViewModel  *viewModel;

@property (nonatomic, copy) countrySelectBlock  countryBlock;

@end
