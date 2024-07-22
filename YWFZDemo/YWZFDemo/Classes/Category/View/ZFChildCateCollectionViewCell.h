//
//  ZFChildCateCollectionViewCell.h
//  ZZZZZ
//
//  Created by YW on 2018/11/21.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFCategoryParentModel.h"

@interface ZFChildCateCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) ZFCategoryTabContainer *tabContainer;

- (void)configWithImageUrl:(NSString *)url cateName:(NSString *)cateName;

@end
