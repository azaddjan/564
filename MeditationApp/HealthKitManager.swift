import Foundation
import HealthKit

class HealthKitManager: ObservableObject {
    private let healthStore = HKHealthStore()
    
    // Check if HealthKit is available on this device
    var isHealthKitAvailable: Bool {
        return HKHealthStore.isHealthDataAvailable()
    }
    
    // Request authorization for meditation data
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard isHealthKitAvailable else {
            completion(false, NSError(domain: "HealthKitManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "HealthKit is not available on this device"]))
            return
        }
        
        // Define the types we want to read and write
        let typesToWrite: Set<HKSampleType> = [
            HKCategoryType.categoryType(forIdentifier: .mindfulSession)!
        ]
        
        let typesToRead: Set<HKObjectType> = [
            HKCategoryType.categoryType(forIdentifier: .mindfulSession)!
        ]
        
        // Request authorization
        healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead) { success, error in
            DispatchQueue.main.async {
                completion(success, error)
            }
        }
    }
    
    // Save a meditation session to HealthKit
    func saveMeditationSession(duration: TimeInterval, startDate: Date, completion: @escaping (Bool, Error?) -> Void) {
        guard isHealthKitAvailable else {
            completion(false, NSError(domain: "HealthKitManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "HealthKit is not available on this device"]))
            return
        }
        
        // Create the meditation session sample
        let endDate = startDate.addingTimeInterval(duration)
        let mindfulSession = HKCategorySample(
            type: HKCategoryType.categoryType(forIdentifier: .mindfulSession)!,
            value: HKCategoryValue.notApplicable.rawValue,
            start: startDate,
            end: endDate
        )
        
        // Save to HealthKit
        healthStore.save(mindfulSession) { success, error in
            DispatchQueue.main.async {
                completion(success, error)
            }
        }
    }
    
    // Get meditation sessions from HealthKit
    func getMeditationSessions(completion: @escaping ([HKCategorySample]?, Error?) -> Void) {
        guard isHealthKitAvailable else {
            completion(nil, NSError(domain: "HealthKitManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "HealthKit is not available on this device"]))
            return
        }
        
        let mindfulSessionType = HKCategoryType.categoryType(forIdentifier: .mindfulSession)!
        let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictEndDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(
            sampleType: mindfulSessionType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sortDescriptor]
        ) { _, samples, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(nil, error)
                } else {
                    completion(samples as? [HKCategorySample], nil)
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    // Get total meditation time for today
    func getTodayMeditationTime(completion: @escaping (TimeInterval?, Error?) -> Void) {
        guard isHealthKitAvailable else {
            completion(nil, NSError(domain: "HealthKitManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "HealthKit is not available on this device"]))
            return
        }
        
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
        let mindfulSessionType = HKCategoryType.categoryType(forIdentifier: .mindfulSession)!
        
        let query = HKSampleQuery(
            sampleType: mindfulSessionType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: nil
        ) { _, samples, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(nil, error)
                } else {
                    let totalTime = samples?.reduce(0.0) { total, sample in
                        return total + sample.endDate.timeIntervalSince(sample.startDate)
                    } ?? 0.0
                    completion(totalTime, nil)
                }
            }
        }
        
        healthStore.execute(query)
    }
}
