//
//  RightMenuViewController.m
//  MeecaaStickApp
//
//  Created by SoulJa on 15/12/2.
//  Copyright © 2015年 SoulJa. All rights reserved.
//

#import "RightMenuViewController.h"
#import "UserNavigationController.h"
#import "UserUpdateViewController.h"
#import "MessageViewController.h"
#import "MessageNavigationController.h"

@interface RightMenuViewController ()
@property (nonatomic,strong) UIImageView *iconImageView;
@property (nonatomic,strong) UILabel *nicknameLabel;
@end

@implementation RightMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor grayColor]];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //设置头部
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 140)];
    //头像
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 40, 60, 60)];
    imageView.layer.cornerRadius = 30.0f;
    imageView.clipsToBounds = YES;
        [headerView addSubview:imageView];
    self.iconImageView = imageView;
    //昵称
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(90, 50, 100, 40);
    [label setTextColor:[UIColor whiteColor]];
    [headerView addSubview:label];
    self.nicknameLabel = label;
    
    self.tableView.tableHeaderView = headerView;
    
    //尾部
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 140)];
    UIButton *logoutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    logoutBtn.frame = CGRectMake(20, 50, 110, 40);
    [logoutBtn setTitle:@"退出登录" forState:UIControlStateNormal];
    [logoutBtn addTarget:self action:@selector(onClickLogout) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:logoutBtn];
    self.tableView.tableFooterView = footerView;
}

/**
 *  退出登录
 */
- (void)onClickLogout {
    [self.mm_drawerController closeDrawerAnimated:YES completion:nil];
    [[DatabaseTool shared] emptyDataBase];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"First" bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    [self presentViewController:vc animated:NO completion:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //获取默认成员头像
    if ([[DatabaseTool shared] getDefaultMember]) {
        self.nicknameLabel.text = [[[DatabaseTool shared] getDefaultMember] objectForKey:@"name"];
        if (![[[[DatabaseTool shared] getDefaultMember] objectForKey:@"avatar"] isEqualToString:@""]) {
            [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:[[[DatabaseTool shared] getDefaultMember] objectForKey:@"avatar"]] placeholderImage:[UIImage imageNamed:@"home_member_icon"]];
        } else {
            [self.iconImageView setImage:[UIImage imageNamed:@"home_member_icon"]];
        }
    } else {
        [self.iconImageView setImage:[UIImage imageNamed:@"home_member_icon"]];
        self.nicknameLabel.text = @"未登录";
    }

}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identity = @"RightMenuCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identity];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identity];
    }
    
    NSArray *titles = @[@"我的信息",@"家庭成员",@"问题反馈",@"我的消息"];
    cell.textLabel.text = titles[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.mm_drawerController closeDrawerAnimated:YES completion:nil];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Third" bundle:nil];
    if (indexPath.row == 0) {
        if (![[DatabaseTool shared] getDefaultMember]) {
            UIStoryboard *board = [UIStoryboard storyboardWithName:@"First" bundle:nil];
            UIViewController *loginVc = [board instantiateViewControllerWithIdentifier:@"LoginViewController"];
            [self presentViewController:loginVc animated:NO completion:^{
                [SVProgressHUD showErrorWithStatus:@"请您先登录!"];
            }];
        } else {
            UserUpdateViewController *userUpdateVc = [storyboard instantiateViewControllerWithIdentifier:@"UserUpdateViewController"];
            userUpdateVc.memberInfoDict = [[DatabaseTool shared] getDefaultMember];
            userUpdateVc.isFromMain = YES;
            UserNavigationController *userNav = [[UserNavigationController alloc] initWithRootViewController:userUpdateVc];
            [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
            [self presentViewController:userNav animated:NO completion:nil];
        }
        
    } else if (indexPath.row == 1) {
        if (![[DatabaseTool shared] getDefaultMember]) {
            UIStoryboard *board = [UIStoryboard storyboardWithName:@"First" bundle:nil];
            UIViewController *loginVc = [board instantiateViewControllerWithIdentifier:@"LoginViewController"];
            [self presentViewController:loginVc animated:NO completion:^{
                [SVProgressHUD showErrorWithStatus:@"请您先登录!"];
            }];
        } else {
            UserNavigationController *userNav = [storyboard instantiateViewControllerWithIdentifier:@"UserNavigationController"];
            [self presentViewController:userNav animated:NO completion:nil];
        }
    } else if (indexPath.row == 2) {
        UIStoryboard *board = [UIStoryboard storyboardWithName:@"First" bundle:nil];
        UIViewController *vc = [board instantiateViewControllerWithIdentifier:@"ProblemNavigationController"];
        [self presentViewController:vc animated:NO completion:nil];
    } else if (indexPath.row == 3) {
        if (![[DatabaseTool shared] getDefaultMember]) {
            UIStoryboard *board = [UIStoryboard storyboardWithName:@"First" bundle:nil];
            UIViewController *loginVc = [board instantiateViewControllerWithIdentifier:@"LoginViewController"];
            [self presentViewController:loginVc animated:NO completion:^{
                [SVProgressHUD showErrorWithStatus:@"请您先登录!"];
            }];
        } else {
            MessageViewController *messageVc = [[MessageViewController alloc] init];
            MessageNavigationController *nav = [[MessageNavigationController alloc] initWithRootViewController:messageVc];
            [self presentViewController:nav animated:NO completion:nil];
        }
    }
    
}

@end
