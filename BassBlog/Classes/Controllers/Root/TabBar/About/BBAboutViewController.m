//
//  BBAboutViewController.m
//  BassBlog
//
//  Created by Evgeny Sivko on 05.09.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBAboutViewController.h"
#import "BBAboutTableViewCell.h"
#import "BBMixesTableSectionHeaderView.h"

#import "BBSettings.h"
#import "BBMacros.h"
#import "BBThemeManager.h"
#import "BBModelManager.h"
#import "Flurry.h"

DEFINE_STATIC_CONST_NSSTRING(BBAboutViewControllerForceRefreshPopupKey);

typedef NS_ENUM(NSInteger, BBAboutTableModelSection)
{
    BBAboutTableModelSectionSocial = 0,
    BBAboutTableModelSectionBassblog,
    BBAboutTableModelSectionRefresh,
    BBAboutTableModelSectionsCount
};

typedef NS_ENUM(NSInteger, BBAboutTableModelSocialSectionRow)
{
    BBAboutTableModelSocialSectionRowFacebook = 0,
    BBAboutTableModelSocialSectionRowTwitter,
    BBAboutTableModelSocialSectionRowVkontakte,
    BBAboutTableModelSocialSectionRowCount
};

typedef NS_ENUM(NSInteger, BBAboutTableModelBassblogSectionRow)
{
    BBAboutTableModelBassblogSectionRowWebsite = 0,
    BBAboutTableModelBassblogSectionRowTellAFriend,
    BBAboutTableModelBassblogSectionRowFeedback,
    BBAboutTableModelBassblogSectionRowCount
};

@interface BBAboutViewController()

@property (nonatomic, strong) UINib *sectionHeaderNib;

@end

@implementation BBAboutViewController

- (void)commonInit
{
    [super commonInit];
    
    NSString *title = NSLocalizedString(@"More", @"");
    self.title = title.uppercaseString;
    [self setTabBarItemTitle:title imageNamed:@"more_tab" tag:4];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithHEX:0xEFEFF4FF];
    self.tableView.backgroundColor = [UIColor colorWithHEX:0xEFEFF4FF];
}

- (void)updateTheme
{
    [super updateTheme];
    
    [self showNowPlayingBarButtonItem];
}

- (NSString *)cellNibNameAtIndexPath:(NSIndexPath *)indexPath
{    
    return [BBAboutTableViewCell nibName];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return BBAboutTableModelSectionsCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case BBAboutTableModelSectionSocial:
            return BBAboutTableModelSocialSectionRowCount;
            
        case BBAboutTableModelSectionBassblog:
            return BBAboutTableModelBassblogSectionRowCount;
            
        default:
            break;
    }
    
    return 1;
}

+ (UIImage *)imageForCellAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *imageName = nil;
    switch (indexPath.section)
    {
        case BBAboutTableModelSectionSocial:
            if (indexPath.row == BBAboutTableModelSocialSectionRowFacebook)
            {
                imageName = @"facebook";
            }
            else if (indexPath.row == BBAboutTableModelSocialSectionRowTwitter)
            {
                imageName = @"twitter";
            }
            else if (indexPath.row == BBAboutTableModelSocialSectionRowVkontakte)
            {
                imageName = @"vk";
            }
            break;
        
        case BBAboutTableModelSectionBassblog:
            if (indexPath.row == BBAboutTableModelBassblogSectionRowWebsite)
            {
                imageName = @"website";
            }
            else if (indexPath.row == BBAboutTableModelBassblogSectionRowTellAFriend)
            {
                imageName = @"tell_a_friend";
            }
            else if (indexPath.row == BBAboutTableModelBassblogSectionRowFeedback)
            {
                imageName = @"feedback";
            }
            break;
        
        case BBAboutTableModelSectionRefresh:
            imageName = @"force_refresh";
            break;

        default:
            imageName = @"about";
            break;
    }
    
    imageName = [@"settings" stringByAppendingPathComponent:imageName];
    UIImage *image = [[BBThemeManager defaultManager] imageNamed:imageName];
    
    return image;
}

+ (NSString *)titleForCellAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *title = nil;
    switch (indexPath.section)
    {
        case BBAboutTableModelSectionSocial:
            if (indexPath.row == BBAboutTableModelSocialSectionRowFacebook)
            {
                title = @"facebook";
            }
            else if (indexPath.row == BBAboutTableModelSocialSectionRowTwitter)
            {
                title = @"twitter";
            }
            else
            {
                title = @"vkontakte";
            }
            break;
            
        case BBAboutTableModelSectionBassblog:
            if (indexPath.row == BBAboutTableModelBassblogSectionRowWebsite)
            {
                title = @"bassblog.pro";
            }
            else if (indexPath.row == BBAboutTableModelBassblogSectionRowTellAFriend)
            {
                title = @"tell a friend";
            }
            else if (indexPath.row == BBAboutTableModelBassblogSectionRowFeedback)
            {
                title = @"leave a feedback";
            }
            break;

        case BBAboutTableModelSectionRefresh:
            title = @"force refresh";
            break;

        default:
            
            break;
    }
    
    title = NSLocalizedString(title, nil);
    
    return title;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BBAboutTableViewCell *cell = (BBAboutTableViewCell*)[super tableView:tableView cellForRowAtIndexPath:indexPath];
    cell.iconImageView.image = [self.class imageForCellAtIndexPath:indexPath];
    cell.label.text = [[self.class titleForCellAtIndexPath:indexPath] uppercaseString];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(BBAboutTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor whiteColor];    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (!_sectionHeaderNib)
    {
        _sectionHeaderNib = [BBMixesTableSectionHeaderView nib];
    }
    
    return [BBMixesTableSectionHeaderView instanceFromNib:_sectionHeaderNib];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (!_sectionHeaderNib)
    {
        _sectionHeaderNib = [BBMixesTableSectionHeaderView nib];
    }
    
    return [BBMixesTableSectionHeaderView instanceFromNib:_sectionHeaderNib];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case BBAboutTableModelSectionSocial:
            return RUNNING_ON_3_5_INCH ? 10.f : 36.f;

        default:
            break;
    }
    
    return RUNNING_ON_3_5_INCH ? 10.f : 36.f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == BBAboutTableModelSectionsCount - 1)
    {
        return RUNNING_ON_3_5_INCH ? 12.f : 40.f;
    }
    
    return 0.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *urlString = nil;
    switch (indexPath.section)
    {
        case BBAboutTableModelSectionSocial:
            if (indexPath.row == BBAboutTableModelSocialSectionRowFacebook)
            {
                urlString = @"http://www.facebook.com/bass.blog";
            }
            else if (indexPath.row == BBAboutTableModelSocialSectionRowTwitter)
            {
                urlString = @"http://twitter.com/bass_blog";
            }
            else
            {
                urlString = @"http://vk.com/bass_blog";
            }
            break;
            
        case BBAboutTableModelSectionBassblog:
            if (indexPath.row == BBAboutTableModelBassblogSectionRowWebsite)
            {
                urlString = @"http://www.bassblog.pro";
            }
            else if (indexPath.row == BBAboutTableModelBassblogSectionRowTellAFriend)
            {
                urlString = nil;
            }
            else if (indexPath.row == BBAboutTableModelBassblogSectionRowFeedback)
            {
                urlString = @"mailto:bassblog.pro@gmail.com";
            }
            break;
            
        case BBAboutTableModelSectionRefresh:
        {
            BOOL popupWasShown = [BBSettings boolForKey:BBAboutViewControllerForceRefreshPopupKey];
            
            if (!popupWasShown)
            {
                [BBSettings setBool:YES forKey:BBAboutViewControllerForceRefreshPopupKey];
                
                [[[UIAlertView alloc] initWithTitle:nil
                                            message:NSLocalizedString(@"Use this action when you find that some of new mixes didn't appear in the list", nil)
                                           delegate:nil
                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                  otherButtonTitles:nil] show];
            }
            
            self.tabBarController.selectedIndex = 0;
            [[BBModelManager defaultManager] forceRefresh];
            break;
        }
            
        default:
            
            break;
    }
    
    if (urlString != nil)
    {
        [Flurry logEvent:urlString];

        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    }
}

@end
