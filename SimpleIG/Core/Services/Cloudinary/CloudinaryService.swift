import UIKit

final class CloudinaryService {
    func uploadImage(_ image: UIImage) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "ImageConversion", code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Failed to convert UIImage to Data"])
        }

        var request = URLRequest(url: CloudinaryConfig.uploadURL)
        request.httpMethod = "POST"

        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)",
                         forHTTPHeaderField: "Content-Type")
        request.httpBody = createMultipartBody(
            data: imageData,
            boundary: boundary,
            uploadPreset: CloudinaryConfig.uploadPreset
        )

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  200..<300 ~= httpResponse.statusCode else {

                let respStr = String(data: data, encoding: .utf8) ?? ""
                throw NSError(domain: "UploadError", code: 0,
                              userInfo: [NSLocalizedDescriptionKey: "Upload failed, response: \(respStr)"])
            }

            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            guard let urlString = json?["secure_url"] as? String else {
                throw NSError(domain: "UploadError", code: 0,
                              userInfo: [NSLocalizedDescriptionKey: "Failed to get image URL"])
            }
            return urlString

        } catch {
            throw error
        }
    }

    private func createMultipartBody(data: Data, boundary: String, uploadPreset: String) -> Data {
        var body = Data()

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(UUID().uuidString).jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n".data(using: .utf8)!)

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"upload_preset\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(uploadPreset)\r\n".data(using: .utf8)!)

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        return body
    }
}
