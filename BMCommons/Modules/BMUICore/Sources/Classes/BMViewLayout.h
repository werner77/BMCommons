//
// Created by Werner Altewischer on 05/09/2017.
//

typedef NS_OPTIONS(NSUInteger, BMViewLayoutDirection) {
    BMViewLayoutDirectionNone = 0,
    BMViewLayoutDirectionHorizontal = 1 << 0,
    BMViewLayoutDirectionVertical = 1 << 1
};

typedef NS_OPTIONS(NSUInteger, BMViewLayoutAlignment) {
    BMViewLayoutAlignmentLeft = 1 << 0,
    BMViewLayoutAlignmentRight = 1 << 1,
    BMViewLayoutAlignmentCenterHorizontally = 1 << 2,
    BMViewLayoutAlignmentTop = 1 << 3,
    BMViewLayoutAlignmentBottom = 1 << 4,
    BMViewLayoutAlignmentCenterVertically = 1 << 5
};
