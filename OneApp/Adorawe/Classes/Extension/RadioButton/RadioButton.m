//
//  RadioButton.m
//  GearBest
//
//  Created by 10010 on 20/7/22.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "RadioButton.h"
#define RADIO_ICON_WH                     (16.0)
#define ICON_TITLE_MARGIN                 (5.0)

@interface RadioButton()
//-(void)defaultInitNormalImage:(UIImage*)normalImage selectedImage:(UIImage *)selectedImage;
-(void)otherButtonSelected:(id)sender;
-(void)handleButtonTap:(id)sender;
@end

@implementation RadioButton

@synthesize groupId=_groupId;
@synthesize index=_index;

static const NSUInteger kRadioButtonWidth=22;
static const NSUInteger kRadioButtonHeight=22;

static NSMutableArray *rb_instances=nil;
static NSMutableDictionary *rb_instancesDic=nil;  // 识别不同的组
static NSMutableDictionary *rb_observers=nil;

#pragma mark - Observer
+(void)addObserverForGroupId:(NSString*)groupId observer:(id)observer{
    if(!rb_observers){
        rb_observers = [[NSMutableDictionary alloc] init];
    }
    if ([groupId length] > 0 && observer) {
        [rb_observers setObject:observer forKey:groupId];
        // Make it weak reference
    }
}

#pragma mark - Object Lifecycle
-(id)initWithGroupId:(NSString*)groupId index:(NSUInteger)index normalImage:(UIImage *)normalImage selectedImage:(UIImage *)selectedImage frame:(CGRect)frame type:(RadioButtonType)type isOptional:(BOOL)isOptional{
    self = [self init];
    if (self) {
        _groupId = groupId;
        _index = index;
        _normalImage = normalImage;
        _selectedImage = selectedImage;
        _frame = frame;
        [self defaultInitNormalImage:normalImage selectedImage:selectedImage frame:frame type:type isOptional:isOptional];  //1
    }
    return  self;
}

#pragma mark - RadioButton 初始化
-(void) defaultInitNormalImage:(UIImage *)normalImage selectedImage:(UIImage *)selectedImage  frame:(CGRect)frame type:(RadioButtonType)type isOptional:(BOOL)isOptional {   //2
    self.frame = CGRectMake(0, 0, kRadioButtonWidth, kRadioButtonHeight);
    _button = [UIButton buttonWithType:UIButtonTypeCustom];
    _button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    _button.userInteractionEnabled = isOptional;
    _button.frame = frame;
    if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
        _button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, SCREEN_WIDTH - 20);
    } else {
        _button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
    }
    _button.adjustsImageWhenHighlighted = NO;
    
    switch (type) {
        case DefaultImage:
        {
            [_button setImage:normalImage forState:UIControlStateNormal];
            [_button setImage:selectedImage forState:UIControlStateSelected];
        }
            break;
        case BackgroundImage:
        {
            [_button setBackgroundImage:normalImage forState:UIControlStateNormal];
            [_button setBackgroundImage:selectedImage forState:UIControlStateSelected];
        }
            break;
        default:
            break;
    }
    
    [_button addTarget:self action:@selector(handleButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_button];
    //    [RadioButton registerInstance:self];
    
    // update follow:
    [RadioButton registerInstance:self withGroupID:self.groupId];
}

#pragma mark - 点击事件
-(void)handleButtonTap:(id)sender{
    [_button setSelected:YES];
    [RadioButton buttonSelected:self];
}

#pragma mark - Class level handler
+(void)buttonSelected:(RadioButton*)radioButton{
    // Notify observers
    if (rb_observers) {
        id observer= [rb_observers objectForKey:radioButton.groupId];
        if(observer && [observer respondsToSelector:@selector(radioButtonSelectedAtIndex:inGroup:)]){
            [observer radioButtonSelectedAtIndex:radioButton.index inGroup:radioButton.groupId];
        }
    }
    //取消选择另一个单选按钮
    // 初始化按钮数组
    rb_instances = [rb_instancesDic objectForKey:radioButton.groupId];
    if (rb_instances) {
        for (int i = 0; i < [rb_instances count]; i++) {
            RadioButton *button = [rb_instances objectAtIndex:i];
            if (![button isEqual:radioButton]) {
                [button otherButtonSelected:radioButton];
            }
        }
    }
}

-(void)otherButtonSelected:(id)sender{
    // Called when other radio button instance got selected
    if(_button.selected){
        [_button setSelected:NO];
    }
}

#pragma mark - 管理实例
+(void)registerInstance:(RadioButton*)radioButton withGroupID:(NSString *)aGroupID{  //3
    if(!rb_instancesDic){
        rb_instancesDic = [[NSMutableDictionary alloc] initWithCapacity:16];
    }
    //如果是相同组ID则把rbBtn都放一起
    if ([rb_instancesDic objectForKey:aGroupID]) {
        [[rb_instancesDic objectForKey:aGroupID] addObject:radioButton];
        [rb_instancesDic setObject:[rb_instancesDic objectForKey:aGroupID] forKey:aGroupID];
    }else {
        NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:16];
        [arr addObject:radioButton];
        [rb_instancesDic setObject:arr forKey:aGroupID];
    }
}

#pragma mark - 设置默认选中项
- (void) setChecked:(BOOL)isChecked
{
    if (isChecked) {
        [_button setSelected:YES];
    }else {
        [_button setSelected:NO];
    }
}

@end

//static NSMutableDictionary *groupRadioDict = nil;
//
//@implementation RadioButton
//
//- (id)initWithDelegate:(id)delegate groupId:(NSString*)groupId normalImage:(UIImage *)normalImage selectedImage:(UIImage *)selectedImage {
//    self = [super init];
//    if (self) {
//        _delegate = delegate;
//        _groupId = groupId;
//        
//        [self addToGroup];
//        
//        self.exclusiveTouch = YES;
//        
//        [self setImage:normalImage ? normalImage : [UIImage imageNamed:@"radio_unchecked"] forState:UIControlStateNormal];
//        [self setImage:selectedImage ? selectedImage : [UIImage imageNamed:@"radio_checked"] forState:UIControlStateSelected];
//        [self addTarget:self action:@selector(radioBtnChecked) forControlEvents:UIControlEventTouchUpInside];
//    }
//    return self;
//}
//
//- (void)addToGroup {
//    if(!groupRadioDict){
//        groupRadioDict = [NSMutableDictionary dictionary];
//    }
//    
//    NSMutableArray *radios = [groupRadioDict objectForKey:_groupId];
//    if (!radios) {
//        radios = [NSMutableArray array];
//    }
//    [radios addObject:self];
//    [groupRadioDict setObject:radios forKey:_groupId];
//}
//
//- (void)removeFromGroup {
//    if (groupRadioDict) {
//        NSMutableArray *radios = [groupRadioDict objectForKey:_groupId];
//        if (radios) {
//            [radios removeObject:self];
//            if (radios.count == 0) {
//                [groupRadioDict removeObjectForKey:_groupId];
//            }
//        }
//    }
//}
//
//- (void)uncheckOtherRadios {
//    NSMutableArray *radios = [groupRadioDict objectForKey:_groupId];
//    if (radios.count > 0) {
//        for (RadioButton *radio in radios) {
//            if (radio.checked && ![radio isEqual:self]) {
//                radio.checked = NO;
//            }
//        }
//    }
//}
//
//- (void)setChecked:(BOOL)checked {
//    if (_checked == checked) {
//        return;
//    }
//    
//    _checked = checked;
//    self.selected = checked;
//    
//    if (self.selected) {
//        [self uncheckOtherRadios];
//    }
//    
//    if (self.selected && _delegate && [_delegate respondsToSelector:@selector(didSelectedRadioButton:groupId:)]) {
//        [_delegate didSelectedRadioButton:self groupId:_groupId];
//    }
//}
//
//- (void)radioBtnChecked {
//    if (_checked) {
//        return;
//    }
//    
//    self.selected = !self.selected;
//    _checked = self.selected;
//    
//    if (self.selected) {
//        [self uncheckOtherRadios];
//    }
//    
//    if (self.selected && _delegate && [_delegate respondsToSelector:@selector(didSelectedRadioButton:groupId:)]) {
//        [_delegate didSelectedRadioButton:self groupId:_groupId];
//        
//    }
//}
//
//- (CGRect)imageRectForContentRect:(CGRect)contentRect {
//    return CGRectMake(0, (CGRectGetHeight(contentRect) - RADIO_ICON_WH)/2.0, RADIO_ICON_WH, RADIO_ICON_WH);
//}
//
//- (CGRect)titleRectForContentRect:(CGRect)contentRect {
//    return CGRectMake(RADIO_ICON_WH + ICON_TITLE_MARGIN, 0,
//                      CGRectGetWidth(contentRect) - RADIO_ICON_WH - ICON_TITLE_MARGIN,
//                      CGRectGetHeight(contentRect));
//}
//
//- (void)dealloc {
//    [self removeFromGroup];
//    _delegate = nil;
//}
//
//@end
