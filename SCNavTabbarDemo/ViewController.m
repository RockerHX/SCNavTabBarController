//
//  ViewController.m
//  SCNavTabBarControllerDemo
//
//  Created by ShiCang on 14/11/17.
//  Copyright (c) 2014年 SCNavTabBarControllerDemo. All rights reserved.
//

#import "ViewController.h"
#import "SCNavTabBarController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIViewController *oneViewController = [[UIViewController alloc] init];
    oneViewController.title = @"新闻";
    oneViewController.view.backgroundColor = [UIColor whiteColor];
    
    UIViewController *twoViewController = [[UIViewController alloc] init];
    twoViewController.title = @"体育";
    twoViewController.view.backgroundColor = [UIColor whiteColor];
    
    UIViewController *threeViewController = [[UIViewController alloc] init];
    threeViewController.title = @"娱乐八卦";
    threeViewController.view.backgroundColor = [UIColor whiteColor];
    
    UIViewController *fourViewController = [[UIViewController alloc] init];
    fourViewController.title = @"天府之国";
    fourViewController.view.backgroundColor = [UIColor whiteColor];
    
    UIViewController *fiveViewController = [[UIViewController alloc] init];
    fiveViewController.title = @"四川省";
    fiveViewController.view.backgroundColor = [UIColor whiteColor];
    
    UIViewController *sixViewController = [[UIViewController alloc] init];
    sixViewController.title = @"政治";
    sixViewController.view.backgroundColor = [UIColor whiteColor];
    
    UIViewController *sevenViewController = [[UIViewController alloc] init];
    sevenViewController.title = @"国际新闻";
    sevenViewController.view.backgroundColor = [UIColor whiteColor];
    
    UIViewController *eightViewController = [[UIViewController alloc] init];
    eightViewController.title = @"自媒体";
    eightViewController.view.backgroundColor = [UIColor whiteColor];
    
    UIViewController *ninghtViewController = [[UIViewController alloc] init];
    ninghtViewController.title = @"科技";
    ninghtViewController.view.backgroundColor = [UIColor whiteColor];

    NSArray *vcs  = @[oneViewController, twoViewController, threeViewController, fourViewController, fiveViewController, sixViewController, sevenViewController, eightViewController, ninghtViewController];
    
    SCNavTabBarController *navTabBarController = [[SCNavTabBarController alloc] initWithSubViewControllers:vcs];
    navTabBarController.navTabBarColor = [UIColor whiteColor];
    navTabBarController.navTabBarFont = [UIFont systemFontOfSize: 12];
//    navTabBarController.navTabBarColor = [UIColor colorWithRed:0.5 green:0.5 blue:1 alpha:1];
//    navTabBarController.navTabBarSelectedTextColor = [UIColor colorWithRed:0.8 green:0.5 blue:0.5 alpha:1];
//    navTabBarController.navTabBarTextFont = [UIFont systemFontOfSize: 20 ];
//    navTabBarController.navTabBarItemSpace = 40;
//    navTabBarController.navTabBarHeight = 50;
//    CGRect rect = [UIScreen mainScreen].bounds;
//    navTabBarController.navTabBarItemWidth = rect.size.width/3;
    navTabBarController.canPopAllItemMenu = YES;
    [navTabBarController addParentController: self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
