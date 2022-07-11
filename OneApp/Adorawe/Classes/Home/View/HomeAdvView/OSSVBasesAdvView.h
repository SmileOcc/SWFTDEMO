//
//  BaseAdvView.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/3.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^BaseAdvViewBlock)(OSSVAdvsEventsModel *OSSVAdvsEventsModel, BOOL close);

@interface OSSVBasesAdvView : UIView

@property (nonatomic, copy) BaseAdvViewBlock         advDoActionBlock;
@property (nonatomic, strong) OSSVAdvsEventsModel       *advEventModel;

@property (nonatomic, assign) AdverType       advType;

@property (nonatomic, strong) UIView          *bgView;
@property (nonatomic, strong) UIView          *contentView;
@property (nonatomic, strong) UIButton        *cloaseButton;

@end
