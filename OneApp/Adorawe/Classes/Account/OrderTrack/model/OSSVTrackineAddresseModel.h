//
//  OSSVTrackineAddresseModel.h
// XStarlinkProject
//
//  Created by Kevin on 2020/11/13.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OSSVTrackineAddresseModel : NSObject
@property (nonatomic, copy) NSString *district;
@property (nonatomic, copy) NSString *country;
@property (nonatomic, copy) NSString *street;
@property (nonatomic, copy) NSString *province;
@property (nonatomic, copy) NSString *street_more;
@property (nonatomic, copy) NSString *city;

@end

NS_ASSUME_NONNULL_END
