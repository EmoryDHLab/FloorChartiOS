//
//  ViewController.swift
//  FloorChartiOS
//
//  Created by Noah Sutter on 4/3/19.
//  Copyright © 2019 Noah Sutter. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ChartViewController: UIViewController, ExpandedCellDelegate {
    
    @IBOutlet weak var grid: UICollectionView!
    @IBOutlet weak var gridFlowLayout: UICollectionViewFlowLayout!
    
    @IBOutlet weak var expandedGrid: UICollectionView!
    @IBOutlet weak var expandedGridFlow: UICollectionViewFlowLayout!
    
    var rows = 10
    var cols = 10
    var spacing: CGFloat = 3.0
    var smallSpacing: CGFloat = 1.0
    
    var expandedGridRows = 3
    var expandedGridCols = 3
    var expandedGridSpacing: CGFloat = 3
    
    var lastSelectedC = -1
    var lastSelectedR = -1
    var backgroudAlpha:CGFloat = 0.3
    
    var selectedColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
    
    var expandedColorGrid: [UIColor] = []
    
    
    
    var ref: DatabaseReference!
    
    var gridColors: [UIColor] = [UIColor]()
    //var allColors: [[[[UIColor]]]]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        expandedColorGrid = [UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: backgroudAlpha),
         UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: backgroudAlpha),
         UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: backgroudAlpha),
         UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: backgroudAlpha),
         UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: backgroudAlpha),
         UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: backgroudAlpha),
         UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: backgroudAlpha),
         UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: backgroudAlpha),
         UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: backgroudAlpha)]
        
        ref = Database.database().reference()
        
        
        
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
        
        //writeAllIndexes()
        //writeBlankGrid()
        
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
    
    func itemClicked(colorGrid: [UIColor], index: Int, r: Int, c: Int) {
        expandedColorGrid = colorGrid
        print(expandedColorGrid)
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
        
        for row in 0..<rows {
            for col in 0..<cols {
                
                let indexPath = IndexPath(row: row, section: col)
                let cell = grid.cellForItem(at: indexPath) as! GridCell
                
                //let cell = grid.dequeueReusableCell(withReuseIdentifier: "largeGridCell", for: indexPath) as! GridCell
                cell.backgroundColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
                cell.yearGrid.backgroundColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)

                print("Reset Color")
            }
        }
    }
    
    func writeAllIndexes() {
        for r in 0..<rows {
            for c in 0..<cols {
                for eR in 0..<expandedGridRows {
                    for eC in 0..<expandedGridRows {
                        let index = (r * cols * expandedGridRows * expandedGridCols) + (eR * cols * expandedGridCols) + (c * expandedGridCols) + eC
                        //let cell = grid.dequeueReusableCell(withReuseIdentifier: "largeGridCell", for: indexPath) as! GridCell
                        print(index)
                    }
                }
            }
        }
    }
    
    func writeBlankGrid() {
        var blankValues: Dictionary<String, Dictionary<String, Int>> = Dictionary<String, Dictionary<String, Int>>()
        for i in 0..<900 {
            blankValues[String(i)] = ["r": 255, "g": 255, "b": 255]
        }
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

extension ChartViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == self.grid {
            return rows
        } else {
            return expandedGridRows
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.grid {
            return cols
        } else {
            return expandedGridCols
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.grid {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "largeGridCell", for: indexPath) as! GridCell
            
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
            //cell.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            
            // Setting up the small cell's information
            
            
            let index = indexPath.row * cols + indexPath.section
            cell.index = index
            cell.largeRow = indexPath.row
            cell.largeCol = indexPath.section
            cell.delegate = self
            cell.colorGrid = colorGrid
            //print("A")
            //print(cell.colorGrid)
            cell.yearGrid.delegate = cell
            cell.yearGrid.dataSource = cell
            cell.yearGridFlow.minimumLineSpacing = smallSpacing
            cell.yearGridFlow.minimumInteritemSpacing = smallSpacing
            cell.yearGridFlow.sectionInset = UIEdgeInsets(top: smallSpacing, left: smallSpacing, bottom: smallSpacing, right: smallSpacing)
            
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("PICKED")
        if collectionView == self.grid {
            // TODO: Allow this to select grids here so if a line is clicked not the actual cell it still selects it
            print("B")
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "largeGridCell", for: indexPath) as! GridCell
            let colorGrid = cell.colorGrid
            expandedColorGrid = colorGrid
            expandedGrid.reloadData()
        } else {
            print(indexPath.row)
            print(indexPath.section)
            print("A")
            // Expanded grid clicked
            
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
            
            print("Else")
        }
    }
}

extension ChartViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionViewLayout == gridFlowLayout {
            let totalHeight = collectionView.bounds.size.height - (2 * spacing * CGFloat(rows))
            let numberOfCellsPerRow = cols
            let dimensions = totalHeight / CGFloat(numberOfCellsPerRow)
            return CGSize(width: dimensions, height: dimensions)
        } else {
            let totalHeight = collectionView.bounds.size.height - (2 * expandedGridSpacing)
            let numberOfCellsPerRow = expandedGridCols
            let dimensions = totalHeight / CGFloat(numberOfCellsPerRow)
            return CGSize(width: dimensions, height: dimensions)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == expandedGrid {
            if section < 2 {
                return expandedGridSpacing
            } else {
                return 0
            }
        } else {
            return spacing
        }
    }
//
//    func collectionView
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        if
//    }
}
