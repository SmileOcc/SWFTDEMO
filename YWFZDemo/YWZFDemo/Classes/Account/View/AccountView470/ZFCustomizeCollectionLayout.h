//
//  ZFCustomizeCollectionLayout.h
//  ZZZZZ
//
//  Created by YW on 2019/6/27.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//  自定义Collection layout

#import <UIKit/UIKit.h>
#import "ZFCollectionSectionProtocol.h"
#import "ZFCustomerBackgroundCRView.h"

NS_ASSUME_NONNULL_BEGIN

static NSString * CollectionViewSectionBackground = @"CollectionViewSectionBackground";

@protocol ZFCustomerLayoutDatasource <NSObject>

//返回数据源section
-(NSInteger)customerLayoutNumsSection:(UICollectionView *)collectionView;

//返回section一个布局对象
-(id<ZFCollectionSectionProtocol>)customerLayoutDatasource:(UICollectionView *)collectionView sectionNum:(NSInteger)section;

@optional;
/**
 * 返回section header 高度的方法
 */
-(CGFloat)customerLayoutSectionHeightHeight:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)layout indexPath:(NSIndexPath *)indexPath;

/**
 * 返回section footer 高度的方法
 */
-(CGFloat)customerLayoutSectionFooterHeight:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)layout indexPath:(NSIndexPath *)indexPath;

/**
 * 返回section 的自定义背景attributes
 */
-(CustomerBackgroundAttributes *)customerLayoutSectionAttributes:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)layout indexPath:(NSIndexPath *)indexPath;

@end

@protocol ZFCustomerLayoutDelegate <NSObject>

@optional;
/**
 * 布局完毕
 */
-(void)customerLayoutDidLayoutDone;

@end


@interface ZFCustomizeCollectionLayout : UICollectionViewFlowLayout

@property (nonatomic, weak) id<ZFCustomerLayoutDatasource>dataSource;
@property (nonatomic, weak) id<ZFCustomerLayoutDelegate>delegate;

/*
 插入section数
 用于重新计算布局，使用该方法时需要调用 collectoin 的 reloadata方法
 当大于当前section时，默认插入到队列尾部
 */
-(void)inserSection:(NSInteger)section;

/*
 刷新section
 用于重新计算布局，使用该方法时需要调用 collectoin 的 reloadata方法
 当大于当前section时，默认插入到队列尾部
 */
-(void)reloadSection:(NSInteger)section;

@end

NS_ASSUME_NONNULL_END
