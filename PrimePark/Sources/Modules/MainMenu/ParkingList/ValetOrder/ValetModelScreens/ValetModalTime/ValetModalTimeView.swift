//
//  ValetModalTimeView.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 05.05.2021.
//
// swiftlint:disable trailing_whitespace
import UIKit

protocol ValetModalTimeViewDelegate: class {
    func back()
    func chooseDay(date: Date)
    func chooseTime()
    func serveCar()
}

final class ValetModalTimeView: UIView {
    @IBOutlet weak var dayPickerCollection: UICollectionView!
    @IBOutlet weak var timeLabel: UILabel!
    
    weak var delegate: ValetModalTimeViewDelegate?
    
    var content: [ValetTimeModel] = [] {
        didSet {
            dayPickerCollection.reloadData()
            DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.5) {
                self.dayPickerCollection.selectItem(at: IndexPath(row: 1, section: 0), animated: true, scrollPosition: .left)
            }
        }
    }
    
    func commonInit(delegate: ValetModalTimeViewDelegate) {
        self.delegate = delegate
        dayPickerCollection.delegate = self
        dayPickerCollection.dataSource = self
        
        dayPickerCollection.registerNib(cellClass: ValetDayCell.self)
    }
    
    @IBAction func backTap(_ sender: Any) {
        delegate?.back()
    }
    
    @IBAction func timeTap(_ sender: Any) {
        delegate?.chooseTime()
    }
    
    @IBAction func serveCar(_ sender: Any) {
        delegate?.serveCar()
    }
}

extension ValetModalTimeView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return content.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ValetDayCell = collectionView.dequeueReusableCell(for: indexPath)
        print(content[indexPath.row], "\(indexPath.row)")
        cell.data = content[indexPath.row]
        
        return cell
    }
}

extension ValetModalTimeView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(content[indexPath.row].date)
        delegate?.chooseDay(date: content[indexPath.row].date)
    }
}

extension ValetModalTimeView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 44, height: 65)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
}
