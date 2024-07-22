//
//  ZFAccountCell.h
//  ZZZZZ
//
//  Created by YW on 2018/3/16.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kCellImageKey            @"kCellImageKey"
#define kCellShowIconDotKey      @"kCellShowIconDotKey"
#define kCellTextKey             @"kCellTextKey"
#define kCellShowTitleBageKey    @"kCellShowTitleBageKey"
#define kCellSubTextKey          @"kCellSubTextKey"
#define kCellTagetVCNameKey      @"kCellTagetVCNameKey"

@interface ZFAccountCell : UITableViewCell

@property (nonatomic, strong) NSDictionary *cellDataDic;

@end
