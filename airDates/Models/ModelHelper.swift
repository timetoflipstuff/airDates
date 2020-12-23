//
//  ModelHelper.swift
//  airDates
//
//  Created by Alex Mikhaylov on 04.05.2020.
//  Copyright © 2020 Alexander Mikhaylov. All rights reserved.
//

import Foundation

final class ModelHelper {

    private init() {}

    static func getNextEpisodeString(from date: Date?) -> String? {

        guard let date = date else { return nil }
        let difference = Calendar.current.dateComponents([.year, .day, .hour, .minute], from: Date(), to: date)
        guard let years = difference.year,
            let days = difference.day,
            let hours = difference.hour,
            let minutes = difference.minute
        else { return nil }

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
    }

    static func getMinutesTilNextEpisode(from dateString: String) -> NSNumber? {
        var minutesTilNextEpisode: Int?
        guard let difference = getTimeTilNextEpisode(from: dateString),
            let years = difference.year,
            let days = difference.day,
            let hours = difference.hour,
            let minutes = difference.minute
        else { return nil }
        minutesTilNextEpisode = years*525600 + days*1440 + hours*60 + minutes

        return minutesTilNextEpisode as NSNumber?
    }

    static func getEpisodeDate(from dateString: String?) throws -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd' 'HH':'mm':'ss"
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

        guard let dateString = dateString, let date = dateFormatter.date(from: dateString) else {
            throw MyShowError.invalidDateStringFormat
        }

        dateFormatter.timeZone = TimeZone.current

        return date
    }

    private static func getTimeTilNextEpisode(from dateString: String) -> DateComponents? {

        do {
            let date = try getEpisodeDate(from: dateString)

            let difference = Calendar.current.dateComponents([.year, .day, .hour, .minute], from: Date(), to: date)

            return difference
        } catch {
            return nil
        }
    }
}
