//
//  CategorySubLevelViewModel.h
//  ListPageViewController
//
//  Created by YW on 26/6/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CategoryNewModel.h"

typedef void(^SubLevelCompletionHandler)(CategoryNewModel *model);

@interface CategorySubLevelViewModel : NSObject<UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>

@property (nonatomic, copy) SubLevelCompletionHandler   handler;

- (void)requestSubLevelDataWithParentID:(NSString *)parentID completion:(void (^)(void))completion;

@end
