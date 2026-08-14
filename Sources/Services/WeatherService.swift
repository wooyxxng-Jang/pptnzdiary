import Foundation
import CoreLocation

enum WeatherServiceError: LocalizedError {
    case geocodeFailed
    case requestFailed
    case dateOutOfRange
    case noData

    var errorDescription: String? {
        switch self {
        case .geocodeFailed:
            return "공연장 위치를 찾지 못했어요. 날씨를 직접 입력해 주세요."
        case .requestFailed:
            return "날씨 정보를 불러오지 못했어요. 잠시 후 다시 시도해 주세요."
        case .dateOutOfRange:
            return "이 날짜의 날씨는 자동으로 조회할 수 없어요."
        case .noData:
            return "해당 날짜의 날씨 데이터가 없어요."
        }
    }
}

enum WeatherService {
    private static let forecastRangeDays = 16

    private static var geocodeCache: [String: CLLocationCoordinate2D] = [:]

    /// 시드 데이터의 미정 sentinel(2099-)이거나 예보 범위(오늘부터 16일 이내)를 벗어나면 조회 불가.
    static func isDateSupported(_ date: Date, now: Date = .now) -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        if calendar.component(.year, from: date) >= 2099 {
            return false
        }
        guard let maxForecastDate = calendar.date(byAdding: .day, value: forecastRangeDays, to: now) else {
            return false
        }
        return date <= maxForecastDate
    }

    static func fetchWeatherSummary(date: Date, venue: String) async throws -> String {
        guard isDateSupported(date) else {
            throw WeatherServiceError.dateOutOfRange
        }

        let coordinate = try await geocode(venue: venue)
        let (weatherCode, maxTemp, minTemp) = try await fetchDailyWeather(date: date, coordinate: coordinate)

        let description = koreanDescription(forWeatherCode: weatherCode)
        let maxText = String(format: "%.0f", maxTemp)
        let minText = String(format: "%.0f", minTemp)
        return "\(description), \(minText)~\(maxText)도"
    }

    private static func geocode(venue: String) async throws -> CLLocationCoordinate2D {
        if let cached = geocodeCache[venue] {
            return cached
        }

        let geocoder = CLGeocoder()
        let placemarks: [CLPlacemark]
        do {
            placemarks = try await geocoder.geocodeAddressString("\(venue) 대한민국")
        } catch {
            throw WeatherServiceError.geocodeFailed
        }

        guard let coordinate = placemarks.first?.location?.coordinate else {
            throw WeatherServiceError.geocodeFailed
        }

        geocodeCache[venue] = coordinate
        return coordinate
    }

    private static func fetchDailyWeather(
        date: Date,
        coordinate: CLLocationCoordinate2D
    ) async throws -> (weatherCode: Int, maxTemp: Double, minTemp: Double) {
        let calendar = Calendar(identifier: .gregorian)
        let isFuture = date > calendar.startOfDay(for: .now)

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)

        let host = isFuture ? "api.open-meteo.com" : "archive-api.open-meteo.com"
        var components = URLComponents()
        components.scheme = "https"
        components.host = host
        components.path = "/v1/\(isFuture ? "forecast" : "archive")"
        components.queryItems = [
            URLQueryItem(name: "latitude", value: "\(coordinate.latitude)"),
            URLQueryItem(name: "longitude", value: "\(coordinate.longitude)"),
            URLQueryItem(name: "start_date", value: dateString),
            URLQueryItem(name: "end_date", value: dateString),
            URLQueryItem(name: "daily", value: "weathercode,temperature_2m_max,temperature_2m_min"),
            URLQueryItem(name: "timezone", value: "Asia/Seoul"),
        ]

        guard let url = components.url else {
            throw WeatherServiceError.requestFailed
        }

        let data: Data
        do {
            let (responseData, _) = try await URLSession.shared.data(from: url)
            data = responseData
        } catch {
            throw WeatherServiceError.requestFailed
        }

        let decoded: OpenMeteoResponse
        do {
            decoded = try JSONDecoder().decode(OpenMeteoResponse.self, from: data)
        } catch {
            throw WeatherServiceError.requestFailed
        }

        guard let weatherCode = decoded.daily.weathercode.first,
              let maxTemp = decoded.daily.temperature_2m_max.first,
              let minTemp = decoded.daily.temperature_2m_min.first else {
            throw WeatherServiceError.noData
        }

        return (weatherCode, maxTemp, minTemp)
    }

    private static func koreanDescription(forWeatherCode code: Int) -> String {
        switch code {
        case 0:
            return "맑음"
        case 1, 2, 3:
            return "구름 조금"
        case 45, 48:
            return "안개"
        case 51, 53, 55, 56, 57:
            return "이슬비"
        case 61, 63, 65, 66, 67:
            return "비"
        case 71, 73, 75, 77:
            return "눈"
        case 80, 81, 82:
            return "소나기"
        case 85, 86:
            return "눈날림"
        case 95, 96, 99:
            return "뇌우"
        default:
            return "흐림"
        }
    }
}

private struct OpenMeteoResponse: Decodable {
    struct Daily: Decodable {
        let weathercode: [Int]
        let temperature_2m_max: [Double]
        let temperature_2m_min: [Double]
    }

    let daily: Daily
}
