//
//  YXUICollectionViewFlowLayout.m
//  uSmartOversea
//
//  Created by ellison on 2018/11/28.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import "YXUICollectionViewFlowLayout.h"

@interface YXUICollectionViewFlowLayout ()

@property (nonatomic, strong) NSMutableArray *allAttributes;

@end

@implementation YXUICollectionViewFlowLayout

- (NSMutableArray *)allAttributes {
    if (_allAttributes == nil) {
        _allAttributes = [[NSMutableArray alloc] init];
    }
    return _allAttributes;
}

- (void)prepareLayout {
    [super prepareLayout];
    NSUInteger count = [self.collectionView numberOfItemsInSection:0];
    for (int i = 0; i < count; i ++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
        [self.allAttributes addObject:attributes];
    }
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger item = indexPath.item;
    NSInteger page = item / (self.itemCountPerRow * self.rowCount);
    NSInteger x = item % self.itemCountPerRow + page * self.itemCountPerRow;
    NSInteger y = item / self.itemCountPerRow - page * self.rowCount;
    item = x * self.rowCount + y;
    
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:item inSection:0];
    UICollectionViewLayoutAttributes *newAttr = [super layoutAttributesForItemAtIndexPath:newIndexPath];
    newAttr.indexPath = indexPath;
    return newAttr;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *attributesArray = [super layoutAttributesForElementsInRect:rect];
    NSMutableArray *tmp = [[NSMutableArray alloc] init];
    for (UICollectionViewLayoutAttributes *attr in attributesArray) {
        for (UICollectionViewLayoutAttributes *attr2 in self.allAttributes) {
            if (attr.indexPath.item == attr2.indexPath.item) {
                [tmp addObject:attr2];
                break;
            }
        }
    }
    return tmp;
}


//fileprivate func targetPosition(item: Int, x: inout Int, y: inout Int) {
//    let page = item / (self.itemCountPerRow * self.rowCount)
//
//    x = item % self.itemCountPerRow + page * self.itemCountPerRow
//    y = item / self.itemCountPerRow - page * self.rowCount
//
//}

@end
