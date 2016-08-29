//
//  SCNavTabBarController.h
//  SCNavTabBarController
//
//  Created by ShiCang on 14/11/17.
//  Copyright (c) 2014年 SCNavTabBarController. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SCNavTabBar;

@protocol SCNavTabBarControllerDelegate <NSObject>

- (void)viewController:(UIViewController*)controller didSelectedTabIndex:(NSInteger)index;

@end


@interface SCNavTabBarController : UIViewController

@property (nonatomic, assign)   BOOL        canPopAllItemMenu;          // Default value: YES
@property (nonatomic, assign)   BOOL        scrollAnimation;            // Default value: NO
@property (nonatomic, assign)   BOOL        mainViewBounces;            // Default value: NO
@property (nonatomic, assign)   BOOL        dragToSwitchView;           // Default value: YES // 2015-03-09 Gevin Added

@property (nonatomic, strong)   NSArray     *subViewControllers;        // An array of children view controllers

@property (nonatomic, strong)   UIColor     *navTabBarColor;            // Could not set [UIColor clear], if you set, NavTabbar will show initialize color
@property (nonatomic, strong)   UIColor     *navTabBarLineColor;
@property (nonatomic, strong)   UIImage     *navTabBarArrowImage;
@property (nonatomic, assign)   UIView      *containerView;
@property (nonatomic, strong)   UIFont      *navTabBarTextFont;         // Gevin added
@property (nonatomic, strong)   UIColor     *navTabBarTextColor;        // Gevin added
@property (nonatomic, strong)   UIColor     *navTabBarSelectedTextColor;// Gevin added
@property (nonatomic)           BOOL        showShadow;                 // Gevin added
@property (nonatomic)           float       navTabBarLineHeight;        // Gevin added
@property (nonatomic)           float       navTabBarItemSpace;         // Gevin added
@property (nonatomic)           float       navTabBarHeight;            // Gevin added
@property (nonatomic)           float       navTabBarItemWidth;         // Gevin added, default 0, if value is 0, the item width auto calculate 
@property (nonatomic)           id<SCNavTabBarControllerDelegate> delegate;                   // Gevin added

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
- (id)initWithParentViewController:(UIViewController *)viewController containerView:(UIView*)containerView;

/**
 *  Initialize SCNavTabBarViewController Instance, Show On The Parent View Controller And Show On The Parent View Controller
 *
 *  @param subControllers - set an array of children view controllers
 *  @param viewController - set parent view controller
 *  @param can            - can pop all item menu
 *  @param containerView  - set view to display content of child view controllers // Add by Gevin
 *
 *  @return Instance
 */
- (id)initWithSubViewControllers:(NSArray *)subControllers andParentViewController:(UIViewController *)viewController canPopAllItemMenu:(BOOL)can;
- (id)initWithSubViewControllers:(NSArray *)subControllers andParentViewController:(UIViewController *)viewController containerView:(UIView*)containerView canPopAllItemMenu:(BOOL)can;

/**
 *  Show On The Parent View Controller
 *
 *  @param viewController - set parent view controller
 */
- (void)addParentController:(UIViewController *)viewController;

- (void)addParentController:(UIViewController *)viewController containerView:(UIView*)containerView;

/**
 *  Show specify index of child view controller
 *
 *  @param index - set container view display index of child view controller
 */
- (void)itemDidSelectedWithIndex:(NSInteger)index;

// Gevin Added
- (NSInteger)getCurrentIndex;

@end
