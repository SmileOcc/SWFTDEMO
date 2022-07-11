//
//  OSSVCategroysTablev.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/17.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol STLCategroyTableviewDelegate<NSObject>

@optional

- (void)didDeselectRowAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface OSSVCategroysTablev : UITableView

@property (nonatomic,weak) id <STLCategroyTableviewDelegate> myDelegate ;
@property (nonatomic, assign) NSIndexPath *selectIndexPath;
@property (nonatomic, strong) NSArray *dataArray;

+ (CGFloat)contnetCellHeight;

- (void)updateData:(NSArray *)dataArray;

- (void)updateSelectIndex:(NSInteger)index;

@end
