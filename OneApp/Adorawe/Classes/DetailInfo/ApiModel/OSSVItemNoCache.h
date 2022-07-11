//
//  OSSVItemNoCache.h
// XStarlinkProject
//
//  Created by fan wang on 2021/9/2.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSSVNoCacheFlashSale.h"

NS_ASSUME_NONNULL_BEGIN

@interface OSSVItemNoCache : NSObject<YYModel>
@property (nonatomic,copy) NSString *is_collect;
@property (nonatomic,strong) OSSVNoCacheFlashSale *flash_sale;
@property (nonatomic,copy) NSString *free_goods_exists;
@property (nonatomic,copy) NSString *goods_number;
@end

NS_ASSUME_NONNULL_END
