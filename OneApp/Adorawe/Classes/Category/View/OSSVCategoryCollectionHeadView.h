//
//  OSSVCategoryCollectionHeadView.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/29.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVSecondsCategorysModel.h"

@class OSSVCategoryCollectionHeadView;

@protocol STLCategoryCollectionHeaderViewDelegate <NSObject>

@optional

- (void)categoriesChannelId:(OSSVSecondsCategorysModel *)model cell:(OSSVCategoryCollectionHeadView *)sender;

@end

@interface OSSVCategoryCollectionHeadView : UICollectionReusableView

@property (nonatomic, strong) OSSVSecondsCategorysModel *model;

@property (nonatomic, weak) id <STLCategoryCollectionHeaderViewDelegate> categoriesSeeAllDelegate;
@end
