//
//  SkillCreator.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 01/05/2025.
//  Copyright © 2025 Alexander Kvamme. All rights reserved.
//

//
//  MuscleCreatorScreen.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 29/04/2025.
//  Copyright © 2025 Alexander Kvamme. All rights reserved.
//

import UIKit
import SnapKit


class SkillCreatorScreen: UIViewController, isStringReceiver, SkillReceiver, MuscleReceiver, PickableReceiver {
    func receive(pickable: any PickableEntity) {
        print("received ", pickable)
    }
    
    func receive(muscles: [Muscle]) {
        print("received muscles ", muscles)
    }
    
    // MARK:: R
    func receive(skills: [Skill]) {
        print("received skills ", skills)
    }
    
    var stringReceivedHandler: ((String) -> Void) = { _ in
        // Empty implementation
    }

    lazy var header: TwoLabelStack = {
        let stack = TwoLabelStack(frame: CGRect(x: 0, y: 100, width: Constant.UI.width, height: 70), topText: "New skill", topFont: UIFont.custom(style: .bold, ofSize: .medium), topColor: UIColor.akDark.withAlphaComponent(0.4), bottomText: "Name of new Skill", bottomFont: UIFont.custom(style: .bold, ofSize: .big), bottomColor: UIColor.akDark, fadedBottomLabel: false)
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
            let newSkill = DatabaseFacade.makeSkill(named: str)
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
        let configuration = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold)
        let icon = UIImage(systemName: "book", withConfiguration: configuration)
        let rightBarButton = UIBarButtonItem(
            image: icon,
            style: .plain,
            target: self,
            action: #selector(rightBarButtonTapped)
        )
        
        // Customize the appearance if needed
        rightBarButton.tintColor = .akDark
        
        // Set it as the right bar button item
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    @objc private func rightBarButtonTapped() {
        let skills = DatabaseFacade.fetchSkills()
        let musclePicker = PickerController<Skill>.init(withPicksFrom: skills, withPreselection: [])
        musclePicker.pickableReceiver = self
        navigationController?.pushViewController(musclePicker, animated: Constant.Animation.pickerVCsShouldAnimateIn)
    }

}

