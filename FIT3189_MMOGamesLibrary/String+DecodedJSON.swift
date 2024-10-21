//
//  String+DecodedJSON.swift
//  FIT3189_MMOGamesLibrary
//
//  Created by Jordan Nathanael on 9/5/2023.
//
import Foundation

extension String {
    var decoded: String {
        let encodedData = self.data(using: .utf8)!
        let attributedOptions: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        do {
            let attributedString = try NSAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil)
            return attributedString.string
        } catch {
            print("Error decoding string: \(error.localizedDescription)")
            return self
        }
    }
    
    var removeTags: String{
        let encodedData = self
        let pattern = "<p>"
        let regex = try! NSRegularExpression(pattern: pattern, options: .dotMatchesLineSeparators)
        let range = NSRange(encodedData.startIndex..<encodedData.endIndex, in: encodedData)
        
        let modifiedString = regex.stringByReplacingMatches(in: encodedData, options: [], range: range, withTemplate: "")
        
        let pattern2 = "</p>"
        let regex2 = try! NSRegularExpression(pattern: pattern2, options: .dotMatchesLineSeparators)
        let range2 = NSRange(modifiedString.startIndex..<modifiedString.endIndex, in: modifiedString)
        
        let modifiedString2 = regex2.stringByReplacingMatches(in: modifiedString, options: [], range: range2, withTemplate: "")
        return modifiedString2
    }
    
    var removeIframe: String{
        let string = self
        let pattern = "<iframe[^>]*>.*?</iframe>"
        let regex = try! NSRegularExpression(pattern: pattern, options: .dotMatchesLineSeparators)
        let range = NSRange(string.startIndex..<string.endIndex, in: string)
        
        let modifiedString = regex.stringByReplacingMatches(in: string, range: range, withTemplate: "")
        
        return modifiedString
    }
    
    var addNewLine: String{
        let htmlString = self
        // Regular expression pattern to match the iframe tags and extract their attributes
        let pattern = #"\n"#

        // Create an instance of NSRegularExpression
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(htmlString.startIndex..<htmlString.endIndex, in: htmlString)
        
        let modifiedString = regex.stringByReplacingMatches(in: htmlString, options: [], range: range, withTemplate: "<br/></br>")
        
        return modifiedString
    }
}
