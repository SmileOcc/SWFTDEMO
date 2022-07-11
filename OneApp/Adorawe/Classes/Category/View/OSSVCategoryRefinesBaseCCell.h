//
//  OSSVCategoryRefinesBaseCCell.h
// XStarlinkProject
//
//  Created by odd on 2020/9/29.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVCategorysFiltersNewModel.h"

typedef NS_ENUM(NSInteger,CategoryRefineCellType) {
    CategoryRefineCellTypeNormal,
    CategoryRefineCellTypeSpecial,
    CategoryRefineCellTypeColor,
    CategoryRefineCellTypePrice,
};

@interface OSSVCategoryRefinesBaseCCell : UICollectionViewCell

@property (nonatomic, strong) UIView    *mainView;

@property (nonatomic, strong) STLCategoryFilterValueModel  *model;


- (void)hightLightState:(BOOL)isHight;

@end

