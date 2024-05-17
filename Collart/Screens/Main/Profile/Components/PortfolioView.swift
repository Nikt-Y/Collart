//
//  PortfolioView.swift
//  Collart
//

import SwiftUI
import CachedAsyncImage
import Combine

struct PortfolioView: View {
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.dismiss) var dismiss
    @Environment(\.networkService) private var networkService: NetworkService
    
    @State private var downloadProgress: [URL: Double] = [:]
    @State private var showingAlert = false
    @State private var downloadedFileURL: URL?
    @State private var downloadCancellables = Set<AnyCancellable>()
    
    let project: PortfolioProject
    
    private var profileService: ProfileServiceDelegate {
        networkService
    }
    
    init(project: PortfolioProject) {
        self.project = project
    }
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    Text(project.projectName)
                        .font(.system(size: settings.textSizeSettings.pageName))
                        .foregroundColor(settings.currentTheme.textColorPrimary)
                        .bold()
                        .padding(.horizontal)
                    
                    CachedAsyncImage(url: URL(string: !project.projectImage.isEmpty ? project.projectImage : "no url"), urlCache: .imageCache) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        case .empty:
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: settings.currentTheme.primaryColor))
                        case .failure(_):
                            Image(systemName: "photo.artframe")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(settings.currentTheme.textColorPrimary)
                                .frame(height: 100)
                        @unknown default:
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: settings.currentTheme.primaryColor))
                        }
                    }
                    .padding(.bottom)
                    
                    Text(project.description)
                        .font(.system(size: settings.textSizeSettings.body))
                        .foregroundColor(settings.currentTheme.textColorPrimary)
                        .padding(.horizontal)
                    
                    if !project.files.isEmpty {
                        Button(action: downloadFiles) {
                            HStack {
                                Image("file")
                                    .resizable()
                                    .foregroundColor(settings.currentTheme.primaryColor)
                                    .frame(width: 30, height: 30)

                                Text("Дополнительные файлы")
                                    .font(.system(size: settings.textSizeSettings.body))
                                    .foregroundColor(settings.currentTheme.primaryColor)
                                    .underline()
                            }
                            .padding(.horizontal)
                        }
                    }

                    ForEach(project.files.compactMap { URL(string: $0) }, id: \.self) { url in
                        if let progress = downloadProgress[url] {
                            ProgressView("Downloading \(url.lastPathComponent)", value: progress, total: 1.0)
                                .padding()
                        }
                    }
                }
            }
        }
        .background(settings.currentTheme.backgroundColor)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(settings.currentTheme.textColorPrimary)
                        .bold()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                if project.ownerId == UserManager.shared.user.id {
                    Button(action: {
                        deletePortfolio()
                    }) {
                        Image(systemName: "x.circle.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden()
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Download Complete"),
                message: Text("File downloaded to \(downloadedFileURL?.path ?? "Unknown location")"),
                dismissButton: .default(Text("Open"), action: {
                    if let url = downloadedFileURL {
                        openFile(url: url)
                    }
                })
            )
        }
    }
    
    private func deletePortfolio() {
        profileService.deletePortfolio(projId: project.id) { success, error in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                ToastManager.shared.show(message: "Проект успешно удален")
                dismiss()
            }
        }
    }
    
    private func downloadFiles() {
        for file in project.files {
            if let url = URL(string: file) {
                downloadFile(from: url)
            }
        }
    }

    private func downloadFile(from url: URL) {
        let task = URLSession.shared.downloadTask(with: url) { localURL, response, error in
            guard let localURL = localURL else { return }

            do {
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
                let destinationURL = documentsURL?.appendingPathComponent(url.lastPathComponent)
                try FileManager.default.moveItem(at: localURL, to: destinationURL!)
                print("File downloaded to: \(destinationURL!)")

                DispatchQueue.main.async {
                    self.downloadedFileURL = destinationURL
                    self.showingAlert = true
                }
            } catch {
                print("File download error: \(error)")
            }
        }

        task.progress.publisher(for: \.fractionCompleted)
            .sink { progress in
                DispatchQueue.main.async {
                    self.downloadProgress[url] = progress
                }
            }
            .store(in: &downloadCancellables)

        task.resume()
    }

    private func openFile(url: URL) {
        print("Opening file at: \(url)")
    }
}
