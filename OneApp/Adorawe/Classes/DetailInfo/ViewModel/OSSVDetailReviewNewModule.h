//
//  OSSVDetailReviewNewModule.h
// XStarlinkProject
//
//  Created by odd on 2021/6/29.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSSVCollectionSectionProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface OSSVDetailReviewNewModule : NSObject
<
    OSSVCollectionSectionProtocol
>

@property (nonatomic, assign) CGSize cellSize;

@end

NS_ASSUME_NONNULL_END
