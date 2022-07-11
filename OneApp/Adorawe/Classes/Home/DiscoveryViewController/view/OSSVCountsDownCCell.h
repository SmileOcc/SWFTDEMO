//
//  OSSVCountsDownCCell.h
// OSSVCountsDownCCell
//
//  Created by 10010 on 20/7/5.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//  倒计时cell

#import <UIKit/UIKit.h>
#import "OSSVCollectCCellProtocol.h"
#import "OSSVTimeDownCCellModel.h"

@interface OSSVCountsDownCCell : UICollectionViewCell
<
    OSSVCollectCCellProtocol
>

@property (nonatomic, strong) OSSVTimeDownCCellModel *model;

@end
