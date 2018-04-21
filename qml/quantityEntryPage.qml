import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.0

Rectangle {
 id: quantityEntryPage
 property bool indicatorEnabled: true
 property int indicatorIndex: 3
 property bool forwardEnabled: true
 signal forward()
 onForward: {
  workingItem.quantity = quantity.text
  if (workingItem.index < 0) {
   QmlBridge.newItem(workingItem.description, workingItem.location, workingItem.quantity)
  }
  else {
   QmlBridge.editItem(workingItem.index, workingItem.description, workingItem.location, workingItem.quantity)
  }
  stack.push("qrc:///qml/itemListPage.qml")
 }
 TextField {
  width: parent.width
  id: quantity
  placeholderText: "Quantity"
 }
 Component.onCompleted: {
  if (workingItem.quantity.length > 0) {
   quantity.text = workingItem.quantity
  }
 }
}
