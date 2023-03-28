

/*
This is a UI file (.ui.qml) that is intended to be edited in Qt Design Studio only.
It is supposed to be strictly declarative and only uses a subset of QML. If you edit
this file manually, you might introduce QML code that is not supported by Qt Design Studio.
Check out https://doc.qt.io/qtcreator/creator-quick-ui-forms.html for details on .ui.qml files.
*/
import QtQuick
import QtQuick.Controls

import QtMultimedia
import QtQuick.Layouts

Rectangle {
    id: rectangle
    width: 1280
    height: 720

    //    color: Constants.backgroundColor
    StackLayout {
        id: stackLayout
        width: parent.width
        height: parent.height - 40
        anchors.top: parent.top
        anchors.topMargin: 40
        currentIndex: 0

        Rectangle {
            id: videoCompress
            RowLayout {
                id: rowLayout
                anchors.fill: parent
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 0

                Rectangle {
                    color: "#DDDDDD"
                    width: 100
                    height: 100
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    border.color: "#E0E0E0"
                    border.width: 1
                    Column {
                        anchors.centerIn: parent
                        anchors.fill: parent
                        spacing: 0

                        Rectangle {
                            width: parent.width
                            height: parent.height * 0.7
                            MyVideo {
                                id: selectVideo

                            }
                        }

                        Rectangle {
                            width: parent.width
                            height: parent.height * 0.3
                            color: "#CCCC99"
                            JsonTextArea {
                                id: selectVideoInfo
                                videoInfoStr: selectVideo.videoInfoStr
                            }
                        }
                    }
                }

                Rectangle {
                    border.color: "#E0E0E0"
                    border.width: 1
                    width: 100
                    height: 100
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    CompressForm {
                        id: compressForm
                        videoUrl:selectVideo.videoUrl
                        selectVideoInfoStr: selectVideo.videoInfoStr
                    }
                }

                Rectangle {
                    color: "#DDDDDD"
                    width: 100
                    height: 100
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    border.color: "#E0E0E0"
                    border.width: 1
                    Column {
                        anchors.centerIn: parent
                        anchors.fill: parent
                        spacing: 0

                        Rectangle {
                            width: parent.width
                            height: parent.height * 0.7
                            MyVideo {
                                id: compressedVideo
                                isSaveView: true
                                compressOutPut: compressForm.compressOutPut

                            }
                        }

                        Rectangle {
                            width: parent.width
                            height: parent.height * 0.3
                            color: "#CCCC99"
                            JsonTextArea {
                               videoInfoStr: compressedVideo.videoInfoStr
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            id: page2
            color: "lightgreen"
            Text {
                text: "Page 2"
                anchors.centerIn: parent
            }
        }

        Rectangle {
            id: page3
            color: "lightcoral"
            Text {
                text: "Page 3"
                anchors.centerIn: parent
            }
        }
    }

    Row {
        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10

        Button {
            text: "视频压缩"
            onClicked: stackLayout.currentIndex = 0
        }

        Button {
            text: "视频裁剪"
            onClicked: stackLayout.currentIndex = 1
        }

        Button {
            text: "视频封面"
            onClicked: stackLayout.currentIndex = 2
        }
    }
}
