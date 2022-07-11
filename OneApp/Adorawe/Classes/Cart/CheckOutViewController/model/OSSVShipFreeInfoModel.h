//
//  OSSVShipFreeInfoModel.h
// XStarlinkProject
//
//  Created by Kevin on 2021/3/18.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OSSVShipFreeInfoModel : NSObject
@property (nonatomic, copy) NSString *shipFreeTextStr; //COD Cost 固定文案
@property (nonatomic, copy) NSString *shipFreeDiscount; //COD折扣
@property (nonatomic, copy) NSString *shipFreeRedPrice;

@end

NS_ASSUME_NONNULL_END
