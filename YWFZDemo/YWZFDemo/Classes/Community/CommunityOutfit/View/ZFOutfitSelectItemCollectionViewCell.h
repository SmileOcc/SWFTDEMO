//
//  ZFOutfitSelectItemCollectionViewCell.h
//  ZZZZZ
//
//  Created by YW on 2018/5/23.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFInitViewProtocol.h"

@interface ZFOutfitSelectItemCollectionViewCell : UICollectionViewCell <ZFInitViewProtocol>

/**
 配置数据

 @param url 图片URL
 @param isSelected 是否已经被选中
 */
- (void)configDataWithImageURL:(NSString *)url isSelected:(BOOL)isSelected;
- (void)selectedAnimation;

@end
