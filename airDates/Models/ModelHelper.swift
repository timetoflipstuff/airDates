//
//  ModelHelper.swift
//  airDates
//
//  Created by Alex Mikhaylov on 04.05.2020.
//  Copyright © 2020 Alexander Mikhaylov. All rights reserved.
//

import Foundation

class ModelHelper {

    static let shared = ModelHelper()

    private init() {}

    func formNextEpisodeString(apiDateString: String) -> String {

        do {
            guard let difference = try getTimeTilNextEpisode(apiDateString: apiDateString) else { return "poop" }
            guard let years = difference.year, let days = difference.day, let hours = difference.hour, let minutes = difference.minute else { return "poop2" }

            let countdown: String
            if years > 1 {
                countdown = "\(years) years"
            } else if years == 1 {
                countdown = "1 year"
            } else if days > 1 {
                countdown = "\(days) days"
            } else if days == 1 {
                countdown = "1 day"
            } else if hours > 1 {
                countdown = "\(hours) hours"
            } else if hours == 1 {
                countdown = "1 hour"
            } else if minutes > 1 {
                countdown = "\(minutes) minutes"
            } else {
                countdown = "1 minute"
            }
            return "New episode in \(countdown)"
        } catch {
            print(error.localizedDescription)
            return "Well this is poopy"
        }
    }

    func getMinutesTilNextEpisode(apiDateString: String) -> NSNumber? {
        var minutesTilNextEpisode: Int? = nil
        do {
            if let difference = try getTimeTilNextEpisode(apiDateString: apiDateString) {
                if let years = difference.year, let days = difference.day, let hours = difference.hour, let minutes = difference.minute {
                    minutesTilNextEpisode = years*525600 + days*1440 + hours*60 + minutes
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        return minutesTilNextEpisode as NSNumber?
    }

    private func getTimeTilNextEpisode(apiDateString: String) throws -> DateComponents? {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd' 'HH':'mm':'ss"
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

        guard let date = dateFormatter.date(from: apiDateString) else {
            throw MyShowError.invalidDateStringFormat
        }

        dateFormatter.timeZone = TimeZone.current

        let difference = Calendar.current.dateComponents([.year, .day, .hour, .minute], from: Date(), to: date)

        return difference

    }
}
