pragma Singleton
import Qt.labs.folderlistmodel
import QtQuick

QtObject {
    signal changeImage(file: string)

    property FolderListModel wallpapers: FolderListModel {
        folder: "file:///home/lingchen/Pictures/Wallpapers/"
        nameFilters: ["*.jpg", "*.png"]
    }

    property FolderListModel shaders: FolderListModel {
        folder: "file:///home/lingchen/.config/quickshell/assets/shaders/"
        nameFilters: ["*.frag.qsb"]
    }

    function randomShader() {
        if (shaders.count === 0) return ""
        let index = Math.floor(Math.random()*shaders.count)
        return shaders.get(index, "fileUrl") || ""
    }

    function randomImage() {
        if (wallpapers.count === 0) return ""
        let index = Math.floor(Math.random()*wallpapers.count)
        return wallpapers.get(index, "fileUrl") || ""
    }
}
