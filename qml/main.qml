import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.0
import Qt.labs.settings 1.0

ApplicationWindow {
 id: window
 visible: true
 title: "Inventory"
 minimumWidth: 400
 minimumHeight: 400

 Settings {
  id: settings
  property alias x: window.x
  property alias y: window.y
  property alias width: window.width
  property alias height: window.height

  property string itemDbType: "postgres"
  property string itemDbHost: ""
  property string itemDbPort: "5432"
  property string itemDbName: ""
  property string itemDbUsername: "postgres"
  property string itemDbPassword: ""
 }

 Connections {
  target: QmlBridge
  onErrorLoadingItems: {
   window.itemLabelMessage = "Error Loading Items: " + errmsg + "\nHave you set up your server?"
   window.itemLoaderSource = itemLabel
   window.itemsLoaded = 0
  }
  onItemsLoaded: {
   if (count === 0) {
    window.itemLabelMessage = "No Items Available. Use the + button to add a item."
    window.itemLoaderSource = itemLabel
   }
   else {
    window.itemLoaderSource = Qt.createComponent("qrc:///qml/itemList.qml")
   }
   window.itemsLoaded = count
  }

  onError: {
   errorToolTip.text = errmsg
   errorToolTip.visible = true
  }
 }

 property var itemLoaderSource: itemLabel
 property string itemLabelMessage: "Loading Items..."

 Component {
  id: itemLabel
  Rectangle {
   anchors.horizontalCenter: parent.horizontalCenter
   anchors.verticalCenter: parent.verticalCenter
   Label {
    text: window.itemLabelMessage
    width: parent.width
    horizontalAlignment: Text.AlignHCenter
    wrapMode: Text.Wrap
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter
    font.pixelSize: 24
   }
  }
 }

 header: ToolBar {
  Material.foreground: "white"

  Label {
   anchors.horizontalCenter: parent.horizontalCenter
   anchors.verticalCenter: parent.verticalCenter
   id: titleLabel
   text: "Inventory"
   font.pixelSize: 20
   horizontalAlignment: Qt.AlignHCenter
   verticalAlignment: Qt.AlignVCenter
   Layout.fillWidth: true
  }

  ToolButton {
   id: backButton
   visible: !stack.currentItem.backDisabled
   anchors.left: parent.left
   anchors.verticalCenter: parent.verticalCenter
   width: parent.height
   height: parent.height
   contentItem: Image {
    fillMode: Image.PreserveAspectFit
    horizontalAlignment: Image.AlignHCenter
    verticalAlignment: Image.AlignVCenter
    source: "images/back.png"
   }
   onClicked: {
    stack.pop()
   }
  }

  ToolButton {
   id: addButton
   visible: stack.currentItem.addEnabled || false
   anchors.right: parent.right
   anchors.verticalCenter: parent.verticalCenter
   width: parent.height
   height: parent.height
   contentItem: Image {
    fillMode: Image.PreserveAspectFit
    horizontalAlignment: Image.AlignHCenter
    verticalAlignment: Image.AlignVCenter
    source: "images/plus.png"
   }
   onClicked: {
    stack.currentItem.add()
   }
  }

  ToolButton {
   id: forwardButton
   visible: stack.currentItem.forwardEnabled || false
   anchors.right: parent.right
   anchors.verticalCenter: parent.verticalCenter
   width: parent.height
   height: parent.height
   contentItem: Image {
    fillMode: Image.PreserveAspectFit
    horizontalAlignment: Image.AlignHCenter
    verticalAlignment: Image.AlignVCenter
    source: "images/forward.png"
   }
   onClicked: {
    stack.currentItem.forward()
   }
  }

  ToolButton {
   id: settingsButton
   visible: stack.currentItem.settingsEnabled || false
   anchors.left: parent.left
   anchors.verticalCenter: parent.verticalCenter
   width: parent.height
   height: parent.height
   contentItem: Image {
    fillMode: Image.PreserveAspectFit
    horizontalAlignment: Image.AlignHCenter
    verticalAlignment: Image.AlignVCenter
    source: "images/settings.png"
   }
   onClicked: {
    stack.push("qrc:///qml/settingsPage.qml")
   }
  }

  ToolButton {
   id: editButton
   visible: stack.currentItem.editEnabled || false
   anchors.right: parent.right
   anchors.verticalCenter: parent.verticalCenter
   width: parent.height
   height: parent.height
   contentItem: Image {
    fillMode: Image.PreserveAspectFit
    horizontalAlignment: Image.AlignHCenter
    verticalAlignment: Image.AlignVCenter
    source: "images/edit.png"
   }
   onClicked: {
    stack.currentItem.edit()
   }
  }

  ToolButton {
   id: refreshButton
   visible: stack.currentItem.refreshEnabled || false
   anchors.left: settingsButton.right
   anchors.verticalCenter: parent.verticalCenter
   width: parent.height
   height: parent.height
   contentItem: Image {
    fillMode: Image.PreserveAspectFit
    horizontalAlignment: Image.AlignHCenter
    verticalAlignment: Image.AlignVCenter
    source: "images/refresh.png"
   }
   onClicked: {
    ItemModel.reset()
    window.itemLoaderSource = itemLabel
    window.itemLabelMessage = "Loading Items..."
    QmlBridge.loadItems(settings.itemDbType,
                       settings.itemDbHost,
                       settings.itemDbPort,
                       settings.itemDbName,
                       settings.itemDbUsername,
                       settings.itemDbPassword)
    window.itemsLoaded = -1
   }
  }

  // This a new type of page indicator which I invented...
  PageIndicator {
   id: editIndicator
   z: 1
   spacing: 10
   anchors.horizontalCenter: parent.horizontalCenter
   anchors.top: titleLabel.bottom
   currentIndex: stack.currentItem.indicatorIndex || false
   visible: stack.currentItem.indicatorEnabled || false
   count: 4
   delegate: Loader {
    property var thisIndex: index
    sourceComponent: {
     // Each indicator dot has three states: Loading, Loaded, or N/A
     switch (index) {
      case 0:
       if (window.itemsLoaded > 1) {
        return indicatorRect
       }
       else if (window.itemsLoaded === -1) {
        return indicatorLoading
       }
       else {
        return indicatorNa
       }
       break;
      // Only the first two page actually has states other than Loaded
      default:
       return indicatorRect
     }
    }
   }
  }
 }

 // -1: Loading
 //  0: N/A
 // >0: Loaded
 property int itemsLoaded: -1

 Component {
  id: indicatorLoading
  BusyIndicator {
   height: 28
   width: 28
   y: -8
   running: true
   opacity: parent.thisIndex === stack.currentItem.indicatorIndex ? 1 : 0.45
  }
 }

 Component {
  id: indicatorRect
  // The rect-in-rect is to achieve the same sizing as the loading indicator
  Rectangle {
   height: 28
   width: 28
   y: -8
   color: "transparent"
   Rectangle {
    anchors.verticalCenter: parent.verticalCenter
    anchors.horizontalCenter: parent.horizontalCenter
    implicitWidth: 15
    implicitHeight: 15
    radius: width
    color: "#21be2b"
    opacity: parent.parent.thisIndex === stack.currentItem.indicatorIndex ? 1 : 0.45
   }
  }
 }

 Component {
  id: indicatorNa
  Rectangle {
   height: 28
   width: 28
   y: -8
   color: "transparent"
   Rectangle {
    anchors.verticalCenter: parent.verticalCenter
    anchors.horizontalCenter: parent.horizontalCenter
    implicitWidth: 15
    implicitHeight: 5
    color: "#21be2b"
    opacity: parent.parent.thisIndex === stack.currentItem.indicatorIndex ? 1 : 0.45
   }
  }
 }

 StackView {
  id: stack
  anchors.fill: parent
  initialItem: "qrc:///qml/itemListPage.qml"
 }

 Rectangle {
  anchors.bottom: parent.bottom
  anchors.margins: 10
  anchors.left: parent.left
  anchors.right: parent.right
  z: 1
  ToolTip {
   id: errorToolTip
   width: parent.width
   timeout: 3000
   contentItem: Text {
    width: parent.width
    text: errorToolTip.text
    font: errorToolTip.font
    color: "#ffffff"
    wrapMode: Text.Wrap
   }
  }
 }

 Item {
  id: workingItem
  property string description: ""
  property string location: ""
  property string quantity: ""
  property int index: -1
  signal reset()
  onReset: {
   workingItem.description = ""
   workingItem.location = ""
   workingItem.quantity = ""
   workingItem.index = -1
  }
 }

 Component.onCompleted: {
  QmlBridge.loadItems(settings.itemDbType,
                      settings.itemDbHost,
                      settings.itemDbPort,
                      settings.itemDbName,
                      settings.itemDbUsername,
                      settings.itemDbPassword)
 }

 // Handle the back button in Android
 onClosing: {
  if (Qt.platform.os == "android" && backButton.visible) {
   stack.pop()
   close.accepted = false
  }
 }
}
