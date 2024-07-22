//
//  ZFCollectionPostsMenuView.m
//  ZZZZZ
//
//  Created by YW on 2019/6/11.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCollectionPostsMenuView.h"

#import "ZFThemeManager.h"
#import "SystemConfigUtils.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "ZFLocalizationString.h"

@interface ZFCollectionPostsMenuView()

@property (nonatomic, strong) UISegmentedControl    *segmentControl;
@property (nonatomic, strong) NSArray               *titleWidthArray;
@end


@implementation ZFCollectionPostsMenuView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _selectIndex = 0;
        self.titleWidthArray = [NSArray arrayWithObjects:ZFLocalizedString(@"MyStylePage_SubVC_Shows", nil),ZFLocalizedString(@"Community_Tab_Title_Outfits", nil),nil];
        
        self.segmentControl = [[UISegmentedControl alloc] initWithItems:self.titleWidthArray];
        self.segmentControl.layer.masksToBounds = YES;
        self.segmentControl.layer.cornerRadius = 4;
        self.segmentControl.layer.borderWidth = 1.5;
        self.segmentControl.layer.borderColor = ZFC0xF1F1F1().CGColor;
        self.segmentControl.selectedSegmentIndex = 0;
        self.segmentControl.tintColor = ZFC0xFFFFFF();
        self.segmentControl.backgroundColor = ZFC0xF1F1F1();

        [self.segmentControl setTitleTextAttributes:@{NSForegroundColorAttributeName:ZFC0x2D2D2D(),NSFontAttributeName:[UIFont systemFontOfSize:14.0f]}forState:UIControlStateSelected];
        
        [self.segmentControl setTitleTextAttributes:@{NSForegroundColorAttributeName:ZFC0x999999(),NSFontAttributeName:[UIFont systemFontOfSize:14.0f]}forState:UIControlStateNormal];
        [self.segmentControl addTarget:self action:@selector(actionChange:) forControlEvents:UIControlEventValueChanged];
        

        [self addSubview:self.segmentControl];

        [self.segmentControl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.mas_centerX);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(260, 32));
        }];
    }
    return self;
}

- (void)actionChange:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex != _selectIndex) {
        _selectIndex = sender.selectedSegmentIndex;
        if (self.indexBlock) {
            self.indexBlock(_selectIndex);
        }
    }
}
#pragma mark - setter/getter

- (void)setSelectIndex:(NSInteger)selectIndex {
    if (_selectIndex != selectIndex) {
        _selectIndex = selectIndex;
        if (self.indexBlock) {
            self.indexBlock(_selectIndex);
        }
        self.segmentControl.selectedSegmentIndex = selectIndex;
    }
}

- (NSArray *)titleWidthArray {
    if (!_titleWidthArray) {
        _titleWidthArray = [[NSArray alloc] init];
    }
    return _titleWidthArray;
}

@end
