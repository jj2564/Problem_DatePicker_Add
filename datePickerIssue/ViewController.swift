//
//  ViewController.swift
//  datePickerIssue
//
//  Created by IrvingHuang on 2020/6/9.
//  Copyright © 2020 Irving Huang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let formatString = "yyyy-MM-dd HH:mm"
    
    var startIsSelected: Bool = false
    var startTime = Date()
    var endTime = Date()
    
    // 設定成1 上午 11:00 確定 > 下午 11:00
    // 但設成2 上午 11:00 確定 > 下午 1:00
    /// 設定增加時數
    let duringHours = 1
    
    /// 顯示狀態
    let topLabel: UILabel = {
        let label = UILabel()
        label.text = "起始"
        label.font = UIFont.systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var scheduleDatePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .dateAndTime
        datePicker.minuteInterval = 10
        datePicker.date = self.startTime
        
        datePicker.locale = Locale(identifier: "zh_hant_TW")
        datePicker.addTarget(self, action: #selector(datePickerChanged), for: .valueChanged)
        datePicker.translatesAutoresizingMaskIntoConstraints = false

        return datePicker
    }()
    
    private func initPicker() {
        let currentDate = Date()
        var dateComponents = DateComponents()
        dateComponents.day = -7
        let oneWeekBefore = Calendar.current.date(byAdding: dateComponents, to: currentDate)
        dateComponents.day = +7
        let oneWeekAfter = Calendar.current.date(byAdding: dateComponents, to: currentDate)
        scheduleDatePicker.minimumDate = oneWeekBefore
        scheduleDatePicker.maximumDate = oneWeekAfter
    }
    
    let confirmButton: UIButton = {
        let button = UIButton()
        button.setTitle("確定", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.addTarget(
            self,
            action: #selector(handleConfirm),
            for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button

    }()
    
    let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("取消", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.addTarget(
            self,
            action: #selector(cancelConfirm),
            for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button

    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupView()
        initPicker()
    }

    @objc func datePickerChanged(datePicker: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = formatString

        if startIsSelected {
            endTime = datePicker.date
        } else {
            startTime = datePicker.date
        }
    }
    
    @objc func handleConfirm() {
        startIsSelected = !startIsSelected
        
        if startIsSelected {
            scheduleDatePicker.minimumDate = startTime
            topLabel.text = "結束"
            
            if let maximunDate = startTime.dateMax() {
                scheduleDatePicker.maximumDate = maximunDate
            }
            
            guard let defaultEndDate = startTime.addHour(hour: duringHours) else { return }
            
            scheduleDatePicker.setDate(defaultEndDate, animated: false)
        } else {
            endTime = scheduleDatePicker.date
        }
    }
    
    @objc func cancelConfirm() {
        startIsSelected = false
        topLabel.text = "起始"
        scheduleDatePicker.setDate(Date(), animated: false)
        initPicker()
    }
    
    
    private func setupView() {
        view.addSubview(scheduleDatePicker)
        view.addSubview(topLabel)
        view.addSubview(cancelButton)
        view.addSubview(confirmButton)
        
        NSLayoutConstraint.activate([
            scheduleDatePicker.leftAnchor.constraint(equalTo: view.leftAnchor),
            scheduleDatePicker.rightAnchor.constraint(equalTo: view.rightAnchor),
            scheduleDatePicker.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            scheduleDatePicker.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3),
            
            topLabel.bottomAnchor.constraint(equalTo: scheduleDatePicker.topAnchor, constant: 8),
            topLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            confirmButton.leftAnchor.constraint(equalTo: view.leftAnchor),
            confirmButton.topAnchor.constraint(equalTo: scheduleDatePicker.bottomAnchor, constant: 8),
            confirmButton.widthAnchor.constraint(equalTo: view.widthAnchor),
            confirmButton.heightAnchor.constraint(equalToConstant: 33),
            
            cancelButton.leftAnchor.constraint(equalTo: view.leftAnchor),
            cancelButton.topAnchor.constraint(equalTo: confirmButton.bottomAnchor, constant: 8),
            cancelButton.widthAnchor.constraint(equalTo: view.widthAnchor),
            cancelButton.heightAnchor.constraint(equalToConstant: 33)
        ])
    }
}


extension Date {
    
    /// 轉換為DateComponents
    var dateComponents: DateComponents {
        let calendar = Calendar.current
        return calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
    }
    
    /// 增加小時
    /// - Parameter month: 要加幾小時就給多少
    func addHour( hour: Int) -> Date? {
        let result = Calendar.current.date(byAdding: .hour, value: hour, to: self)
        return result
    }
    
    /// 取得今日最大時間
    func dateMax() -> Date? {
        let calendar = Calendar.current
        var components = self.dateComponents
        components.calendar = calendar
        components.hour = 23
        components.minute = 59
        let result = calendar.date(from: components)
        return result
    }
}
