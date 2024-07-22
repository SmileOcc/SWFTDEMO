
//
//  UITableView+TouchPreviewing.m
//  ZZZZZ
//
//  Created by YW on 2018/4/11.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "UITableView+TouchPreviewing.h"
#import "ZFPreviewingViewController.h"
#import "ZF3DTouchHeader.h"
#import "YWCFunctionTool.h"
#import <objc/runtime.h>
#import "Constants.h"

@implementation UITableView (TouchPreviewing)

#pragma mark - <UIViewControllerPreviewingDelegate>
- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    
    UITableViewCell *touchCell = (UITableViewCell *)[previewingContext sourceView];
    if (!touchCell || ![touchCell isKindOfClass:[UITableViewCell class]]) return nil;
    
    NSIndexPath *indexPath = [self indexPathForCell:touchCell];
    if(!indexPath) return nil;
    
    NSDictionary *cellDataDic = objc_getAssociatedObject(touchCell, k3DTouchPreviewingModelKey);
    if (!cellDataDic || ![cellDataDic isKindOfClass:[NSDictionary class]]) return nil;
    
    //预览控制器
    ZFPreviewingViewController *previewingVC = [[ZFPreviewingViewController alloc] init];
    previewingVC.view.backgroundColor = [UIColor whiteColor];
    //previewingVC.preferredContentSize = CGSizeMake(300, 300);
    previewingVC.previewingImageOrUrl = ZFToString(cellDataDic[@"goods_thumb"]);
    
    NSArray *actions = cellDataDic[@"actions"];
    previewingVC.actions = actions;

    return previewingVC;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    YWLog(@"----用力按钮屏幕进入控制器----");
    UITableViewCell *touchCell = (UITableViewCell *)[previewingContext sourceView];
    if (!touchCell || ![touchCell isKindOfClass:[UITableViewCell class]]) return ;
    
    NSIndexPath *indexPath = [self indexPathForCell:touchCell];
    if (indexPath && self.delegate && [self.delegate respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:)]) {
        [self.delegate tableView:self didSelectRowAtIndexPath:indexPath];
    }
}
@end
