//
//  SubLevelCell.h
//  ListPageViewController
//
//  Created by YW on 26/6/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CategoryNewModel;

@interface CategorySubLevelCell : UICollectionViewCell

+ (NSString *)setIdentifier;

@property (nonatomic, strong) CategoryNewModel   *model;

@end
