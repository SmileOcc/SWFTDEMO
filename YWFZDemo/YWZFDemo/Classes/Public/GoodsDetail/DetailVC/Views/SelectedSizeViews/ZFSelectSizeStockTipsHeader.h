//
//  ZFSelectSizeStockTipsHeader.h
//  ZZZZZ
//
//  Created by YW on 2019/7/16.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kStockTipsWidth   (KScreenWidth - (16 * 2 + 14 + 8 ))
#define kStockTipsTopSetY (10)

@interface ZFSelectSizeStockTipsHeader : UICollectionReusableView

// V4.8.0增加显示库存提示
@property (nonatomic, copy) NSString *stockTipsInfo;

@end
