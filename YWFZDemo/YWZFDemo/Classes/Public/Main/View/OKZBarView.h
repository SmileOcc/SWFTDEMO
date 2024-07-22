//
//  OKZBarView.h
//  AFNetworking
//
//  Created by Mac on 2017/8/26.
//

#import <UIKit/UIKit.h>

#define kCustomViewTag              2017

@interface OKZBarView : UIView

@property (nonatomic,strong) UIImage *lineImage UI_APPEARANCE_SELECTOR;    // 扫描线  
@property (nonatomic,strong) UIImage *scanRectangleImage UI_APPEARANCE_SELECTOR;          // 扫描框图片

/**
 *  打开二维码视图
 */
+ (instancetype)openZbarView:(UIViewController *)viewcomtroller
                   startScan:(BOOL)startScan
                      height:(CGFloat)height
             completionBlock:(void(^)(BOOL ret, NSString *scanCodeType, NSString *result))completionBlock;

/**
 *  添加扫描顶部和底部提示文字
 */
- (void)addScanTopTipText:(NSString *)topText
            bottomTipText:(NSString *)bottomText
               startRectY:(CGFloat)startY;

/**
 * 设置底部提示信息
 */
- (void)refreshBottomText:(NSString *)text
                     font:(UIFont *)font
                    image:(UIImage *)image
               clickBlock:(void(^)(void))clickBlock;

/**
 *  开启扫描
 */
- (void)startScane;

/**
 * 开始扫描延迟返回扫描结果 -->(产品要求:扫码太块需要延迟)
 */
- (void)startScaneDelayPatchResult:(NSTimeInterval)delay;

/**
 *  停止扫描
 */
- (void)stopScane;

/**
 *  移除所有扫描视图
 */
- (void)removeAllScanView;

/**
 控制闪光灯
 
 @param show 是否开打闪光灯
 */
- (void)showFlash:(BOOL)show;

/**
 * 获取相机没有开启权限的提示语
 */
- (NSString *)getOpenScanErrortipString;

@end
