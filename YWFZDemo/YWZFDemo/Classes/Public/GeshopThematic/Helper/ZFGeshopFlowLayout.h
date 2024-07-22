//
//  ZFGeshopFlowLayout.h
//  ZZZZZ
//
//  Created by YW on 2019/12/18.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZFGeshopFlowLayout : UICollectionViewFlowLayout

/// 吸顶是否生效 (默认生效)
@property (nonatomic, assign) BOOL enableStickyLayout;

/// 需要吸顶的Cell类名
@property (nonatomic, strong) NSArray *stickyCellClassArray;

@end

NS_ASSUME_NONNULL_END
