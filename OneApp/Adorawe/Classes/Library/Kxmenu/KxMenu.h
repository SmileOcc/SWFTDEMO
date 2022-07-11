     //
//  KxMenu.h
//  GearBest
//
//  Created by 10010 on 20/7/16.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface PopoverCell : UITableViewCell

@property (nonatomic, copy) NSString *title;
+ (instancetype)popoverCellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;

@end

//@protocol KxMenuDelegate <NSObject>
//
//@optional
//- (void)menuItemSelect:(NSInteger)index;
//@end

typedef NS_ENUM(NSUInteger, MenuStyle) {
    MenuStyle_Default,
    MenuStyle_Border,
};

typedef void(^KxMenuClickBlock)(NSInteger index);

@interface KxMenu : NSObject
@property (nonatomic, copy) NSString    *selectTitle;

//@property (nonatomic,assign) id<KxMenuDelegate> delegate;
@property (nonatomic,copy) KxMenuClickBlock menuClickBlock;

//+ (void) showMenuInView:(UIView *)view
//               fromRect:(CGRect)rect
//              menuItems:(NSArray *)menuItems delegate:(id)delegate;

+ (void) showMenuInView:(UIView *)view
               fromRect:(CGRect)rect
           selectTitle : (NSString *)title
              menuItems:(NSArray *)menuItems block:(KxMenuClickBlock)menuClickBlock;

+ (void) showMenuInView:(UIView *)view
               fromRect:(CGRect)rect
           selectTitle : (NSString *)title
                  style:(MenuStyle)style
              menuItems:(NSArray *)menuItems block:(KxMenuClickBlock)menuClickBlock;

+ (void) dismissMenu;

+ (UIColor *) tintColor;
+ (void) setTintColor: (UIColor *) tintColor;

+ (UIColor *) selectedColor;
+ (void) setSelectedColor: (UIColor *) selectedColor;

+ (UIFont *) titleFont;
+ (void) setTitleFont: (UIFont *) titleFont;

@end
