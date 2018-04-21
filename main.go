package main

import (
 "os"
 "github.com/therecipe/qt/core"
 "github.com/therecipe/qt/gui"
 "github.com/therecipe/qt/qml"
 "github.com/therecipe/qt/quickcontrols2"
 "sync"
)

type QmlBridge struct {
 core.QObject

 _ func(errmsg string) `signal:"error"`

 _ func(t string, h string, p string, n string, u string, k string) `slot:"loadItems"`
 _ func(count int) `signal:"itemsLoaded"`
 _ func(errmsg string) `signal:"errorLoadingItems"`
 _ func(d string, l string, q string) `slot:"newItem"`
 _ func(i int, d string, l string, q string) `slot:"editItem"`
 _ func(i int) `slot:"removeItem"`
}

var qmlBridge *QmlBridge
var itemModel *ItemModel

// dbMutex is for controlling DB access.
var dbMutex sync.Mutex

func main() {
 qmlBridge = NewQmlBridge(nil)
 itemModel = NewItemModel(nil)

 core.QCoreApplication_SetAttribute(core.Qt__AA_EnableHighDpiScaling, true)
 gui.NewQGuiApplication(len(os.Args), os.Args)
 quickcontrols2.QQuickStyle_SetStyle("material")
 view := qml.NewQQmlApplicationEngine(nil)

 qmlBridge.ConnectLoadItems(itemModel.loadItemsShim)
 qmlBridge.ConnectNewItem(itemModel.newItemShim)
 qmlBridge.ConnectEditItem(itemModel.editItemShim)
 qmlBridge.ConnectRemoveItem(itemModel.removeItemShim)

 view.RootContext().SetContextProperty("QmlBridge", qmlBridge)
 view.RootContext().SetContextProperty("ItemModel", itemModel)

 view.Load(core.NewQUrl3("qrc:///qml/main.qml", 0))
 gui.QGuiApplication_Exec()
}
