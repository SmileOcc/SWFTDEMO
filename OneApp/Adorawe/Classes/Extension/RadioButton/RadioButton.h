//
//  RadioButton.h
//  GearBest
//
//  Created by 10010 on 20/7/22.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

//#import <UIKit/UIKit.h>
//
//@protocol RadioButtonDelegate;
//
//@interface RadioButton : UIButton
//
//@property(nonatomic, assign) id<RadioButtonDelegate>  delegate;
//@property(nonatomic, copy, readonly) NSString *groupId;
//@property(nonatomic, assign) BOOL checked;
//
//- (id)initWithDelegate:(id)delegate groupId:(NSString*)groupId normalImage:(UIImage *)normalImage selectedImage:(UIImage *)selectedImage;
//
//@end
//
//@protocol RadioButtonDelegate <NSObject>
//
//@optional
//- (void)didSelectedRadioButton:(RadioButton *)radio groupId:(NSString *)groupId;
//
//@end
#import <UIKit/UIKit.h>

@protocol RadioButtonDelegate <NSObject>
-(void)radioButtonSelectedAtIndex:(NSUInteger)index inGroup:(NSString*)groupId;
@end

@interface RadioButton : UIButton {
    NSString *_groupId;
    NSUInteger _index;
    UIImage *_normalImage;
    UIImage *_selectedImage;
    UIButton *_button;
    CGRect _frame;
}
@property(nonatomic,retain)NSString *groupId;
@property(nonatomic,assign)NSUInteger index;

-(id)initWithGroupId:(NSString*)groupId index:(NSUInteger)index normalImage:(UIImage *)normalImage selectedImage:(UIImage *)selectedImage frame:(CGRect)frame type:(RadioButtonType)type isOptional:(BOOL)isOptional;
+(void)addObserverForGroupId:(NSString*)groupId observer:(id)observer;

// 可以设置默认选中项 
- (void) setChecked:(BOOL)isChecked;
@end
