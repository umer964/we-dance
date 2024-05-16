//
//  AppModel.swift
//  dancereality
//
//  Created by Saad Khalid on 02.08.22.
//

import Foundation
public class AppModel {
    public static let DOWNLOAD_DIRECTORY = "Dance Reality Media"
    public static let STORE_DIRECTORY = "Store"
    public static let DANCE_TYPE_FILE = "danceType.json"
    public static let DANCE_FILE = "dances.json"
    public static let serverURL = "https://ballroomdance-new.247analytics.de"
    public static let SOTRAGE_RELATIVE_PATH = FileManager.default.urls(for: .documentDirectory,
                                                                       in: .userDomainMask)[0]
    public static let BOUNDING_BOX_PARAM: Float = 0.5
    public static let DANCER_NODE_NAME = "dancer"
    public static let FOOTSTEP_NODE_NAME = "foot"
    public static let AVATAR_FRAME_RATE: Double = 60.0
    public static let AVATAR_INITIAL_FRAMES: Double = 40.0
    public static let ENGLISH_VALSE = "Waltz"
    public static let WIENER_VALSE = "Viennese Waltz"
    public static let SLOWFOX = "Slow Foxtrot"
    public static let TANGE = "Tango"
    public static let QUICKSTEP = "Quickstep"
    public static let AVATAR_INSTRUCTIONS = "to get the 3D-model ready to move across the dance floor"
    public static let FOOTSTEPS_INSTRUCTIONS = "to show the Footsteps that will be visible on the floor"
    public static let VIDEO_INSTRUCTIONS = "to show the Video of our dancing couple"
    public static let FOR_BACK_INSTRUCTIONS = "controls forward/backward movements of Videos, 3D-model and all the Footsteps"
    public static let SPEED_INSTRCUTIONS = "controls faster/slower Music, Video, 3D-model and all the Footsteps"
    public static let MUSIC_INSTRUCTIONS = "choose the Song you want to Dance to"
    public static let PLAY_INSTRUCTIONS = "Press the Highlighted Play Icon to Play the Mode"
    public static let FINAL_INSTRUCTIONS = "Please note that this is the beta version of our app! Buttons that are gray are not yet stored with 3-D models or videos! Thanx!"
    public static let GESTURES_INSTRUCTIONS = "You can change the size of the 3D-model by zooming in and out with two fingers when the 3D-model is visible - ⁠You can rotate the 3D-model by swiping your finger left and right across the screen when the 3D-model is visible"
    // Errors
    // Music Errors
    public static let MUSIC_FILE_COULD_NOT_BE_PLAYED = "MUSIC_FILE_COULD_NOT_BE_PLAYED"
    
    // Download Errors
    public static let DOWNLOAD_FILE_URI_NOT_AVAILABLE = "DOWNLOAD_FILE_URI_NOT_AVAILABLE"
    public static let DOWNLOAD_FAILED = "DOWNLOAD_FAILED"
}
