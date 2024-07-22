//
//  ZFAddressLibraryViewModel.h
//  Zaful
//
//  Created by occ on 2019/1/14.
//  Copyright © 2019 Zaful. All rights reserved.
//

#import "BaseViewModel.h"


@interface ZFAddressLibraryManager : BaseViewModel

/**
 国家列表数据
 */
@property (nonatomic, strong) NSArray *countryDataArray;

+(instancetype)manager;

+ (void)preparatoryRequestCountryCityData:(BOOL)isNeedHold;

+ (void)startRequestCountryCityData:(void (^)(NSArray *datas))completion;

+ (void)saveLocalCountry:(NSArray *)countryArray;

+ (NSArray *)localCountryList;

@end

