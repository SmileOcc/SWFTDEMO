//
//  ZFCanvasOptionCollectionViewCell.h
//  ZZZZZ
//
//  Created by YW on 2018/5/23.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZFCanvasOptionCollectionViewCell : UICollectionViewCell

- (void)configWithImage:(UIImage *)image isSelected:(BOOL)isSelected;
- (void)configWithURL:(NSString *)imageURL isSelected:(BOOL)isSelected;

@end
