//
//  OSSVCountryeViewModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/8.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "BaseViewModel.h"

@class CountryModel;
typedef void(^selectCountrySuccess)(CountryModel *model);

@interface OSSVCountryeViewModel : BaseViewModel<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, weak) UIViewController        *controller;
@property (nonatomic, copy) selectCountrySuccess    countrySelect;
@property (nonatomic, strong) NSString              *countryName;

- (void)initDataSources;
@end
