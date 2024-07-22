//
//  ZFCommunityHomeTableFooterView.h
//  ZZZZZ
//
//  Created by YW on 2018/11/27.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFCommunityExploreModel.h"
@class ZFBannerModel;
@class ZFCommunityFavesItemModel;
@protocol ZFCommunityHomeTableFooterViewDelegate;

@interface ZFCommunityHomeTableFooterView : UIView

@property (nonatomic, weak) id<ZFCommunityHomeTableFooterViewDelegate>               delegate;

@property (nonatomic, strong) NSMutableArray                                         *datasArray;

@property (nonatomic, assign) NSInteger                                              selectIndex;

@property (nonatomic, copy) void (^selectBlock)(NSInteger index);

- (void)updateDatas:(NSArray *)datas;

///当前视图第一次加载视图
- (void)currentViewFirstRequest:(NSInteger)index;


- (UICollectionView *)currentCollectionView;

- (instancetype)initWithFrame:(CGRect)frame baseData:(NSArray *)baseData;

@end


@protocol ZFCommunityHomeTableFooterViewDelegate <NSObject>

- (void)communityHomeTableFooterView:(ZFCommunityHomeTableFooterView *)footerView scrollUp:(BOOL)scrollUp;

@end
