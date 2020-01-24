//
//  MoonPhaseCalendarBarItem.swift
//  MTMR
//
//  Created by D on 24/01/2020.
//  Copyright © 2020 Anton Palgunov. All rights reserved.
//

import Cocoa
import CoreLocation

class MoonPhaseCalendarBarItem: CustomButtonTouchBarItem, Widget {
    static var name: String = "moonPhase"
    static var identifier: String = "com.toxblh.mtmr.moonPhase"
    
    private let activity: NSBackgroundActivityScheduler
    private var tests = 1;
    init(identifier: NSTouchBarItem.Identifier) {
        activity = NSBackgroundActivityScheduler(identifier: "\(identifier.rawValue).updatecheck")
        activity.interval = 2.0
     
        
        super.init(identifier: identifier, title: "")
        
        image = NSImage(named: NSImage.Name(moon_phase(yearParam: 2020, monthParam: 1, dayParam: 24)))
      activity.repeats = true
            activity.qualityOfService = .utility
            activity.schedule { (completion: NSBackgroundActivityScheduler.CompletionHandler) in
                self.tests = self.tests + 1;
                DispatchQueue.main.async {
                    
                  
                    let calendar = Calendar.current
                      let date = Date()
                    self.image = NSImage(named: NSImage.Name(self.moon_phase(yearParam: calendar.component(.year, from: date),
                                                                             monthParam: calendar.component(.month, from: date),
                                                                             dayParam: calendar.component(.day, from: date))))

                    }
                completion(NSBackgroundActivityScheduler.Result.finished)
            }
        print(moon_phase(yearParam: 2020, monthParam: 1, dayParam: 24))
        
    }
    
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func moon_phase(yearParam: Int, monthParam: Int, dayParam: Int) -> String {
        var year = yearParam;
        var month = monthParam;
        let day = dayParam;
        
        var c: Double = 0;
        var e: Double = 0;
        var jd: Double = 0;
        var b: Int = 0;
        
        if (month < 3) {
            year = year - 1;
            month += 12;
        }
        
        month = month + 1;
        
        c = 365.25 * Double(year);
        
        e = 30.6 * Double(month);
        
        jd = c + e + Double(day) - 694039.09;
        
        jd /= 29.5305882;
        
        b = Int(jd);
        
        jd = jd - Double(b);
        
        b = Int(round(jd * 8));
        
        if (b >= 8 ) {
            b = 0;
        }
        
        switch (b)
        {
        case 0:
            return "new-moon";
        case 1:
            return "waxing-crescent-moon";
        case 2:
            return "quarter-moon";
        case 3:
            return "waxing-gibbous-moon";
        case 4:
            return "full-moon";
        case 5:
            return "waning-gibbous-moon";
        case 6:
            return "last-quarter-moon";
        case 7:
            return "waning-crescent-moon";
        default:
            return "error";
        }
    }
 
    
    func setWeather(text: String) {
        title = text
    }
    
    deinit {
        activity.invalidate()
    }
}
