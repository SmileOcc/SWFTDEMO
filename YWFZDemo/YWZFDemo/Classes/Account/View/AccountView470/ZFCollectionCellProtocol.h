//
//  ZFCollectionCellProtocol.h
//  ZZZZZ
//
//  Created by YW on 2019/6/25.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFCollectionCellDatasourceProtocol.h"

@protocol ZFCollectionCellDelegate <NSObject>

@end

@protocol ZFCollectionCellProtocol <NSObject>

@property (nonatomic, strong) id<ZFCollectionCellDatasourceProtocol>model;
@property (nonatomic, weak) id<ZFCollectionCellDelegate>delegate;

@optional;
///返回一个自定义Cell尺寸
+ (CGSize)itemSize:(NSInteger)sectionRows protocol:(id<ZFCollectionCellDatasourceProtocol>)protocol;

@end
