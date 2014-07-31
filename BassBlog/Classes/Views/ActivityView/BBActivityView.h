//
//  BBActivityView.h
//  BassBlog
//
//  Created by Evgeny Sivko on 21.08.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "ProgressPieView.h"

@interface BBActivityView : UIView

@property (nonatomic, strong) IBOutlet ProgressPieView *activityIndicator;
@property (nonatomic, strong) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, strong) IBOutlet UILabel *subDescriptionLabel;

@end
