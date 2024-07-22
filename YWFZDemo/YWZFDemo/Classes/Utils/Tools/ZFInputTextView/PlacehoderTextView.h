//
//  PlacehoderTextView.h
//  GearBest
//
//  Created by YW on 16/3/15.
//  Copyright © 2016年 gearbest. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlacehoderTextView : UITextView

@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic, strong) UIColor *realTextColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *placeholderColor UI_APPEARANCE_SELECTOR;

@end
