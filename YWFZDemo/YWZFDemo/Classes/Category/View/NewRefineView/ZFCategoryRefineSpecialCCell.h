//
//  ZFCategoryRefineSpecialCCell.h
//  ZZZZZ
//
//  Created by YW on 2019/11/4.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCategoryRefineBaseCCell.h"


@interface ZFCategoryRefineSpecialCCell : ZFCategoryRefineBaseCCell

@property (nonatomic, strong) UILabel    *titleLabel;

+ (CGSize)contentSize:(NSString *)title maxWidt:(CGFloat)maxWidth;
@end

