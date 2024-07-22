//
//  ZFCustomerBackgroundCRView.h
//  ZZZZZ
//
//  Created by YW on 2019/7/3.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomerBackgroundAttributes : UICollectionViewLayoutAttributes

@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIImage *backgroundImage;
@property (nonatomic, assign) CGFloat  bottomOffset;

@end

@interface ZFCustomerBackgroundCRView : UICollectionReusableView

@end


