//
//  YXUICollectionViewFlowLayout.h
//  uSmartOversea
//
//  Created by ellison on 2018/11/28.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YXUICollectionViewFlowLayout : UICollectionViewFlowLayout

@property (nonatomic, assign) NSUInteger itemCountPerRow;
@property (nonatomic, assign) NSUInteger rowCount;

@end

NS_ASSUME_NONNULL_END
