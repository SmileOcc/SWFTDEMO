//
//  STLActionCollectionFooterView.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/10.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVSizeChartModel.h"

@interface STLActionCollectionFooterView : UICollectionReusableView

+ (STLActionCollectionFooterView *)actionCollectionFooterView:(UICollectionView *)collectionView kind:(NSString*)kind indexPath:(NSIndexPath *)indexPath;

@property (nonatomic, strong) UILabel                *contentLabel;
@property (nonatomic, strong) UIView                 *bgView;

+ (CGSize)sizeDescContent:(NSMutableAttributedString *)content;

- (void)updateDescContent:(NSMutableAttributedString *)content;
@end
