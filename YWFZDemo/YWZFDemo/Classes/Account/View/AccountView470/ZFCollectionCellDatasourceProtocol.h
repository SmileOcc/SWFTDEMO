//
//  ZFCollectionCellDatasourceProtocol.h
//  ZZZZZ
//
//  Created by YW on 2019/6/25.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//  Collection cell 数据源 protocol

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol ZFCollectionCellDatasourceProtocol <NSObject>

@property (nonatomic, assign) Class registerClass;

@optional;
/**
 可以在这里定制特殊的不重用的identifier

 @param indexPath 表结构的indexPath
 @param identifier 区分模型对应视图的唯一标识
 @return 返回一个自定义唯一标识，用于标示图注册子视图
 */
- (NSString *)CollectionDatasourceCell:(NSIndexPath *)indexPath identifier:(id)identifier;

///collectionCell 的注册方法
- (NSString *)registerCollectionView:(UICollectionView *)collectionView identifier:(NSString *)identifier;

@end

