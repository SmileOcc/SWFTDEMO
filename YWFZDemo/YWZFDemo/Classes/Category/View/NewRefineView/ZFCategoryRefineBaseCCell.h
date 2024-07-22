//
//  ZFCategoryRefineBaseCCell.h
//  ZZZZZ
//
//  Created by YW on 2019/11/4.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Masonry.h"
#import "Constants.h"
#import "ZFThemeManager.h"
#import "NSString+Extended.h"
#import "YWCFunctionTool.h"

typedef NS_ENUM(NSInteger,CategoryRefineCellType) {
    CategoryRefineCellTypeNormal,
    CategoryRefineCellTypeSpecial,
    CategoryRefineCellTypeColor,
    CategoryRefineCellTypePrice,
};

@interface ZFCategoryRefineBaseCCell : UICollectionViewCell

@property (nonatomic, strong) UIView    *mainView;

- (void)hightLightState:(BOOL)isHight;

@end

