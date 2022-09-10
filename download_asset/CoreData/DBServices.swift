//
//  DBServices.swift
//  download_asset
//
//  Created by design on 30.08.2022.
//

import CoreData
import UIKit
import os.log

class DBServices: NSObject {
    static let sharedInstance = DBServices()
    static let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //MARK: - Films
    
    public func saveContext(from method: String = "Unknown") throws {
        // Save changes
        do {
            try DBServices.context.save()
        } catch {
            print("error with saving data to CoreData(method:\(method)) -> \(error)")
            throw error
        }
    }
}

//MARK: - Movie methods

extension DBServices {
    func isKinoExists(movieID: Int, completion: (Bool)->() ){
        let request: NSFetchRequest<Kino> = Kino.fetchRequest()
        
        request.predicate = NSPredicate(format: "id == %@", "\(movieID)")
        
        var itemArray: [Kino] = []
        
        do {
            itemArray = try DBServices.context.fetch(request)
        } catch {
            print("Error with reading from coredata \(error)")
            return completion(false)
        }
        
        return completion(itemArray.count > 0)
    }
    
    public func addKinoToDB(id: Int,
                            movieName: String = "",
                            duration: String = "0",
                            downloadURL: String,
                            imageURL: String,
                            seasonIndex: Int = 0,
                            episodeIndex: Int = 0,
                            isSerial: Bool = false,
                            downloadingState: DownloadingState = .downloading
    ) throws {
        let newItem = Kino(context: DBServices.context)
        
        print("\(#fileID) => \(#function)")
        newItem.id = Int32(id)
        newItem.k_name = movieName
        newItem.downloaded = false
        newItem.local_path = ""
        newItem.size = 0
        newItem.d_size = 0
        newItem.url = downloadURL
        newItem.state = isSerial ? 1 : 0
        newItem.duration = duration
        newItem.last_watch_time = 0
        newItem.cover_url = imageURL
        newItem.episode_index = Int32(episodeIndex)+1
        newItem.season_index = Int32(seasonIndex)+1
        newItem.downloadingState = downloadingState
        
        do {
            /// Save context
            try DBServices.context.save()
            print("successfully saved")
        } catch {
            print("error with adding kino")
        }
        
    }
    
    public func changeDownloadingStateKinoByID(withID id: Int32, to downloadingState: DownloadingState) {
        print("\(#fileID) => \(#function)")
        let request: NSFetchRequest<Kino> = Kino.fetchRequest()
        
        request.predicate = NSPredicate(format: "id == %@", "\(id)")
        
        var itemArray: [Kino] = []
        
        do {
            /// Fetch request
            itemArray = try DBServices.context.fetch(request)
            
            /// Try setting as downloaded item
            for item in itemArray {
                item.downloadingState = downloadingState
            }
            
            /// Try saving
            do {
                try DBServices.context.save()
            } catch {
                print(error.localizedDescription)
                return
            }
            
        } catch {
            print("Error with reading from coredata \(error)")
        }
    }
    
    public func changeLocalPathKinoById(with id: Int, to path: String) {
        let request: NSFetchRequest<Kino> = Kino.fetchRequest()
        
        request.predicate = NSPredicate(format: "id == %@", "\(id)")
        
        var itemArray: [Kino] = []
        
        do {
            /// Fetch request
            itemArray = try DBServices.context.fetch(request)
            
            /// Try setting as downloaded item
            for item in itemArray {
                item.local_path = path
            }
            
            /// Try saving
            do {
                try DBServices.context.save()
            } catch {
                print(error.localizedDescription)
                return
            }
            
        } catch {
            print("Error with reading from coredata \(error)")
        }
    }
    
    public func changeDownloadingStateAndProgressByMovieId(withID id: Int32, toState downloadingState: DownloadingState, toProgress progress: Double?) {
        os_log("%@ => %@ => %@", log: OSLog.coreData, type: .info, #fileID, #function, String(id))
        let request: NSFetchRequest<Kino> = Kino.fetchRequest()
        
        request.predicate = NSPredicate(format: "id == %@", "\(id)")
        
        var itemArray: [Kino] = []
        
        do {
            /// Fetch request
            itemArray = try DBServices.context.fetch(request)
            
            /// Try setting as downloaded item
            for item in itemArray {
                item.downloadingState = downloadingState
                if let safeProgress = progress {
                    item.progress = safeProgress
                }
            }
            
            /// Try saving
            do {
                try DBServices.context.save()
            } catch {
                print(error.localizedDescription)
                return
            }
            
        } catch {
            os_log("%@ => %@ => %@", log: OSLog.coreData, type: .info, #fileID, #function, error.localizedDescription)
        }
    }
    
    public func changeLocalPathAndProgressByMovieID(with movieId: Int32, location path: String, progress: Double) {
        os_log("%@ => %@ => %@", log: OSLog.coreData, type: .info, #fileID, #function, String(movieId))
        let request: NSFetchRequest<Kino> = Kino.fetchRequest()
        
        request.predicate = NSPredicate(format: "id == %@", "\(movieId)")
        
        var itemArray: [Kino] = []
        
        do {
            /// Fetch request
            itemArray = try DBServices.context.fetch(request)
            
            /// Try setting as downloaded item
            for item in itemArray {
                item.local_path = path
                item.progress = progress
            }
            
            /// Try saving
            do {
                try DBServices.context.save()
            } catch {
                print(error.localizedDescription)
                return
            }
            
        } catch {
            os_log("%@ => %@ => %@", log: OSLog.coreData, type: .info, #fileID, #function, error.localizedDescription)
        }
    }
    
    public func changeLocalPathKinoByStreamUrl(withUrl url: String, to path: String) {
        print("\(#fileID) => \(#function)")
        let request: NSFetchRequest<Kino> = Kino.fetchRequest()
        
        request.predicate = NSPredicate(format: "url == %@", "\(url)")
        
        var itemArray: [Kino] = []
        
        do {
            /// Fetch request
            itemArray = try DBServices.context.fetch(request)
            
            /// Try setting as downloaded item
            for item in itemArray {
                item.local_path = path
            }
            
            /// Try saving
            do {
                try DBServices.context.save()
            } catch {
                print(error.localizedDescription)
                return
            }
            
        } catch {
            print("Error with reading from coredata \(error)")
        }
    }
    
    
    
    public func setKinoAsDownloadedByID(id: Int32, completion:(Bool)->()) {
        let request: NSFetchRequest<Kino> = Kino.fetchRequest()
        
        request.predicate = NSPredicate(format: "id == %@", "\(id)")
        
        var itemArray: [Kino] = []
        
        do {
            /// Fetch request
            itemArray = try DBServices.context.fetch(request)
            
            /// Try setting as downloaded item
            for item in itemArray {
                item.downloaded = true
                item.downloadingState = .downloaded
            }
            
            /// Try saving
            do {
                try DBServices.context.save()
            } catch {
                print(error.localizedDescription)
                completion(false)
                return
            }
            
            /// setting completed
            completion(true)
        } catch {
            print("Error with reading from coredata \(error)")
            completion(false)
        }
    }
    
    public func setLastWatchTimeByID(id: Int32, lastWatchTime: Float, completion:(Bool)->()) {
        let request: NSFetchRequest<Kino> = Kino.fetchRequest()
        
        request.predicate = NSPredicate(format: "id == %@", "\(id)")
        
        var itemArray: [Kino] = []
        
        do {
            /// Fetch request
            itemArray = try DBServices.context.fetch(request)
            
            /// Try remove item
            for item in itemArray {
                item.last_watch_time = lastWatchTime
            }
            
            /// Try saving
            do {
                try DBServices.context.save()
            } catch {
                print(error.localizedDescription)
                completion(false)
                return
            }
            
            /// Remove completed
            completion(true)
        } catch {
            print("Error with reading from coredata \(error)")
            completion(false)
        }
    }
    
    public func deleteKinoFromDB(id: Int, completion:(Bool)->()) {
        let request: NSFetchRequest<Kino> = Kino.fetchRequest()
        
        request.predicate = NSPredicate(format: "id == %@", "\(id)")
        
        var itemArray: [Kino] = []
        
        do {
            /// Fetch request
            itemArray = try DBServices.context.fetch(request)
            
            /// Try remove item
            for item in itemArray {
                DBServices.context.delete(item)
            }
            
            /// Try saving
            do {
                try DBServices.context.save()
            } catch {
                print(error.localizedDescription)
                completion(false)
                return
            }
            
            /// Remove completed
            completion(true)
        } catch {
            print("Error with reading from coredata \(error)")
            completion(false)
        }
    }
    
    func removeNotLoadedKino(completion:(Bool)->()) {
        let request: NSFetchRequest<Kino> = Kino.fetchRequest()
        
        request.predicate = NSPredicate(format: "downloaded == %@", NSNumber(value: false))
        
        var itemArray: [Kino] = []
        
        do {
            /// Fetch request
            itemArray = try DBServices.context.fetch(request)
            
            /// Try remove item
            for item in itemArray {
                DBServices.context.delete(item)
            }
            
            /// Try saving
            do {
                try DBServices.context.save()
            } catch {
                print(error.localizedDescription)
                completion(false)
                return
            }
            
            /// Remove completed
            completion(true)
        } catch {
            print("Error with reading from coredata \(error)")
            completion(false)
        }
    }
    
    func getKino() -> [Kino] {
        let request: NSFetchRequest<Kino> = Kino.fetchRequest()
        
        var res: [Kino] = []
        
        do {
            res = try DBServices.context.fetch(request)
        } catch {
            print("Error when getting list of all Kino \(error)")
            
        }
        
        return res
    }
    
    func getKinoByID(id: Int) -> Kino? {
        let movieID = Int32(id)
        
        let request: NSFetchRequest<Kino> = Kino.fetchRequest()
        
        request.predicate = NSPredicate(format: "id == %@", "\(movieID)")
        
        var itemArray: [Kino] = []
        var res: Kino? = nil
        do {
            /// Fetch request
            itemArray = try DBServices.context.fetch(request)
            
            /// Try remove item
            for item in itemArray {
                res = item
            }
            
        } catch {
            print("Error with reading from coredata \(error)")
            return nil
        }
        
        return res
    }
    
    func getSeasonIndicesBySerialName(serialName: String) -> [Int] {
        let uniqueRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Kino")
        //        = Kino.fetchRequest()
        uniqueRequest.resultType = .dictionaryResultType
        uniqueRequest.propertiesToFetch = ["season_index"]
        uniqueRequest.returnsDistinctResults = true
        
        let request = uniqueRequest
        
        request.predicate = NSPredicate(format: "k_name == %@", "\(serialName)")
        request.sortDescriptors = [NSSortDescriptor(key: "season_index", ascending: true)]
        
        var res: [Int] = []
        
        do {
            /// Fetch request
            let response: [[String: Int]]? = try DBServices.context.fetch(request) as? [[String: Int]]
            
            guard let safeResponse = response else {
                return []
            }
            
            for item in safeResponse {
                res.append(item["season_index"] ?? 0)
            }
            
        } catch {
            print("Error with reading from coredata \(error)")
            return []
        }
        
        return res
    }
    
    func getEpisodesBySeasonIndexAndSerialName(serialName: String, seasonIndex: Int) -> [Kino] {
        let request: NSFetchRequest<Kino> = Kino.fetchRequest()
        request.predicate = NSPredicate(format: "k_name == %@ AND season_index == %@", "\(serialName)", "\(Int32(seasonIndex))")
        request.sortDescriptors = [NSSortDescriptor(key: "episode_index", ascending: true)]
        
        var res: [Kino] = []
        
        do {
            res = try DBServices.context.fetch(request)
        } catch {
            print("Error when getting list of all Kino \(error)")
        }
        
        return res
    }
    
    func getAllEpisodesBySerialName(serialName: String) -> [Kino] {
        let request: NSFetchRequest<Kino> = Kino.fetchRequest()
        request.predicate = NSPredicate(format: "k_name == %@", "\(serialName)")
        
        var res: [Kino] = []
        
        do {
            res = try DBServices.context.fetch(request)
        } catch {
            print("Error when getting list of all Kino \(error)")
        }
        
        return res
    }
    
    func removeAllEpisodesBySerialName(serialName: String) -> Bool {
        let request: NSFetchRequest<Kino> = Kino.fetchRequest()
        
        request.predicate = NSPredicate(format: "k_name == %@", "\(serialName)")
        
        var itemArray: [Kino] = []
        
        do {
            /// Fetch request
            itemArray = try DBServices.context.fetch(request)
            
            /// Try remove item
            for item in itemArray {
                DBServices.context.delete(item)
            }
            
            /// Try saving
            do {
                try DBServices.context.save()
            } catch {
                print(error.localizedDescription)
                return false
            }
            
            /// Remove completed
            return true
        } catch {
            print("Error with reading from coredata \(error)")
            return false
        }
    }
}
