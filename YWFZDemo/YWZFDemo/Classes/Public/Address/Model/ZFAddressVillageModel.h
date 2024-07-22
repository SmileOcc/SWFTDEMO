//
//  ZFAddressVillageModel.h
//  Zaful
//
//  Created by occ on 2019/1/11.
//  Copyright © 2019 Zaful. All rights reserved.
//

#import "ZFAddressBaseModel.h"

// 镇、村
@interface ZFAddressTownModel : ZFAddressBaseModel

@property (nonatomic, copy) NSString *barangay;
@property (nonatomic, copy) NSString *barangay_code;
@property (nonatomic, copy) NSString *barangay_id;
@property (nonatomic, copy) NSString *city_id;

@property (nonatomic, copy) NSString *key;

- (void)handleSelfKey;
@end

