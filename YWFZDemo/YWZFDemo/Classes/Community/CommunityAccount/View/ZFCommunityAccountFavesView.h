//
//  ZFCommunityFavesListView.h
//  ZZZZZ
//
//  Created by YW on 2017/7/26.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFCommuntityGestureTableView.h"

@class ZFCommunityFavesItemModel;
@protocol ZFCommunityAccountFavesViewProtocol;


typedef void(^CommunityFavesListDetailCompletionHandler)(NSString *userId, NSString *reviewId, NSInteger type);
typedef void(^CommunityFavesAddMoreFriendsCompletionHandler)(void);

@interface ZFCommunityAccountFavesView : UICollectionViewCell

@property (nonatomic, weak) id<ZFCommunityAccountFavesViewProtocol>        delegate;
@property (nonatomic, weak) UIViewController                               *controller;
@property (nonatomic, copy) NSString                                       *userId;
@property (nonatomic, strong) ZFCommuntityCollectionView                   *favesListView;

@property (nonatomic, copy) CommunityFavesListDetailCompletionHandler       communityFavesListDetailCompletionHandler;
@property (nonatomic, copy) CommunityFavesAddMoreFriendsCompletionHandler   communityFavesAddMoreFriendsCompletionHandler;

@end



@protocol ZFCommunityAccountFavesViewProtocol <NSObject>

- (void)zf_accountFavesView:(ZFCommunityAccountFavesView *)favesView collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)zf_accountFavesView:(ZFCommunityAccountFavesView *)favesView collectionView:(UICollectionView *)collectionView didSelectItemCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)zf_accountFavesView:(ZFCommunityAccountFavesView *)favesView requestAccountFavesListData:(BOOL)isFirstPage;

@end
