//
//  CountryListModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/8.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CountryModel;
@interface CountryListModel : NSObject
@property (nonatomic,copy) NSString *key;
@property (nonatomic,strong) NSArray<CountryModel *> *countryList;
@end
