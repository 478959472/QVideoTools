import QtQuick

QtObject {
    property alias value: FFmpegWrapper.value

    FFmpegWrapper {
        id: fmpegWrapper
    }
}
