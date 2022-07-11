//
//  OSSVAccounteMyeOrderseHeadereView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/7.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVAccounteMyeOrderseHeadereView.h"

@interface OSSVAccounteMyeOrderseHeadereView ()
@property (nonatomic,weak) UIButton *rosegalOrderBtn;
@end

@implementation OSSVAccounteMyeOrderseHeadereView

+ (OSSVAccounteMyeOrderseHeadereView *)accountMyOrdersHeaderViewWithTableView:(UITableView *)tableView {
    [tableView registerClass:[OSSVAccounteMyeOrderseHeadereView class] forHeaderFooterViewReuseIdentifier:NSStringFromClass(OSSVAccounteMyeOrderseHeadereView.class)];
    return [tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass(OSSVAccounteMyeOrderseHeadereView.class)];
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        __weak typeof(self.contentView) ws = self.contentView;
        ws.backgroundColor = [UIColor clearColor];
        
        
        
    }
    return self;
}

@end
