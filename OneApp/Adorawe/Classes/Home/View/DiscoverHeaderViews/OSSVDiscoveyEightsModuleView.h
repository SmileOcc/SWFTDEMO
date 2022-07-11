//
//  STLDiscoveryEightModuleView.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/8.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//  八分管或者16分管
/**
 *  顶部图片
 *     +
 *  8张长方形 4/3比例
 *     +
 *  如果大于16有一个按钮《按钮是整张图片做的》
 *
 */

#import "OSSVHomeeModulesView.h"

#define EightCellWidth ((SCREEN_WIDTH / 4.0))
#define EightCellScale (238.0/188.0)  //由UI给的比例
#define EightModuleContentHeight (floor(EightCellWidth * EightCellScale) * 2)
#define kDiscoveryEightModuleHeight      (45 * DSCREEN_WIDTH_SCALE + EightModuleContentHeight + 10)
#define kDiscoverySixteenModuleHeight    (45 * DSCREEN_WIDTH_SCALE * 2 + EightModuleContentHeight + 10)

@interface OSSVDiscoveyEightsModuleView : OSSVHomeeModulesView

@end
