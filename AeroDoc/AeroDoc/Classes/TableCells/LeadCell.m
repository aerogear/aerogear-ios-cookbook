/*
 * JBoss, Home of Professional Open Source.
 * Copyright Red Hat, Inc., and individual contributors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "LeadCell.h"

@implementation LeadCell {

}
@synthesize topLabel, bottomLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withTableView: (UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath withImageDisplay:(BOOL)imageDisplay {
    
    if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier])) {
        CGFloat indicatorWidth = 0.0;
        
        const CGFloat LABEL_HEIGHT = 20;
        UIImage *image = [UIImage imageNamed:@"fullstar.png"];
        
        
        // Create the label for the top row of text
        topLabel = [[UILabel alloc] initWithFrame: CGRectMake(
                                                              image.size.width + 2.0 * self.indentationWidth,
                                                              0.5 * (tableView.rowHeight - 2 * LABEL_HEIGHT),
                                                              tableView.bounds.size.width -
                                                              image.size.width - 4.0 * self.indentationWidth
                                                              - indicatorWidth,
                                                              LABEL_HEIGHT)];
        [self.contentView addSubview:topLabel];
        
        // Configure the properties for the text that are the same on every row
        topLabel.backgroundColor = [UIColor clearColor];
        topLabel.textColor = [UIColor blackColor];
        topLabel.font = [UIFont systemFontOfSize:[UIFont labelFontSize]];
        
        // Create the label for the top row of text
        bottomLabel = [[UILabel alloc] initWithFrame: CGRectMake(
                                                                 image.size.width + 2.0 * self.indentationWidth,
                                                                 0.5 * (tableView.rowHeight - 2 * LABEL_HEIGHT) + LABEL_HEIGHT,
                                                                 tableView.bounds.size.width -
                                                                 image.size.width - 4.0 * self.indentationWidth
                                                                 - indicatorWidth,
                                                                 LABEL_HEIGHT)];
        [self.contentView addSubview:bottomLabel];
        
        // Configure the properties for the text that are the same on every row
        bottomLabel.backgroundColor = [UIColor clearColor];
        bottomLabel.textColor = [UIColor blackColor];
        bottomLabel.font = [UIFont systemFontOfSize:[UIFont labelFontSize] - 2];
        
        // Create a background image view.
        self.backgroundView = [[UIImageView alloc] init];
        self.selectedBackgroundView = [[UIImageView alloc] init];
    }
    NSInteger row = [indexPath row];
    [self decorateCell:row inListCount:[tableView numberOfRowsInSection:[indexPath section]] with:imageDisplay];
    
    return self;
}

- (void)decorateCell:(NSInteger)row inListCount:(NSInteger)count with:(BOOL)imageDisplay {
    if (imageDisplay) {
        self.image = [UIImage imageNamed:@"notification_red.png"];
    } else {
        self.image = nil;
    }
}

@end
