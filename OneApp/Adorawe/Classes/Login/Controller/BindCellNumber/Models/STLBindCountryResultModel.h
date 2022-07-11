//
//  STLBindCountryResponseModel.h
// XStarlinkProject
//
//  Created by fan wang on 2021/5/18.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STLBindCountryModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface STLBindCountryResultModel : NSObject <YYModel>
@property (strong,nonatomic) NSArray<STLBindCountryModel *>* countries;
@property (strong,nonatomic) NSDictionary *messages;
@property (copy,nonatomic) NSString *default_country_id;
@end

NS_ASSUME_NONNULL_END
