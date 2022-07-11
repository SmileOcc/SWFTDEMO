//
//  OSSVCartNoDataView.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/3.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CartNoDataBlock)();

@interface OSSVCartNoDataView : UIView

- (instancetype)initWithFrame:(CGRect)frame completion:(CartNoDataBlock)noDataBlock;
@end
