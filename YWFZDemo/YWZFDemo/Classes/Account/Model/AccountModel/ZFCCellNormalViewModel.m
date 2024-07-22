//
//  ZFCCellNormalViewModel.m
//  ZZZZZ
//
//  Created by YW on 2019/7/9.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCCellNormalViewModel.h"

@implementation ZFCCellNormalViewModel
@synthesize registerClass = _registerClass;

- (NSString *)CollectionDatasourceCell:(NSIndexPath *)indexPath identifier:(id)identifier
{
    return NSStringFromClass([self registerClass]);
}

- (Class)registerClass
{
    if (!_registerClass) {
        return [UICollectionViewCell class];
    }
    return _registerClass;
}

@end
