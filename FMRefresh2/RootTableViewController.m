//
//  RootTableViewController.m
//  FMRefresh
//
//  Created by qianjn on 2016/10/27.
//  Copyright © 2016年 SF. All rights reserved.
//

#import "RootTableViewController.h"

#import "FMrefreshControl.h"
#import "FMRefreshfoot.h"
@interface RootTableViewController ()
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) FMRefreshControl *refreshCon;
@property (nonatomic, strong) FMRefreshfoot *foot;
@end

@implementation RootTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataArr = [NSMutableArray new];
    [self loadData];
    [self.tableView reloadData];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.refreshCon = [[FMRefreshControl alloc] initWithTargrt:self refreshAction:@selector(dorefresh)];
    self.foot = [[FMRefreshfoot alloc] initWithTargrt:self refreshAction:@selector(doAppendData)];
    [self.tableView addSubview:_refreshCon];
    [self.tableView addSubview:_foot];
}

- (void)dorefresh
{
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self loadData];
        [self.tableView reloadData];
        [self.refreshCon endRefreshing];
    });
}

- (void)doAppendData
{
    [self appendData];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        if (self.dataArr.count > 30) {
            [self.foot endRefreshingWithNoMoreData];
        } else {
            [self.foot endRefreshing];
        }
        
    });
}
- (void)loadData
{
    [self.dataArr removeAllObjects];
    for (int i = 0; i < 15; i++) {
        [self.dataArr addObject:@"测试数据"];
    }
}


- (void)refresh{

    [self.refreshCon beginRefreshing];
    [self loadData];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self.refreshCon endRefreshing];

    });

}

- (void)appendData
{
    for (int i = 0; i < 10; i++) {
        [self.dataArr addObject:@"append"];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.dataArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cellID"];
        cell.contentView.backgroundColor = [UIColor grayColor];
    }
    cell.textLabel.text = self.dataArr[indexPath.row];
    
    return cell;
}




@end
