import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.0

ListView {
 id: searchList
 model: SearchModel
 // Set this list so the last added items are at top
 verticalLayoutDirection: ListView.BottomToTop
 delegate: ItemDelegate {
  anchors.left: parent.left
  anchors.right: parent.right
  Text {
   anchors.left: parent.left
   anchors.top: parent.top
   font.pixelSize: 20
   elide: Text.ElideRight
   // Remove newlines
   text: Number(quantity) + "  " + description.replace(/(\r\n|\n|\r)/gm, " ")
  }
  Text {
   anchors.left: parent.left
   anchors.bottom: parent.bottom
   font.pixelSize: 14
   text: location
  }
  onClicked: {
   if (searchList.currentIndex != index) {
    searchList.currentIndex = index
   }
   workingItem.description = model.description
   workingItem.location = model.location
   workingItem.quantity = model.quantity
   workingItem.index = index
   stack.push("qrc:///qml/itemViewPage.qml")
  }
 }
 // This header is added to push the items to the top of the view if there aren't enough to fill the view.
 header: Item {}
 onContentHeightChanged: {
  if (contentHeight < height) {
   headerItem.height += (height - contentHeight)
  }
  currentIndex = count-1
  positionViewAtEnd()
 }
 Component.onCompleted: {
  itemList.positionViewAtEnd()
 }
}
