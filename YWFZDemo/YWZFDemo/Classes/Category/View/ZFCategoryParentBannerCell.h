//
//  ZFCategoryParentBannerCell.h
//  ZZZZZ
//
//  Created by YW on 2019/3/12.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFCategoryParentModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFCategoryParentBannerCell : UICollectionViewCell

@property (nonatomic, strong) ZFCategoryTabContainer *tabContainer;

- (void)configWithImageUrl:(NSString *)url;

@end

NS_ASSUME_NONNULL_END
