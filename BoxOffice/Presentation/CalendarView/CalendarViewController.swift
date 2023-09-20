//
//  CalendarViewController.swift
//  BoxOffice
//
//  Created by Rhode, Rilla on 2023/04/04.
//

import UIKit

protocol CalendarViewControllerDelegate: AnyObject {
    func deliverData(_ data: Date)
}

final class CalendarViewController: UIViewController {
    private var date: Date
    weak var delegate: CalendarViewControllerDelegate?
    
    private let calendarView: UICalendarView = {
        let calendarView = UICalendarView()
        let gregorianCalendar = Calendar(identifier: .gregorian)
        calendarView.calendar = gregorianCalendar
        calendarView.locale = Locale(identifier: "ko_KR")
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        
        calendarView.fontDesign = .rounded
        return calendarView
    }()
    
    init(_ date: Date) {
        self.date = date
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureMainView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.post(name: .calendarViewDismiss, object: nil, userInfo: ["currentDate": date])
    }
    
    private func configureMainView() {
        view.backgroundColor = .white
        
        configureCalendarView()
    }
    
    private func configureCalendarView() {
        view.addSubview(calendarView)
        
        configureSelectedDate()
        configureCalendarRange()
        configureAutoLayout()
    }
    
    private func configureSelectedDate() {
        let dateSelection = UICalendarSelectionSingleDate(delegate: self)
        let dateComponents = date.convertString(isFormatted: true)
            .components(separatedBy: "-")
            .compactMap { Int($0) }
        
        
        guard let year = dateComponents[index: 0],
              let month = dateComponents[index: 1],
              let day = dateComponents[index: 2] else { return }
        
        let selectedDate = DateComponents(calendar: Calendar(identifier: .gregorian),
                                          year: year,
                                          month: month,
                                          day: day)
        
        calendarView.selectionBehavior = dateSelection
        dateSelection.selectedDate = selectedDate
    }
    
    private func configureCalendarRange() {
        let fromDateComponents = DateComponents(calendar: Calendar(identifier: .gregorian), year: 2003, month: 11, day: 11)
        let yesterdayDate = Date(timeIntervalSinceNow: -86400)
        
        guard let fromDate = fromDateComponents.date else { return }
        let calendarViewDateRange = DateInterval(start: fromDate, end: yesterdayDate)
        
        calendarView.availableDateRange = calendarViewDateRange
    }
    
    private func configureAutoLayout() {
        NSLayoutConstraint.activate([
            calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            calendarView.topAnchor.constraint(equalTo: view.topAnchor),
            calendarView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}

extension CalendarViewController: UICalendarSelectionSingleDateDelegate {
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        guard let date = dateComponents?.date else { return }
   
        self.date = date
        self.dismiss(animated: true)
    }
}


