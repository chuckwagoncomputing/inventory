import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.0

Rectangle {
 id: searchPage
 anchors.fill: parent
 property bool backEnabled: true
 property bool searchEnabled: true
 property bool searchFieldEnabled: true
 signal search()
 onSearch: {
  window.searchLabelMessage = "Searching..."
  window.searchLoaderSource = searchLabel
  QmlBridge.search(searchField.text)
 }
 Loader {
  id: searchLoader
  anchors.fill: parent
  sourceComponent: window.searchLoaderSource
 }
}
