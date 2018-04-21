import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.0

Rectangle {
 id: itemViewPage
 anchors.fill: parent
 property bool forwardEnabled: false
 property bool editEnabled: true
 signal edit()
 onEdit: {
  stack.push("qrc:///qml/descriptionEntryPage.qml")
 }
 ScrollView {
  id: itemScrollView
  anchors.top: parent.top
  anchors.bottom: deleteButton.top
  width: itemViewPage.width
  clip: true
  Column {
   width: itemViewPage.width
   Label {
    id: descLabel
    width: parent.width
    text: workingItem.description
    font.pixelSize: 24
    anchors.margins: 10
   }
   Label {
    id: locLabel
    width: parent.width
    text: "Location: " + workingItem.location
    font.pixelSize: 20
    anchors.margins: 10
   }
   SpinBox {
    id: quantitySpinner
    anchors.horizontalCenter: parent.horizontalCenter
    editable: true
    value: Number(workingItem.quantity)
    anchors.margins: 20
   }
  }
 }
 Button {
  id: deleteButton
  text: "Delete"
  width: parent.width
  anchors.bottom: parent.bottom
  onClicked: {
   QmlBridge.removeItem(workingItem.index)
   stack.pop()
  }
 }
 StackView.onStatusChanged: {
  if (StackView.status === StackView.Deactivating && quantitySpinner.value != Number(workingItem.quantity)) {
   QmlBridge.editItem(workingItem.index, workingItem.description, workingItem.location, quantitySpinner.value + "")
  }
 }
}
