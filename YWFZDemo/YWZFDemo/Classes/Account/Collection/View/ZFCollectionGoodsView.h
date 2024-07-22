//
//  ZFCollectionGoodsView.h
//  ZZZZZ
//
//  Created by YW on 2019/6/11.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ZFCollectionListModel.h"
#import "ZFCollectionViewModel.h"

@protocol ZFCollectionGoodsViewDelegate <NSObject>

///下拉刷新数据,应用场景为，本来数据为空时下拉刷新数据
- (BOOL)ZFCollectionGoodsViewRefreshData:(ZFCollectionListModel *)listModel;

@end

@interface ZFCollectionGoodsView : UIView

@property (nonatomic, weak) UIViewController *controller;
@property (nonatomic, strong) ZFCollectionListModel *listModel;
@property (nonatomic, weak) id<ZFCollectionGoodsViewDelegate>delegate;

- (void)refreshRequest:(BOOL)isFirstPage;

@end

