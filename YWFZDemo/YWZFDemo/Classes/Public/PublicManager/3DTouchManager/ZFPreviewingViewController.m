//
//  ZFPreviewingViewController.m
//  ZZZZZ
//
//  Created by YW on 2018/4/11.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFPreviewingViewController.h"
#import <YYWebImage/UIImageView+YYWebImage.h>
#import "YWCFunctionTool.h"

@interface ZFPreviewingViewController ()

@end

@implementation ZFPreviewingViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}

/**
 * 显示预览视图
 */
- (UIImageView *)imageView
{
    if(!_imageView){
        CGSize size = self.preferredContentSize;
        if (CGSizeEqualToSize(size, CGSizeZero)) {
            size = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height);
        }
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.clipsToBounds = YES;
        _imageView.image = ZFImageWithName(@"loading_product");
        [self.view addSubview:_imageView];
    }
    return _imageView;
}

- (void)setPreviewingImageOrUrl:(id)previewingImageOrUrl {
    _previewingImageOrUrl = previewingImageOrUrl;
    
    //设置预览图片
    if ([previewingImageOrUrl isKindOfClass:[UIImage class]]) {
        self.imageView.image = previewingImageOrUrl;
        
    } else if ([previewingImageOrUrl isKindOfClass:[NSString class]]) {
        //先获取小图地址
        UIImage *cellSmallPicImg = [UIImage imageNamed:@"loading_product"];
        if (self.placeholderImg) {
            cellSmallPicImg = self.placeholderImg;
        }
        [self.imageView  yy_setImageWithURL:[NSURL URLWithString:previewingImageOrUrl]
                               placeholder:cellSmallPicImg
                                    options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                                   progress:nil
                                  transform:nil
                                 completion:nil];
    }
}

/** 必须: 重写弹框菜单方法 */
-(NSArray<id<UIPreviewActionItem>> *)previewActionItems {
    self.imageView.center = self.view.center;
    return self.actions;
}

@end
