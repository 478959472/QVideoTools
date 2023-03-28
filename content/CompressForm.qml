import QtQuick
import QtQuick.Controls
import com.example.ffmpeg 1.0

Column {
    anchors.centerIn: parent
    id:compressForm
    spacing: 20
    width: 300
    height: 500
    property string videoUrl: ''
    property string selectVideoInfoStr: ''
    property string compressOutPut: ''
    property var resolutions: [
        "1920x1080",
        "1280x720",
        "960x540",
        "640x360",
        "1080x1920",
        "720x1280",
        "540x960",
        "360x640"
    ]
    //           leftPadding: 20
    property int labelWidth: 75
    FFmpegWrapper {
        id: compressFfmpegWrapper
        onOutputReceived: {
            processReceived()
        }
    }
    onSelectVideoInfoStrChanged: {
        console.log("视频已选择：", selectVideoInfoStr);
        let videoInfo = JSON.parse(selectVideoInfoStr);
        // 分辨率
        switchResolution(videoInfo.width, videoInfo.height)
    }
    function switchResolution(w, h) {
        console.log(w, h);
        let size = w + 'x' + h;
        resolutions.push(size)
        console.log(resolutions);
        resolutionComboBox.model = resolutions
        var index = resolutionComboBox.model.indexOf(size)
        if (index !== -1) {
            resolutionComboBox.currentIndex = index
        }
    }
    function processReceived() {
        console.log("FFmpeg 压缩完成,输出路径:" , compressOutPut);

      }
    Row {
        id: row1
        spacing: 10
        Label {
            text: "指定大小："
            width: 75
            anchors.verticalCenter: parent.verticalCenter
        }
        TextField {
            id: sizeField
            width: 200
            validator: DoubleValidator {}
            placeholderText: "1.9"
        }
    }

    Row {
        id: row2
        spacing: 10
        Label {
            text: "指定分辨率："
            width: 75
            anchors.verticalCenter: parent.verticalCenter
        }
        ComboBox {
            id: resolutionComboBox
            width: 200
            model: resolutions
        }
    }

    Row {
        id: row3
        spacing: 10
        Label {
            width: 75
            text: "指定倍速："
            anchors.verticalCenter: parent.verticalCenter
        }
        ComboBox {
            id: speedComboBox
            width: 200
            model: [
                "1.0",
                "1.2",
                "1.3",
                "1.4",
                "1.5",
                "1.6",
                "1.7",
                "1.8",
                "1.9",
                "2.0"
            ]
        }
    }
    Row {
        id: row4
        spacing: 10
        leftPadding: 85
        Button {
            width: 200
            text: "开始压缩"
            onClicked: {
                console.log("压缩视频信息:", selectVideoInfoStr)
                let videoInfo = JSON.parse(selectVideoInfoStr);
                console.log("压缩视频信息:", selectVideoInfoStr)
                console.log("指定大小：", sizeField.text)
                console.log("指定分辨率：", resolutionComboBox.currentText)
                console.log("指定倍速：", speedComboBox.currentText)
                // 在此处添加提交逻辑
                var commond;
                let commondArray;
                let fileInput = videoInfo.path
                let fileOutPut = getDirectoryPath(fileInput) +"/"+ generateFilename() + ".mp4"
                //视频加速
                let targetSpeed = parseFloat(speedComboBox.currentText)
                if(targetSpeed && targetSpeed !== 1){
                    commondArray = speedVideo(fileInput, fileOutPut, targetSpeed)
                    commond = commondArray.join(" ")
                    console.log("进行视频加速", commond)
                    compressFfmpegWrapper.executeFFmpegCommand(commond)
                    fileInput = fileOutPut
                    fileOutPut = getDirectoryPath(fileInput) +"/"+ generateFilename() + ".mp4"
                }


                let targetSize = sizeField.text !== '' ?parseFloat(sizeField.text) : 1.9;

                let width = resolutionComboBox.currentText.split("x")[0]
                let height = resolutionComboBox.currentText.split("x")[1]
                let videoLength = Math.ceil(parseFloat(videoInfo.duration));
                console.log("压缩参数:", fileInput, fileOutPut, targetSize, width, height, videoLength)
                commondArray = compressVideo(fileInput, fileOutPut, targetSize, width, height, videoLength)
                commond = commondArray.join(" ")
                console.log(commond)
                compressFfmpegWrapper.executeFFmpegCommand(commond)
                compressOutPut = fileOutPut
            }
        }

    }

    function compressVideo(fileInput, fileOutPut, targetSize, width, height, videoLength) {
        let commond = [];
        commond.push("ffmpeg");
        commond.push("-i");
        commond.push(fileInput);
        // 设置分辨率
        if (width !== null && width > 0 && height !== null && height > 0) {
            commond.push("-s");
            let resolution = width.toString() + "x" + height.toString();
            commond.push(resolution);
        }
        // target size in bits
        targetSize = targetSize * 1000 * 1000 * 8;
        // 获取视频duration
        let length = videoLength;
        // total_bitrate=$(( $target_size / $length_round_up ))
        let totalBitrate = Math.floor(targetSize / length);
        //audio_bitrate=$(( 32 * 1000 ))
        //video_bitrate=$(( $total_bitrate - $audio_bitrate ))
        let audioBitrate = 32 * 1000;
        let videoBitrate = totalBitrate - audioBitrate;
        commond.push("-b:v");
        commond.push(videoBitrate.toString());
        commond.push("-maxrate:v");
        commond.push(videoBitrate.toString());
        commond.push("-bufsize:v");
        commond.push(Math.floor(targetSize / 20).toString());
        commond.push("-b:a");
        commond.push(audioBitrate.toString());
        commond.push(fileOutPut);
        return commond;
    }

    function speedVideo(fileInput, fileOutPut, targetSpeed) {
        if (targetSpeed < 0 || targetSpeed > 5) {
            console.error("目标速度超出范围，targetSpeed: ", targetSpeed);
            return;
        }

        let ffmpegPath = "ffmpeg"; // 设置FFmpeg的路径

        let commond = [];
        commond.push(ffmpegPath);
        commond.push("-i");
        commond.push(fileInput);
        commond.push("-vf");

        let setpts = "setpts=(PTS-STARTPTS)/" + targetSpeed;
        commond.push(setpts);
        commond.push("-af");

        let atempo = "atempo=" + targetSpeed;
        commond.push(atempo);
        commond.push(fileOutPut);
        return commond;
    }

    function getDirectoryPath(filePath) {
        let pathComponents = filePath.split('/');
        pathComponents.pop();
        return pathComponents.join('/');
    }

    function generateFilename() {
        const date = new Date();
        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const day = String(date.getDate()).padStart(2, '0');
        const hours = String(date.getHours()).padStart(2, '0');
        const minutes = String(date.getMinutes()).padStart(2, '0');
        const seconds = String(date.getSeconds()).padStart(2, '0');
        const milliseconds = String(date.getMilliseconds()).padStart(3, '0');

        return `file_${year}${month}${day}_${hours}${minutes}${seconds}${milliseconds}`;
    }
}
