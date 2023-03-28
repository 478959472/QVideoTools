import QtQuick
import QtQuick.Controls

Column  {
    id: textAreaJson
    anchors.centerIn: parent
    anchors.fill: parent
    leftPadding: 10
    spacing: 10
    property string videoInfoStr: ''
    property var  jsonData: videoInfoStr != '' ? JSON.parse(videoInfoStr) :JSON.parse("{\"size\":0,\"format\":\"mp4\",\"width\":0,\"height\":0,\"duration\":0,\"bitRate\":0,\"encoder\":\"\",\"path\":\"\"}")
    onVideoInfoStrChanged: {
        if(videoInfoStr != ''){
            console.log("textAreaJson属性值变化：" ,videoInfoStr)
            jsonData = JSON.parse(videoInfoStr)
        }

    }

    Text {
          text: "大小: " + jsonData.size
      }
      Text {
          text: "格式: " + jsonData.format
      }
      Text {
          text: "宽: " + jsonData.width
      }
      Text {
          text: "高: " + jsonData.height
      }
      Text {
          text: "比特率: " + jsonData.bitRate
      }
      Text {
          text: "时长: " + jsonData.duration
      }
      Text {
          text: "路径: " + jsonData.path
      }
}

