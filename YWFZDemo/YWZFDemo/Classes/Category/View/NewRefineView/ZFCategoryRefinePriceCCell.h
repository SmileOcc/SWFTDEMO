//
//  ZFCategoryRefinePriceCCell.h
//  ZZZZZ
//
//  Created by YW on 2019/11/4.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCategoryRefineBaseCCell.h"


@interface ZFCategoryRefinePriceCCell : ZFCategoryRefineBaseCCell


@property (nonatomic, strong) UIView      *lineView;

@property (nonatomic, strong) UITextField *minPriceTextField;
@property (nonatomic, strong) UITextField *maxPriceTextField;

@property (nonatomic, copy) NSString *min;
@property (nonatomic, copy) NSString *max;

@property (nonatomic, copy) void (^editBlock)(NSString *minString, NSString *maxString);


- (void)refinePriceMin:(NSString *)min max:(NSString *)max;

- (void)updatePlaceholder:(NSString *)min max:(NSString *)max;

+ (CGSize)contentSize:(NSString *)title maxWidt:(CGFloat)maxWidth;

@end

