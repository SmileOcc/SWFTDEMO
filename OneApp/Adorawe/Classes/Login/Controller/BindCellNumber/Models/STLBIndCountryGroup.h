//
//  STLBIndCountryGroup.h
// XStarlinkProject
//
//  Created by fan wang on 2021/5/18.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STLBindCountryModel.h"


NS_ASSUME_NONNULL_BEGIN

@interface STLBIndCountryGroup : NSObject
@property (copy,nonatomic) NSString *key;
@property (strong,nonatomic) NSArray<STLBindCountryModel *> *countries;
@end

NS_ASSUME_NONNULL_END
