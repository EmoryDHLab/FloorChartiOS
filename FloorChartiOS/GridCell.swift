//
//  GridCell.swift
//  FloorChartiOS
//
//  Created by Noah Sutter on 4/3/19.
//  Copyright © 2019 Noah Sutter. All rights reserved.
//
//  This code controls the 3x3 grids
//

import UIKit

// Defining a protocol that will be used to interact with ChartViewController when a 3x3 cell is clicked
protocol ExpandedCellDelegate: ChartViewController {
    func itemClicked(colorGrid: [UIColor], index: Int, r: Int, c: Int)
}

class GridCell: UICollectionViewCell {
    // yearGrid is the 3x3 cell collection, yearGridFlow defines the layout of the 3x3 grid
    @IBOutlet weak var yearGrid: UICollectionView!
    @IBOutlet weak var yearGridFlow: UICollectionViewFlowLayout!
    
    // This is set upon 3x3 cell creating in ChartViewController so that this class can interact with ChartViewController
    weak var delegate: ExpandedCellDelegate?
    
    // This cell's row and col in the 10x10 grid in ChartViewController
    var largeRow = -1
    var largeCol = -1
    
    // The color grid that appears in this 3x3 grid
    var rows = 3
    var cols = 3
    var colorGrid: [UIColor] = [UIColor]()    
}

// This extension controls the data for and what happens to the 3x3 grid
extension GridCell: UICollectionViewDataSource {
    
    // This function defines the number of rows in the grid
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return rows
    }
    
    // This function defines the number of columns in the grid
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cols
    }
    
    // This function defines the data for each cell in the grid when it is intialized
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Set color of the cell in the 3x3 grid
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "smallGridCell", for: indexPath)
        let index = indexPath.row * cols + indexPath.section
        cell.backgroundColor = colorGrid[index]
        return cell
    }
    
    // This function is called when a cell is clicked, it highlights this 3x3 grid and alerts ChartViewController
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.row * cols + indexPath.section
        
        // Change the opacity for this grid to reflect that it is selected
        for i in 0..<colorGrid.count {
            colorGrid[i] = colorGrid[i].withAlphaComponent(1.0)
            print(colorGrid[i].withAlphaComponent(0.0))
        }
        yearGrid.reloadData()
        
        // Alert ChartViewController that this 3x3 grid was clicked
        delegate?.itemClicked(colorGrid: colorGrid, index: index, r: largeRow, c: largeCol)
    }
}

// This extension controls how the grid will look with spacing and sizing
extension GridCell: UICollectionViewDelegateFlowLayout {
    // THis function defines the size of each cell based on number of rows and cols
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalHeight = collectionView.bounds.size.height - (2 * CGFloat(rows))
        let numberOfCellsPerRow = cols
        let dimensions = totalHeight / CGFloat(numberOfCellsPerRow)
        return CGSize(width: dimensions, height: dimensions)
    }
}
