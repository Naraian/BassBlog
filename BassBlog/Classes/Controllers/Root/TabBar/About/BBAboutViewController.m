//
//  BBAboutViewController.m
//  BassBlog
//
//  Created by Evgeny Sivko on 05.09.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBAboutViewController.h"
#import "BBAboutTableViewCell.h"

#import "BBThemeManager.h"

typedef NS_ENUM(NSInteger, BBAboutTableModelSection)
{
    BBAboutTableModelSectionSocial = 0,
    BBAboutTableModelSectionBassblog,
    BBAboutTableModelSectionTellAFriend,
    BBAboutTableModelSectionFeedback
};

typedef NS_ENUM(NSInteger, BBAboutTableModelSocialSectionRow)
{
    BBAboutTableModelSocialSectionRowFacebook = 0,
    BBAboutTableModelSocialSectionRowTwitter,
    BBAboutTableModelSocialSectionRowVkontakte,
    BBAboutTableModelSocialSectionRowCount
};

@implementation BBAboutViewController

- (void)commonInit
{
    [super commonInit];
    
    self.title = NSLocalizedString(@"MORE", @"");
    
    [self setTabBarItemTitle:self.title
                  imageNamed:@"more_tab"
                         tag:4];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithHEX:0xEFEFF4FF];
    self.tableView.backgroundColor = [UIColor colorWithHEX:0xEFEFF4FF];
}

- (NSString *)cellNibNameAtIndexPath:(NSIndexPath *)indexPath {
    
    return [BBAboutTableViewCell nibName];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case BBAboutTableModelSectionSocial:
            return BBAboutTableModelSocialSectionRowCount;
            
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
            imageName = @"website";
            break;
            
        case BBAboutTableModelSectionTellAFriend:
            imageName = @"tell_a_friend";
            break;
            
        case BBAboutTableModelSectionFeedback:
            imageName = @"feedback";
            break;
            
        default:
            imageName = @"about";
            break;
    }
    
    imageName = [@"social" stringByAppendingPathComponent:imageName];
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
            title = @"bassblog.pro";
            break;
        case BBAboutTableModelSectionTellAFriend:
            title = @"tell a friend";
            break;
        case BBAboutTableModelSectionFeedback:
            title = @"leave feedback";
            break;
        default:
            
            break;
    }
    
    title = NSLocalizedString(title, nil);
    
    return title;
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
    return [UIView new];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case BBAboutTableModelSectionSocial:
            return RUNNING_ON_3_5_INCH ? 24.f : 36.f;
        case BBAboutTableModelSectionBassblog:
            return RUNNING_ON_3_5_INCH ? 18.f : 36.f;
            
        default:
            break;
    }
    
    return 18.f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    switch (section)
    {
        case BBAboutTableModelSectionFeedback:
            return 18.f;
            
        default:
            break;
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
                urlString = @"http://www.facebook.com/dnb.mix.blog";
            }
            else if (indexPath.row == BBAboutTableModelSocialSectionRowTwitter)
            {
                urlString = @"https://twitter.com/bass_blog";
            }
            else
            {
                urlString = @"http://vk.com/bass_blog";
            }
            break;
        case BBAboutTableModelSectionBassblog:
            urlString = @"http://www.bassblog.pro";
            break;
        case BBAboutTableModelSectionTellAFriend:
            urlString = nil;
            break;
        case BBAboutTableModelSectionFeedback:
            urlString = nil;
            break;
        default:
            
            break;
    }
    
    if (urlString != nil)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    }
}

@end
