//
//  SCNavTabBarController.h
//  SCNavTabBarController
//
//  Created by ShiCang on 14/11/17.
//  Copyright (c) 2014年 SCNavTabBarController. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SCNavTabBar;

@interface SCNavTabBarController : UIViewController

@property (nonatomic, assign)   BOOL        canPopAllItemMenu;          // Default value: YES
@property (nonatomic, assign)   BOOL        scrollAnimation;            // Default value: NO
@property (nonatomic, assign)   BOOL        mainViewBounces;            // Default value: NO

@property (nonatomic, strong)   NSArray     *subViewControllers;        // An array of children view controllers

@property (nonatomic, strong)   UIColor     *navTabBarColor;            // Could not set [UIColor clear], if you set, NavTabbar will show initialize color
@property (nonatomic, strong)   UIFont      *navTabBarFont;             // tabbar text font
@property (nonatomic, strong)   UIColor     *navTabBarLineColor;
@property (nonatomic, strong)   UIImage     *navTabBarArrowImage;

/**
 *  Initialize Methods
 *
 *  @param show - can pop all item menu
 *
 *  @return Instance
 */
- (id)initWithCanPopAllItemMenu:(BOOL)can;

/**
 *  Initialize SCNavTabBarViewController Instance And Show Children View Controllers
 *
 *  @param subViewControllers - set an array of children view controllers
 *
 *  @return Instance
 */
- (id)initWithSubViewControllers:(NSArray *)subViewControllers;

/**
 *  Initialize SCNavTabBarViewController Instance And Show On The Parent View Controller
 *
 *  @param viewController - set parent view controller
 *
 *  @return Instance
 */
- (id)initWithParentViewController:(UIViewController *)viewController;

/**
 *  Initialize SCNavTabBarViewController Instance, Show On The Parent View Controller And Show On The Parent View Controller
 *
 *  @param subControllers - set an array of children view controllers
 *  @param viewController - set parent view controller
 *  @param can            - can pop all item menu
 *
 *  @return Instance
 */
- (id)initWithSubViewControllers:(NSArray *)subControllers andParentViewController:(UIViewController *)viewController canPopAllItemMenu:(BOOL)can;

/**
 *  Show On The Parent View Controller
 *
 *  @param viewController - set parent view controller
 */
- (void)addParentController:(UIViewController *)viewController;

@end
