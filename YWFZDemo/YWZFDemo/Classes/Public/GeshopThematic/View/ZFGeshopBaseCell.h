//
//  ZFGeshopBaseCell.h
//  ZZZZZ
//
//  Created by YW on 2019/12/17.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFGeshopSectionModel.h"

@interface ZFGeshopBaseCell : UICollectionViewCell

@property(nonatomic, strong) NSIndexPath *indexPath;

@property(nonatomic, strong) ZFGeshopSectionModel *sectionModel;

@end
