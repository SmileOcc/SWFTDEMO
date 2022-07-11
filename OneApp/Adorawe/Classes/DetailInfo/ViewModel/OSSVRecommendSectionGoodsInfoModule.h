//
//  OSSVRecommendSectionGoodsInfoModule.h
// XStarlinkProject
//
//  Created by odd on 2021/4/13.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSSVCollectionSectionProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface OSSVRecommendSectionGoodsInfoModule : NSObject
<
    OSSVCollectionSectionProtocol
>

@property (nonatomic, assign) CGSize cellSize;
- (void)updateBottomOffset:(CGFloat)offsetY;
@end

NS_ASSUME_NONNULL_END
