//
//  OSSVCategoryRefinesNormalsCCell.h
// XStarlinkProject
//
//  Created by odd on 2020/9/29.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVCategoryRefinesBaseCCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface OSSVCategoryRefinesNormalsCCell : OSSVCategoryRefinesBaseCCell

@property (nonatomic, strong) UILabel    *titleLabel;
@property (nonatomic, strong) UIImageView      *closeImageView;

+ (CGSize)contentSize:(NSString *)title maxWidt:(CGFloat)maxWidth  isSelect:(BOOL)isSelect;

@end

NS_ASSUME_NONNULL_END
