//
//  GridCell.swift
//  FloorChartiOS
//
//  Created by Noah Sutter on 4/3/19.
//  Copyright © 2019 Noah Sutter. All rights reserved.
//

import UIKit

protocol ExpandedCellDelegate: ChartViewController {
    func itemClicked(colorGrid: [UIColor], index: Int, r: Int, c: Int)
}

class GridCell: UICollectionViewCell {
    @IBOutlet weak var yearGrid: UICollectionView!
    @IBOutlet weak var yearGridFlow: UICollectionViewFlowLayout!
    
    weak var delegate: ExpandedCellDelegate?
    
    var largeRow = -1
    var largeCol = -1
    
    var rows = 3
    var cols = 3
    var colorGrid: [UIColor] = [UIColor]()
    var index = -1
    
}

extension GridCell: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return rows
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cols
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "smallGridCell", for: indexPath)
        let index = indexPath.row * cols + indexPath.section
        cell.backgroundColor = colorGrid[index]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.row * cols + indexPath.section
        
        // Change the opacity for this grid to reflect that it is selected
        for i in 0..<colorGrid.count {
            colorGrid[i] = colorGrid[i].withAlphaComponent(1.0)
            print(colorGrid[i].withAlphaComponent(0.0))
        }
        //colorGrid[index] = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        
        yearGrid.reloadData()
        
        
        delegate?.itemClicked(colorGrid: colorGrid, index: index, r: largeRow, c: largeCol)
        //yearGrid.backgroundColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        print(colorGrid)
        print("Clicked")
    }
}

extension GridCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalHeight = collectionView.bounds.size.height - (2 * CGFloat(rows))
        let numberOfCellsPerRow = cols
        let dimensions = totalHeight / CGFloat(numberOfCellsPerRow)
        return CGSize(width: dimensions, height: dimensions)
    }
}
