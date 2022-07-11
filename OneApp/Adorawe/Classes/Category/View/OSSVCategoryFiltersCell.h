//
//  OSSVCategoryFiltersCell.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/17.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OSSVCategoryFiltersCell : UITableViewCell

@property (nonatomic, assign) BOOL isSelected;

- (void)configWithTitle:(NSString *)title;

@end
