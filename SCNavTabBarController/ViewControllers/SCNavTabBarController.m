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
    
    NSLayoutConstraint *_constraintNavTabBarHeight;
    
    BOOL runDrag;
    CGPoint dragStartPoint;
    NSInteger nextIndex;
    int preOffsetVector;
}

@end

@implementation SCNavTabBarController

#pragma mark - Life Cycle
#pragma mark -

- (id)initWithCanPopAllItemMenu:(BOOL)can
{
    self = [super init];
    if (self){
        [self initConfig];
        _canPopAllItemMenu = can;
    }
    return self;
}

- (id)initWithSubViewControllers:(NSArray *)subViewControllers
{
    self = [super init];
    if (self){
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
    if (self){
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
    _navTabBarTextFont = [UIFont systemFontOfSize:17];
    _navTabBarTextColor = [UIColor darkGrayColor];
    _navTabBarHeight = 60;
}

//  load child controller title
- (void)loadChildTitles
{
    // Load all title of children view controllers
    _titles = [[NSMutableArray alloc] initWithCapacity:_subViewControllers.count];
    for (UIViewController *viewController in _subViewControllers){
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
    _navTabBar.textColor = _navTabBarTextColor;
    _navTabBar.itemTitles = _titles;
    _navTabBar.arrowImage = _navTabBarArrowImage;
    [_navTabBar updateItemLayout];
    
    _mainView = [[UIScrollView alloc] initWithFrame:CGRectMake(DOT_COORDINATE, _navTabBar.frame.origin.y + _navTabBar.frame.size.height, SCREEN_WIDTH, SCREEN_HEIGHT - _navTabBar.frame.origin.y - _navTabBar.frame.size.height - STATUS_BAR_HEIGHT - _navTabBar.barHeight )];
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
    UIView *emptyView = [[UIView alloc] init];
    [self.view addSubview:emptyView]; // for self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:_mainView];
    [self.view addSubview:_navTabBar];
    
    //Gevin added for autolayout
    _navTabBar.translatesAutoresizingMaskIntoConstraints = NO;
    _mainView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_navTabBar]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_navTabBar)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_mainView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_mainView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_navTabBar][_mainView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_navTabBar,_mainView)]];
    _constraintNavTabBarHeight = [NSLayoutConstraint constraintWithItem:_navTabBar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant: _navTabBarHeight ];
    [self.view addConstraint: _constraintNavTabBarHeight ];
    
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
    if ([navTabBarColor getRed:&red green:&green blue:&blue alpha:&alpha] && !red && !green && !blue && !alpha){
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

- (void)setNavTabBarItemSpace:(float)navTabBarItemSpace
{
    _navTabBarItemSpace = navTabBarItemSpace;
    if ( _navTabBarItemSpace > -1 ) {
        _navTabBar.itemSpace = _navTabBarItemSpace;
    }
}

- (void)setNavTabBarHeight:(float)navTabBarHeight
{
    _navTabBarHeight = navTabBarHeight;
    if ( _navTabBarHeight < ( [_navTabBar.textFont pointSize] + 10 ) ) {
        _navTabBarHeight = [_navTabBar.textFont pointSize] + 10;
    }
    _navTabBar.barHeight = _navTabBarHeight;
    _constraintNavTabBarHeight.constant = _navTabBarHeight;
}

- (void)setNavTabBarItemWidth:(float)navTabBarItemWidth
{
    _navTabBarItemWidth = navTabBarItemWidth;
    _navTabBar.itemWidth = _navTabBarItemWidth;
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
    if ( _containerView == viewController.view && [viewController respondsToSelector:@selector(edgesForExtendedLayout)]){
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


// called on start of dragging (may require some time and or distance to move)
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    runDrag = YES;
    dragStartPoint = scrollView.contentOffset;
    preOffsetVector = 0;
//    NSLog(@"dragStartPoint %@", NSStringFromCGPoint( dragStartPoint));
    //  如果還在跑動畫，就停止
    if ( [_navTabBar isFocusBarAnimated] ) {
        [_navTabBar stopFocusBarAnimation];
    }
}

//  拖曳中呼叫
//  注意：即使手放開了，scroll view 還是會自動拖到定位，這期間還是會呼叫這個 function，並不是你手指 touch 拖曳才會呼叫
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ( runDrag ) {
    
        NSInteger index = dragStartPoint.x / SCREEN_WIDTH;
        
        //  計算偏移量
        float offset = scrollView.contentOffset.x - dragStartPoint.x;
        //  計算偏移方向
        int offsetVector = (int)(offset / fabsf(offset));
        
        //  依偏移方向，決定要移去的目標
        //  move right
        if ( offsetVector > 0 ) {
            if ( index >= _navTabBar.itemTitles.count - 1) {
                return;
            }
            nextIndex = index + 1;
        }
        //  move left
        else{
            if ( index <= 0 ) {
                return;
            }
            nextIndex = index - 1;
            
        }
        
        //  如果原本的偏移方向不一樣，那動畫的方向就要變
        if ( preOffsetVector == 0 || preOffsetVector != offsetVector ) {
            preOffsetVector = offsetVector;
            //  duration 用 0.3秒，是因為目測後，最接近 scrollView 自動捲動的動畫的速度
            [_navTabBar setFocusBarAnimationToIndex:nextIndex duratioin:0.3f];
//            NSLog(@"start !!");
        }
        
        //  設定時間偏移量
        float t = fabsf( offset / SCREEN_WIDTH );
//        NSLog(@"offset:%f, index:%ld nextIndex:%ld, preVector:%d, t:%f",offset, index, (long)nextIndex, preOffsetVector, t );
        [_navTabBar setFocusBarTimeOffset: t ];
        
        //    NSLog(@"offset x %f , index %ld", _mainView.contentOffset.x, index);
        //    if ( index != _currentIndex ) {
        //        _currentIndex = index;
        //        _navTabBar.currentItemIndex = index;
        //    }

    }
}

//  手放開時呼叫
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    
    runDrag = NO;
    NSInteger targetIndex = targetContentOffset->x / SCREEN_WIDTH;
    float t = 0.3f * ( fabsf( scrollView.contentOffset.x - targetContentOffset->x ) / SCREEN_WIDTH );
    [_navTabBar setFocusBarAnimationToIndex:targetIndex duratioin:t];
    [_navTabBar startFocusBarAnimation];
}


//  停止滑動時呼叫
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
//    runDrag = NO;
//    NSLog(@"Decelerating !!");
    NSInteger index = (NSInteger)( _mainView.contentOffset.x/SCREEN_WIDTH);
//    NSLog(@"offset x %f , index %ld >> end", _mainView.contentOffset.x, index);
    if ( index != _currentIndex ) {
//        NSLog(@"change index !!");
        _currentIndex = index;
        _navTabBar.currentItemIndex = index;
    }
    
//    [_navTabBar performSelector:@selector(stopFocusBarAnimation) withObject:nil afterDelay:0.1];
}

#pragma mark - SCNavTabBarDelegate Methods
#pragma mark -
- (void)itemDidSelectedWithIndex:(NSInteger)index
{
    _currentIndex = index;
//    _navTabBar.currentItemIndex = index;
    CGPoint point = CGPointMake(index * SCREEN_WIDTH, DOT_COORDINATE);
//    NSLog(@"tab move to %.0f index %ld", point ,index );
    [_mainView setContentOffset:point animated:_scrollAnimation];
    
    if( self.delegate ){
        UIViewController *controller = _subViewControllers[_currentIndex];
        [self.delegate viewController:controller didSelectedTabIndex:_currentIndex];
    }
}

- (void)shouldPopNavgationItemMenu:(BOOL)pop height:(CGFloat)height
{
    if (pop){
        [UIView animateWithDuration:0.5f animations:^{
            _navTabBar.frame = CGRectMake(_navTabBar.frame.origin.x, _navTabBar.frame.origin.y, _navTabBar.frame.size.width, height + NAV_TAB_BAR_HEIGHT);
        }];
    }
    else{
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
