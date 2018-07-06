//
//  SCNavTabBarController.m
//  SCNavTabBarController
//
//  Created by ShiCang on 14/11/17.
//  Copyright (c) 2014年 SCNavTabBarController. All rights reserved.
//

#import "SCNavTabBarController.h"
#import "CommonMacro.h"
#import "SCNavTabBar.h"

@interface SCNavTabBarController () <UIScrollViewDelegate, SCNavTabBarDelegate>
{
    NSInteger       _currentIndex;              // current page index
    NSMutableArray  *_titles;                   // array of children view controller's title
    
    SCNavTabBar     *_navTabBar;                // NavTabBar: press item on it to exchange view
    UIScrollView    *_mainView;                 // content view
}

@end

@implementation SCNavTabBarController

#pragma mark - Life Cycle
#pragma mark -

- (id)initWithCanPopAllItemMenu:(BOOL)can
{
    self = [super init];
    if (self)
    {
        _canPopAllItemMenu = can;
    }
    return self;
}

- (id)initWithSubViewControllers:(NSArray *)subViewControllers
{
    self = [super init];
    if (self)
    {
        _subViewControllers = subViewControllers;
    }
    return self;
}

- (id)initWithParentViewController:(UIViewController *)viewController
{
    self = [super init];
    if (self)
    {
        [self addParentController:viewController];
    }
    return self;
}

- (id)initWithSubViewControllers:(NSArray *)subControllers andParentViewController:(UIViewController *)viewController canPopAllItemMenu:(BOOL)can;
{
    self = [self initWithSubViewControllers:subControllers];
    
    _canPopAllItemMenu = can;
    [self addParentController:viewController];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initConfig];
    [self viewConfig];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods
#pragma mark -
- (void)initConfig
{
    // Iinitialize value
    _currentIndex = 1;
    _navTabBarColor = _navTabBarColor ? _navTabBarColor : NavTabbarColor;
    _navTabBarFont = _navTabBarFont ? _navTabBarFont : [UIFont systemFontOfSize:14.0f];
    
    // Load all title of children view controllers
    _titles = [[NSMutableArray alloc] initWithCapacity:_subViewControllers.count];
    for (UIViewController *viewController in _subViewControllers)
    {
        [_titles addObject:viewController.title];
    }
}

- (void)viewInit
{
    // Load NavTabBar and content view to show on window
    _navTabBar = [[SCNavTabBar alloc] initWithFrame:CGRectMake(DOT_COORDINATE, DOT_COORDINATE, SCREEN_WIDTH, NAV_TAB_BAR_HEIGHT) canPopAllItemMenu:_canPopAllItemMenu];
    _navTabBar.delegate = self;
    _navTabBar.backgroundColor = _navTabBarColor;
    _navTabBar.lineColor = _navTabBarLineColor;
    _navTabBar.itemTitles = _titles;
    _navTabBar.arrowImage = _navTabBarArrowImage;
    _navTabBar.titleFont = _navTabBarFont;
    [_navTabBar updateData];
    
    _mainView = [[UIScrollView alloc] initWithFrame:CGRectMake(DOT_COORDINATE, _navTabBar.frame.origin.y + _navTabBar.frame.size.height, SCREEN_WIDTH, SCREEN_HEIGHT - _navTabBar.frame.origin.y - _navTabBar.frame.size.height - STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT)];
    _mainView.delegate = self;
    _mainView.pagingEnabled = YES;
    _mainView.bounces = _mainViewBounces;
    _mainView.showsHorizontalScrollIndicator = NO;
    _mainView.contentSize = CGSizeMake(SCREEN_WIDTH * _subViewControllers.count, DOT_COORDINATE);
    [self.view addSubview:_mainView];
    [self.view addSubview:_navTabBar];
}

- (void)viewConfig
{
    [self viewInit];
    
    // Load children view controllers and add to content view
    [_subViewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        
        UIViewController *viewController = (UIViewController *)_subViewControllers[idx];
        viewController.view.frame = CGRectMake(idx * SCREEN_WIDTH, DOT_COORDINATE, SCREEN_WIDTH, _mainView.frame.size.height);
        [_mainView addSubview:viewController.view];
        [self addChildViewController:viewController];
    }];
}

#pragma mark - Public Methods
#pragma mark -
- (void)setNavTabBarLineColor:(UIColor *)navTabBarLineColor
{
    _navTabBarLineColor = navTabBarLineColor;
    _navTabBar.lineColor = navTabBarLineColor;
}

- (void)setNavTabbarColor:(UIColor *)navTabbarColor
{
    // prevent set [UIColor clear], because this set can take error display
    CGFloat red, green, blue, alpha;
    if ([navTabbarColor getRed:&red green:&green blue:&blue alpha:&alpha] && !red && !green && !blue && !alpha)
    {
        navTabbarColor = NavTabbarColor;
    }
    _navTabBarColor = navTabbarColor;
}

- (void)addParentController:(UIViewController *)viewController
{
    // Close UIScrollView characteristic on IOS7 and later
    if ([viewController respondsToSelector:@selector(edgesForExtendedLayout)])
    {
        viewController.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [viewController addChildViewController:self];
    [viewController.view addSubview:self.view];
}

#pragma mark - Scroll View Delegate Methods
#pragma mark -
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    _currentIndex = scrollView.contentOffset.x / SCREEN_WIDTH;
    _navTabBar.currentItemIndex = _currentIndex;
}

#pragma mark - SCNavTabBarDelegate Methods
#pragma mark -
- (void)itemDidSelectedWithIndex:(NSInteger)index
{
    [_mainView setContentOffset:CGPointMake(index * SCREEN_WIDTH, DOT_COORDINATE) animated:_scrollAnimation];
}

- (void)shouldPopNavgationItemMenu:(BOOL)pop height:(CGFloat)height
{
    if (pop)
    {
        [UIView animateWithDuration:0.5f animations:^{
            _navTabBar.frame = CGRectMake(_navTabBar.frame.origin.x, _navTabBar.frame.origin.y, _navTabBar.frame.size.width, SCREEN_HEIGHT - _navTabBar.frame.origin.y);
        }];
    }
    else
    {
        [UIView animateWithDuration:0.5f animations:^{
            _navTabBar.frame = CGRectMake(_navTabBar.frame.origin.x, _navTabBar.frame.origin.y, _navTabBar.frame.size.width, NAV_TAB_BAR_HEIGHT);
        }];
    }
    [_navTabBar refresh];
}

@end
