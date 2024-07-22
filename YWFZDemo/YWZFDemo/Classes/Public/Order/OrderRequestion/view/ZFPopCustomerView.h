//
//  ZFPopCustomerView.h
//  ZZZZZ
//
//  Created by YW on 2019/3/22.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//  弹出自定义视图

#import <UIKit/UIKit.h>

//模型protocol
typedef void(^didClickItem)(void);
@protocol CustomerViewProtocol <NSObject>

@property (nonatomic, assign) UIEdgeInsets edgeInsets;
@property (nonatomic, copy) didClickItem didClickItemBlock;

@end

//cell delegate
@protocol ContentViewCellDelegate <NSObject>
@end

//cell protocol
@protocol UITableViewCellProtocol <NSObject>

@property (nonatomic, strong) id<CustomerViewProtocol>model;
@property (nonatomic, weak) id<ContentViewCellDelegate>delegate;

@end

#pragma mark - customerModel

@interface CustomerSelectMarkModel : NSObject
<
    CustomerViewProtocol
>

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) NSString *imagePath;
@property (nonatomic, assign) BOOL isSelect;
@property (nonatomic, copy) NSString *content;

@end


//纯图片
@interface CustomerImageModel : NSObject
<
    CustomerViewProtocol
>

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) NSString *imagePath;

@end

//纯文字内容
@interface CustomerTitleModel : NSObject
<
    CustomerViewProtocol
>
@property (nonatomic, copy) NSString *content;
///default [UIFont systemFontOfSize:14]
@property (nonatomic, strong) UIFont *contentFont;
///default NSTextAlignmentNatural
@property (nonatomic, assign) NSTextAlignment contentTextAlignment;

@end

//图片和文字
@interface CustomerImageTitleModel : NSObject
<
    CustomerViewProtocol
>
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *imagePath;
@property (nonatomic, strong) UIImage *image;

@end

//按钮
@interface CustomerButtonModel : NSObject
<
    CustomerViewProtocol
>
@property (nonatomic, copy) NSString *buttonTitle;
@property (nonatomic, strong) UIColor *buttonBackgroundColor;
@property (nonatomic, strong) UIColor *titleColor;

@end

//倒计时按钮
//按钮
@interface CustomerCountDownButtonModel : CustomerButtonModel
<
    CustomerViewProtocol
>
//倒计时设置，默认为0
@property (nonatomic, assign) NSInteger countDown;

@end

#pragma mark - ZFPopCustomerView

@protocol ZFPopCustomerViewDelegate <NSObject>

- (void)popCustomerViewDidSelect:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;

@end

@interface ZFPopCustomerView : UIView

///default UIEdgeInsert(0,0,0,0)
@property (nonatomic, assign) UIEdgeInsets edgeInsets;
@property (nonatomic, weak) id<ZFPopCustomerViewDelegate>delegate;
///主视图背景颜色
@property (nonatomic, strong) UIColor *contentViewBackgroundColor;

- (void)showCustomer:(NSArray <id<CustomerViewProtocol>> *)customerViews;
- (void)hiddenCustomer;

@end

