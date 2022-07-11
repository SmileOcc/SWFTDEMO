//
//  OSSVCSelectsView.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/20.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, SelectViewStatus) {
    SelectView_Default,
    SelectView_Selected,
};

typedef NS_ENUM(NSInteger, SelectViewType) {
    SelectViewType_Open,
    SelectViewType_Close,
} ;

@protocol STLSelectViewDelegate <NSObject>

-(void)STL_SelectViewDidClick;

@end

@interface OSSVCSelectsView : UIView

@property (nonatomic, weak) id<STLSelectViewDelegate>delegate;
@property (nonatomic, assign) SelectViewStatus status;
@property (nonatomic, assign) SelectViewType type;

///设置选项
-(void)handleSelectContent:(NSString *)content;

-(NSString *)selectPhoneCode;

-(void)setDefaultBorderColor;

@end
