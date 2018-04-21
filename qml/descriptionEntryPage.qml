import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.0

Rectangle {
 id: descriptionEntryPage
 property bool indicatorEnabled: true
 property int indicatorIndex: 1
 property bool forwardEnabled: true
 signal forward()
 onForward: {
  workingItem.description = description.text
  stack.push("qrc:///qml/locationEntryPage.qml")
 }
 ScrollView {
  anchors.fill: parent
  TextArea {
   id: description
   placeholderText: "Description"
   wrapMode: Text.Wrap
  }
 }
 Component.onCompleted: {
  if (workingItem.description.length > 0) {
   description.text = workingItem.description
  }
 }
}
