//
//  AppHelper.swift
//  dancereality
//
//  Created by Saad Bin Khalid on 15.02.24.
//

import Foundation

public class AppHelper{
    public static func sumAtIndex(index: Int, arrays: [[Double]]) -> Double? {
        // Check if the index is within the bounds of the arrays
        guard index >= 0 && index < arrays.first?.count ?? 0 else {
            return nil
        }
        
        var sum: Double = 0.0
        
        for array in arrays {
            // Check if the current array has enough elements
            guard index < array.count else {
                return nil
            }
            sum += array[index]
        }
        
        return sum
    }
    
    public static func findBeatCycleFromBeats(beatLength: Double?, beatsNumbers: [[Double]] = [], danceName: String) -> [[Double]]{
        var beatCycle: [[Double]] = []
        var beats = beatsNumbers
        var skipOffset = 2
        for beat in beats {
            if (skipOffset >= 1){
                if (beat[1] == 4.0 && (danceName == AppModel.TANGE
                                       || danceName == AppModel.QUICKSTEP
                                       || danceName == AppModel.SLOWFOX)) {
                    skipOffset = skipOffset - 1
                } else if (beat[1] == 3.0 && (danceName == AppModel.ENGLISH_VALSE
                                              || danceName == AppModel.WIENER_VALSE)) {
                    skipOffset = skipOffset - 1
                }
                beats.removeFirst()
                continue
            }
        }
        
        guard let beatLengthInTotal = beatLength else {
            return beatCycle
        }
        
        let end = beatLengthInTotal - 1
        var skip = 0.0
        for beat in beats {
            if(skip != 0.0){
                skip = skip - 1.0
                continue
            }
            let beatCount : Double = beat[1]
            if(beatCount == 1.0){
                if(Int(beatLengthInTotal) <= beats.count){
                    let cycleFromBeat = Array(beats[0...Int(end)])
                    skip = end
                    for cycle in cycleFromBeat {
                        beatCycle.append(cycle)
                        beats.removeFirst()
                    }
                }
            } else {
                beats.removeFirst()
            }
        }
        
        return beatCycle
    }
}
