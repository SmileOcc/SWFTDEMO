//
//  OSSVAccounteOrdereDetaileView.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/7.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OSSVAccounteOrdersDetaileGoodsModel;
@class OSSVAccounteOrdereDetaileView;

@protocol AccountOrderDetailViewDelegate <NSObject>

@optional
- (void)OSSVAccounteOrdereDetaileView:(OSSVAccounteOrdereDetaileView *)goodsView goodsModel:(OSSVAccounteOrdersDetaileGoodsModel*)goodsModel;

@end

@interface OSSVAccounteOrdereDetaileView : UIView

- (void) initWithGoodsModel:(OSSVAccounteOrdersDetaileGoodsModel*)goodsModel orderStatue:(NSInteger)orderStatue;

@property (nonatomic,strong) OSSVAccounteOrdersDetaileGoodsModel *goodsModel;
@property (nonatomic,weak) id<AccountOrderDetailViewDelegate> delegate;

@end
