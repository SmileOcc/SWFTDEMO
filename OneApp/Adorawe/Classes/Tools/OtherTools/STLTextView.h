//
//  STLTextView.h
//  post
//
//  Created by 10010 on 20/7/5.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STLTextView : UITextView

@property (nonatomic, copy  ) NSString *placeholder;
@property (nonatomic, strong) UIColor  *placeholderColor;
@property (nonatomic, strong) UIFont   *placeholderFont;
@property (nonatomic,assign ) CGPoint  placeholderPoint;

@end
