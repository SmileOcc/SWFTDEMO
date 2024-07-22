//
//  ZFCollectionLayoutProtocol.h
//  ZZZZZ
//
//  Created by YW on 2019/7/8.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ZFCollectionCellDatasourceProtocol.h"

@protocol ZFCollectionLayoutProtocol <NSObject>

///返回一个自定义Cell尺寸
+ (CGSize)itemSize:(NSInteger)sectionRows protocol:(id<ZFCollectionCellDatasourceProtocol>)protocol;

@end

