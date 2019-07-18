//
//  ViewController.swift
//  UndoManagerExample
//
//  Created by Ankush Chakraborty on 16/07/19.
//  Copyright © 2019 Ankush Chakraborty. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var collectionViewColorPallet: UICollectionView!
    
    @IBOutlet weak var viewBox: UIView!
    @IBOutlet weak var buttonUndo: UIButton!
    @IBOutlet weak var buttonRedo: UIButton!
    
    fileprivate var colors: [UIColor] {
        get {
            return [.red,
                    .black,
                    .blue,
                    .green,
                    .orange,
                    .brown,
                    .cyan,
                    .darkGray,
                    .magenta,
                    .purple,
                    .yellow]
        }
    }
}

//MARK: - View controller life cycle

extension ViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateButtonsState()
    }
}

//MARK: - Button actions

extension ViewController {
    @IBAction func buttonUndoDidTap(_ sender: Any) {
        undoManager?.undo()
        updateButtonsState()
    }
    
    @IBAction func buttonRedoDidTap(_ sender: Any) {
        undoManager?.redo()
        updateButtonsState()
    }
}

//MARK: - File private methods

extension ViewController {
    fileprivate func updateButtonsState() {
        buttonUndo.isEnabled = undoManager?.canUndo ?? false
        buttonRedo.isEnabled = undoManager?.canRedo ?? false
    }
    
    fileprivate func registerForUndoPositionChange(withPoint: CGPoint) {
        let oldPoint = viewBox.center
        undoManager?.registerUndo(withTarget: self, handler: { (selfTarget) in
            selfTarget.registerForUndoPositionChange(withPoint: oldPoint)
        })
        UIView.beginAnimations("animateBox", context: nil)
        UIView.animate(withDuration: 0.3) {
            self.viewBox.center = withPoint
        }
        UIView.commitAnimations()
    }
    
    fileprivate func registerForUndoColorChange(withColor: UIColor) {
        let oldColor = viewBox.backgroundColor!
        undoManager?.registerUndo(withTarget: self, handler: { (selfTarget) in
            selfTarget.registerForUndoColorChange(withColor: oldColor)
        })
        UIView.beginAnimations("animateBox", context: nil)
        UIView.animate(withDuration: 0.3) {
            self.viewBox.backgroundColor = withColor
        }
        UIView.commitAnimations()
    }
}

//MARK: - Touch delegate

extension ViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = event?.allTouches?.first else {
            return
        }
        if touch.view == viewBox {
            registerForUndoPositionChange(withPoint: viewBox.convert(touch.location(in: viewBox),
                                                       to: view))
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = event?.allTouches?.first else {
            return
        }
        if touch.view == viewBox {
            viewBox.center = viewBox.convert(touch.location(in: viewBox), to: self.view)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        updateButtonsState()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        updateButtonsState()
    }
}

//MARK: - Collection view delegate

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        registerForUndoColorChange(withColor: colors[indexPath.item])
        viewBox.backgroundColor = colors[indexPath.item]
        updateButtonsState()
    }
}

//MARK: - Collection view data source

extension ViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "colorCellIdentifier", for: indexPath)
        cell.contentView.backgroundColor = colors[indexPath.item]
        return cell
    }
}

//MARK: - Collection view flow layout

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.height, height: collectionView.frame.size.height)
    }
}
