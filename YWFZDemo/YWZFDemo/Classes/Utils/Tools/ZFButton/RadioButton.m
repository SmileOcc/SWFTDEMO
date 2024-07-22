//
//  RadioButton.m
//  OrderInfoTest
//
//  Created by YW on 2017/2/24.
//  Copyright © 2017年 share. All rights reserved.
//

#import "RadioButton.h"
#import "Masonry.h"
#import "Constants.h"

#define RADIO_ICON_WH                     (16.0)
#define ICON_TITLE_MARGIN                 (5.0)

@interface RadioButton()
-(void)defaultInitNormalImage:(UIImage*)normalImage selectedImage:(UIImage *)selectedImage;
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

+ (void)removerRb_observersData {
    [rb_instances removeAllObjects];
    rb_instances = nil;
    
    [rb_instancesDic removeAllObjects];
    rb_instancesDic = nil;
    
    [rb_observers removeAllObjects];
    rb_observers = nil;
}

+(void)addObserverForGroupId:(NSString*)groupId observer:(id)observer{
    if(!rb_observers){
        rb_observers = [[NSMutableDictionary alloc] init];
    }
    
    if ([groupId length] > 0 && observer) {
        [rb_observers setObject:observer forKey:groupId];
        // Make it weak reference
    }
}

#pragma mark - Manage Instances

+(void)registerInstance:(RadioButton*)radioButton withGroupID:(NSString *)aGroupID{
    
    if(!rb_instancesDic){
        rb_instancesDic = [[NSMutableDictionary alloc] initWithCapacity:16];
    }
    
    if ([rb_instancesDic objectForKey:aGroupID]) {
        [[rb_instancesDic objectForKey:aGroupID] addObject:radioButton];
        [rb_instancesDic setObject:[rb_instancesDic objectForKey:aGroupID] forKey:aGroupID];
    }else {
        NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:16];
        [arr addObject:radioButton];
        [rb_instancesDic setObject:arr forKey:aGroupID];
    }
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
    
    // Unselect the other radio buttons
    
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

#pragma mark - Object Lifecycle

-(id)initWithGroupId:(NSString*)groupId index:(NSUInteger)index normalImage:(UIImage *)normalImage selectedImage:(UIImage *)selectedImage{
    self = [self init];
    if (self) {
        _groupId = groupId;
        _index = index;
        _normalImage = normalImage;
        _selectedImage = selectedImage;
        [self defaultInitNormalImage:normalImage selectedImage:selectedImage];  // 移动至此
    }
    return  self;
}

-(id)initWithGroupId:(NSString*)groupId index:(NSUInteger)index normalImage:(UIImage *)normalImage selectedImage:(UIImage *)selectedImage title:(NSString *)title color:(UIColor *)color{
    self = [self init];
    if (self) {
        _groupId = groupId;
        _index = index;
        _normalImage = normalImage;
        _selectedImage = selectedImage;
        [self defaultInitNormalImage:normalImage selectedImage:selectedImage title:title color:color];  // 移动至此
    
    }
    return  self;
}

- (id)init{
    self = [super init];
    if (self) {
        //       [self defaultInit];
    }
    return self;
}

- (void)dealloc
{
    YWLog(@"RadioButton dealloc");
}


#pragma mark - Set Default Checked

- (void) setChecked:(BOOL)isChecked
{
    if (isChecked) {
        [_button setSelected:YES];
    }else {
        [_button setSelected:NO];
    }
}

#pragma mark - Tap handling

-(void)handleButtonTap:(id)sender{
    [_button setSelected:YES];
    [RadioButton buttonSelected:self];
}

-(void)otherButtonSelected:(id)sender{
    // Called when other radio button instance got selected
    if(_button.selected){
        [_button setSelected:NO];
    }
}

#pragma mark - RadioButton init

-(void)defaultInitNormalImage:(UIImage *)normalImage selectedImage:(UIImage *)selectedImage{
    // Setup container view
    self.frame = CGRectMake(0, 0, kRadioButtonWidth, kRadioButtonHeight);
    
    // Customize UIButton
    _button = [UIButton buttonWithType:UIButtonTypeCustom];
    _button.frame = CGRectMake(0, 0,kRadioButtonWidth, kRadioButtonHeight);
    _button.adjustsImageWhenHighlighted = NO;
    [_button setImage:normalImage forState:UIControlStateNormal];
    [_button setImage:selectedImage forState:UIControlStateSelected];
    [_button addTarget:self action:@selector(handleButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_button];
    
    //   [RadioButton registerInstance:self];
    
    // update follow:
    [RadioButton registerInstance:self withGroupID:self.groupId];
    
}

-(void)defaultInitNormalImage:(UIImage *)normalImage selectedImage:(UIImage *)selectedImage title:(NSString *)title color:(UIColor *)color{
    // Customize UIButton
    _button = [UIButton buttonWithType:UIButtonTypeCustom];
    _button.adjustsImageWhenHighlighted = NO;
    [_button setImage:normalImage forState:UIControlStateNormal];
    [_button setImage:selectedImage forState:UIControlStateSelected];
    [_button setTitle:title forState:UIControlStateNormal];
    [_button setTitleColor:color forState:UIControlStateNormal];
    _button.titleLabel.font = [UIFont systemFontOfSize:14];
    [_button addTarget:self action:@selector(handleButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_button];
    [_button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self).with.insets(UIEdgeInsetsZero);
    }];
    
    // update follow:
    [RadioButton registerInstance:self withGroupID:self.groupId];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect bounds = self.bounds;
    CGFloat widthDelta = MAX(self.clickAreaRadious - bounds.size.width, 0);
    CGFloat heightDelta = MAX(self.clickAreaRadious - bounds.size.height, 0);
    bounds = CGRectInset(bounds, -0.5 * widthDelta, -0.5 * heightDelta);
    return CGRectContainsPoint(bounds, point);
}

@end
