//
//  OSSVThemeItemGoodsRanksModuleModel.h
// XStarlinkProject
//
//  Created by odd on 2021/4/1.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CollectionCellModelProtocol.h"
#import "OSSVHomeGoodsListModel.h"
#import "OSSVThemeGoodsItesRankModuleCCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface OSSVThemeItemGoodsRanksModuleModel : NSObject
<
    CollectionCellModelProtocol
>

@property (nonatomic, assign) CGSize size;

@property (nonatomic, assign) CGSize subItemSize;
@end

NS_ASSUME_NONNULL_END
