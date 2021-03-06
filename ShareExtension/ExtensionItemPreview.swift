////
///  ExtensionItemPreview.swift
//

struct ExtensionItemPreview {
    let image: UIImage?
    let imagePath: URL?
    let text: String?
    let gifData: Data?

    init(image: UIImage? = nil, imagePath: URL? = nil, text: String? = nil, gifData: Data? = nil) {
        self.image = image
        self.imagePath = imagePath
        self.text = text
        self.gifData = gifData
    }

    var description: String {
        return
            "image: \(String(describing: self.image)), imagePath: \(String(describing: self.imagePath)) text: \(String(describing: self.text)) gif: \(self.gifData == nil)"
    }
}

func == (lhs: ExtensionItemPreview, rhs: ExtensionItemPreview) -> Bool {
    return lhs.image == rhs.image && lhs.imagePath == rhs.imagePath && lhs.text == rhs.text
        && lhs.gifData == rhs.gifData
}
