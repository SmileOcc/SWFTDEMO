//
//  OSSVThemesZeroActivyCellModel.h
// OSSVThemesZeroActivyCellModel
//
//  Created by odd on 2020/9/12.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CollectionCellModelProtocol.h"
#import "OSSVThemeZeroPrGoodsModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface OSSVThemesZeroActivyCellModel : NSObject
<
CollectionCellModelProtocol
>

@property (nonatomic, assign) CGSize size;

@end

NS_ASSUME_NONNULL_END
