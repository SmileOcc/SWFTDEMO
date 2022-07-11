//
//  CollectionCellModelProtocol.h
//  TestCollectionView
//
//  Created by 10010 on 20/7/30.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol CollectionCellModelProtocol <NSObject>

@property (nonatomic, strong) NSObject *dataSource;

@optional
@property (nonatomic, copy) NSString   *bg_color;

@property (nonatomic, copy) NSString   *channelId;
@property (nonatomic, copy) NSString   *channelName;

/**
 *  默认 CGSizeZero
 *
 *  如果设置了该属性，算法中就以此为标准计算
 */
-(CGSize)customerSize;

//-(CGFloat)leftSpace;

-(NSString *)reuseIdentifier;

+(NSString *)reuseIdentifier;

@end
