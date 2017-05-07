//
//  FMRefreshHeader.h
//  FMRefresh2
//
//  Created by qianjn on 2017/5/7.
//  Copyright © 2017年 SF. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *FM_Refresh_normal_title  = @"正常状态";
static NSString *FM_Refresh_pulling_title  = @"释放刷新状态";
static NSString *FM_Refresh_Refreshing_title  = @"正在刷新";

@interface FMRefreshHeader : UIRefreshControl

- (instancetype)initWithTargrt:(id)target refreshAction:(SEL)refreshAction;
- (void)endRefreshing;

@end
