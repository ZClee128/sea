import Foundation

struct PictureModel: Identifiable {
    var id: String { imageName }
    let imageName: String
    let styleTag: String
    let lipColorHex: String
}

let pictures = [
    PictureModel(imageName: "img_1", styleTag: "Vintage Ruby", lipColorHex: "9E1B32"),
    PictureModel(imageName: "img_2", styleTag: "Spring Peach", lipColorHex: "FFA07A"),
    PictureModel(imageName: "img_3", styleTag: "Natural Glow", lipColorHex: "E8B4B8"),
    PictureModel(imageName: "img_4", styleTag: "Midnight Glam", lipColorHex: "3C1A20"),
    PictureModel(imageName: "img_5", styleTag: "Soft Pink", lipColorHex: "FFB6C1"),
    PictureModel(imageName: "img_6", styleTag: "Bold Red", lipColorHex: "E32636"),
    PictureModel(imageName: "img_7", styleTag: "Coral Sunset", lipColorHex: "FF7F50"),
    PictureModel(imageName: "img_8", styleTag: "Berry Stain", lipColorHex: "8A2BE2"),
    PictureModel(imageName: "img_9", styleTag: "Mocha Nude", lipColorHex: "C0A080"),
    PictureModel(imageName: "img_10", styleTag: "Rose Gold", lipColorHex: "B76E79"),
    PictureModel(imageName: "img_11", styleTag: "Classic Matte", lipColorHex: "A52A2A"),
    PictureModel(imageName: "img_12", styleTag: "Glossy Plum", lipColorHex: "DDA0DD"),
    PictureModel(imageName: "img_13", styleTag: "Tangerine Tango", lipColorHex: "FF4500"),
    PictureModel(imageName: "img_14", styleTag: "Electric Pink", lipColorHex: "FF69B4"),
    PictureModel(imageName: "img_15", styleTag: "Warm Amber", lipColorHex: "FFBF00"),
    PictureModel(imageName: "img_16", styleTag: "Cool Mauve", lipColorHex: "E0B0FF")
]
