//
//  ZFGeshopFlowLayout.m
//  ZZZZZ
//
//  Created by YW on 2019/12/18.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFGeshopFlowLayout.h"

@interface ZFGeshopFlowLayout ()
@property (nonatomic, strong) NSMutableSet *stickyAttributeSet;
@end

@implementation ZFGeshopFlowLayout

- (instancetype)init {
    self = [super init];
    if (self) {
        self.stickyAttributeSet = [[NSMutableSet alloc] init];
    }
    return self;
}

/*
 * 作用:返回指定区域的cell布局对象
 */
- (NSArray *) layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *superArray = [[super layoutAttributesForElementsInRect:rect] mutableCopy];
    
    if (!self.enableStickyLayout) {
        [self.stickyAttributeSet removeAllObjects];
        return [superArray copy];
    }
    
    for (UICollectionViewLayoutAttributes *myAttributes in self.stickyAttributeSet) {
        if (![superArray containsObject:myAttributes]) {
            [superArray addObject:myAttributes];
        }
    }
    for (UICollectionViewLayoutAttributes *attributes in superArray) {
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:attributes.indexPath];
        
        //如果当前item是需要悬浮的类型;
        if ([self.stickyCellClassArray containsObject:[cell class]]) {
          // UICollectionViewLayoutAttributes *lastMyAttributes = self.myAttributeSet.allObjects.firstObject;
            [self.stickyAttributeSet removeObject:attributes];
            [self.stickyAttributeSet addObject:attributes];
            
            // 找到需要悬浮的前一个Cell的最大Y位置
            NSIndexPath *beforePath = nil;
            
            NSInteger sectionCount = attributes.indexPath.section;
            NSInteger currentItem = attributes.indexPath.item;
            if (currentItem > 0) {
                beforePath = [NSIndexPath indexPathForRow:currentItem-1 inSection:sectionCount];
                
            } else if (sectionCount > 0) {
                sectionCount -= 1;
                NSInteger lastSectionItemCount = [self.collectionView numberOfItemsInSection:sectionCount];
                
                for (NSInteger i=sectionCount; i>=0; i--) {
                    if (lastSectionItemCount > 0) {
                        beforePath = [NSIndexPath indexPathForRow:lastSectionItemCount - 1 inSection:sectionCount];
                        break;
                    } else {
                        sectionCount -= 1;
                        lastSectionItemCount = [self.collectionView numberOfItemsInSection:sectionCount];
                    }
                }
            }
            UICollectionViewLayoutAttributes *beforeAttributes = [self layoutAttributesForItemAtIndexPath:beforePath];

            //获取当前header的frame
            CGFloat offsetY = self.collectionView.contentOffset.y;
            CGFloat beforeAttrMaxY = 0;
            if (beforeAttributes) {
                beforeAttrMaxY = CGRectGetMaxY(beforeAttributes.frame);
            }
            
//            if (attributesRect.origin.y < CGRectGetMaxY(lastMyAttributes.frame)) {
//                CGRect myAttributesRect = lastMyAttributes.frame;
//                myAttributesRect.origin.y -= (CGRectGetMaxY(lastMyAttributes.frame) - attributesRect.origin.y);
//                lastMyAttributes.frame = myAttributesRect;
//                lastMyAttributes.zIndex = 9101;
//            }
//            printf("悬浮CellY位置=== %.2f\n", attributesRect.origin.y);
            
            CGRect tmpRect = attributes.frame;
            tmpRect.origin.y = MAX(offsetY, beforeAttrMaxY);
            attributes.frame = tmpRect;
            attributes.zIndex = 9102;
        }
    }
    //转换回不可变数组，并返回
    return [superArray copy];
}

///return YES;表示一旦滑动就实时调用上面这个layoutAttributesForElementsInRect:方法
- (BOOL) shouldInvalidateLayoutForBoundsChange:(CGRect)newBound {
    return YES;
}


@end
