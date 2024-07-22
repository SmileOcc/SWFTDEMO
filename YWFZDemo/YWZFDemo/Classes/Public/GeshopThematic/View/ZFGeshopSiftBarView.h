//
//  ZFGeshopSiftBarView.h
//  ZZZZZ
//
//  Created by YW on 2019/11/1.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFGeshopSiftPopListView.h"

@interface ZFGeshopSiftBarView : UIView

/** Section所对应的Item cell对应的Block */
@property (nonatomic, copy) void (^itemButtonActionBlock)(NSInteger dataType, BOOL openList);

- (void)refreshCategoryTitle:(NSString *)categoryTitle sortTitle:(NSString *)sortTitle;

@end
