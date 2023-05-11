//
//  MyCollectionViewCell.m
//  OCDemo
//
//  Created by Weiwen Wan on 2023/5/10.
//

#import "MyCollectionViewCell.h"
#import "Masonry.h"

@interface MyCollectionViewCell()

@property (nonatomic, strong) UILabel *label;

@end

@implementation MyCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor grayColor];
    UILabel *label = [[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:18];
    [self.contentView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    self.label = label;
}

- (void)setLabelText:(NSString *)labelText {
    _labelText = labelText;
    self.label.text = labelText;
}

-(void)prepareForReuse {
    [super prepareForReuse];
    self.label.text = @"";
}

@end
