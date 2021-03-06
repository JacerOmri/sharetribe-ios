//
//  AppDelegate.m
//  Sharetribe
//
//  Created by Janne Käki on 1/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

#import "CommunitySelectionViewController.h"
#import "Listing.h"
#import "LoginViewController.h"
#import "SharetribeAPIClient.h"
#import "User.h"
#import "NSArray+Sharetribe.h"
#import "UINavigationController+Sharetribe.h"

#import "TestFlight.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize tabBarController;

@synthesize offersViewController;
@synthesize requestsViewController;
@synthesize messagesViewController;
@synthesize profileViewController;

@synthesize listingComposer;
@synthesize createListingNavigationController;

void uncaughtExceptionHandler(NSException *exception);

void uncaughtExceptionHandler(NSException *exception)
{
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    [TestFlight takeOff:@"cc6ffc3a-6fd0-4e04-bc53-d0e1ac0f5c5b"];
    // [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor viewFlipsideBackgroundColor];
    
    [application setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
        
    self.offersViewController   = [[ListingsTopViewController alloc] initWithListingType:kListingTypeOffer];
    self.requestsViewController = [[ListingsTopViewController alloc] initWithListingType:kListingTypeRequest];
    self.messagesViewController = [[ConversationListViewController alloc] init];
    self.profileViewController  = [[ProfileViewController alloc] init];
    
    [offersViewController view];
    [requestsViewController view];
    [messagesViewController view];
    
    UINavigationController *offersNavigationController = [[UINavigationController alloc] initWithRootViewController:offersViewController];
    UINavigationController *requestsNavigationController = [[UINavigationController alloc] initWithRootViewController:requestsViewController];
    UINavigationController *messagesNavigationController = [[UINavigationController alloc] initWithRootViewController:messagesViewController];
    UINavigationController *profileNavigationController = [[UINavigationController alloc] initWithRootViewController:profileViewController];
    
    offersNavigationController.delegate   = self;
    requestsNavigationController.delegate = self;
    messagesNavigationController.delegate = self;
    profileNavigationController.delegate  = self;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard_iPhone" bundle:[NSBundle mainBundle]];
    self.listingComposer = [storyboard instantiateViewControllerWithIdentifier:@"NewListing"];
    self.createListingNavigationController = [[UINavigationController alloc] initWithRootViewController:listingComposer];
    
    offersViewController.title   = NSLocalizedString(@"tabs.offers", @"");
    requestsViewController.title = NSLocalizedString(@"tabs.requests", @"");
    messagesViewController.title = NSLocalizedString(@"tabs.messages", @"");
    profileViewController.title  = NSLocalizedString(@"tabs.profile", @"");
    
    User *currentUser = [User currentUser];
    profileViewController.user = currentUser;
    
    offersNavigationController.tabBarItem.image   = [UIImage imageWithIconNamed:@"share" pointSize:21 color:[UIColor whiteColor]];
    requestsNavigationController.tabBarItem.image = [UIImage imageWithIconNamed:@"tip" pointSize:21 color:[UIColor whiteColor]];
    messagesNavigationController.tabBarItem.image = [UIImage imageWithIconNamed:@"mail" pointSize:24 color:[UIColor whiteColor]];
    profileNavigationController.tabBarItem.image  = [UIImage imageNamed:@"icon-kaapo"];
    
    NSMutableArray *tabViewControllers = [NSMutableArray arrayWithCapacity:5];
    [tabViewControllers addObject:offersNavigationController];
    [tabViewControllers addObject:requestsNavigationController];
    [tabViewControllers addObject:messagesNavigationController];
    [tabViewControllers addObject:profileNavigationController];
    
    self.tabBarController = [[ButtonTabBarController alloc] initWithMiddleViewController:createListingNavigationController otherViewControllers:tabViewControllers];
    
    tabBarController.middleButtonTitle = NSLocalizedString(@"tabs.new_listing", @"");
    tabBarController.middleButtonNormalImage = [UIImage imageWithIconNamed:@"addfile" pointSize:20 color:[UIColor grayColor]];
    tabBarController.middleButtonHighlightedImage = [UIImage imageWithIconNamed:@"addfile" pointSize:20 color:[UIColor whiteColor]];
        
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(userDidLogIn:) name:kNotificationForUserDidLogIn object:nil];
    [notificationCenter addObserver:self selector:@selector(userDidLogOut:) name:kNotificationForUserDidLogOut object:nil];
    [notificationCenter addObserver:self selector:@selector(userDidSelectCommunity:) name:kNotificationForDidSelectCommunity object:nil];
    [notificationCenter addObserver:self selector:@selector(userDidPostListing:) name:kNotificationForDidPostListing object:nil];
    
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    
    // Register for push notifications
    [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound)];
    
    [self refreshTintColors];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    User *currentUser = [User currentUser];
    if (currentUser != nil && self.community == nil) {
        [self refreshInitialContent];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceTokenData
{
    NSString *deviceToken = [[deviceTokenData description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    deviceToken = [deviceToken stringByReplacingOccurrencesOfString:@" " withString:@""];
	NSLog(@"Registered for push notifications with token: %@", deviceToken);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:deviceToken forKey:kDefaultsKeyForDeviceToken];
    [defaults synchronize];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
	NSLog(@"Failed to register for push notifications: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSString *message = nil;
    id alert = [userInfo objectForKey:@"alert"];
    if ([alert isKindOfClass:NSString.class]) {
        message = alert;
    } else if ([alert isKindOfClass:NSDictionary.class]) {
        message = [alert objectForKey:@"body"];
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"New notification!" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

- (void)doInitialCheck
{
    if  (![[SharetribeAPIClient sharedClient] isLoggedIn]) {
        [self showLogin];
    } else if ([[SharetribeAPIClient sharedClient] currentCommunityId] == NSNotFound) {
        [self showCommunitySelection];
    } else {
        // [self loadInitialContent];
    }
}

- (void)showLogin
{
    LoginViewController *loginViewer = [[LoginViewController alloc] init];
    [self.tabBarController presentViewController:loginViewer animated:NO completion:nil];
    
    [tabBarController setSelectedIndex:0];
}

- (void)showCommunitySelection
{
    CommunitySelectionViewController *communitySelectionViewer = [[CommunitySelectionViewController alloc] init];
    [self.tabBarController presentViewController:communitySelectionViewer animated:YES completion:nil];
}

- (void)refreshInitialContent
{
    [offersViewController startIndicatingRefresh];
    [requestsViewController startIndicatingRefresh];
    NSInteger currentCommunityId = [[SharetribeAPIClient sharedClient] currentCommunityId];
    [[SharetribeAPIClient sharedClient] getCommunityWithId:currentCommunityId onSuccess:^(Community *community) {
        
        self.community = community;
        
        [offersViewController refreshListings];
        [requestsViewController refreshListings];
        [messagesViewController refreshConversations];
        [self refreshTintColors];
        
        if (community.location) {
            offersViewController.mapViewer.defaultLocation = community.location;
            requestsViewController.mapViewer.defaultLocation = community.location;
        }
            
        [tabBarController setSelectedIndex:0];
        
        [[SharetribeAPIClient sharedClient] getClassificationsForCommunityWithId:currentCommunityId onSuccess:^(NSDictionary *classifications) {
            
            self.community.classifications = classifications;
            [listingComposer reloadData];
            
        } onFailure:^(NSError *error) {
            
        }];
        
    } onFailure:^(NSError *error) {
        
    }];
}

- (void)refreshTintColors
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    UIColor *color;
    if (self.community) {
        color = kSharetribeThemeColor;
    } else {
        NSData *savedColorData = [defaults objectForKey:kDefaultsKeyForThemeColor];
        UIColor *savedColor = [NSKeyedUnarchiver unarchiveObjectWithData:savedColorData];
        color = savedColor ?: kSharetribeThemeColor;
    }
    
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:color];
    [defaults setObject:colorData forKey:kDefaultsKeyForThemeColor];
    [defaults synchronize];
    
    if ([tabBarController.tabBar respondsToSelector:@selector(setTintColor:)]) {
        tabBarController.tabBar.selectedImageTintColor = color;
    }
    for (UIViewController *controller in tabBarController.viewControllers) {
        if ([controller isKindOfClass:UINavigationController.class]) {
            [(UINavigationController *) controller navigationBar].tintColor = color;
        }
    }
    createListingNavigationController.navigationBar.tintColor = color;
    
    requestsViewController.listViewer.searchBar.tintColor = [color colorWithAlphaComponent:0.7];
    offersViewController.listViewer.searchBar.tintColor = [color colorWithAlphaComponent:0.7];
    
    requestsViewController.listViewer.header.backgroundView.backgroundColor = color;
    offersViewController.listViewer.header.backgroundView.backgroundColor = color;
}

- (void)userDidLogIn:(NSNotification *)notification
{
    User *currentUser = [User currentUser];
    profileViewController.user = currentUser;
    
    if (currentUser.communities.count < 2) {
        [self refreshInitialContent];
    } else {
        [self performSelector:@selector(showCommunitySelection) withObject:nil afterDelay:0.5];
    }
}

- (void)userDidSelectCommunity:(NSNotification *)notification
{
    [self refreshInitialContent];
}

- (void)userDidLogOut:(NSNotification *)notification
{
    [offersViewController clearAllListings];
    [requestsViewController clearAllListings];
    [self showLogin];
}

- (void)userDidPostListing:(NSNotification *)notification
{
    Listing *listing = notification.object;
    ListingsTopViewController *controller;
    if ([listing.type isEqual:kListingTypeOffer]) {
        tabBarController.selectedIndex = 0;
        controller = offersViewController;
    } else {
        tabBarController.selectedIndex = 1;
        controller = requestsViewController;
    }
    [controller.navigationController popToRootViewControllerAnimated:NO];
    [controller viewController:controller didSelectListing:listing];
}

+ (AppDelegate *)sharedAppDelegate
{
    return (AppDelegate *) [[UIApplication sharedApplication] delegate];
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (navigationController.viewControllers.count > 1) {
        UIViewController *previousViewController = [navigationController.viewControllers objectOrNilAtIndex:navigationController.viewControllers.count-2];
        if (previousViewController.title == nil) {
            viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrow-back"] style:UIBarButtonItemStyleBordered target:navigationController action:@selector(pop)];
        }
    }
}

@end
