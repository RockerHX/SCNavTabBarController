//
//  SCNavTabBar.h
//  SCNavTabBarController
//
//  Created by ShiCang on 14/11/17.
//  Copyright (c) 2014年 SCNavTabBarController. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SCNavTabBarDelegate <NSObject>

@optional
/**
 *  When NavTabBar Item Is Pressed Call Back
 *
 *  @param index - pressed item's index
 */
- (void)itemDidSelectedWithIndex:(NSInteger)index;

/**
 *  When Arrow Pressed Will Call Back
 *
 *  @param pop    - is needed pop menu
 *  @param height - menu height
 */
- (void)shouldPopNavgationItemMenu:(BOOL)pop height:(CGFloat)height;

@end

@interface SCNavTabBar : UIView

@property (nonatomic, weak)     id          <SCNavTabBarDelegate>delegate;

@property (nonatomic, assign)   NSInteger   currentItemIndex;           // current selected item's index
@property (nonatomic, strong)   NSArray     *itemTitles;                // all items' title
@property (nonatomic, strong)   UIColor     *naviColor;                 // Gevin added, assign color to background color is not work, so declare this property to fixed it.
@property (nonatomic, strong)   UIColor     *textColor;                 // Gevin added
@property (nonatomic, strong)   UIColor     *selectedTextColor;         // Gevin added
@property (nonatomic, strong)   UIColor     *lineColor;                 // set the underscore color
@property (nonatomic, strong)   UIImage     *arrowImage;                // set arrow button's image
@property (nonatomic)           BOOL        showShadow;                 // Gevin added
@property (nonatomic)           float       lineHeight;                 // Gevin added line height

/**
 *  Initialize Methods
 *
 *  @param frame - SCNavTabBar frame
 *  @param show  - is show Arrow Button
 *
 *  @return Instance
 */
- (id)initWithFrame:(CGRect)frame canPopAllItemMenu:(BOOL)can;

/**
 *  Update Item Data
 */
- (void)updateData;

/**
 *  Refresh All Subview
 */
- (void)refresh;

@end
