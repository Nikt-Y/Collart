//
//  TextErrorField.swift
//  Collart
//

import SwiftUI

// MARK: - TextErrorField
struct TextErrorField: View {
    @EnvironmentObject var settingsManager: SettingsManager
    
    let placeHolder: String
    @Binding var fieldText: String
    
    @Binding var isValid: Bool
    var validateMethod: (String) -> Bool = { _ in return true }
    var errorText: String = ""
    var autocapitalization = true
    
    @State private var isEdited: Bool = false
    @FocusState private var focusedField: Bool
    
    var body: some View {
        VStack {
            TextField("", text: $fieldText, prompt: Text(placeHolder).foregroundColor(settingsManager.currentTheme.textColorLightPrimary))
                .focused($focusedField)
                .autocapitalization(autocapitalization ? .sentences : .none)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 100)
                        .strokeBorder(settingsManager.currentTheme.selectedTextColor(isSelected: focusedField || !fieldText.isEmpty), lineWidth: 1)
                        .background(RoundedRectangle(cornerRadius: 100).fill(Color.clear))
                        .contentShape(RoundedRectangle(cornerRadius: 100))
                        .onTapGesture {
                            focusedField = true
                        }
                )
                .font(.system(size: settingsManager.textSizeSettings.body))
                .foregroundColor(settingsManager.currentTheme.textColorPrimary)
                .onChange(of: fieldText) { newValue in
                    withAnimation {
                        isValid = validateMethod(newValue)
                        isEdited = true
                    }
                }
            
            if !errorText.isEmpty && !isValid && isEdited {
                HStack {
                    Text(errorText)
                        .foregroundColor(.red)
                        .padding(.leading)
                    Spacer()
                }
            }
        }
    }
}

// MARK: - TextErrorEditor
struct TextErrorEditor: View {
    @EnvironmentObject var settingsManager: SettingsManager
    
    let placeHolder: String
    @Binding var fieldText: String
    
    @Binding var isValid: Bool
    var validateMethod: (String) -> Bool = { _ in return true }
    var errorText: String = ""
    
    @State private var isEdited: Bool = false
    @FocusState private var focusedField: Bool
    @State private var editorHeight: CGFloat = 125

    var body: some View {
        VStack {
            ZStack(alignment: .topLeading) {
                TextEditor(text: $fieldText)
                    .focused($focusedField)
                    .frame(height: editorHeight)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .font(.system(size: settingsManager.textSizeSettings.body))
                    .foregroundColor(settingsManager.currentTheme.textColorPrimary)
                    .onChange(of: fieldText) { newValue in
                        withAnimation {
                            isValid = validateMethod(newValue)
                            isEdited = true
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(settingsManager.currentTheme.selectedTextColor(isSelected: focusedField || !fieldText.isEmpty), lineWidth: 1)
                            .background(RoundedRectangle(cornerRadius: 20).fill(Color.clear))
                            .contentShape(RoundedRectangle(cornerRadius: 20))
                            .onTapGesture {
                                focusedField = true
                            }
                    )
                
                if fieldText.isEmpty {
                    Text(placeHolder)
                        .foregroundColor(settingsManager.currentTheme.textColorLightPrimary)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 15)
                        .onTapGesture {
                            focusedField = true
                        }
                }
            }
            .frame(height: editorHeight)
            
            if !errorText.isEmpty && !isValid && isEdited {
                HStack {
                    Text(errorText)
                        .foregroundColor(.red)
                        .padding(.leading)
                    Spacer()
                }
            }
        }
    }
}

// MARK: - DateErrorPicker
struct DateErrorPicker: View {
    @EnvironmentObject var settingsManager: SettingsManager

    @Binding var selectedDate: Date
    @Binding var isValid: Bool
    var validateMethod: (Date) -> Bool = { _ in true }
    var errorText: String = ""

    @State private var isEdited: Bool = false
    @FocusState private var focusedField: Int?

    var body: some View {
        VStack {
            DatePicker(
                "",
                selection: $selectedDate,
                displayedComponents: .date
            )
            .labelsHidden()
            .focused($focusedField, equals: 0)
            .padding(7)
            .background(RoundedRectangle(cornerRadius: 100).strokeBorder(settingsManager.currentTheme.selectedTextColor(isSelected: focusedField == 0), lineWidth: 1))
            .font(.system(size: settingsManager.textSizeSettings.body))
            .foregroundColor(settingsManager.currentTheme.textColorPrimary)
            .onChange(of: selectedDate) { newValue in
                withAnimation {
                    isValid = validateMethod(newValue)
                    isEdited = true
                }
            }
            
            if !errorText.isEmpty && !isValid && isEdited {
                HStack {
                    Text(errorText)
                        .foregroundColor(.red)
                        .padding(.leading)
                    Spacer()
                }
            }
        }
    }
}

// MARK: - ImagePickerField
struct ImagePickerField: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @Binding var image: UIImage?
    var errorText: String = ""
    
    var body: some View {
        VStack {
            Button(action: { isShowingPicker = true }) {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 25).strokeBorder(settingsManager.currentTheme.textColorPrimary, lineWidth: 1))
                } else {
                    Text("Выберите изображение")
                        .foregroundColor(settingsManager.currentTheme.textColorLightPrimary)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 25).strokeBorder(settingsManager.currentTheme.textColorPrimary, lineWidth: 1))
                }
            }
            
            if !errorText.isEmpty {
                HStack {
                    Text(errorText)
                        .foregroundColor(.red)
                        .padding(.leading)
                    Spacer()
                }
            }
        }
        .sheet(isPresented: $isShowingPicker) {
            ImagePicker(image: $image)
        }
    }
    
    @State private var isShowingPicker = false
}

// MARK: - ImagePicker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
        ) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

import UniformTypeIdentifiers

// MARK: - FilePicker
struct FilePicker: UIViewControllerRepresentable {
    @Binding var fileUrls: [URL]
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.content], asCopy: true)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: FilePicker

        init(_ parent: FilePicker) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            parent.fileUrls = urls
            parent.presentationMode.wrappedValue.dismiss()
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - FilePickerField
struct FilePickerField: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @Binding var fileUrls: [URL]
    var errorText: String = ""
    
    var body: some View {
        VStack {
            Button(action: { isShowingPicker = true }) {
                Text(fileUrls.first?.lastPathComponent ?? "Выберите файл")
                    .foregroundColor(settingsManager.currentTheme.textColorLightPrimary)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 25).strokeBorder(settingsManager.currentTheme.textColorPrimary, lineWidth: 1))
            }
            
            if !errorText.isEmpty {
                HStack {
                    Text(errorText)
                        .foregroundColor(.red)
                        .padding(.leading)
                    Spacer()
                }
            }
        }
        .sheet(isPresented: $isShowingPicker) {
            FilePicker(fileUrls: $fileUrls)
        }
    }
    
    @State private var isShowingPicker = false
}
