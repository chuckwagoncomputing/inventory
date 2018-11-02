import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.0

Rectangle {
 id: itemListPage
 anchors.fill: parent
 // Let the page indicator be visible, and this is the first page
 property bool indicatorEnabled: true
 property int indicatorIndex: 0
 property bool backDisabled: true
 property bool addEnabled: true
 property bool searchEnabled: true
 property bool settingsEnabled: true
 property bool refreshEnabled: true
 signal add()
 onAdd: {
  // Reset the current job to empty values
  workingItem.reset()
  stack.push("qrc:///qml/descriptionEntryPage.qml")
 }
 signal search()
 onSearch: {
  stack.push("qrc:///qml/searchPage.qml")
 }
 Loader {
  id: itemLoader
  anchors.fill: parent
  sourceComponent: window.itemLoaderSource
 }
}

