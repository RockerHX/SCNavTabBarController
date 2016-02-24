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
    
    NSMutableArray  *_items;                // SCNavTabBar pressed item
    NSArray         *_itemsWidth;           // an array of items' width
    BOOL            _canPopAllItemMenu;     // is showed arrow button
    BOOL            _popItemMenu;           // is needed pop item menu
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
    _items = [@[] mutableCopy];
    _arrowImage = [UIImage imageNamed:SCNavTabbarSourceName(@"arrow.png")];
    _textFont = [UIFont systemFontOfSize: 17 ];
    _itemSpace = 30;
    _barHeight = 60;
    _itemWidth = 0;    // 0 為自動設定，若指定的話，就每個都是這個寬
    
    [self viewConfig];
    [self addTapGestureRecognizer];
}

- (void)viewConfig
{
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

    _navgationTabBar = [[UIScrollView alloc] initWithFrame:CGRectMake(DOT_COORDINATE, DOT_COORDINATE, functionButtonX, _barHeight)];
    _navgationTabBar.showsHorizontalScrollIndicator = NO;
    [self addSubview:_navgationTabBar];
    
    if( _showShadow ) [self viewShowShadow:self shadowRadius:10.0f shadowOpacity:10.0f];
}

- (void)showLineWithButtonWidth:(CGFloat)width
{
    // 為了讓 updateData 可以重覆呼叫
    if (!_line) {
        _line = [[UIView alloc] init];
        [_navgationTabBar addSubview:_line];
    }
    _line.frame = CGRectMake(2.0f, _barHeight - _lineHeight, width - 4.0f, _lineHeight );
    _line.backgroundColor = UIColorWithRGBA(20.0f, 80.0f, 200.0f, 0.7f);
}

- (CGFloat)configTabbarItems:(NSArray *)widths
{
    // 2016-01-27 Gevin added for textFont
    CGFloat buttonX = DOT_COORDINATE;
    //  建立 item object，每個物件只執行一次
    if ( _items.count < _itemTitles.count ) {
        NSInteger start = _items.count;
        for (NSInteger index = start; index < [_itemTitles count]; index++) {
            UIButton *button = button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button addTarget:self action:@selector(itemPressed:) forControlEvents:UIControlEventTouchUpInside];
            [_navgationTabBar addSubview:button];
            [_items addObject:button];
        }
    }
    
    //  設定 item object
    for (NSInteger index = 0; index < [_itemTitles count]; index++){
        UIButton *button = _items[index];
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

- (void)addTapGestureRecognizer
{
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(functionButtonPressed)];
    [_arrowButton addGestureRecognizer:tapGestureRecognizer];
}

/** Gevin note 2015-04-23 tabbar item 被按到時觸發 */
- (void)itemPressed:(UIButton *)button
{
    NSInteger index = [_items indexOfObject:button];
    [_delegate itemDidSelectedWithIndex:index];
}

- (void)functionButtonPressed
{
    _popItemMenu = !_popItemMenu;
    [_delegate shouldPopNavgationItemMenu:_popItemMenu height:[self popMenuHeight]];
}

- (NSArray *)getButtonsWidthWithTitles:(NSArray *)titles;
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
    for (NSInteger index = 0; index < [_itemsWidth count]; index++)
    {
        buttonX += [_itemsWidth[index] floatValue];
        
        @try {
            if ((buttonX + [_itemsWidth[index + 1] floatValue]) >= SCREEN_WIDTH)
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
    for (UIButton* button in _items ) {
        [button setTitleColor: _textColor?_textColor:[UIColor blackColor] forState:UIControlStateNormal ];
    }
}

// Gevin added
- (void)setSelectedTextColor:(UIColor *)selectedTextColor{
    _selectedTextColor = selectedTextColor;
    if (_selectedTextColor) {
        for (UIButton* button in _items ) {
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
    if ( _items.count > 0 ) {
        [self updateData];
    }
}

- (void)setItemSpace:(float)itemSpace
{
    _itemSpace = itemSpace;
    if ( _itemSpace > -1 ) {
        [self updateData];
    }
}

- (void)setItemWidth:(float)itemWidth
{
    _itemWidth = itemWidth;
    [self updateData];
}

- (void)setBarHeight:(float)barHeight
{
    _barHeight = barHeight;
    
    CGFloat functionButtonX = _canPopAllItemMenu ? (SCREEN_WIDTH - ARROW_BUTTON_WIDTH) : SCREEN_WIDTH;
    _navgationTabBar.frame = CGRectMake(DOT_COORDINATE, DOT_COORDINATE, functionButtonX, _barHeight);
    [self updateData];
}

- (void)setArrowImage:(UIImage *)arrowImage
{
    _arrowImage = arrowImage ? arrowImage : _arrowImage;
    _arrowButton.image = _arrowImage;
}

- (void)setCurrentItemIndex:(NSInteger)currentItemIndex
{
    // Gevin added 2105-11-4 selected text color
    UIButton *prebutton = _items[_currentItemIndex];
    prebutton.selected = NO;
    
    _currentItemIndex = currentItemIndex;
    UIButton *button = _items[currentItemIndex];
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
    
    // Gevin note 2015-04-23 移動底線，原本的放在 - (void)setCurrentItemIndex:(NSInteger)currentItemIndex，會有問題
    // Gevin note 2015-07-28 移動底線，又改回原本的地方
    [UIView animateWithDuration:0.2f animations:^{
        _line.frame = CGRectMake(button.frame.origin.x + 2.0f, _line.frame.origin.y, [_itemsWidth[_currentItemIndex] floatValue] - 4.0f, _line.frame.size.height);
    }];
}

//  call by SCNavTabBarController
- (void)updateData
{
    _arrowButton.backgroundColor = self.backgroundColor;
    //  計算 button width
    _itemsWidth = [self getButtonsWidthWithTitles:_itemTitles];
    if (_itemsWidth.count)
    {
        // Gevin modify 2015-07-17 從 [self configTabbarItems:] 移到這裡
        [self showLineWithButtonWidth:[_itemsWidth[0] floatValue]];
        CGFloat contentWidth = [self configTabbarItems:_itemsWidth];
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

@end
