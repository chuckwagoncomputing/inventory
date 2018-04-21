import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.0

Rectangle {
 id: locationEntryPage
 property bool indicatorEnabled: true
 property int indicatorIndex: 2
 property bool forwardEnabled: true
 signal forward()
 onForward: {
  workingItem.location = location.text
  stack.push("qrc:///qml/quantityEntryPage.qml")
 }
 TextField {
  id: location
  width: parent.width
  placeholderText: "Item Location"
 }
 Component.onCompleted: {
  if (workingItem.location.length > 0) {
   location.text = workingItem.location
  }
 }
}
