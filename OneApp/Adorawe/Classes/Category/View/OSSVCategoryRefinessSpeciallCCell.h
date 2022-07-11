//
//  OSSVCategoryRefinessSpeciallCCell.h
// XStarlinkProject
//
//  Created by odd on 2020/9/29.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVCategoryRefinesBaseCCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface OSSVCategoryRefinessSpeciallCCell : OSSVCategoryRefinesBaseCCell

@property (nonatomic, strong) UILabel    *titleLabel;

+ (CGSize)contentSize:(NSString *)title maxWidt:(CGFloat)maxWidth;
@end

NS_ASSUME_NONNULL_END
