//
//  InputViewModel.swift
//  ExpenseTracker
//
//  Created by Rifqi Fadhlillah on 21/08/25.
//

import Observation
import SwiftUI
import Foundation

@Observable
@MainActor
final class InputViewModel {
  var text: String = ""
  var state: InputViewState = .empty
  var showActivityIndicator = false
  
  var didSendMessage: ((DraftMessage) -> Void)?
  
  func inputViewAction() -> (InputViewAction) -> Void {
    { [weak self] in
      self?.inputViewActionInternal($0)
    }
  }
  
  private func inputViewActionInternal(_ action: InputViewAction) {
    print("LMAOO")
    switch action {
    case .send:
      send()
    default: break
    }
  }
  
  func send() {
    print("Send it bro")
    Task {
      //              await recorder.stopRecording()
      //              await recordingPlayer?.reset()
      sendMessage()
    }
  }
  
  func reset() {
    DispatchQueue.main.async { [weak self] in
      //              self?.showPicker = false
      //              self?.showGiphyPicker = false
      self?.text = ""
      //              self?.saveEditingClosure = nil
      //              self?.attachments = InputViewAttachments()
      //              self?.subscribeValidation()
      self?.state = .empty
    }
  }
}

private extension InputViewModel {
  func sendMessage() {
    showActivityIndicator = true
    let draft = DraftMessage(
      text: self.text,
      //            medias: attachments.medias,
      //            giphyMedia: attachments.giphyMedia,
      //            recording: attachments.recording,
      replyMessage: nil,
      createdAt: Date()
    )
    didSendMessage?(draft)
    DispatchQueue.main.async { [weak self] in
      self?.showActivityIndicator = false
      self?.reset()
    }
  }
}
