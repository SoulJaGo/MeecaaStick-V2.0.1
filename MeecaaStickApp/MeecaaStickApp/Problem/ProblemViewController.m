//
//  ProblemViewController.m
//  MeecaaStickApp
//
//  Created by SoulJa on 15/12/3.
//  Copyright © 2015年 SoulJa. All rights reserved.
//

#import "ProblemViewController.h"

@interface ProblemViewController () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (nonatomic,strong) UILabel *placeholderLabel;
@end

@implementation ProblemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置Nav
    [self setupNav];
    
    [self.view setBackgroundColor:UIVIEW_BACKGROUND_COLOR];
    self.modalPresentationCapturesStatusBarAppearance = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.textView.delegate = self;
    
    UILabel *placeholderLabel = [[UILabel alloc] init];
    placeholderLabel.frame = CGRectMake(0, 0, self.textView.bounds.size.width, 40);
    placeholderLabel.text = @"请输入你的问题，谢谢!";
    self.placeholderLabel = placeholderLabel;
    [self.textView addSubview:placeholderLabel];
}

/**
 *  设置Nav
 */
- (void)setupNav {
    [self.navigationController.navigationBar setBackgroundImage:[[GlobalTool shared] createImageWithColor:NAVIGATIONBAR_BACKGROUND_COLOR] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationItem.title = @"问题反馈";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"message_back_icon"] style:UIBarButtonItemStyleDone target:self action:@selector(goBack)];
}

- (void)goBack {
    [self dismissViewControllerAnimated:NO completion:nil];
}


#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    self.placeholderLabel.hidden = YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (textView.text.length == 0) {
        self.placeholderLabel.hidden = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
