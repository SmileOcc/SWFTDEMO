//
//  ZFCommunityShowAlbumVC.h
//  ZZZZZ
//
//  Created by YW on 2019/10/9.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFBaseViewController.h"
#import "ZFCommunityShowPostTransitionDelegate.h"
#import <Photos/Photos.h>
#import "PYCamera.h"
#import "PYAblum.h"

@interface ZFCommunityShowAlbumVC : ZFBaseViewController

@property (nonatomic, strong) ZFCommunityShowPostTransitionDelegate *transitionDelegate;

@property (nonatomic, copy) void (^confirmAlbumsBlock)(NSMutableArray <PYAssetModel *> *selectAssetModelArray);

- (void)showParentController:(UIViewController *)parentViewController topGapHeight:(CGFloat)topGapHeight;

@end

