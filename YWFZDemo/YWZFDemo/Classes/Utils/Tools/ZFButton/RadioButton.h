//
//  RadioButton.h
//  OrderInfoTest
//
//  Created by YW on 2017/2/24.
//  Copyright © 2017年 share. All rights reserved.
//
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
}
@property(nonatomic,retain)NSString *groupId;
@property(nonatomic,assign)NSUInteger index;

+ (void)removerRb_observersData;

-(id)initWithGroupId:(NSString*)groupId index:(NSUInteger)index normalImage:(UIImage *)normalImage selectedImage:(UIImage *)selectedImage;

-(id)initWithGroupId:(NSString*)groupId index:(NSUInteger)index normalImage:(UIImage *)normalImage selectedImage:(UIImage *)selectedImage title:(NSString *)title color:(UIColor *)color;

+(void)addObserverForGroupId:(NSString*)groupId observer:(id)observer;

// 可以设置默认选中项
- (void) setChecked:(BOOL)isChecked;
-(void)handleButtonTap:(id)sender;
@property (nonatomic,assign) CGFloat clickAreaRadious;
@end
