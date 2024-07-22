//
//  CategoryPriceListModel.h
//  ListPageViewController
//
//  Created by YW on 6/7/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CategoryPriceListModel : NSObject

@property (nonatomic, assign) CGFloat   price_max;

@property (nonatomic, assign) CGFloat   price_min;

@property (nonatomic, copy) NSString   *price_range;

@end
