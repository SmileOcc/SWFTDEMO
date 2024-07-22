//
//  GJPickerView.h
//  YDGJ
//
//  Created by Luke on 16/7/28.
//  Copyright © 2016年 Galaxy360. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NSArray<NSArray <NSString *>*>* ZFDataList;

@interface ZFPickerViewSelectModel : NSObject

@property (nonatomic, assign) NSInteger section;
@property (nonatomic, assign) NSInteger row;
@property (nonatomic, assign) NSString *content;
@property (nonatomic, copy) NSString *selectId;

@end

@interface ZFPickerView : UIView

/**
 *  弹出一个自定义pickerView
 *  @params pickDataArr  二维数组， 一维表示section数量, 二维表示section中row数量
 */
+ (instancetype)showPickerViewWithTitle:(id)title
                            pickDataArr:(ZFDataList)pickDataArr
                              sureBlock:(void(^)(NSArray<ZFPickerViewSelectModel *> * selectContents))sureBlock cancelBlock:(void (^)(void))cancelBlock;



/**
 离开进入其他界面记得隐藏
 */
- (void)dismissView;

/**
 * 默认选中
 * @[第一组选中的内容,第二组选中的，第三组选中的，。。。]
 * 传入的对应内容未找到不处理
 */
- (void)selectPickerRowArray:(NSArray <NSString *> *)selectRowArr;
@end
