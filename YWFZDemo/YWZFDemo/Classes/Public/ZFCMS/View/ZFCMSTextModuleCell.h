//
//  ZFCMSTextModuleCell.h
//  ZZZZZ
//
//  Created by YW on 2018/12/12.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFCMSSectionModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFCMSTextModuleCell : UICollectionViewCell

+ (ZFCMSTextModuleCell *)reusableTextModuleCell:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, strong) ZFCMSSectionModel *sectionModel;

@end

NS_ASSUME_NONNULL_END
