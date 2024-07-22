//
//  ZFWishListVerticalStyleView.h
//  ZZZZZ
//
//  Created by YW on 2019/7/22.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//  心愿单

#import <UIKit/UIKit.h>
#import "ZFCollectionListModel.h"
#import "ZFCollectionViewModel.h"

@protocol ZFWishListVerticalStyleViewDelegate <NSObject>

- (void)ZFWishListVerticalStyleViewAddCartCompetion;

- (void)ZFWishListVerticalStyleViewNoData;

@end

@interface ZFWishListVerticalStyleView : UITableView

@property (nonatomic, strong) ZFCollectionListModel *listModel;
@property (nonatomic, weak) id<ZFWishListVerticalStyleViewDelegate>styleViewdelegate;

- (void)refreshRequest:(BOOL)isFirstPage;

@end


