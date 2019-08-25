//
//  ChipFilterView.swift
//  Layout
//
//  Created by Thulasi Ram Boddu on 24/08/19.
//  Copyright © 2019 Test. All rights reserved.
//

import UIKit

class ChipFilterView: UIView {
    
    let chipHeight = 40
    let rowGap: CGFloat = 10
    let chipExtraWidth: CGFloat = 28
    
    var filtersArray:[String] = []
    var selectedFilters:[String] = []
    var stretchToBorder:Bool = false
    var rearangeRequired:Bool = false
    var printedElements:[String] = []
    var heightOfView: CGFloat = 0.0
    var getFilters:([String])->Void = { arr in
        
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupFilters(filters:[String],selectedFil:[String],rearrange:Bool ,stretch:Bool) -> CGFloat {
        self.stretchToBorder = stretch
        self.filtersArray = filters
        self.selectedFilters = selectedFil
        self.rearangeRequired = rearrange
        print("Total = \(self.filtersArray.count)")
    
        setupFilters()
      
        let set1:Set<String> = Set(filters)
        let set2:Set<String> = Set(printedElements)
        print("Printed = \(self.printedElements.count)")
        print("Missing -> \(set1.subtracting(set2))")
        return self.heightOfView + CGFloat(chipHeight)
    }
  
    func setupFilters() {
        
        var rowNumber = 1 //Hold current row value
        var remaining = self.filtersArray.count //Hold current indext to start at this row
        repeat {
            //Check and fill number labels fit in from current index in current row
            self.calculateAndAddMaximumLabels(row:rowNumber)
            remaining = self.filtersArray.count
            rowNumber = rowNumber+1
        }while(0 < remaining) //Repet till current index is last
    }
    
    //Add maximum labels and return remaining
    func calculateAndAddMaximumLabels(row:Int) {
        let yPos = (chipHeight + Int(rowGap))*(row - 1)
        let totalSpace = self.frame.size.width  //Hold total space/width
        var spaceUsed: CGFloat = 0.0 //To calculate space used after every label added
        var inputViews:[ChipView] = [] //Saave added input labels to rearrange
        let count = self.filtersArray.count
        let localArray = self.filtersArray
        for i in 0..<count {
            let string = localArray[i]
            let inputView = ChipView()
            inputView.titleLbl.text = string
            let finalWidth = chipExtraWidth + string.widthOfString(usingFont: inputView.titleLbl.font) //45 in the view extra size without label width
            inputView.frame = CGRect(x: Int(spaceUsed), y: yPos, width: Int(finalWidth), height: chipHeight)
            inputView.titleLbl.text = string
            
            inputView.getUpdatedText = {str in
                if self.selectedFilters.contains(str) {
                    self.selectedFilters.removeAll(where: {$0 == str })
                    inputView.accessoryImgView.isHidden = true
                    inputView.titleLbl.textColor = "#7f7f7f".hexStringToUIColor()
                    inputView.backgroundColor = "#f4f4f4".hexStringToUIColor()
                    inputView.titileLEadingConstant.constant = 12
                    inputView.accessoryImgWidth.constant = 10
                }
                else {
                    self.selectedFilters.append(str)
                    
                    inputView.accessoryImgView.isHidden = false
                    inputView.titleLbl.textColor = UIColor.white
                    inputView.backgroundColor = "#5dbdcd".hexStringToUIColor()
                    inputView.titileLEadingConstant.constant = 8
                    inputView.accessoryImgWidth.constant = 15
                }
                
                self.getFilters(self.selectedFilters)
                
            }
            if selectedFilters.contains(string) {
                inputView.accessoryImgView.isHidden = false
                inputView.titleLbl.textColor = UIColor.white
                inputView.backgroundColor = "#5dbdcd".hexStringToUIColor()
                inputView.titileLEadingConstant.constant = 8
                inputView.accessoryImgWidth.constant = 15
            }
            else {
                inputView.accessoryImgView.isHidden = true
                inputView.titleLbl.textColor = "#7f7f7f".hexStringToUIColor()
                inputView.backgroundColor = "#f4f4f4".hexStringToUIColor()
                inputView.titileLEadingConstant.constant = 12
                inputView.accessoryImgWidth.constant = 10
            }
            
            spaceUsed = spaceUsed + finalWidth + CGFloat(rowGap)
            self.heightOfView = CGFloat(yPos)
            
            if ((spaceUsed-rowGap) <= totalSpace) {
                self.addSubview(inputView)
                self.printedElements.append(inputView.titleLbl.text!)
                inputViews.append(inputView)
                self.filtersArray.removeAll(where: {$0 == string })
            }
            else {
                if rearangeRequired && (i < count-1) {
                    spaceUsed = spaceUsed - finalWidth - CGFloat(rowGap)
                }
                else {
                    if stretchToBorder {
                        let finalGap = totalSpace - (spaceUsed-finalWidth-rowGap-rowGap) //Gaap ramianed after last lbel
                        if inputViews.count > 1 {
                            let modifiedWidth = (finalGap)/CGFloat(inputViews.count) //Split remained sapce to equal parts
                            for j in 0..<inputViews.count {
                                let kInputView = inputViews[j]
                                //Rearrange and resize added input labels
                                kInputView.frame = CGRect(x: Int(kInputView.frame.origin.x + (CGFloat(j)*modifiedWidth)), y: yPos, width: Int(kInputView.frame.size.width + modifiedWidth), height: chipHeight)
                            }
                        }
                        else {
                            if self.filtersArray.count > 1 {
                                let kInputView = inputViews[0]
                                //Rearrange and resize added input labels
                                kInputView.frame = CGRect(x: 0, y: yPos, width: Int(totalSpace), height: chipHeight)
                            }
                        }
                    }
                    break
                }
            }
        }
    }

}
