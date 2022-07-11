//
//  OSSVThemeCouponCCellModel.h
// XStarlinkProject
//
//  Created by Starlinke on 2021/7/5.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CollectionCellModelProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface OSSVThemeCouponCCellModel : NSObject
<
    CollectionCellModelProtocol
>

@property (nonatomic, assign) CGSize size;

-(NSString *)reuseIdentifier;

+(NSString *)reuseIdentifier;

@end

NS_ASSUME_NONNULL_END
