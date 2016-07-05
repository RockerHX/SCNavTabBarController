//
//  SCNavTabBar.m
//  SCNavTabBarController
//
//  Created by ShiCang on 14/11/17.
//  Copyright (c) 2014年 SCNavTabBarController. All rights reserved.
//

#import "SCNavTabBar.h"
#import "CommonMacro.h"
#import "SCPopView.h"

@interface SCNavTabBar () <SCPopViewDelegate>
{
    UIScrollView    *_navgationTabBar;      // all items on this scroll view
    UIImageView     *_arrowButton;          // arrow button
    
    UIView          *_line;                 // underscore show which item selected
    SCPopView       *_popView;              // when item menu, will show this view
    
    NSMutableArray  *_itemButtons;                // SCNavTabBar pressed item
    NSArray         *_itemButtonsWidths;           // an array of items' width
    BOOL            _canPopAllItemMenu;     // is showed arrow button
    BOOL            _popItemMenu;           // is needed pop item menu
    
    NSInteger       _nextIndex;             // for focus bar animation
    float           _animationDuration;     // for focus bar animation
}

@end

@implementation SCNavTabBar

- (id)initWithFrame:(CGRect)frame canPopAllItemMenu:(BOOL)can
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _canPopAllItemMenu = can;
        [self initConfig];
    }
    return self;
}

#pragma mark -
#pragma mark - Private Methods

- (void)initConfig
{
    _lineHeight = 3.0f; // gevin added
    _itemButtons = [@[] mutableCopy];
    _naviColor = NavTabbarColor;
    _arrowImage = [UIImage imageNamed:SCNavTabbarSourceName(@"arrow.png")];
    _textFont = [UIFont systemFontOfSize: 17 ];
    _textColor = [UIColor darkGrayColor];
    _selectedTextColor = nil;
    _itemSpace = 30;
    _barHeight = 60;
    _itemWidth = 0;    // 0 為自動設定，若指定的話，就每個都是這個寬
    _lineColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.6 alpha:1];
    _showShadow = NO;
    
    //------------------------------
    //  init sub view instance
    //------------------------------
    CGFloat functionButtonX = _canPopAllItemMenu ? (SCREEN_WIDTH - ARROW_BUTTON_WIDTH) : SCREEN_WIDTH;
    if (_canPopAllItemMenu)
    {
        _arrowButton = [[UIImageView alloc] initWithFrame:CGRectMake(functionButtonX, DOT_COORDINATE, ARROW_BUTTON_WIDTH, ARROW_BUTTON_WIDTH)];
        _arrowButton.layer.shadowColor = [UIColor lightGrayColor].CGColor;
        _arrowButton.image = _arrowImage;
        _arrowButton.userInteractionEnabled = YES;
        [self addSubview:_arrowButton];
        if( _showShadow ) [self viewShowShadow:_arrowButton shadowRadius:20.0f shadowOpacity:20.0f];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(functionButtonPressed)];
        [_arrowButton addGestureRecognizer:tapGestureRecognizer];
    }
    
    //  int navi tab bar
    _navgationTabBar = [[UIScrollView alloc] initWithFrame:CGRectMake(DOT_COORDINATE, DOT_COORDINATE, functionButtonX, _barHeight)];
    _navgationTabBar.showsHorizontalScrollIndicator = NO;
    [self addSubview:_navgationTabBar];
    
    //  init focus line
    _line = [[UIView alloc] init];
    _line.backgroundColor = _lineColor;
    [_navgationTabBar addSubview:_line];
    
    if( _showShadow ) [self viewShowShadow:self shadowRadius:10.0f shadowOpacity:10.0f];

}

- (CGFloat)configTabbarItems:(NSArray *)widths
{
    CGFloat buttonX = DOT_COORDINATE;
    //  設定 item object
    for (NSInteger index = 0; index < [_itemTitles count]; index++){
        UIButton *button = _itemButtons[index];
        button.frame = CGRectMake(buttonX, DOT_COORDINATE, [widths[index] floatValue], _barHeight);
        //  2016-01-27 Gevin added for textFont
        button.titleLabel.font = _textFont;
        [button setTitle:_itemTitles[index] forState:UIControlStateNormal];
        [button setTitleColor: (_textColor?_textColor:[UIColor blackColor]) forState:UIControlStateNormal];
        if ( _selectedTextColor) [button setTitleColor: _selectedTextColor forState:UIControlStateSelected];
        buttonX += [widths[index] floatValue];
    }
    
    return buttonX;
}

/** Gevin note 2015-04-23 tabbar item 被按到時觸發 */
- (void)itemPressed:(UIButton *)button
{
    NSInteger index = [_itemButtons indexOfObject:button];
    
    //  移動 focus bar
    [self setFocusBarAnimationToIndex:index duratioin:0.7f];
    [self startFocusBarAnimation];

    //  變換 index
    [self setCurrentItemIndex: index ];
    
    //  通知 delegate
    [_delegate itemDidSelectedWithIndex:index];
}

- (void)functionButtonPressed
{
    _popItemMenu = !_popItemMenu;
    [_delegate shouldPopNavgationItemMenu:_popItemMenu height:[self popMenuHeight]];
}

- (NSArray *)calculateButtonsWidthWithTitles:(NSArray *)titles;
{
    NSMutableArray *widths = [@[] mutableCopy];
    
    for (NSString *title in titles)
    {
        if (_itemWidth>0) {
            [widths addObject:@(_itemWidth)];
        }
        else{
            // 2016-01-27 Gevin added for textFont
            NSDictionary *attributes = @{NSFontAttributeName:_textFont};
            CGSize size = [title sizeWithAttributes:attributes];
    //        CGSize size = [title sizeWithFont:[UIFont systemFontOfSize:[UIFont systemFontSize]]];
            NSNumber *width = [NSNumber numberWithFloat:size.width + _itemSpace ];
            [widths addObject:width];
        }
    }
    
    return widths;
}

- (void)viewShowShadow:(UIView *)view shadowRadius:(CGFloat)shadowRadius shadowOpacity:(CGFloat)shadowOpacity
{
    view.layer.shadowRadius = shadowRadius;
    view.layer.shadowOpacity = shadowOpacity;
}

- (CGFloat)popMenuHeight
{
    CGFloat buttonX = DOT_COORDINATE;
    CGFloat buttonY = ITEM_HEIGHT;
    CGFloat maxHeight = SCREEN_HEIGHT - STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT - NAV_TAB_BAR_HEIGHT;
    for (NSInteger index = 0; index < [_itemButtonsWidths count]; index++)
    {
        buttonX += [_itemButtonsWidths[index] floatValue];
        
        @try {
            if ((buttonX + [_itemButtonsWidths[index + 1] floatValue]) >= SCREEN_WIDTH)
            {
                buttonX = DOT_COORDINATE;
                buttonY += ITEM_HEIGHT;
            }
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
    }
    
    buttonY = (buttonY > maxHeight) ? maxHeight : buttonY;
    return buttonY;
}

- (void)popItemMenu:(BOOL)pop
{
    if (pop)
    {
        if( _showShadow ) [self viewShowShadow:_arrowButton shadowRadius:DOT_COORDINATE shadowOpacity:DOT_COORDINATE];
        [UIView animateWithDuration:0.5f animations:^{
            _navgationTabBar.hidden = YES;
            _arrowButton.transform = CGAffineTransformMakeRotation(M_PI);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2f animations:^{
                if (!_popView)
                {
                    _popView = [[SCPopView alloc] initWithFrame:CGRectMake(DOT_COORDINATE, NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, self.frame.size.height - NAVIGATION_BAR_HEIGHT)];
                    _popView.delegate = self;
                    _popView.itemNames = _itemTitles;
                    [self addSubview:_popView];
                }
                _popView.hidden = NO;
            }];
        }];
    }
    else
    {
        [UIView animateWithDuration:0.5f animations:^{
            _popView.hidden = !_popView.hidden;
            _arrowButton.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            _navgationTabBar.hidden = !_navgationTabBar.hidden;
            if( _showShadow ) [self viewShowShadow:_arrowButton shadowRadius:20.0f shadowOpacity:20.0f];
        }];
    }
}

#pragma mark -
#pragma mark - Public Methods

// Gevin added
- (void)setNaviColor:(UIColor *)naviColor{
    _naviColor = naviColor;
    _navgationTabBar.backgroundColor = _naviColor;
}

// Gevin added
- (void)setTextColor:(UIColor *)textColor{
    _textColor = textColor;
    for (UIButton* button in _itemButtons ) {
        [button setTitleColor: _textColor?_textColor:[UIColor blackColor] forState:UIControlStateNormal ];
    }
}

// Gevin added
- (void)setSelectedTextColor:(UIColor *)selectedTextColor{
    _selectedTextColor = selectedTextColor;
    if (_selectedTextColor) {
        for (UIButton* button in _itemButtons ) {
            [button setTitleColor: _selectedTextColor forState:UIControlStateSelected ];
        }
    }
}

// Gevin added
- (void)setLineColor:(UIColor *)lineColor{
    _lineColor = lineColor;
    _line.backgroundColor = _lineColor;
}

// Gevin added
- (void)setLineHeight:(float)lineHeight{
    _lineHeight = lineHeight;
    _line.frame = (CGRect){_line.frame.origin.x, NAV_TAB_BAR_HEIGHT - _lineHeight, _line.frame.size.width, _lineHeight };
}

// Gevin added
- (void)setShowShadow:(BOOL)showShadow{
    _showShadow = showShadow;
    if( _showShadow ){
        [self viewShowShadow:_arrowButton shadowRadius:20.0f shadowOpacity:20.0f];
        [self viewShowShadow:self shadowRadius:10.0f shadowOpacity:10.0f];
    }
    else{
        [self viewShowShadow:_arrowButton shadowRadius:0 shadowOpacity:0];
        [self viewShowShadow:self shadowRadius:0 shadowOpacity:0];
    }
}

//  2016-01-27 Gevin added for textFont
- (void)setTextFont:(UIFont *)textFont
{
    _textFont = textFont;
    if ( _itemButtons.count > 0 ) {
        [self updateItemLayout];
    }
}

- (void)setItemSpace:(float)itemSpace
{
    _itemSpace = itemSpace;
    if ( _itemSpace > -1 ) {
        [self updateItemLayout];
    }
}

- (void)setItemWidth:(float)itemWidth
{
    _itemWidth = itemWidth;
    [self updateItemLayout];
}

- (void)setBarHeight:(float)barHeight
{
    _barHeight = barHeight;
    
    CGFloat functionButtonX = _canPopAllItemMenu ? (SCREEN_WIDTH - ARROW_BUTTON_WIDTH) : SCREEN_WIDTH;
    _navgationTabBar.frame = CGRectMake(DOT_COORDINATE, DOT_COORDINATE, functionButtonX, _barHeight);
    [self updateItemLayout];
}

- (void)setArrowImage:(UIImage *)arrowImage
{
    _arrowImage = arrowImage ? arrowImage : _arrowImage;
    _arrowButton.image = _arrowImage;
}

- (void)setItemTitles:(NSArray *)itemTitles
{
    _itemTitles = itemTitles;
    
    if ( _itemButtons.count < _itemTitles.count ) {
        NSInteger start = _itemButtons.count;
        for (NSInteger index = start; index < [_itemTitles count]; index++) {
            UIButton *button = button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button addTarget:self action:@selector(itemPressed:) forControlEvents:UIControlEventTouchUpInside];
            [_navgationTabBar addSubview:button];
            [_itemButtons addObject:button];
        }
    }
}

- (void)setCurrentItemIndex:(NSInteger)currentItemIndex
{
    
    // Gevin added 2105-11-4 selected text color
    UIButton *prebutton = _itemButtons[_currentItemIndex];
    prebutton.selected = NO;
    
    _currentItemIndex = currentItemIndex;
    UIButton *button = _itemButtons[currentItemIndex];
    button.selected = YES;
    CGFloat flag = _canPopAllItemMenu ? (SCREEN_WIDTH - ARROW_BUTTON_WIDTH) : SCREEN_WIDTH;
    
    if (button.frame.origin.x + button.frame.size.width > flag)
    {
        CGFloat offsetX = button.frame.origin.x + button.frame.size.width - flag;
        if (_currentItemIndex < [_itemTitles count] - 1)
        {
            offsetX = offsetX + 40.0f;
        }
        
        [_navgationTabBar setContentOffset:CGPointMake(offsetX, DOT_COORDINATE) animated:YES];
    }
    else
    {
        [_navgationTabBar setContentOffset:CGPointMake(DOT_COORDINATE, DOT_COORDINATE) animated:YES];
    }
}

//  call by SCNavTabBarController
- (void)updateItemLayout
{
    _arrowButton.backgroundColor = self.backgroundColor;
    //  計算 button width
    _itemButtonsWidths = [self calculateButtonsWidthWithTitles:_itemTitles];
    if (_itemButtonsWidths.count)
    {
        // 設定線寬及顏色
        // 取目前選取的 item 寬，做為線的寬
        [_navgationTabBar bringSubviewToFront:_line];
        float width = [_itemButtonsWidths[_currentItemIndex] floatValue];
        _line.frame = CGRectMake(2.0f, _barHeight - _lineHeight, width - 4.0f, _lineHeight );
        _line.backgroundColor = _lineColor;
        
        CGFloat contentWidth = [self configTabbarItems:_itemButtonsWidths];
        _navgationTabBar.contentSize = CGSizeMake(contentWidth, DOT_COORDINATE);
    }
}

- (void)refresh
{
    [self popItemMenu:_popItemMenu];
}

#pragma mark - SCFunctionView Delegate Methods
#pragma mark -
- (void)itemPressedWithIndex:(NSInteger)index
{
    [self functionButtonPressed];
    [_delegate itemDidSelectedWithIndex:index];
}


#pragma mark - LineBar Animation
#pragma mark -


- (void)setFocusBarAnimationToIndex:(NSInteger)destIndex duratioin:(float)duration
{
    if ( [self isFocusBarAnimated] ) {
        [self stopFocusBarAnimation];
    }
    _animationDuration = duration;
    _nextIndex = destIndex;
//    UIButton *item1 = _itemButtons[_currentItemIndex];
    UIButton *item2 = _itemButtons[destIndex];
//    CGRect currentFrame = item1.frame;
//    CGRect finalFrame = item2.frame;
    
    
    CABasicAnimation * baseAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    baseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]; 
    baseAnimation.fromValue = [NSValue valueWithCGPoint:_line.center] ; 
    baseAnimation.toValue = [NSValue valueWithCGPoint:(CGPoint){item2.center.x,_line.center.y}] ;
//    NSLog(@"position from:%@ to:%@", NSStringFromCGPoint( _line.center), NSStringFromCGPoint((CGPoint){item2.center.x,_line.center.y}));
    
    CABasicAnimation * boundsAnimation = [CABasicAnimation animationWithKeyPath:@"bounds"];
    
    boundsAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]; 
    boundsAnimation.fromValue = [NSValue valueWithCGRect:_line.bounds] ;
    boundsAnimation.toValue = [NSValue valueWithCGRect:(CGRect){item2.frame.origin, item2.frame.size.width - 4, _lineHeight }] ;
//    NSLog(@"bounds from:%@ to:%@", NSStringFromCGRect(_line.bounds), NSStringFromCGRect((CGRect){item2.frame.origin, item2.frame.size.width - 4, _lineHeight }));
    
    CAAnimationGroup * group =[CAAnimationGroup animation];
    // making animation does not reset after completed
    group.removedOnCompletion=NO;
    group.fillMode=kCAFillModeForwards;
    
    group.animations =[NSArray arrayWithObjects:baseAnimation, boundsAnimation, nil];    
    group.duration = duration;
    group.delegate = self;

//    [_line.layer removeAllAnimations];
    [_line.layer addAnimation:group forKey:@"frame"];     
    _line.layer.speed = 0; // default 1
    _line.layer.timeOffset = 0;
}

- (void)startFocusBarAnimation
{
    _line.layer.speed = 1;
}

- (void)pauseFocusBarAnimation
{
    _line.layer.speed = 0;
}

- (void)stopFocusBarAnimation
{
//    UIButton *item = _itemButtons[_currentItemIndex];
//    CGPoint center = (CGPoint){item.center.x,_line.center.y};
//    CGRect frame = (CGRect){item.frame.origin, item.frame.size.width - 4, _lineHeight };
//    _line.frame = frame;
//    _line.center = center;
    //  動畫播放時，真正在變換值的 layer 是 layer.presentationLayer
    CGPoint position = ((CALayer*)_line.layer.presentationLayer).position;
    CGRect bounds = ((CALayer*)_line.layer.presentationLayer).bounds;
    _line.frame = bounds;
    _line.center = position;
    
    [_line.layer removeAllAnimations];
}

//   0 ~ 1
- (void)setFocusBarTimeOffset:(float)offset
{
    _line.layer.timeOffset = _animationDuration * ( offset / 1.0f );
}

- (BOOL)isFocusBarAnimated
{
    CAAnimation *animation = [_line.layer animationForKey:@"frame"];
    return animation ? YES:NO;
}

//  animation delegate
//  動畫播放結束，或是從 layer 移除的時候會呼叫
- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag
{
    NSLog(@"animation finish:%d", flag );
    //  動畫跑完後，_line 的實際位置並沒有真的改變，這個動畫就真的只是個動畫而已
    //  所以動畫結束後必須再自己設定到目標位置
    CGPoint position = ((CALayer*)_line.layer.presentationLayer).position;
    CGRect bounds = ((CALayer*)_line.layer.presentationLayer).bounds;
    _line.frame = bounds;
    _line.center = position;
//    if ( flag ) {   // 動畫真的跑到結束的地方才停止
//        UIButton *item = _itemButtons[_currentItemIndex];
//        
//        CGPoint center = (CGPoint){item.center.x,_line.center.y};
//        CGRect frame = (CGRect){item.frame.origin, item.frame.size.width - 4, _lineHeight };
//        
//        _line.frame = frame;
//        _line.center = center;
//    }
//    else{   //  動畫停止的時候，沒有跑到結束的地方
////        _line.frame = 
//    }
    
}

@end
