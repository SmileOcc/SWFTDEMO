//
//  OSSVAsinglesAdvCCell.h
// OSSVAsinglesAdvCCell
//
//  Created by 10010 on 20/7/31.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVAsingleCCellModel.h"
#import "OSSVCollectCCellProtocol.h"

//首页banner
@class OSSVAsinglesAdvCCell;

@protocol STLAsingleCCellDelegate<CollectionCellDelegate>

- (void)stl_asingleCCell:(OSSVAsinglesAdvCCell *)cell contentModel:(id)model;

@end

@interface OSSVAsinglesAdvCCell : UICollectionViewCell
<
    OSSVCollectCCellProtocol
>

@property (nonatomic, weak) id<STLAsingleCCellDelegate> delegate;

@property (nonatomic, strong) STLProductImagePlaceholder *goodsImageView;
-(void)setAdvModel:(STLAdvEventSpecialModel *)model;
@end
