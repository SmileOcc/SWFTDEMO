//
//  OSSVSortsOptionalView.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/17.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger, SortOptionalState) {
    /**关闭*/
    SortOptionalStateClose,
    /**关闭中*/
    SortOptionalStateCloseAnimating,
    /**打开*/
    SortOptionalStateOpen,
    /**打开中*/
    SortOptionalStateOpenAnimating,
};

@class OSSVSortsOptionalView;

@protocol STLSortOptionalViewDataSource<NSObject>

@required
- (NSArray *) datasYSSortOptionalView;

@end

@protocol STLSortOptionalViewDelegate<NSObject>

- (void)sortOptinalView:(OSSVSortsOptionalView *)optionView selectIndex:(NSInteger )index;
@end



@interface OSSVSortsOptionalView : UIControl<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>

@property (nonatomic, weak) id<STLSortOptionalViewDataSource> dataSource;
@property (nonatomic, weak) id<STLSortOptionalViewDelegate> delegate;
@property (nonatomic, strong) UIView *topLienView;
@property (nonatomic, strong) UITableView *optionTable;
@property (nonatomic, assign) NSInteger selectIndex;
@property (nonatomic, assign) SortOptionalState optionalState;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

-(void)show:(BOOL)flag;
- (void)dismiss;

@end
