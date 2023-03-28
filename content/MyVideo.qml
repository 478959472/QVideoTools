import QtQuick
import QtQuick.Controls 2.15
import QtMultimedia
import QtQuick.Dialogs
import Qt.labs.folderlistmodel 2.1
import com.example.ffmpeg 1.0
Rectangle {
    id: videoRectangle
    color: "#DDDDDD"
    width: 500
    height: 300
    anchors.fill: parent
    property bool isSaveView: false
    property string videoUrl: ''
    property string videoInfoStr: ''
    property string compressOutPut: ''

    onCompressOutPutChanged: {
        if(compressOutPut == ''){
            return
        }
        console.log("compressOutPut file: " + compressOutPut)
        videoPlayer.playVideo("file:///" + compressOutPut)
        let command = "ffprobe -v error  -print_format json -show_format -show_streams " + compressOutPut
        ffmpegVideoWrapper.executeFFmpegCommand(command);
    }
    FFmpegWrapper {
        id: ffmpegVideoWrapper
        onOutputReceived: {
            processReceived(output)
        }
    }
    Column {
        anchors.centerIn: parent
        anchors.fill: parent
        spacing: 0
        Rectangle {
            width: parent.width
            height: (parent.height - 25) * 0.9
            Video {
                id: videoPlayer
                source: videoRectangle.videoUrl
                anchors.fill: parent
            //    autoPlay: true
            //    loops: Video.Infinite
                onPositionChanged: {
                    // 更新进度条的值
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        videoPlayer.playOrPause()
                    }
                }
                function playOrPause(){
                    if(videoRectangle.videoUrl == ''){
                        console.log('视频地址不能为空')
                        return
                    }
                    if (videoPlayer.playbackState === MediaPlayer.PlayingState) {
                        videoPlayer.pause();
                    } else {
                        videoPlayer.play();
                    }
                }

                function playVideo(url){
                    videoPlayer.stop()
                    videoRectangle.videoUrl = url
                    videoPlayer.play()
                }
            }
        }
        Rectangle {
            width: parent.width
            height: 25
            color: "#CCCC99"
            Slider {
                id: slider
                width: parent.width
                height: 25
                orientation: Qt.Horizontal
                value: videoPlayer.enabled ? videoPlayer.position : 0
                from: 0
                to: videoPlayer.enabled ? videoPlayer.duration : 0
                onValueChanged: {
                    if (videoPlayer.enabled) {
                        videoPlayer.seek(value);
                    }
                }
            }
        }

        Rectangle {
            width: parent.width
            height: (parent.height - 25) * 0.1
            color: "#CCCC99"
            Row {
                id: row
                height: parent.height
                anchors.top: parent.top
                anchors.topMargin: 0
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10
                Text {
                    text: msToTime(videoPlayer.position)
                    anchors.verticalCenter: parent.verticalCenter
                  }
                Button {
                    height: parent.height
                    visible: !videoRectangle.isSaveView
                    text: "选择视频"
                    onClicked: {
                        fileDialog.title = "选择视频";
                        fileDialog.visible = true
                    }
                }

                Button {
                    height: parent.height
                    text: "播放/暂停"
                    onClicked:  videoPlayer.playOrPause()
                }


//                Button {
//                    visible: videoRectangle.isSaveView
//                    height: parent.height
//                    text: "视频另存为"
//                    onClicked:  videoPlayer.playOrPause()
//                }
            }
        }
    }

    FileDialog {
        id: fileDialog
        title: "Open File"
        nameFilters: ["Text files (*.Mp4)", "All files (*)"]
//        selectedNameFilter: "Text files (*.mp4)"
        onAccepted: {
            console.log("Selected file: " + selectedFile)
            videoPlayer.playVideo(selectedFile)
            let filePath =selectedFile.toString().replace("file:///", "")

//            videoRectangle.fileSize =ffmpegVideoWrapper.getFileSize(filePath);

            let command = "ffprobe -v error  -print_format json -show_format -show_streams " + filePath
            ffmpegVideoWrapper.executeFFmpegCommand(command);
        }
        onRejected: {
            console.log("Dialog rejected")
        }
    }

    function processReceived(str) {
        str = str.replace(/\s+/g, '');
        console.log("FFmpeg 输出:", str);
        if(str.length < 20){
            console.error( str);
            return
        }

        //这里为什么少个大阔号}}}
        let videoInfo = JSON.parse(str);

        let videoWidth = videoInfo.streams[0].width;
        let videoHeight = videoInfo.streams[0].height;
        let videoBitRate = videoInfo.streams[0].bit_rate;
        let videoSize = videoInfo.format.size;
        let videoFormat = videoInfo.format.format_name;
        let videoPath = videoInfo.format.filename;
        let videoDuration = videoInfo.format.duration;
        console.log("Video url: " + videoUrl);
        console.log("Video width: " + videoWidth);
        console.log("Video height: " + videoHeight);
        console.log("Video duration: " + videoDuration);
        console.log("Video bit rate: " + videoBitRate);
        let videoInfoJson =JSON.parse("{\"size\":0,\"width\":0,\"height\":0,\"duration\":0,\"bitRate\":0,\"encoder\":\"\",\"path\":\"\"}")
        videoInfoJson.size =videoSize
        videoInfoJson.width = videoWidth
        videoInfoJson.height = videoHeight
        videoInfoJson.duration = videoDuration
        videoInfoJson.bitRate = videoBitRate
        videoInfoJson.format = videoFormat
        videoInfoJson.path =videoPath
        videoInfoStr = JSON.stringify(videoInfoJson);
      }

    function msToTime(duration) {
        let seconds = Math.floor((duration / 1000) % 60);
        let minutes = Math.floor((duration / (1000 * 60)) % 60);
        let hours = Math.floor((duration / (1000 * 60 * 60)) % 24);

        hours = (hours < 10) ? "0" + hours : hours;
        minutes = (minutes < 10) ? "0" + minutes : minutes;
        seconds = (seconds < 10) ? "0" + seconds : seconds;

        return hours + ":" + minutes + ":" + seconds;
    }
}

