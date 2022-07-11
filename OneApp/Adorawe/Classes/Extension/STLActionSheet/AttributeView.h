//
//  AttributeView.h
// XStarlinkProject
//
//  Created by 10010 on 2017/9/18.
//  Copyright © 2017年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^AttributeViewEventBlock)(NSString *url);

@interface AttributeView : UICollectionReusableView

+ (AttributeView *)attributeViewWithCollectionView:(UICollectionView *)collectionView kind:(NSString*)kind indexPath:(NSIndexPath *)indexPath;

@property (nonatomic, copy) AttributeViewEventBlock  eventBlock;

@property (nonatomic, copy) NSString                 *keyword;
@property (nonatomic, copy) NSString                 *detailWords;

// 根据sizechar && sizeChartUrl 存在显示跳转按钮
@property (nonatomic, copy) NSString                 *sizeChart;
@property (nonatomic, copy) NSString                 *sizeChartUrl;

//是否隐藏按钮
@property (nonatomic, assign) BOOL                   hideEvent;


@property (nonatomic, strong) UIView                 *topLineView;
@property (nonatomic, strong) UILabel                *titleLabel;
@property (nonatomic, strong) UILabel                *detLabel;
@property (nonatomic, strong) UIImageView            *rulerImgView;
@property (nonatomic, strong) UILabel                *rulerLabel;
@property (nonatomic, strong) UIButton               *eventBtn;

@property (nonatomic, strong) UIImageView            *arrowImgView;

@end
