//
//  OSSVThemeZeroActivyTwoCCellModel.h
// OSSVThemeZeroActivyTwoCCellModel
//
//  Created by Starlinke on 2021/7/12.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CollectionCellModelProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface OSSVThemeZeroActivyTwoCCellModel : NSObject
<
CollectionCellModelProtocol
>

@property (nonatomic, assign) NSInteger cart_exits;// 0元商品是否已经加购过

@property (nonatomic, assign) CGSize size;

@property (nonatomic, assign) NSInteger type;
@end

NS_ASSUME_NONNULL_END
