//
//  HistoryViewController.m
//  QRCodeScan
//
//  Created by wenyou on 2016/10/8.
//  Copyright © 2016年 wenyou. All rights reserved.
//

#import "HistoryViewController.h"

#import <Masonry/Masonry.h>
#import "HistoryDataCache.h"
#import "ScanViewController.h"
#import <AudioToolbox/AudioToolbox.h>

@interface HistoryViewController () <UITableViewDataSource, UITableViewDelegate>
@end


@implementation HistoryViewController {
    UITableView *_tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;             // scrollView遮挡
    self.navigationController.navigationBar.translucent = NO;   // navigation遮挡
    self.edgesForExtendedLayout = UIRectEdgeNone;               // tabBar遮挡
    
    self.navigationItem.rightBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, 32, 32);
        button.titleLabel.font = [TLIconfont fontOfSize:20];
        [button setTitle:@"\uf014" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(deleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        button;
    })];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [_tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[HistoryDataCache sharedInstance] getCacheValues].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:@""];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@""];
    }
    cell.textLabel.text = [[HistoryDataCache sharedInstance] getCacheValues][indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [[HistoryDataCache sharedInstance] deleteCacheValueAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [ScanViewController handleValue:[[HistoryDataCache sharedInstance] getCacheValues][indexPath.row] withViewController:self endBlock:nil];
}

#pragma mark - private
- (void)deleteButtonClicked:(id)sender {
    [self presentViewController:({
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"确认全部删除" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [controller addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [[HistoryDataCache sharedInstance] deleteAllCacheValue];
            [_tableView reloadData];
        }]];
        [controller addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        controller;
    }) animated:YES completion:nil];
}
@end
