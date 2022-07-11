//
//  OSSVCategoryRefinesPriceCCell.h
// XStarlinkProject
//
//  Created by odd on 2021/4/16.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVCategoryRefinesBaseCCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface OSSVCategoryRefinesPriceCCell : OSSVCategoryRefinesBaseCCell

@property (nonatomic, strong) UILabel       *minLabel;
@property (nonatomic, strong) UITextField   *minTextField;
@property (nonatomic, strong) UIView        *minLineView;
@property (nonatomic, strong) UILabel       *maxLabel;
@property (nonatomic, strong) UITextField   *maxTextField;
@property (nonatomic, strong) UIView        *maxLineView;

@property (nonatomic, copy) void (^editBlock)(NSString *minString, NSString *maxString);

- (void)refinePriceMin:(NSString *)min max:(NSString *)max;

@end

NS_ASSUME_NONNULL_END
