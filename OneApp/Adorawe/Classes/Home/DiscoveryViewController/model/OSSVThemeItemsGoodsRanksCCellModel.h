//
//  OSSVThemeItemsGoodsRanksCCellModel.h
// XStarlinkProject
//
//  Created by odd on 2021/4/1.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CollectionCellModelProtocol.h"
#import "OSSVHomeGoodsListModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface OSSVThemeItemsGoodsRanksCCellModel : NSObject
<
    CollectionCellModelProtocol
>

@property (nonatomic, assign) CGSize size;
@end

NS_ASSUME_NONNULL_END
