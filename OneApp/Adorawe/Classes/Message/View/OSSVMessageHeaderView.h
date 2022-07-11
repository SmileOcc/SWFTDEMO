//
//  OSSVMessageHeaderView.h
// XStarlinkProject
//
//  Created by odd on 2020/8/6.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVMessageListModel.h"

@interface OSSVMessageHeaderView : UIView

@property (nonatomic, strong) UIView      *headBgView;
@property (nonatomic, strong) UIView      *bottomGrayView;
@property (nonatomic, strong) UILabel     *messageLabel;
@property (nonatomic, strong) UIView      *menuBgView;

@property (nonatomic, copy) void(^tapItemBlock)(OSSVMessageModel *model, NSInteger index);

- (void)updateModel:(OSSVMessageListModel *)model index:(NSInteger)index isFirst:(BOOL)first;

+ (CGFloat)mssageHeadercontentH;
@end

