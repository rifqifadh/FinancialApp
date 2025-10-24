//
//  UIList.swift
//  ExpenseTracker
//
//  Created by Rifqi Fadhlillah on 21/08/25.
//

import SwiftUI
//import UIKit

public extension Notification.Name {
  static let onScrollToBottom = Notification.Name("onScrollToBottom")
}

struct UIList<MessageContent: View, InputView: View>: UIViewRepresentable {
  typealias MessageBuilderClosure = ChatView<MessageContent, DefaultMessageMenuAction>.MessageBuilderClosure
  
  @Environment(\.chatTheme) var theme
  
  var viewModel: ChatViewModel
  var inputViewModel: InputViewModel
  
  @Binding var isScrolledToBottom: Bool
  @Binding var shouldScrollToTop: () -> ()
  @Binding var tableContentHeight: CGFloat
  
  var messageBuilder: MessageBuilderClosure?
  var mainHeaderBuilder: (()->AnyView)?
  var headerBuilder: ((Date)->AnyView)?
  var inputView: InputView
  
  let type: ChatType
  let showDateHeaders: Bool
  let isScrollEnabled: Bool
  let avatarSize: CGFloat
  let showMessageMenuOnLongPress: Bool
  //      let tapAvatarClosure: ChatView.TapAvatarClosure?
  let paginationHandler: PaginationHandler?
  let messageStyler: (String) -> AttributedString
  let shouldShowLinkPreview: (URL) -> Bool
  let showMessageTimeView: Bool
  let messageLinkPreviewLimit: Int
  let messageFont: UIFont
  let sections: [MessagesSection]
  let ids: [String]
  let listSwipeActions: ListSwipeActions
  
  @State var isScrolledToTop = false
  @State var updateQueue = UpdateQueue()
  
  func makeUIView(context: Context) -> UITableView {
    let tableView = UITableView(frame: .zero, style: .grouped)
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.separatorStyle = .none
    tableView.dataSource = context.coordinator
    tableView.delegate = context.coordinator
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    tableView.transform = CGAffineTransform(rotationAngle: (type == .conversation ? .pi : 0))
    tableView.bouncesVertically = false
//    tableView.transform = CGAffineTransform(rotationAngle: 0)
    
    tableView.showsVerticalScrollIndicator = false
    tableView.estimatedSectionHeaderHeight = 1
    tableView.estimatedSectionFooterHeight = UITableView.automaticDimension
    tableView.backgroundColor = UIColor(theme.colors.mainBG)
    tableView.scrollsToTop = false
    tableView.isScrollEnabled = isScrollEnabled
    
    NotificationCenter.default.addObserver(forName: .onScrollToBottom, object: nil, queue: nil) { _ in
      DispatchQueue.main.async {
        if !context.coordinator.sections.isEmpty {
          tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: true)
        }
      }
    }
    
    DispatchQueue.main.async {
      shouldScrollToTop = {
        tableView.contentOffset = CGPoint(x: 0, y: tableView.contentSize.height - tableView.frame.height)
      }
    }
    
    return tableView
  }
  
  func updateUIView(_ tableView: UITableView, context: Context) {
    if !isScrollEnabled {
      DispatchQueue.main.async {
        tableContentHeight = tableView.contentSize.height
      }
    }
    
    if context.coordinator.sections == sections {
      return
    }
    
    Task {
      await updateQueue.enqueue {
        await updateIfNeeded(coordinator: context.coordinator, tableView: tableView)
      }
    }
  }
  
  @MainActor
  private func updateIfNeeded(coordinator: Coordinator, tableView: UITableView) async {
    if coordinator.sections == sections {
      return
    }
    
    if coordinator.sections.isEmpty {
      coordinator.sections = sections
      tableView.reloadData()
      if !isScrollEnabled {
        DispatchQueue.main.async {
          tableContentHeight = tableView.contentSize.height
        }
      }
      return
    }
    
    if let lastSection = sections.last {
      coordinator.paginationTargetIndexPath = IndexPath(row: lastSection.rows.count - 1, section: sections.count - 1)
    }
    
    let prevSections = coordinator.sections
    
    //print("0 whole sections:", runID, "\n")
    //print("whole previous:\n", formatSections(prevSections), "\n")
    let splitInfo = await performSplitInBackground(prevSections, sections)
    await applyUpdatesToTable(tableView, splitInfo: splitInfo) {
      coordinator.sections = $0
    }
  }
  
  nonisolated private func performSplitInBackground(_  prevSections:  [MessagesSection], _ sections: [MessagesSection]) async -> SplitInfo {
    await withCheckedContinuation { continuation in
      Task.detached {
        let result = operationsSplit(oldSections: prevSections, newSections: sections)
        continuation.resume(returning: result)
      }
    }
  }
  
  @MainActor
  private func applyUpdatesToTable(_ tableView: UITableView, splitInfo: SplitInfo, updateSections: @escaping ([MessagesSection]) -> Void) async {
    
  }
  
  /**
   * CHAT UI UPDATE ALGORITHM - Complete Documentation
   *
   * This function is the "brain" that figures out how to smoothly update a chat UI
   * when new messages arrive, messages are edited, deleted, or reordered.
   *
   * ANALOGY: Think of it like a smart photo album manager that compares two versions
   * of your photo album and creates a step-by-step plan to transform one into the other
   * with smooth animations.
   */
  
  /**
   * Analyzes differences between old and new message sections and generates
   * a detailed plan of UI operations needed for smooth table view updates.
   *
   * @param oldSections - The current state of chat messages (what user sees now)
   * @param newSections - The desired state of chat messages (what we want to show)
   * @returns SplitInfo - A detailed plan containing all necessary operations
   */
  private nonisolated func operationsSplit(oldSections: [MessagesSection], newSections: [MessagesSection]) -> SplitInfo {
    
    // 🎯 GOAL: Create intermediate states to apply changes step-by-step
    // This prevents jarring UI updates by breaking changes into phases
    
    var appliedDeletes = oldSections // State after deletions only
    var appliedDeletesSwapsAndEdits = newSections // State after deletes + swaps + edits (but not inserts yet)
    
    // 📋 OPERATION LISTS: The "recipe" for updating the UI
    var deleteOperations = [Operation]()  // Remove these items
    var swapOperations = [Operation]()    // Move these items
    var editOperations = [Operation]()    // Update these items
    var insertOperations = [Operation]()  // Add these items
    
    // =====================================
    // PHASE 1: COMPARE SECTIONS (Days/Groups)
    // =====================================
    
    let oldDates = oldSections.map { $0.date }      // [Monday, Tuesday, Wednesday]
    let newDates = newSections.map { $0.date }      // [Monday, Wednesday, Thursday]
    let commonDates = Array(Set(oldDates + newDates)).sorted(by: >) // All unique dates, newest first
    
    for date in commonDates {
      let oldIndex = appliedDeletes.firstIndex(where: { $0.date == date })
      let newIndex = appliedDeletesSwapsAndEdits.firstIndex(where: { $0.date == date })
      
      // 🗑️ CASE 1: Section was DELETED (exists in old, not in new)
      // Example: Tuesday disappeared from chat
      if oldIndex == nil, let newIndex = newIndex {
        if let operationIndex = newSections.firstIndex(where: { $0.date == date }) {
          appliedDeletesSwapsAndEdits.remove(at: newIndex)
          insertOperations.append(.insertSection(operationIndex))
        }
        continue
      }
      
      // ➕ CASE 2: Section was ADDED (exists in new, not in old)
      // Example: Thursday is a new day with messages
      if newIndex == nil, let oldIndex = oldIndex {
        if let operationIndex = oldSections.firstIndex(where: { $0.date == date }) {
          appliedDeletes.remove(at: oldIndex)
          deleteOperations.append(.deleteSection(operationIndex))
        }
        continue
      }
      
      // 🔄 CASE 3: Section EXISTS IN BOTH - Compare individual messages
      guard let newIndex = newIndex, let oldIndex = oldIndex else { continue }
      
      // =====================================
      // PHASE 2: COMPARE MESSAGES WITHIN SECTION
      // =====================================
      
      var oldRows = appliedDeletes[oldIndex].rows      // Messages in old version
      var newRows = appliedDeletesSwapsAndEdits[newIndex].rows // Messages in new version
      
      let oldRowIDs = oldRows.map { $0.id }           // ["msg1", "msg2", "msg3"]
      let newRowIDs = newRows.map { $0.id }           // ["msg1", "msg3", "msg4"]
      
      // 🔍 FIND DIFFERENCES
      let rowIDsToDelete = oldRowIDs.filter { !newRowIDs.contains($0) }.reversed() // ["msg2"] - exists in old, not new
      let rowIDsToInsert = newRowIDs.filter { !oldRowIDs.contains($0) }           // ["msg4"] - exists in new, not old
      
      // 🗑️ HANDLE DELETIONS
      // Remove messages that no longer exist
      for rowId in rowIDsToDelete {
        if let index = oldRows.firstIndex(where: { $0.id == rowId }) {
          oldRows.remove(at: index)
          deleteOperations.append(.delete(oldIndex, index))
        }
      }
      
      // ➕ HANDLE INSERTIONS
      // Mark messages that need to be added
      for rowId in rowIDsToInsert {
        if let index = newRows.firstIndex(where: { $0.id == rowId }) {
          insertOperations.append(.insert(newIndex, index))
        }
      }
      
      // 🧹 CLEANUP: Remove insert messages from comparison arrays
      // This leaves only "duplicate" messages that exist in both versions
      for rowId in rowIDsToInsert {
        if let index = newRows.firstIndex(where: { $0.id == rowId }) {
          newRows.remove(at: index)
        }
      }
      
      // =====================================
      // PHASE 3: COMPARE POSITIONS & CONTENT
      // =====================================
      
      // Now oldRows and newRows contain only messages that exist in both versions
      // Compare them position by position to find swaps and edits
      
      for i in 0..<oldRows.count {
        let oldRow = oldRows[i]
        let newRow = newRows[i]
        
        // 🔄 CASE A: SWAP DETECTED
        // Same position, different message = messages switched places
        if oldRow.id != newRow.id {
          if let correctIndex = newRows.firstIndex(where: { $0.id == oldRow.id }) {
            // Avoid duplicate swap operations
            if !swapsContain(swaps: swapOperations, section: oldIndex, index: i) &&
                !swapsContain(swaps: swapOperations, section: oldIndex, index: correctIndex) {
              swapOperations.append(.swap(oldIndex, i, correctIndex))
            }
          }
        }
        // ✏️ CASE B: EDIT DETECTED
        // Same message ID, same position, but content changed
        else if oldRow != newRow {
          editOperations.append(.edit(oldIndex, i))
        }
        // ✅ CASE C: NO CHANGE
        // Same message, same position, same content - do nothing
      }
      
      // 💾 UPDATE INTERMEDIATE STATES
      appliedDeletes[oldIndex].rows = oldRows
      appliedDeletesSwapsAndEdits[newIndex].rows = newRows
    }
    
    // 🎁 RETURN THE COMPLETE PLAN
    return SplitInfo(
      appliedDeletes: appliedDeletes,                    // State after step 1 (deletions)
      appliedDeletesSwapsAndEdits: appliedDeletesSwapsAndEdits, // State after steps 1-3 (dels + swaps + edits)
      deleteOperations: deleteOperations,                // What to delete
      swapOperations: swapOperations,                    // What to move
      editOperations: editOperations,                    // What to update
      insertOperations: insertOperations                 // What to add
    )
  }
  
  /**
   * EXECUTION ORDER (handled by applyUpdatesToTable):
   *
   * Step 1: 🗑️ DELETE operations    - Remove old messages
   * Step 2: 🔄 SWAP operations      - Move messages to new positions
   * Step 3: ✏️ EDIT operations      - Update changed content (no animation)
   * Step 4: ➕ INSERT operations    - Add new messages
   *
   * This order prevents index conflicts and creates smooth animations!
   */
  
  /**
   * Helper function to check if a swap operation already exists for given position
   * * REAL-WORLD EXAMPLE:
   *
   * OLD STATE: [Message A, Message B, Message C]
   * NEW STATE: [Message A, Message C (edited), Message D]
   *
   * OPERATIONS GENERATED:
   * - Delete: Message B (position 1)
   * - Edit: Message C (content changed)
   * - Insert: Message D (position 2)
   *
   * RESULT: Smooth transition with proper animations! ✨
   */
  private nonisolated func swapsContain(swaps: [Operation], section: Int, index: Int) -> Bool {
    swaps.filter {
      if case let .swap(swapSection, rowFrom, rowTo) = $0 {
        return swapSection == section && (rowFrom == index || rowTo == index)
      }
      return false
    }.count > 0
  }
  
  // MARK: - Operations
  enum Operation {
    case deleteSection(Int)
    case insertSection(Int)
    
    case delete(Int, Int) // delete with animation
    case insert(Int, Int) // insert with animation
    case swap(Int, Int, Int) // delete first with animation, then insert it into new position with animation. do not do anything with the second for now
    case edit(Int, Int) // reload the element without animation
    
    var description: String {
      switch self {
      case .deleteSection(let int):
        return "deleteSection \(int)"
      case .insertSection(let int):
        return "insertSection \(int)"
      case .delete(let int, let int2):
        return "delete section \(int) row \(int2)"
      case .insert(let int, let int2):
        return "insert section \(int) row \(int2)"
      case .swap(let int, let int2, let int3):
        return "swap section \(int) rowFrom \(int2) rowTo \(int3)"
      case .edit(let int, let int2):
        return "edit section \(int) row \(int2)"
      }
    }
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(
      viewModel: viewModel,
      inputViewModel: inputViewModel,
      isScrolledToBottom: $isScrolledToBottom,
      isScrolledToTop: $isScrolledToTop,
      type: type, // Assuming conversation type for now
      showDateHeaders: showDateHeaders,
      avatarSize: avatarSize,
      showMessageMenuOnLongPress: showMessageMenuOnLongPress,
      paginationHandler: paginationHandler,
      messageStyler: messageStyler,
      shouldShowLinkPreview: shouldShowLinkPreview,
      showMessageTimeView: showMessageTimeView,
      messageLinkPreviewLimit: messageLinkPreviewLimit,
      messageFont: messageFont,
      sections: sections,
      ids: ids,
      mainBackgroundColor: theme.colors.mainBG,
      listSwipeActions: listSwipeActions
    )
  }
}

class Coordinator: NSObject, UITableViewDataSource, UITableViewDelegate {
  
  @Bindable var viewModel: ChatViewModel
  @Bindable var inputViewModel: InputViewModel
  
  let mainHeaderBuilder: (()->AnyView)?
  
  let type: ChatType
  let showDateHeaders: Bool
  let avatarSize: CGFloat
  let showMessageMenuOnLongPress: Bool
  let paginationHandler: PaginationHandler?
  let messageStyler: (String) -> AttributedString
  let shouldShowLinkPreview: (URL) -> Bool
  let showMessageTimeView: Bool
  let messageLinkPreviewLimit: Int
  let messageFont: UIFont
  let ids: [String]
  let mainBackgroundColor: Color
  let isDisplayingMessageMenu: Bool = false
  let listSwipeActions: ListSwipeActions
  
  private let impactGenerator = UIImpactFeedbackGenerator(style: .heavy)
  
  var sections: [MessagesSection] {
    didSet {
      if let lastSection = sections.last {
        paginationTargetIndexPath = IndexPath(row: lastSection.rows.count - 1, section: sections.count - 1)
      }
    }
  }
  
  init(
    viewModel: ChatViewModel, inputViewModel: InputViewModel,
    isScrolledToBottom: Binding<Bool>, isScrolledToTop: Binding<Bool>,
    type: ChatType, showDateHeaders: Bool,
    avatarSize: CGFloat, showMessageMenuOnLongPress: Bool,
    /*tapAvatarClosure: ChatView.TapAvatarClosure?,*/ paginationHandler: PaginationHandler?,
    messageStyler: @escaping (String) -> AttributedString,
    shouldShowLinkPreview: @escaping (URL) -> Bool, showMessageTimeView: Bool,
    messageLinkPreviewLimit: Int, messageFont: UIFont, sections: [MessagesSection],
    ids: [String], mainBackgroundColor: Color, paginationTargetIndexPath: IndexPath? = nil,
    listSwipeActions: ListSwipeActions
  ) {
    self.viewModel = viewModel
    self.inputViewModel = inputViewModel
    self.type = type
    self.showDateHeaders = showDateHeaders
    self.avatarSize = avatarSize
    self.showMessageMenuOnLongPress = showMessageMenuOnLongPress
    self.paginationHandler = paginationHandler
    self.messageStyler = messageStyler
    self.shouldShowLinkPreview = shouldShowLinkPreview
    self.showMessageTimeView = showMessageTimeView
    self.messageLinkPreviewLimit = messageLinkPreviewLimit
    self.messageFont = messageFont
    self.sections = sections
    self.paginationTargetIndexPath = paginationTargetIndexPath
    self.mainBackgroundColor = mainBackgroundColor
    self.mainHeaderBuilder = nil // Placeholder for main header builder, can be set later
    self.ids = ids
    self.listSwipeActions = listSwipeActions
  }
  
  /// call pagination handler when this row is reached
  /// without this there is a bug: during new cells insertion willDisplay is called one extra time for the cell which used to be the last one while it is being updated (its position in group is changed from first to middle)
  var paginationTargetIndexPath: IndexPath?
  
  func numberOfSections(in tableView: UITableView) -> Int {
    sections.count
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    sections[section].rows.count
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    //    if type == .comments {
    //      return sectionHeaderView(section)
    //    }
    return nil
  }
  
  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    if type == .conversation {
      return sectionHeaderView(section)
    }
    return nil
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    if !showDateHeaders && (section != 0 || mainHeaderBuilder == nil) {
      return 0.1
    }
    return type == .conversation ? 0.1 : UITableView.automaticDimension
  }
  
  
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    if !showDateHeaders && (section != 0 || mainHeaderBuilder == nil) {
      return 0.1
    }
    return type == .conversation ? UITableView.automaticDimension : 0.1
  }
  
  func sectionHeaderView(_ section: Int) -> UIView? {
    if !showDateHeaders && (section != 0 || mainHeaderBuilder == nil) {
      return nil
    }
    let header = UIHostingController(
      rootView:
        sectionHeaderViewBuilder(section)
        .rotationEffect(Angle(degrees: (type == .conversation ? 180 : 0)))
    ).view
    header?.backgroundColor = UIColor(mainBackgroundColor)
    return header
  }
  
  @ViewBuilder
  func sectionHeaderViewBuilder(_ section: Int) -> some View {
    //    if let mainHeaderBuilder, section == 0 {
    //      VStack(spacing: 0) {
    //        mainHeaderBuilder()
    //        dateViewBuilder(section)
    //      }
    //    } else {
    dateViewBuilder(section)
    //    }
  }
  
  @ViewBuilder
  func dateViewBuilder(_ section: Int) -> some View {
    if showDateHeaders {
      //      if let headerBuilder {
      //        headerBuilder(sections[section].date)
      //      } else {
      Text(sections[section].formattedDate)
        .font(.system(size: 11))
        .padding(.top, 30)
        .padding(.bottom, 8)
        .foregroundColor(.gray)
    }
    //    }
  }
  
  func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    guard let items = type == .conversation ? listSwipeActions.trailing : listSwipeActions.leading else { return nil }
    guard !items.actions.isEmpty else { return nil }
    let message = sections[indexPath.section].rows[indexPath.row].message
    let conf = UISwipeActionsConfiguration(actions: items.actions.filter({ $0.activeFor(message) }).map { toContextualAction($0, message: message) })
    conf.performsFirstActionWithFullSwipe = items.performsFirstActionWithFullSwipe
    return conf
  }
  
  func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    guard let items = type == .conversation ? listSwipeActions.leading : listSwipeActions.trailing else { return nil }
    guard !items.actions.isEmpty else { return nil }
    let message = sections[indexPath.section].rows[indexPath.row].message
    let conf = UISwipeActionsConfiguration(actions: items.actions.filter({ $0.activeFor(message) }).map { toContextualAction($0, message: message) })
    conf.performsFirstActionWithFullSwipe = items.performsFirstActionWithFullSwipe
    return conf
  }
  
  private func toContextualAction(_ item: SwipeActionable, message:Message) -> UIContextualAction {
    let ca = UIContextualAction(style: .normal, title: nil) { (action, sourceView, completionHandler) in
      item.action(message, self.viewModel.messageMenuAction())
      completionHandler(true)
    }
    ca.image = item.render(type: type)
    
    let bgColor = item.background ?? mainBackgroundColor
    ca.backgroundColor = UIColor(bgColor)
    
    return ca
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    tableViewCell.selectionStyle = .none
    tableViewCell.backgroundColor = UIColor(mainBackgroundColor)
    
    let row = sections[indexPath.section].rows[indexPath.row]
    
    tableViewCell.contentConfiguration = UIHostingConfiguration {
      ChatMessageView(
        viewModel: viewModel,
        row: row,
        chatType: type,
        avatarSize: avatarSize,
        messageStyler: messageStyler,
        shouldShowLinkPreview: shouldShowLinkPreview,
        isDisplayingMessageMenu: isDisplayingMessageMenu,
        showMessageTimeView: showMessageTimeView,
        messageLinkPreviewLimit: messageLinkPreviewLimit,
        messageFont: messageFont
      )
      .transition(.scale)
      .background(MessageMenuPreferenceViewSetter(id: row.id))
//      .rotationEffect(Angle(degrees: 180))
      .rotationEffect(Angle(degrees: (type == .conversation ? 180 : 0)))
      .applyIf(showMessageMenuOnLongPress) {
        $0.simultaneousGesture(
          TapGesture().onEnded { } // add empty tap to prevent iOS17 scroll breaking bug (drag on cells stops working)
        )
        .onLongPressGesture {
          // Trigger haptic feedback
          self.impactGenerator.impactOccurred()
          // Launch the message menu
          self.viewModel.messageMenuRow = row
        }
      }
    }
    .minSize(width: 0, height: 0)
    .margins(.all, 0)
    
    return tableViewCell
  }
  
}

extension UIList {
  struct SplitInfo: @unchecked Sendable {
    let appliedDeletes: [MessagesSection]
    let appliedDeletesSwapsAndEdits: [MessagesSection]
    let deleteOperations: [Operation]
    let swapOperations: [Operation]
    let editOperations: [Operation]
    let insertOperations: [Operation]
  }
}

actor UpdateQueue {
  private var isProcessing = false
  
  func enqueue(_ work: @escaping @Sendable () async -> Void) async {
    while isProcessing {
      await Task.yield() // Wait for previous task to finish
    }
    
    isProcessing = true
    await work()
    isProcessing = false
  }
}
