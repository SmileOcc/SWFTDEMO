//
//  OSSVThemesMainLayout.h
//  OSSVThemesMainLayout
//
//  Created by 10010 on 20/7/26.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomerLayoutSectionModuleProtocol.h"

@protocol CustomerLayoutDatasource <NSObject>

-(id<CustomerLayoutSectionModuleProtocol>)customerLayoutDatasource:(UICollectionView *)collectionView sectionNum:(NSInteger)section;

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
 * 返回section Menu位置，没有返回 -1
 */
-(NSInteger)customerLayoutThemeMenusSection:(UICollectionView *)collectionView;

@end

@protocol CustomerLayoutDelegate <NSObject>

/**
 * 布局完毕
 */
-(void)customerLayoutDidLayoutDone;

@end

@interface OSSVThemesMainLayout : UICollectionViewLayout

@property (nonatomic, weak) id<CustomerLayoutDatasource>dataSource;
@property (nonatomic, weak) id<CustomerLayoutDelegate>delegate;

///存储每个section最终bottom
@property (nonatomic, strong) NSMutableArray *columnHeightsArray;

@property (nonatomic, assign) BOOL showBottomsGoodsSeparate;

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

-(CGFloat)customerLastSectionFirstViewTop;

/*
    通过传入的section，获取指定分区的第一个布局结构
    可以使用 delegate customerLayoutDidLayoutDone 获取布局完成的状态
 */
-(CGRect)customerSectionFirstAttribute:(NSInteger)section;

@end
