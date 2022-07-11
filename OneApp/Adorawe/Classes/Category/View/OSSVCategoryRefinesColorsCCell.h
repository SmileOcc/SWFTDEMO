//
//  OSSVCategoryRefinesColorsCCell.h
// XStarlinkProject
//
//  Created by odd on 2020/9/29.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVCategoryRefinesBaseCCell.h"

@class STLColorView;
@interface OSSVCategoryRefinesColorsCCell : OSSVCategoryRefinesBaseCCell

@property (nonatomic, strong) STLColorView     *colorView;
@property (nonatomic, strong) UILabel          *colorTitleLabel;
@property (nonatomic, strong) UIImageView      *closeImageView;

+ (CGSize)contentSize:(NSString *)title maxWidt:(CGFloat)maxWidth isSelect:(BOOL)isSelect;

@end


@interface STLColorView : UIView

@end
