import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.0
import QtQuick.Dialogs 1.3

Rectangle {
 id: settingsPage
 anchors.fill: parent
 property bool forwardEnabled: false

 Column {
  width: parent.width
  ComboBox {
   id: itemDbTypeField
   width: parent.width
   model: ["postgres", "mysql", "mssql", "sqlite3"]
   Component.onCompleted: {
    itemDbTypeField.currentIndex = itemDbTypeField.find(settings.itemDbType)
   }
  }
  TextField {
   id: itemDbHostField
   width: parent.width
   placeholderText: "Host/URL"
   text: settings.itemDbHost
  }
  TextField {
   id: itemDbPortField
   width: parent.width
   placeholderText: "Port"
   text: settings.itemDbPort
  }
  TextField {
   id: itemDbNameField
   width: parent.width
   placeholderText: "DB Name"
   text: settings.itemDbName
  }
  TextField {
   id: itemDbUsernameField
   width: parent.width
   placeholderText: "Username"
   text: settings.itemDbUsername
  }
  TextField {
   id: itemDbPasswordField
   width: parent.width
   echoMode: TextInput.Password
   placeholderText: "Password"
   text: settings.itemDbPassword
  }
 }

 StackView.onStatusChanged: {
  // Check for changes and save them
  if (StackView.status === StackView.Deactivating) {
   var itemDbChanged = false
   if (settings.itemDbType != itemDbTypeField.currentText) {
    settings.itemDbType = itemDbTypeField.currentText
    itemDbChanged = true
   }
   if (settings.itemDbHost != itemDbHostField.text) {
    settings.itemDbHost = itemDbHostField.text
    itemDbChanged = true
   }
   if (settings.itemDbPort != itemDbPortField.text) {
    settings.itemDbPort = itemDbPortField.text
    itemDbChanged = true
   }
   if (settings.itemDbName != itemDbNameField.text) {
    settings.itemDbName = itemDbNameField.text
    itemDbChanged = true
   }
   if (settings.itemDbUsername != itemDbUsernameField.text) {
    settings.itemDbUsername = itemDbUsernameField.text
    itemDbChanged = true
   }
   if (settings.itemDbPassword != itemDbPasswordField.text) {
    settings.itemDbPassword = itemDbPasswordField.text
    itemDbChanged = true
   }
   if (itemDbChanged) {
    QmlBridge.loadItems(settings.itemDbType,
                       settings.itemDbHost,
                       settings.itemDbPort,
                       settings.itemDbName,
                       settings.itemDbUsername,
                       settings.itemDbPassword)
    window.itemLabelMessage = "Loading Items..."
    window.itemLoaderSource = itemLabel
    window.itemsLoaded = -1
   }
  }
 }
}
