//
//  OSSVRecommendSectionModule.h
// XStarlinkProject
//
//  Created by odd on 2021/4/13.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSSVCollectionSectionProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface OSSVRecommendSectionModule : NSObject
<
    OSSVCollectionSectionProtocol
>

@property (nonatomic, assign) BOOL isTopSpace;

///无数据时空白高度
@property (nonatomic,assign) CGFloat contentHeight;
@end

NS_ASSUME_NONNULL_END
