//
//  ZFCategoryRefineColorCCell.h
//  ZZZZZ
//
//  Created by YW on 2019/11/4.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCategoryRefineBaseCCell.h"


@interface ZFCategoryRefineColorCCell : ZFCategoryRefineBaseCCell

@property (nonatomic, strong) UIView    *colorView;
@property (nonatomic, strong) UILabel   *colorTitleLabel;

+ (CGSize)contentSize:(NSString *)title maxWidt:(CGFloat)maxWidth;

@end

