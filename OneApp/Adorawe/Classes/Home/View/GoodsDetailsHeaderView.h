//
//  GoodsDetailsHeaderView.h
//  Yoshop
//
//  Created by huangxieyue on 16/5/30.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GoodsDetailsListModel;

typedef void (^GoodsSelectedBlock)();
@interface GoodsDetailsHeaderView : UICollectionReusableView
+(GoodsDetailsHeaderView*)goodsDetailsHeaderWithCollectionView:(UICollectionView *)collectionView Kind:(NSString*)kind IndexPath:(NSIndexPath *)indexPath;
@property (nonatomic,weak) UIViewController *controller;
@property (nonatomic,copy) GoodsSelectedBlock goodsSelectedBlock;
@property (nonatomic,strong) GoodsDetailsListModel *headerViewModel;
@end
