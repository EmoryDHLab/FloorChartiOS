//
//  ChartViewController.swift
//  FloorChartiOS
//
//  Created by Noah Sutter on 4/3/19.
//  Copyright © 2019 Noah Sutter. All rights reserved.
//
//  This code controls the main view controller for the color picker
//  It handles the logic associated with the 10x10 grid (of 3x3 cells),
//  the expanded grid (which is used to select specific cells that would be too small to click),
//  and the color selector
//
//

import UIKit
import FirebaseDatabase

class ChartViewController: UIViewController, ExpandedCellDelegate {
    
    // This grid and flow layout is the 10x10 grid of smaller 3x3 grids
    @IBOutlet weak var grid: UICollectionView!
    @IBOutlet weak var gridFlowLayout: UICollectionViewFlowLayout!
    
    // This grid and flow layout are for the large 3x3 grid that is used to select colors for smaller grid locaitons
    @IBOutlet weak var expandedGrid: UICollectionView!
    @IBOutlet weak var expandedGridFlow: UICollectionViewFlowLayout!
    
    // Defining the rows cols and the spacing for the 10x10 grid
    var rows = 10
    var cols = 10
    var spacing: CGFloat = 3.0
    var smallSpacing: CGFloat = 1.0
    
    // Defining the rows cols and spacing for the expanded 3x3 grid
    var expandedGridRows = 3
    var expandedGridCols = 3
    var expandedGridSpacing: CGFloat = 3
    
    // Storing the last selected cell in the 10x10 grid in order to highlight the correct one
    var lastSelectedC = -1
    var lastSelectedR = -1
    
    // The alpha value for all cells in the background
    var backgroudAlpha:CGFloat = 0.3
    // THe color of the selected cell in the expanded grid, is used to make the smaller grid reflect the expanded grid
    var selectedColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
    
    // An array containing the colors in the selected grid
    var expandedColorGrid: [UIColor] = []
    
    
    // A reference to the firebase database, will be used to get the colors from firebase
    var ref: DatabaseReference!
    
    // An array of all the colors for the whole grid
    var gridColors: [UIColor] = [UIColor]()

    
    // ViewDidLoad is called the first time the screen shows up
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initializing the expanded grid to be all white as nothing has been selected yet
        expandedColorGrid = [UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: backgroudAlpha),
         UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: backgroudAlpha),
         UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: backgroudAlpha),
         UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: backgroudAlpha),
         UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: backgroudAlpha),
         UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: backgroudAlpha),
         UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: backgroudAlpha),
         UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: backgroudAlpha),
         UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: backgroudAlpha)]
        
        // Defining the database
        ref = Database.database().reference()
        
        
        // Setting up the data sources, delegates, and spacing of the grids
        grid.dataSource = self
        grid.delegate = self
        
        gridFlowLayout.minimumLineSpacing = spacing
        gridFlowLayout.minimumInteritemSpacing = spacing
        gridFlowLayout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        
        expandedGrid.dataSource = self
        expandedGrid.delegate = self
        expandedGrid.backgroundColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
        
        expandedGridFlow.minimumInteritemSpacing = expandedGridSpacing
        expandedGridFlow.minimumLineSpacing = expandedGridSpacing
        expandedGridFlow.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: expandedGridSpacing, right: 0)
        
        
        // Getting the colors from the database
        let refHandle = ref.child("grid").observe(DataEventType.value, with: { (snapshot) in
            let gridValues = snapshot.value as? [Dictionary<String, Int>]
            if (gridValues != nil) {
                for i in 0..<gridValues!.count {
                    let val = gridValues![i]
                    let r = CGFloat(val["r"]!) / 255.0
                    let g = CGFloat(val["g"]!) / 255.0
                    let b = CGFloat(val["b"]!) / 255.0
                    //let color = UIColor(red: r, green: g, blue: b, alpha: 1.0)
                    let color = UIColor(red: r, green: g, blue: b, alpha: self.backgroudAlpha)
                    self.gridColors.append(color)
                    
                }
                self.grid.reloadData()
            }
        })
    }
    
    // itemClicked is called everytime a cell is selected in the 10x10 grid
    func itemClicked(colorGrid: [UIColor], index: Int, r: Int, c: Int) {
        // Changing the expanded grid to match the selected cell
        expandedColorGrid = colorGrid
        expandedGrid.reloadData()
        
        // If a row and col have been selected before reset the alpha for that last selection
        if lastSelectedR != -1 && lastSelectedC != -1 && (lastSelectedR != r || lastSelectedC != c) {
            let indexPath = IndexPath(row: lastSelectedR, section: lastSelectedC)
            let cell = grid.cellForItem(at: indexPath) as! GridCell
            var colorGrid = cell.colorGrid
            for i in 0..<colorGrid.count {
                colorGrid[i] = colorGrid[i].withAlphaComponent(backgroudAlpha)
            }
            cell.colorGrid = colorGrid
            cell.yearGrid.reloadData()
        }
        
        // Save this as the last selected row and column
        lastSelectedC = c
        lastSelectedR = r
        
    
// THE FOLLOWING CODE IS CURRENTLY UNUSED BUT SIMILAR LOGIC WILL BE USED SHORTLY
//        for row in 0..<rows {
//            for col in 0..<cols {
//
//                let indexPath = IndexPath(row: row, section: col)
//                let cell = grid.cellForItem(at: indexPath) as! GridCell
//
//                //let cell = grid.dequeueReusableCell(withReuseIdentifier: "largeGridCell", for: indexPath) as! GridCell
//                cell.backgroundColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
//                cell.yearGrid.backgroundColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
//
//                print("Reset Color")
//            }
//        }
    }
    
//    func writeAllIndexes() {
//        for r in 0..<rows {
//            for c in 0..<cols {
//                for eR in 0..<expandedGridRows {
//                    for eC in 0..<expandedGridRows {
//                        let index = (r * cols * expandedGridRows * expandedGridCols) + (eR * cols * expandedGridCols) + (c * expandedGridCols) + eC
//                        //let cell = grid.dequeueReusableCell(withReuseIdentifier: "largeGridCell", for: indexPath) as! GridCell
//                        print(index)
//                    }
//                }
//            }
//        }
//    }
    
    // writeBlankGrid writes a blank grid to the database to reset it
    func writeBlankGrid() {
        // Creates a blank dictionary of integer locations to colors
        var blankValues: Dictionary<String, Dictionary<String, Int>> = Dictionary<String, Dictionary<String, Int>>()
        for i in 0..<900 {
            blankValues[String(i)] = ["r": 255, "g": 255, "b": 255]
        }
        
        // Set the database to be blank
        self.ref.child("grid").setValue(blankValues) {
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                print("Blank Grid could not be saved: \(error).")
            } else {
                print("Blank Grid saved successfully!")
            }
        }
    }
}

// This extension extra functionality for the collection views (the grids)
extension ChartViewController: UICollectionViewDataSource {
    
    // This function is called in the setup of the grids and returns the desired number of rows
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == self.grid {
            return rows
        } else {
            return expandedGridRows
        }
    }
    
    // This function is called in the setup of the grids and returns the desired number of columns
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.grid {
            return cols
        } else {
            return expandedGridCols
        }
    }
    
    // This funciton is called whenever the cell is populated and determines what to do when that occurs
    // It sets the correct colors based on the color grid
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.grid {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "largeGridCell", for: indexPath) as! GridCell
            
            // If the color grid has not been loaded, set all the colors to white, otherwise set them to the appropriate values
            var colorGrid = [UIColor]()
            if self.gridColors == [UIColor]() {
                for i in 0..<9 {
                    colorGrid.append(UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
                }
            } else {
                let r = indexPath.row
                let c = indexPath.section
                for eR in 0..<expandedGridRows {
                    for eC in 0..<expandedGridRows {
                        let index = (r * cols * expandedGridRows * expandedGridCols) + (eR * cols * expandedGridCols) + (c * expandedGridCols) + eC
                        colorGrid.append(gridColors[index])
                    }
                }
            }

            // Set the color of the cell
            cell.backgroundColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
            cell.yearGrid.backgroundColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
            
            // Setting up the small cell's information
            // setting index and row/col so the cell knows which cell it is
            cell.largeRow = indexPath.row
            cell.largeCol = indexPath.section
            // setting the delegate to self so the cell can interact with this ChartViewController
            cell.delegate = self
            // Setting up the 3x3 grid to have the correct colors
            cell.colorGrid = colorGrid
            cell.yearGrid.delegate = cell
            cell.yearGrid.dataSource = cell
            // setting up the spacing for the 3x3 grid
            cell.yearGridFlow.minimumLineSpacing = smallSpacing
            cell.yearGridFlow.minimumInteritemSpacing = smallSpacing
            cell.yearGridFlow.sectionInset = UIEdgeInsets(top: smallSpacing, left: smallSpacing, bottom: smallSpacing, right: smallSpacing)
            
            // Reloading the Cell to display the new information
            cell.yearGrid.reloadData()
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "expandedGridCell", for: indexPath)
            let index = indexPath.row * expandedGridCols + indexPath.section
            //print(index)
            cell.backgroundColor = expandedColorGrid[index]
            return cell
        }
    }
    
    // This function is called when a cell is clicked in either the 10x10 grid or the expanded grid
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // If the 10x10 grid was clicked, set the expanded color grid equal to the selected cell
        if collectionView == self.grid {
            // TODO: Allow this to select grids here so if a line is clicked not the actual cell it still selects it
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "largeGridCell", for: indexPath) as! GridCell
            let colorGrid = cell.colorGrid
            expandedColorGrid = colorGrid
            expandedGrid.reloadData()
            
        } else { // If the expanded grid was clicked, change the color to the selected color in both expanded and 10x10 grid

            // Change the color of the cell item clicked to the selected Color
            expandedColorGrid[indexPath.row * 3 + indexPath.section] = selectedColor
            expandedGrid.reloadData()
            
            // Change the color of the small cell to reflect the grid
            if lastSelectedR != -1 && lastSelectedC != -1 {
                let indexPath = IndexPath(row: lastSelectedR, section: lastSelectedC)
                let cell = grid.cellForItem(at: indexPath) as! GridCell
                cell.colorGrid = expandedColorGrid
                cell.yearGrid.reloadData()
            }
        }
    }
}

// This extension controls the layout of the grids (the spacing between cells etc.)
extension ChartViewController: UICollectionViewDelegateFlowLayout {
    
    // This function controls the size of the items
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // If it is the 10x10 grid set the spacing and dimensions as follows
        if collectionViewLayout == gridFlowLayout {
            let totalHeight = collectionView.bounds.size.height - (2 * spacing * CGFloat(rows))
            let numberOfCellsPerRow = cols
            let dimensions = totalHeight / CGFloat(numberOfCellsPerRow)
            return CGSize(width: dimensions, height: dimensions)
        } else { // The expanded grid
            let totalHeight = collectionView.bounds.size.height - (2 * expandedGridSpacing)
            let numberOfCellsPerRow = expandedGridCols
            let dimensions = totalHeight / CGFloat(numberOfCellsPerRow)
            return CGSize(width: dimensions, height: dimensions)
        }
    }
    
    // This function controls the iteritem spacing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        // Set the spacing for the exanded grid
        if collectionView == expandedGrid {
            if section < 2 {
                return expandedGridSpacing
            } else {
                return 0
            }
        } else { // The spacing for the 10x10 grid
            return spacing
        }
    }
}
