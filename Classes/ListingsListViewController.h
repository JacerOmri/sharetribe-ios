//
//  ListingsListViewController.h
//  Sharetribe
//
//  Created by Janne Käki on 2/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ListingCollectionView.h"
#import "ListingCollectionViewDelegate.h"

@interface ListingsListViewController : UITableViewController <ListingCollectionView>

@property (strong) UIView *header;
@property (strong) UILabel *updateIntroLabel;
@property (strong) UILabel *updateTimeLabel;
@property (strong) UIActivityIndicatorView *updateSpinner;

@property (unsafe_unretained) id<ListingCollectionViewDelegate> listingCollectionViewDelegate;

@end
