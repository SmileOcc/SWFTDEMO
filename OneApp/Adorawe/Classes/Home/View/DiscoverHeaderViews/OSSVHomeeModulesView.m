//
//  ModuleView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/12.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVHomeeModulesView.h"


NSString *const kModulePlaceholderDefalutImageString = @"placeholder_pdf";
NSString *const kMouulePlaceholderMoreButtonImageString = @"title_placeholder_pdf";

@implementation OSSVHomeeModulesView

/**
    此处本来想写分类的，暂时先这样，对应这个特殊的场景
 */
- (void)assginToImageDataWithButton:(UIButton *)button urlString:(NSString *)urlString size: (CGSize)size placeholderString:(NSString *)imageString {
    
    button.clipsToBounds = YES;
    
    [button yy_setBackgroundImageWithURL:[NSURL URLWithString:urlString]
                                forState:UIControlStateNormal
                             placeholder:[UIImage imageNamed:imageString]
                                 options:YYWebImageOptionShowNetworkActivity
                                 manager:nil
                                progress:nil
                               transform:^UIImage * _Nullable(UIImage * _Nonnull image, NSURL * _Nonnull url) {
                                            image = [image yy_imageByResizeToSize:size contentMode:UIViewContentModeScaleAspectFill];
                                            return image;
                                        }
                              completion:nil];
}


@end
