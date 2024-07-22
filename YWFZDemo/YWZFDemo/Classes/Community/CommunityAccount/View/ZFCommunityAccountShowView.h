//
//  ZFCommunityAccountShowView.h
//  ZZZZZ
//
//  Created by YW on 2017/8/1.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFCommuntityGestureTableView.h"

@class ZFCommunityAccountShowsModel;
@protocol ZFCommunityAccountShowViewProtocol;

typedef void(^CommunityAccountShowDetailCompletionHandler)(NSString *userId, NSString *reviewsId);


@interface ZFCommunityAccountShowView : UICollectionViewCell

@property (nonatomic, weak) id<ZFCommunityAccountShowViewProtocol>        delegate;
@property (nonatomic, weak) UIViewController                    *controller;
@property (nonatomic, copy) NSString                            *userId;
@property (nonatomic, strong) ZFCommuntityCollectionView        *collectionView;

@property (nonatomic, copy) CommunityAccountShowDetailCompletionHandler         communityAccountShowDetailCompletionHandler;

@end


@protocol ZFCommunityAccountShowViewProtocol <NSObject>

- (void)zf_accountShowView:(ZFCommunityAccountShowView *)showsView collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)zf_accountShowView:(ZFCommunityAccountShowView *)showsView collectionView:(UICollectionView *)collectionView didSelectItemCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)zf_accountShowView:(ZFCommunityAccountShowView *)showsView requestAccountShowListData:(BOOL)isFirstPage;
@end
