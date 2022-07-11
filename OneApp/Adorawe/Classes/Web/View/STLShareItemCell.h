//
//  STLShareItemCell.h
// XStarlinkProject
//
//  Created by Starlinke on 2021/7/15.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface STLShareItemCell : UICollectionViewCell

@property (nonatomic, strong)NSDictionary * dataDic;

+(STLShareItemCell *)stlShareItemCellWithCollection:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
