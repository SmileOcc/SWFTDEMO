//
//  UIImage+Compress.h
//  uSmartOversea
//
//  Created by JC_Mac on 2018/10/31.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Compress)

//图片压缩到指定尺寸
- (NSData *)compressQualityWithMaxLength:(NSInteger)maxLength;
- (UIImage *)compressImageQualityWithMaxLength:(NSInteger)maxLength;

- (NSData *)compressQualityLessMaxLength:(NSInteger)maxLength;

@end

NS_ASSUME_NONNULL_END
