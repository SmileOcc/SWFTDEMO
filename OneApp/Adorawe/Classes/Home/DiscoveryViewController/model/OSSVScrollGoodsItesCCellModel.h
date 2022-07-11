//
//  OSSVScrollGoodsItesCCellModel.h
// XStarlinkProject
//
//  Created by odd on 2021/3/23.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CollectionCellModelProtocol.h"
#import "OSSVHomeGoodsListModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface OSSVScrollGoodsItesCCellModel : NSObject
<
    CollectionCellModelProtocol
>

@property (nonatomic, assign) CGSize size;

@property (nonatomic, assign) CGSize subItemSize;
@end

NS_ASSUME_NONNULL_END
