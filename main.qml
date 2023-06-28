import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls
import Qt.labs.platform
import Qt.labs.folderlistmodel

ApplicationWindow {
    id: mainWindow
    width: 640
    height: 480
    visible: true
    title: qsTr("Image Viewer")

    header: ToolBar {
        Flow {
            anchors.fill: parent
            spacing: 5
            ToolButton {
                text: qsTr("Open")
                onClicked: folderOpenDialog.open()
            }

            ToolButton {
                text: qsTr("List view")
                onClicked: {
                    listview.visible = true
                    gridView.visible = false
                    pathview.visible = false
                }
            }

            ToolButton {
                text: qsTr("Grid view")
                onClicked: {
                    listview.visible = false
                    gridView.visible = true
                    pathview.visible = false
                }
            }

            ToolButton {
                text: qsTr("Path view")
                onClicked: {
                    listview.visible = false
                    gridView.visible = false
                    pathview.visible = true
                }
            }
        }
    }

    FolderDialog {
        id: folderOpenDialog
        title: "Select an image folder"
        onAccepted: {
            console.log("You chose: " + folder)
            folderModel.folder = folderOpenDialog.folder
        }
    }

    FolderListModel {
        id: folderModel
        folder: folderOpenDialog.folder
        showDirs: false
        nameFilters: ["*.jpg", "*.png", "*.jpeg"]
    }

    Rectangle{
        anchors.fill: parent
        color: "grey"

        Image {
            id: zoomedImage
            anchors.fill: parent
            anchors.margins: 20
            fillMode: Image.PreserveAspectFit
            visible: false
            source: ""
            z: 1
            property bool blocked: false

            MouseArea {
                anchors.fill: parent
                onClicked: {

                    zoomedImage.visible = false
                    zoomedImage.source = ""
                    zoomedImage.blocked = false
                    listview.opacity = 1
                    gridView.opacity = 1
                    pathview.opacity = 1
                }
            }
        }

        ListView{

            id: listview
            anchors.fill: parent
            visible: true
            spacing: 5
            opacity: 1

            model: folderModel

            delegate: Component{
                Image {
                    id: image
                    width: parent.width*0.75
                    anchors.horizontalCenter: parent.horizontalCenter
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    source: fileURL

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (!zoomedImage.blocked) {
                                zoomedImage.source = image.source
                                zoomedImage.visible = true
                                zoomedImage.blocked = true
                                listview.opacity = 0.3
                            }
                        }
                    }
                }
            }
        }

        GridView {
            id: gridView
            visible: false
            width: parent.width
            height: parent.height
            cellWidth: parent.width/4
            cellHeight: parent.height/4
            opacity: 1

            model: folderModel

            delegate: Component{
                Rectangle {
                    width: gridView.cellWidth
                    height: gridView.cellHeight
                    border.width: 5
                    border.color: "transparent"
                    color: "transparent"

                    Image {
                        id: image
                        width: parent.width - 2*parent.border.width
                        height: parent.height - 2*parent.border.width
                        anchors.centerIn: parent
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        source: fileURL

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (!zoomedImage.blocked) {
                                    zoomedImage.source = image.source
                                    zoomedImage.visible = true
                                    zoomedImage.blocked = true
                                    gridView.opacity = 0.3
                                }
                            }
                        }
                    }
                }
            }
        }

        PathView {
            id: pathview
            anchors.fill: parent
            visible: false
            pathItemCount: 5
            preferredHighlightBegin: 0.5
            preferredHighlightEnd: 0.5
            opacity: 1

            model: folderModel

            delegate: Component{
                Image {
                    id: image
                    width: mainWindow.width/2.5
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    source: fileURL
                    z: PathView.isCurrentItem ? 1 : -1
                    opacity: PathView.isCurrentItem ? 1 : 0.5

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (!zoomedImage.blocked) {
                                zoomedImage.source = image.source
                                zoomedImage.visible = true
                                zoomedImage.blocked = true
                                pathview.opacity = 0.3
                            }
                        }
                    }
                }
            }

            path: Path {
                startX: -mainWindow.width*0.25; startY: mainWindow.height*0.25
                PathQuad { x: mainWindow.width*1.25; y: mainWindow.height*0.25; controlX: mainWindow.width*0.5; controlY: mainWindow.height*0.75 }
            }

        }

    }

}
