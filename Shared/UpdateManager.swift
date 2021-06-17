//
//  UpdateManager.swift
//  AssignmentStatusUpdate
//
//  Created by Michael Dautermann on 6/13/21.
//

import Foundation
import SwiftUI

class Assignment {
    let id: Int
    var name: String
    var status: String

    init(id: Int, name: String, status: String) {
        self.id = id
        self.name = name
        self.status = status
    }
}

extension String {

    var parsedColumns: [String] {
        var columns = [String]()
        var level = 0
        var partialColumn: String = ""

        // A nested parsing function, that we’ll apply to each
        // character within the string.
        func parse(_ character: Character) {

            if character == "[" {
                level += 1
            } else {
                if character == "]" {
                    level -= 1
                } else {
                    // feels like we should simply ignore quotes....
                    if character != "\"" {
                        if character == "," && level == 0 {
                            /// ignore empty partial columns
                            if partialColumn.count > 0 {
                                columns.append(partialColumn)
                                partialColumn = ""
                            }
                        } else {
                            partialColumn.append(character)
                        }
                    }
                }
            }

        }
        // Apply our parsing function to each character
        forEach(parse)

        // at the end of the line parsing, add whatever is remaining to the last column
        if partialColumn.isEmpty == false {
            columns.append(partialColumn)
        }

        return columns
    }
}

class UpdateManager: ObservableObject {
    @Published var stringToDisplay: String = "Hire me! I'm fun to work with."

    func loadKinjoFile(filename: String) {
        stringToDisplay = ""

        if let fileURL = Bundle.main.url(forResource: filename, withExtension: nil) {
            do {
                let originalFile = try String(contentsOf: fileURL)

                /// first load file into rows
                let rows = originalFile.components(separatedBy: CharacterSet.newlines)

                for eachRow in rows {
                    Swift.print(eachRow)
                    /// load the first two columns for existing & new assignments
                    /// ignore the third column because we're supposed to come up with that
                    /// based on the changes between the "existing assignment" column (column 1)
                    /// and the "new assignment" column (column 2)
                    let columns = eachRow.parsedColumns
                    Swift.print("columns is \(columns)")
                    /// make certain there are at least two columns for existing & new assignments
                    if columns.count > 1 {
                        let existingAssignments = parseExistingAssignmentColumnIntoAssignments(column: columns[0])
                        let results = parseNewAssignmentColumnIntoAssignmentsAndShowStatusUpdate(column: columns[1], existingAssignments: existingAssignments)
                        if(results.count > 0) {
                            stringToDisplay.append(results.joined(separator: "\n"))
                            stringToDisplay.append("\n")
                        }
                    }
                }
            } catch (let err) {
                Swift.print("can't load \(filename) - \(err.localizedDescription)")
            }
        }
    }

    private func parseAssignment(assignmentString: String) -> Assignment? {
        let components = assignmentString.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: "_")
        if components.count == 3, let id = Int(components[0]) {
            let newAssignment = Assignment.init(id: id, name: components[1], status: components[2])
            return newAssignment
        }
        return nil
    }

    private func parseExistingAssignmentColumnIntoAssignments(column: String) -> [Assignment] {
        var assignments = [Assignment]()
        let assignmentStrings = column.components(separatedBy: ",")
        assignmentStrings.forEach { singleAssignmentString in
            if let existingAssignment = self.parseAssignment(assignmentString: singleAssignmentString) {
                assignments.append(existingAssignment)
            }
        }
        return assignments
    }

    private func parseNewAssignmentColumnIntoAssignmentsAndShowStatusUpdate(column: String, existingAssignments: [Assignment]) -> [String] {
        var statusStrings = [String]()
        var newAssignments = [Assignment]()
        let assignmentStrings = column.components(separatedBy: ",")
        assignmentStrings.forEach { singleAssignmentString in
            if let newAssignment = self.parseAssignment(assignmentString: singleAssignmentString) {
                newAssignments.append(newAssignment)
            }
        }

        /// let's sort, because the instructions say they want output to be sorted by class ID
        let sortedNewAssignments = newAssignments.sorted {
            $0.id < $1.id
        }

        /// for each assignment in newAssignment, see if something has changed between new and old (existing)
        sortedNewAssignments.forEach { aNewAssignment in
        /// find matching old/existing assignment, if it exists
            if let oldAssignment = existingAssignments.first(where: { $0.id == aNewAssignment.id }) {
                /// check for renaming
                let didStatusChangeToo = (oldAssignment.status != aNewAssignment.status)
                if oldAssignment.name != aNewAssignment.name {
                    statusStrings.append(didStatusChangeToo ?
                        "\(oldAssignment.name)_was_renamed_to \(aNewAssignment.name) and_it_was_\(aNewAssignment.status.lowercased())" :
                        "\(oldAssignment.name)_was_renamed_to \(aNewAssignment.name)")
                } else {
                    /// did status change?
                    if didStatusChangeToo {
                        statusStrings.append("\(aNewAssignment.name)_was_\(aNewAssignment.status.lowercased())")
                    }
                }
            } else {
                statusStrings.append("\(aNewAssignment.name)_was_\(aNewAssignment.status.lowercased())")
            }

        }
        return statusStrings
    }
}
