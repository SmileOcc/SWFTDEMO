//
//  ZFEmptyCCell.h
//  ZZZZZ
//
//  Created by YW on 2019/6/13.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFEmptyView.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFEmptyCCell : UICollectionViewCell

@property (nonatomic, strong) ZFEmptyView *emptyView;

@property (nonatomic, copy) NSString      *msg;
@property (nonatomic, strong) UIImage     *msgImage;
@end

NS_ASSUME_NONNULL_END
