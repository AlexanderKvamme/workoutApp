//
//  MuscleCreatorScreen.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 29/04/2025.
//  Copyright © 2025 Alexander Kvamme. All rights reserved.
//

import UIKit
import SnapKit


class MuscleCreatorScreen: UIViewController, isStringReceiver, MuscleReceiver, PickableReceiver {
    func receive(pickable: any PickableEntity) {
        print("FIXME: received pickable")
    }
    
    // MARK:: R
    func receive(muscles: [Muscle]) {
        print("received muscles: ", muscles)
    }
    
    var stringReceivedHandler: ((String) -> Void) = { _ in
        // Empty implementation
    }

    lazy var header: TwoLabelStack = {
        let stack = TwoLabelStack(frame: CGRect(x: 0, y: 100, width: Constant.UI.width, height: 70), topText: "New Muscle", topFont: UIFont.custom(style: .bold, ofSize: .medium), topColor: UIColor.akDark.withAlphaComponent(0.4), bottomText: "Name of new muscle", bottomFont: UIFont.custom(style: .bold, ofSize: .big), bottomColor: UIColor.akDark, fadedBottomLabel: false)
        stack.button.accessibilityIdentifier = "workout-name-button"
        stack.bottomLabel.adjustsFontSizeToFitWidth = true
        
        return stack
    }()
    
    lazy var inputVC: InputViewController = {
        let vc = InputViewController(inputStyle: .text)
        vc.delegate = self
        return vc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .akLight
        navigationItem.hidesBackButton = false
        
        setupNavigationBar()
        setupRightBarButtonItem()
        
        stringReceivedHandler = { [weak self] (str: String) -> Void in
            print(str)
            DatabaseFacade.makeMuscle(named: str)
            DatabaseFacade.saveContext()
            self?.navigationController?.popViewController(animated: true)
        }
        
        view.addSubview(header)
        header.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(80)
            make.left.right.equalTo(view.safeAreaLayoutGuide)
        }
        
        view.addSubview(inputVC.view)
        inputVC.view.snp.makeConstraints { make in
            make.top.equalTo(header.snp.bottom)
            make.left.right.equalToSuperview()
        }
    }
    
    private func setupNavigationBar() {
        styleBackButton()
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationItem.hidesBackButton = false
    }
    
    private func setupRightBarButtonItem() {
        let menuView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        menuView.translatesAutoresizingMaskIntoConstraints = false
        menuView.backgroundColor = .clear
        menuView.isUserInteractionEnabled = true

        let configuration = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
        let imageView = UIImageView(image: UIImage(systemName: "book", withConfiguration: configuration))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .akDark
        imageView.isUserInteractionEnabled = false
        menuView.addSubview(imageView)

        NSLayoutConstraint.activate([
            menuView.widthAnchor.constraint(equalToConstant: 44),
            menuView.heightAnchor.constraint(equalToConstant: 44),
            imageView.centerXAnchor.constraint(equalTo: menuView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: menuView.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 22),
            imageView.heightAnchor.constraint(equalToConstant: 22)
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(rightBarButtonTapped))
        menuView.addGestureRecognizer(tap)

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: menuView)
    }
    
    @objc private func rightBarButtonTapped() {
        // FIXME: Her kanskjeeee
        let muscles = DatabaseFacade.fetchMuscles()
        let musclePicker = PickerController<Muscle>.init(withPicksFrom: muscles, withPreselection: [])
        musclePicker.pickableReceiver = self
        navigationController?.pushViewController(musclePicker, animated: Constant.Animation.pickerVCsShouldAnimateIn)
    }

}

