//
//  OSSVCollectCCellProtocol.h
//  TestCollectionView
//
//  Created by 10010 on 20/7/30.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CollectionCellModelProtocol.h"

@protocol CollectionCellDelegate <NSObject>

@end

@protocol OSSVCollectCCellProtocol <NSObject>

@property (nonatomic, strong) id<CollectionCellModelProtocol> model;
@property (nonatomic, weak) id<CollectionCellDelegate>delegate;
@property (nonatomic, copy) NSString    *channelId;

@end
