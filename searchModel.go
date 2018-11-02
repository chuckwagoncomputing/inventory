package main

import (
 _ "github.com/jinzhu/gorm"
 _ "github.com/jinzhu/gorm/dialects/mssql"
 _ "github.com/jinzhu/gorm/dialects/mysql"
 _ "github.com/jinzhu/gorm/dialects/postgres"
 _ "github.com/jinzhu/gorm/dialects/sqlite"
 "github.com/therecipe/qt/core"
)

const (
 ResultDescription = int(core.Qt__UserRole) + 1<<iota
 ResultLocation
 ResultQuantity
)

type SearchModel struct {
 core.QAbstractListModel
 _ map[int]*core.QByteArray `property:"roles"`
 _ func()     `constructor:"init"`

 _ []*Item     `property:"items"`

 _ func(s string) `slot:"search"`
 _ func() `slot:"reset"`
}

func (sm *SearchModel) init() {
 sm.SetRoles(map[int]*core.QByteArray{
  ResultDescription: core.NewQByteArray2("description", len("description")),
  ResultLocation:    core.NewQByteArray2("location", len("location")),
  ResultQuantity:    core.NewQByteArray2("quantity", len("quantity")),
 })
 sm.ConnectData(sm.data)
 sm.ConnectRowCount(sm.rowCount)
 sm.ConnectRoleNames(sm.roleNames)
 sm.ConnectReset(sm.reset)
 sm.ConnectSearch(sm.search)
}

func (sm *SearchModel) roleNames() map[int]*core.QByteArray {
 return sm.Roles()
}

func (sm *SearchModel) data(index *core.QModelIndex, role int) *core.QVariant {
 if !index.IsValid() {
  return core.NewQVariant()
 }
 if index.Row() >= len(sm.Items()) {
  return core.NewQVariant()
 }

 i := sm.Items()[index.Row()]

 switch role {
  case ResultDescription:
   return core.NewQVariant14(i.Description)
  case ResultLocation:
   return core.NewQVariant14(i.Location)
  case ResultQuantity:
   return core.NewQVariant14(i.Quantity)
  default:
   return core.NewQVariant()
 }
}

func (sm *SearchModel) rowCount(parent *core.QModelIndex) int {
 return len(sm.Items())
}

func (sm *SearchModel) searchShim(s string) {
 go sm.search(s)
}

func (sm *SearchModel) search(s string) {
 dbMutex.Lock()
 defer dbMutex.Unlock()
 db, err := itemDb.Open()
 if err != nil {
  qmlBridge.Error("Could not open DB to search for items: " + err.Error())
  return
 }
 defer db.Close()
 var items []Item
 if err := db.Where("description ILIKE $1 OR location = $2", "%" + s + "%", s).Find(&items).Error; err != nil {
  qmlBridge.Error("Could not find items: " + err.Error())
  return
 }
 pItems := make([]*Item, len(items))
 for i, _ := range items {
  pItems[i] = &items[i]
 }
 sm.SetItems(pItems)
 qmlBridge.SearchCompleted(len(items))
}

func (sm *SearchModel) reset() {
 sm.BeginRemoveRows(core.NewQModelIndex(), 0, len(sm.Items())-1)
 sm.SetItems([]*Item{})
 sm.EndRemoveRows()
}
