//
//  UIImage+ZFExtended.h
//  ZZZZZ
//
//  Created by YW on 2018/5/15.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ZFExtended)

/**
 * 缩放图片大小
 */
- (UIImage *)scaleToSize:(float)scaleSize;

/**
 给背景图片打水印
 @param watemarkAttrStr  文字描述
 @param drawRect         水印位置
 @return 水印图片
 */
- (UIImage *)addWatemarkWithAttrStr:(NSAttributedString *)watemarkAttrStr
                         drawInRect:(CGRect)drawRect;

/**
 * 给图片设置颜色
 */
- (UIImage *)imageWithColor:(UIColor *)color;

/**
 根据图片设置图标大小

 @param img 源图片
 @param itemSize 大小
 @return 修改后的图片
 */
+ (UIImage *)zf_drawImage:(UIImage *)img size:(CGSize)itemSize;


/**
 绘制图片成不透明的, 避免像素混合渲染 (耗内存: 注意在子线程使用, 注意不要绘制gif图片)
 关键点: opaque:不透明度, YES:不透明，NO:透明
 
 @return 绘制重新绘制后的图片
 */
- (UIImage *)zf_drawImageToOpaque;

- (UIImage *)zf_imageByResizeToSize:(CGSize)size contentMode:(UIViewContentMode)contentMode;

/*
 *
 *  根据颜色绘制图片
 *
 *  @param color 颜色值
 *
 *  @return 图片
 */
+ (UIImage *)zf_createImageWithColor:(UIColor *)color;

// 将PDF二进制转化为图片
+ (UIImage *)zf_cgUIimage:(NSData *)imageData;

/**
 给视图截屏

 @param view 目标视图
 @return 截图后的图片
 */
+ (UIImage *)zf_shortImageFromView:(UIView *)view;

// 将图片压缩到指定大小
- (UIImage *)zf_scaleImage:(UIImage *)image toScale:(float)scaleSize;
// 压缩图片后二进制
- (NSData *)zf_compressImageWithOriginImage:(UIImage *)originImg;

+(UIImage *)fetchPDFImageWithData:(NSData *)imageData;

#pragma mark - 生成条形码
+ (UIImage *)barcodeImageWithContent:(NSString *)content codeImageSize:(CGSize)size red:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue;

// 高斯模糊图片
+ (UIImage *)zf_blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur;
@end
