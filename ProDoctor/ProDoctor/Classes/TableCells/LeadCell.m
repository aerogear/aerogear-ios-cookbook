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

    UIImage *indicatorImage = [UIImage imageNamed:@"indicator.png"];
    self.accessoryView = [[UIImageView alloc] initWithImage:indicatorImage];
    [self.accessoryView setFrame:CGRectMake(0, 0, 15, 45)];
    
    const CGFloat LABEL_HEIGHT = 20;
    UIImage *image = [UIImage imageNamed:@"fullstar.png"];
    
    
    // Create the label for the top row of text
    topLabel = [[UILabel alloc] initWithFrame: CGRectMake(
                                                          image.size.width + 2.0 * self.indentationWidth,
                                                          0.5 * (tableView.rowHeight - 2 * LABEL_HEIGHT),
                                                          tableView.bounds.size.width -
                                                          image.size.width - 4.0 * self.indentationWidth
                                                          - indicatorImage.size.width,
                                                          LABEL_HEIGHT)];
    [self.contentView addSubview:topLabel];
    
    // Configure the properties for the text that are the same on every row
    topLabel.backgroundColor = [UIColor clearColor];
    topLabel.textColor = [UIColor colorWithRed:0.25 green:0.0 blue:0.0 alpha:1.0];
    topLabel.highlightedTextColor = [UIColor colorWithRed:1.0 green:1.0 blue:0.9 alpha:1.0];
    topLabel.font = [UIFont systemFontOfSize:[UIFont labelFontSize]];
    
    // Create the label for the top row of text
    bottomLabel = [[UILabel alloc] initWithFrame: CGRectMake(
                                                             image.size.width + 2.0 * self.indentationWidth,
                                                             0.5 * (tableView.rowHeight - 2 * LABEL_HEIGHT) + LABEL_HEIGHT,
                                                             tableView.bounds.size.width -
                                                             image.size.width - 4.0 * self.indentationWidth
                                                             - indicatorImage.size.width,
                                                             LABEL_HEIGHT)];
    [self.contentView addSubview:bottomLabel];
    
    // Configure the properties for the text that are the same on every row
    bottomLabel.backgroundColor = [UIColor clearColor];
    bottomLabel.textColor = [UIColor colorWithRed:0.25 green:0.0 blue:0.0 alpha:1.0];
    bottomLabel.highlightedTextColor = [UIColor colorWithRed:1.0 green:1.0 blue:0.9 alpha:1.0];
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
    //
	// Set the background and selected background images for the text.
	// Since we will round the corners at the top and bottom of sections, we
	// need to conditionally choose the images based on the row index and the
	// number of rows in the section.
	//
	UIImage *rowBackground;
	UIImage *selectionBackground;
	NSInteger sectionRows = count;
	//
	if (row == 0 && row == sectionRows - 1) {
		rowBackground = [UIImage imageNamed:@"topAndBottomRow.png"];
		selectionBackground = [UIImage imageNamed:@"topAndBottomRowSelected.png"];
	} else if (row == 0) {
		rowBackground = [UIImage imageNamed:@"topRow.png"];
		selectionBackground = [UIImage imageNamed:@"topRowSelected.png"];
	} else if (row == sectionRows - 1) {
		rowBackground = [UIImage imageNamed:@"bottomRow.png"];
		selectionBackground = [UIImage imageNamed:@"bottomRowSelected.png"];
	} else {
		rowBackground = [UIImage imageNamed:@"middleRow.png"];
		selectionBackground = [UIImage imageNamed:@"middleRowSelected.png"];
	}
	((UIImageView *)self.backgroundView).image = rowBackground;
	((UIImageView *)self.selectedBackgroundView).image = selectionBackground;
    if (imageDisplay) {
        self.image = [UIImage imageNamed:@"fullstar.png"];
    } else {
        self.image = nil;
    }
}

@end
