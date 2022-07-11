//
//  YXTableViewController2.h
//  YouXinZhengQuan
//
//  Created by RuiQuan Dai on 2018/7/3.
//  Copyright © 2018年 RenRenDai. All rights reserved.
//

#import "YXViewController.h"
#import "YXTableViewCell.h"
#import "YXTableView.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

@interface YXTableViewController : YXViewController <UITableViewDelegate,UITableViewDataSource,DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, UIScrollViewDelegate>


@property (nonatomic, strong, readonly) YXTableView *tableView;
@property (nonatomic, assign, readonly) UIEdgeInsets contentInset;
@property (nonatomic, assign) BOOL whiteStyle;

- (void)reloadData;

/**
 y default: YXConstant.navBarHeight
 */
- (CGFloat)tableViewTop;



/**
 UITableViewStyle default: UITableViewStylePlain

 */
- (UITableViewStyle)tableViewStyle;



/**
 default : 44px
 */
- (CGFloat)rowHeight;


/**
 给某行cell配置数据

 @param cell cell
 @param indexPath indexPath
 @param object 数据
 */
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withObject:(id)object;


/**
 获取某行Identifier

 */
- (NSString *)cellIdentifierAtIndexPath:(NSIndexPath *)aIndexPath;


/**
 全部cell的标识
 */
- (NSDictionary *)cellIdentifiers;


/**
 根据section来确定类数组的顺序和数量，一个section对应一个Cell类
 
 继承此方法 不需要重写cellIdentifiers 和 cellIdentifierAtIndexPath:

 @return 类的数组, 类必须继承自YXTableViewCell，默认@[YXTableViewCell]
 */
- (NSArray<Class> *)cellClasses;


/**
 网络连接正常, datasource有数据, 但子数组数据为空

 @return dataSource数据为空时title文字
 */
- (NSAttributedString *)customTitleForEmptyDataSet;

/**
 网络连接正常, datasource有数据, 但子数组数据为空
 
 @return dataSource数据为空时显示图片
 */
- (UIImage *)customImageForEmptyDataSet;

/**
 拉取首页数据
 */
- (void)loadFirstPage;

/**
 下拉刷新类型
 */
- (Class)refreshClass;



@end
