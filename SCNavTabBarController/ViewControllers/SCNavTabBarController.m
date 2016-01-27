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
        [self initConfig];
        _canPopAllItemMenu = can;
    }
    return self;
}

- (id)initWithSubViewControllers:(NSArray *)subViewControllers
{
    self = [super init];
    if (self)
    {
        [self initConfig];
        _subViewControllers = subViewControllers;
    }
    return self;
}

- (id)initWithParentViewController:(UIViewController *)viewController {
    return [self initWithParentViewController:viewController containerView:viewController.view];
}

- (id)initWithParentViewController:(UIViewController *)viewController containerView:(UIView *)containerView
{
    self = [super init];
    if (self)
    {
        [self initConfig];
        [self addParentController:viewController containerView:containerView];
    }
    return self;
}

- (id)initWithSubViewControllers:(NSArray *)subControllers andParentViewController:(UIViewController *)viewController canPopAllItemMenu:(BOOL)can
{
    return [self initWithSubViewControllers:subControllers andParentViewController:viewController containerView:viewController.view canPopAllItemMenu:can ];
}

- (id)initWithSubViewControllers:(NSArray *)subControllers andParentViewController:(UIViewController *)viewController containerView:(UIView *)containerView canPopAllItemMenu:(BOOL)can
{
    self = [self initWithSubViewControllers:subControllers];
    
    [self initConfig];
    _canPopAllItemMenu = can;
    [self addParentController:viewController containerView:containerView];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Load all title of children view controllers
    [self loadChildTitles];

    // Do any additional setup after loading the view.
    [self viewConfig];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    // Gevin added : 2015-10-06
    //  case:
    //  假設 SCNavTabbarController 有三個 tab，目前顯示第二個 tab
    //  接著，進入下一個 controller，之後再回到 SCNavTabbarController
    //  這時，SCNavTabbarController 的 tab 仍然會停在第二個 tab，但是顯示內容卻是第一個 tab 的內容
    //  
    //  原因：
    //  _mainView(UIScrollView) 的 offset 在 viewDidLayoutSubviews 時被重置為 0 了
    //  但是上方 tab button 的 focus 還是在第二頁，找不到原因，所以多這個修正
    [_mainView setContentOffset:(CGPoint){ _currentIndex * SCREEN_WIDTH, 0 }];
//    NSLog(@"1 main view offset %@", NSStringFromCGPoint( _mainView.contentOffset ) );
}

//- (void)viewWillLayoutSubviews{
//    [super viewWillLayoutSubviews];
//    NSLog(@"1a main view offset %@", NSStringFromCGPoint( _mainView.contentOffset ) );
//}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    // Gevin added 2015-07-28 處理 _mainView.contentOffset 的問題，可能是因為 autolayout 的關係，在 viewDidLayoutSubviews 之後，先前的設定都會被重置
    [self itemDidSelectedWithIndex: _currentIndex ];
//    NSLog(@"1b main view offset %@", NSStringFromCGPoint( _mainView.contentOffset ) );
}

#pragma mark - Private Methods
#pragma mark -

//  config property default value
- (void)initConfig
{
    // Iinitialize value
    _currentIndex = 0;
    _navTabBarColor = _navTabBarColor ? _navTabBarColor : NavTabbarColor;
    
    // Gevin added
    _dragToSwitchView = YES;
    _showShadow = NO;
    _canPopAllItemMenu = NO;
    
    _navTabBarTextColor = [UIColor darkGrayColor];
    _navTabBarSelectedTextColor = [UIColor darkGrayColor];
    
}

//  load child controller title
- (void)loadChildTitles
{
    // Load all title of children view controllers
    _titles = [[NSMutableArray alloc] initWithCapacity:_subViewControllers.count];
    for (UIViewController *viewController in _subViewControllers)
    {
        if( viewController.title == nil ) NSLog(@"error!! controller title is nil.");
        [_titles addObject:viewController.title];
    }
}

//  init content view and config
- (void)viewConfig
{
    // view init
    // Load NavTabBar and content view to show on window
    _navTabBar = [[SCNavTabBar alloc] initWithFrame:CGRectMake(DOT_COORDINATE, DOT_COORDINATE, SCREEN_WIDTH, NAV_TAB_BAR_HEIGHT) canPopAllItemMenu:_canPopAllItemMenu];
    _navTabBar.delegate = self;
    _navTabBar.naviColor = _navTabBarColor;
    _navTabBar.lineColor = _navTabBarLineColor;
    _navTabBar.itemTitles = _titles;
    _navTabBar.textFont = _navTabBarTextFont;
    _navTabBar.textColor = _navTabBarTextColor;
    _navTabBar.selectedTextColor = _navTabBarSelectedTextColor;
    _navTabBar.arrowImage = _navTabBarArrowImage;
    _navTabBar.showShadow = _showShadow; // Gevin added
    [_navTabBar updateData];
    
    _mainView = [[UIScrollView alloc] initWithFrame:CGRectMake(DOT_COORDINATE, _navTabBar.frame.origin.y + _navTabBar.frame.size.height, SCREEN_WIDTH, SCREEN_HEIGHT - _navTabBar.frame.origin.y - _navTabBar.frame.size.height - STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT)];
    _mainView.delegate = self;
    _mainView.pagingEnabled = YES;
    _mainView.bounces = _mainViewBounces;
    _mainView.showsHorizontalScrollIndicator = NO;
    
    // 2015-03-09 Gevin Added
    int cnt = 1;
    if ( _dragToSwitchView ) {
        cnt = (int)_subViewControllers.count;
    }
    _mainView.contentSize = CGSizeMake(SCREEN_WIDTH * cnt , DOT_COORDINATE);
    [self.view addSubview:_mainView];
    [self.view addSubview:_navTabBar];
    
    //Gevin added for autolayout
    _navTabBar.translatesAutoresizingMaskIntoConstraints = NO;
    _mainView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_navTabBar]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_navTabBar)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_mainView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_mainView)]];
    NSString* statement = [NSString stringWithFormat:@"V:|[_navTabBar(%f)][_mainView]|",NAVIGATION_BAR_HEIGHT];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:statement options:0 metrics:nil views:NSDictionaryOfVariableBindings(_navTabBar,_mainView)]];
    
    // Load children view controllers and add to content view
    [_subViewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        
        UIViewController *viewController = (UIViewController *)_subViewControllers[idx];
        viewController.view.frame = CGRectMake(idx * SCREEN_WIDTH, DOT_COORDINATE, SCREEN_WIDTH, _mainView.frame.size.height);
        [_mainView addSubview:viewController.view];
        [self addChildViewController:viewController];
        
        // gevin added trigger autolayout of viewController.view
        [viewController.view layoutIfNeeded];
        viewController.view.frame = CGRectMake(idx * SCREEN_WIDTH, DOT_COORDINATE, SCREEN_WIDTH, _mainView.frame.size.height);
        
    }];
}

#pragma mark - Public Methods
#pragma mark -

- (void)setNavTabBarLineHeight:(float)navTabBarLineHeight{
    _navTabBarLineHeight = navTabBarLineHeight;
    _navTabBar.lineHeight = _navTabBarLineHeight;
}

- (void)setShowShadow:(BOOL)showShadow{
    _showShadow = showShadow;
    if( _navTabBar ) _navTabBar.showShadow = showShadow;
}

- (void)setNavTabBarColor:(UIColor *)navTabBarColor
{
    // prevent set [UIColor clear], because this set can take error display
    CGFloat red, green, blue, alpha;
    if ([navTabBarColor getRed:&red green:&green blue:&blue alpha:&alpha] && !red && !green && !blue && !alpha)
    {
        navTabBarColor = NavTabbarColor;
    }
    _navTabBarColor = navTabBarColor;
    if(_navTabBar)_navTabBar.naviColor = _navTabBarColor;
}

- (void)setNavTabBarLineColor:(UIColor *)navTabBarLineColor{
    _navTabBarLineColor = navTabBarLineColor;
    if(_navTabBar)_navTabBar.lineColor = navTabBarLineColor;
}

- (void)setNavTabBarTextColor:(UIColor *)navTabBarTextColor{
    _navTabBarTextColor = navTabBarTextColor;
    if(_navTabBar)_navTabBar.textColor = _navTabBarTextColor;
}

- (void)setNavTabBarSelectedTextColor:(UIColor *)navTabBarSelectedTextColor
{
    _navTabBarSelectedTextColor = navTabBarSelectedTextColor;
    if(_navTabBar)_navTabBar.selectedTextColor = _navTabBarSelectedTextColor;
}

- (void)setNavTabBarTextFont:(UIFont *)navTabBarTextFont
{
    _navTabBarTextFont = navTabBarTextFont;
    if ( _navTabBarTextFont ) {
        _navTabBar.textFont = _navTabBarTextFont;
    }
}

// modify by Gevin ，多一個 container view，因為有可能不是要滿版的，containerView 必須要是 viewController 的
- (void)addParentController:(UIViewController *)viewController
{
    [self addParentController:viewController containerView:viewController.view];
}

- (void)addParentController:(UIViewController *)viewController containerView:(UIView*)containerView
{
    _containerView = containerView;
    // Gevin modify: 如果加這行，會把 SCNavTabBarController 的 parent Controller 的 view 下移
    // Close UIScrollView characteristic on IOS7 and later
    if ( _containerView == viewController.view && [viewController respondsToSelector:@selector(edgesForExtendedLayout)])
    {
        viewController.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [viewController addChildViewController:self];
    [_containerView addSubview:self.view];
    
    // Gevin added for autolayout
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    UIView* view = self.view;
    [_containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(view)]];
    [_containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(view)]];

}

// 2015-03-09 Gevin Added
- (void)setDragToSwitchView:(BOOL)dragToSwitchView
{
    _dragToSwitchView = dragToSwitchView;
    
    int cnt = 1;
    if ( _dragToSwitchView ) {
        cnt = (int)_subViewControllers.count;
    }
    _mainView.contentSize = CGSizeMake(SCREEN_WIDTH * cnt , DOT_COORDINATE);
    
}

#pragma mark - Scroll View Delegate Methods
#pragma mark -

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    _currentIndex = scrollView.contentOffset.x / SCREEN_WIDTH;
//    NSLog(@"SCNavTabBarController .... scrollView did scroll");
//}

#pragma mark - SCNavTabBarDelegate Methods
#pragma mark -
- (void)itemDidSelectedWithIndex:(NSInteger)index
{
    // 2015-03-13 Gevin Added，切換 sub controller 要呼叫相映method
//    UIViewController *vc = _subViewControllers[index];
//    [vc viewWillAppear:YES];
    [_mainView setContentOffset:CGPointMake(index * SCREEN_WIDTH, DOT_COORDINATE) animated:_scrollAnimation];
//    [vc viewDidAppear:YES];
    _currentIndex = index;
    _navTabBar.currentItemIndex = index;

}

- (void)shouldPopNavgationItemMenu:(BOOL)pop height:(CGFloat)height
{
    if (pop)
    {
        [UIView animateWithDuration:0.5f animations:^{
            _navTabBar.frame = CGRectMake(_navTabBar.frame.origin.x, _navTabBar.frame.origin.y, _navTabBar.frame.size.width, height + NAV_TAB_BAR_HEIGHT);
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

// Gevin Added
- (NSInteger)getCurrentIndex
{
    return _currentIndex;
}

@end
