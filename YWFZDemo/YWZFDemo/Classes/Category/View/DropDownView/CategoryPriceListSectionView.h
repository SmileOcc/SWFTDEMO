//
//  CategoryPriceListSectionView.h
//  ZZZZZ
//
//  Created by YW on 13/7/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CategoryPriceListSectionViewTouchHandler)(NSString *selectTitle ,BOOL isSelect);

@interface CategoryPriceListSectionView : UITableViewHeaderFooterView

@property (nonatomic, copy)   NSString   *priceRange;

@property (nonatomic, assign) BOOL       isSelect;

@property (nonatomic, copy) CategoryPriceListSectionViewTouchHandler   categoryPriceListSectionViewTouchHandler;

+ (NSString *)setIdentifier;

@end
