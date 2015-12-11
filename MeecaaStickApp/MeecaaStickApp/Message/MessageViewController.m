//
//  MessageViewController.m
//  MeecaaStickApp
//
//  Created by SoulJa on 15/11/26.
//  Copyright © 2015年 SoulJa. All rights reserved.
//

#import "MessageViewController.h"
@interface MessageViewController () <UITableViewDataSource,UITableViewDelegate>
@end
@implementation MessageViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    //设置Nav
    [self setupNav];
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tabBarController.tabBar setHidden:YES];
}

/**
 *  设置Nav
 */
- (void)setupNav {
    [self.navigationController.navigationBar setBackgroundImage:[[GlobalTool shared] createImageWithColor:NAVIGATIONBAR_BACKGROUND_COLOR] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationItem.title = @"我的消息";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"message_back_icon"] style:UIBarButtonItemStyleDone target:self action:@selector(goBack)];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)goBack {
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"MessageCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    
    cell.textLabel.text = @"恭喜您，订单提交成功";
    [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"标题:订单通知";
}
@end
