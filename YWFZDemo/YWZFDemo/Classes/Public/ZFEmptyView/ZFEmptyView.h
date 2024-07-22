//
//  ZFEmptyView.h
//  ZZZZZ
//
//  Created by YW on 2019/6/13.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZFEmptyView : UIView

@property (nonatomic, copy) NSString *msg;
@property (nonatomic, strong) UIImage *msgImage;


/**配置信息*/
@property (nonatomic, assign) CGFloat      imageBottomCenterYSpace;
@property (nonatomic, assign) CGFloat      labelTopCenterYSpace;
@property (nonatomic, assign) CGFloat      labelLeadingSpace;
@property (nonatomic, assign) NSInteger    labelNumberOfLines;
@property (nonatomic, strong) UIColor      *labelTextColor;
@property (nonatomic, assign) NSInteger    labelFontSize;

/**若配置，需刷新*/
- (void)reloadView;





@end

NS_ASSUME_NONNULL_END
