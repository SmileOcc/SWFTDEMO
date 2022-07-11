//
//  OSSVCategorySearchsView.h
// XStarlinkProject
//
//  Created by odd on 2020/8/8.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^SearchInputCompletionHandler)(void);
typedef void(^SearchImageCompletionHandler)(void);

@protocol STLCategorySearchViewDelegate;

@interface OSSVCategorySearchsView : UIView
@property (nonatomic, weak) id <STLCategorySearchViewDelegate> delegate;
@property (nonatomic, copy) NSString            *inputPlaceHolder;
@property (nonatomic, copy) SearchInputCompletionHandler    inputCompletionHandler;
@property (nonatomic, copy) SearchInputCompletionHandler    imageCompletionHandler;
@property (nonatomic, copy) NSArray           *hotWordsArray;
- (void)subViewWithAlpa:(CGFloat)alpha;

- (void)showSearchPhotoImage:(BOOL)show;

@end

@protocol STLCategorySearchViewDelegate <NSObject>

@optional

- (void)textClick:(NSString *)searchKey;

@end

