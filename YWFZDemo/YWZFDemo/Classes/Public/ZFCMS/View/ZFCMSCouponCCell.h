//
//  ZFCMSCouponCCell.h
//  ZZZZZ
//
//  Created by YW on 2019/10/30.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFCMSSectionModel.h"
#import "ZFCMSCouponItemView.h"

@interface ZFCMSCouponCCell : UICollectionViewCell


+ (ZFCMSCouponCCell *)reusableCouponModuleCell:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath;

- (void)updateItem:(NSArray <ZFCMSItemModel *> *)itemModels sctionModel:(ZFCMSSectionModel *)sectionModel;

@property (nonatomic, strong) NSArray <ZFCMSItemModel *> *itemModelArrays;

@property (nonatomic, copy) void (^selectBlock)(ZFCMSItemModel *itemModel);

@end

@interface ZFCMSCouponOneCCell : ZFCMSCouponCCell

@end

@interface ZFCMSCouponTwoCCell : ZFCMSCouponCCell

@end


@interface ZFCMSCouponThreeCCell : ZFCMSCouponCCell

@end

@interface ZFCMSCouponFourCCell : ZFCMSCouponCCell

@end
