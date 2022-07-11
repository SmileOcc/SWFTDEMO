//
//  OSSVFlasttSaleCellModel.h
// XStarlinkProject
//
//  Created by Kevin--Xue on 2020/11/1.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CollectionCellModelProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface OSSVFlasttSaleCellModel : NSObject <CollectionCellModelProtocol>
@property (nonatomic, assign) CGSize size;
//@property (nonatomic, copy)   NSString *channelId; //频道ID 用于闪购商品埋点
@end

NS_ASSUME_NONNULL_END
