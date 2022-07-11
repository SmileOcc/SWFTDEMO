//
//  YXAppDelegateVersionTool.m
//  YouXinZhengQuan
//
//  Created by 陈明茂 on 2021/9/26.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import "YXAppDelegateVersionTool.h"

@implementation YXAppDelegateVersionTool

+ (void)configTableView {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 150000
    if (@available(iOS 15.0, *)) {
        [UITableView appearance].sectionHeaderTopPadding = 0;
        // 先禁用tbelview ios 15的新特性 解决一些奇怪问题
        [UITableView appearance].prefetchingEnabled = NO;
    }
#endif
}

@end
