import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtMultimedia
Rectangle{
    id:root
    property int _imageIndex:-1
    width: 640
    height: 480
    visible: true
    color:"#333"
    CaptureSession{
        id:capturesession
        camera: Camera{}
        imageCapture: ImageCapture{
            id:imagecapture
            onImageSaved:function(id,path){
                imagepth.append({"path":path})
                listview.positionViewAtEnd()
                image.source="file:///"+path
            }

        }

        videoOutput: output
    }
    VideoOutput{
        id:output
        width: 300
        anchors.verticalCenter: root.verticalCenter
        anchors.margins: 20
        anchors.left: root.left
        MouseArea{
            anchors.fill: parent
            onClicked: imagecapture.captureToFile()
        }
    }
    ListModel{id:imagepth}
    ListView{
        id:listview
        anchors{
            left: root.left
            right: root.right
            //            top:output.bottom
            bottom: root.bottom
            bottomMargin: 10
        }
        height: 100
        orientation: ListView.Horizontal
        spacing:2
        model:imagepth
        delegate: Image
        {
            required property string path
            required property int index
            source:"file:///"+path
            fillMode:Image.PreserveAspectFit
            height:100
            MouseArea{

                anchors.fill: parent

                onClicked:
                {

                    image.source=parent.source
                    root._imageIndex=parent.index
                }
            }
        }
        Rectangle{
            color: 'white'
            opacity:0.1
            anchors.fill: parent

        }
    }
    MediaDevices{
        id:mediadevics
    }

    Row{
        ComboBox{
            id:combobox
            height: 30
            model: mediadevics.videoInputs
            textRole: "description"
            onAccepted: function(index){
                capturesession.camera.cameraDevice=combobox.currentValue
            }

        }

        Button{
            width: 50;
            height: 30
            text: "delete"
            onClicked: {
                imagepth.remove(root._imageIndex)
                image.source=""
            }
        }
        Button{
            width: 50;
            height: 30
            text: "play"
            onClicked: {
                startplay()
            }
        }
    }
    function startplay(){
        root._imageIndex=-1
        playtime.start()
    }
    Timer{
        id:playtime
        interval: 200
        repeat: false
        onTriggered: {
            if(root._imageIndex+1<imagepth.count){
                root._imageIndex+=1
                image.source="file:///"+imagepth.get(root._imageIndex).path
                playtime.start()
            }
        }
    }

    Image {
        id: image
        width: 300
        height: 200
        anchors.verticalCenter: root.verticalCenter
        anchors.right:root.right
        source: imagecapture.preview
        fillMode: Image.PreserveAspectFit

    }
    Component.onCompleted: {
        capturesession.camera.start()
    }
}
