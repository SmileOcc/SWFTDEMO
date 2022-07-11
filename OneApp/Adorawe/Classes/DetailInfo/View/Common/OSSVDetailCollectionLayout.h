//
//  OSSVDetailCollectionLayout.h
// XStarlinkProject
//
//  Created by odd on 2021/4/13.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVCollectionSectionProtocol.h"

@protocol OSSVDetailCollectionLayoutDatasource <NSObject>

//返回数据源section
-(NSInteger)customerLayoutNumsSection:(UICollectionView *)collectionView;

//返回section一个布局对象
-(id<OSSVCollectionSectionProtocol>)customerLayoutDatasource:(UICollectionView *)collectionView sectionNum:(NSInteger)section;

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
//-(CustomerBackgroundAttributes *)customerLayoutSectionAttributes:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)layout indexPath:(NSIndexPath *)indexPath;

@end


@protocol OSSVDetailCollectionLayoutDelegate <NSObject>

/**
 * 布局完毕
 */
-(void)customerLayoutDidLayoutDone;

@end

@interface OSSVDetailCollectionLayout : UICollectionViewLayout

@property (nonatomic, weak) id<OSSVDetailCollectionLayoutDatasource>dataSource;
@property (nonatomic, weak) id<OSSVDetailCollectionLayoutDelegate>delegate;

///存储每个section最终bottom
@property (nonatomic, strong) NSMutableArray *columnHeightsArray;


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

