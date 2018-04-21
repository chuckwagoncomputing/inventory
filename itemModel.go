package main

import (
 "errors"
 "github.com/jinzhu/gorm"
 _ "github.com/jinzhu/gorm/dialects/mssql"
 _ "github.com/jinzhu/gorm/dialects/mysql"
 _ "github.com/jinzhu/gorm/dialects/postgres"
 _ "github.com/jinzhu/gorm/dialects/sqlite"
 "github.com/therecipe/qt/core"
 "unsafe"
)

const (
 Description = int(core.Qt__UserRole) + 1<<iota
 Location
 Quantity
)

type ItemModel struct {
 core.QAbstractListModel
 _ map[int]*core.QByteArray `property:"roles"`
 _ func()     `constructor:"init"`

 _ func(*Item) `slot:"addItem"`
 _ []*Item     `property:"items"`

 _ func() `slot:"reset"`
}

func (im *ItemModel) init() {
 im.SetRoles(map[int]*core.QByteArray{
  Description: core.NewQByteArray2("description", len("description")),
  Location:    core.NewQByteArray2("location", len("location")),
  Quantity:    core.NewQByteArray2("quantity", len("quantity")),
 })
 im.ConnectData(im.data)
 im.ConnectRowCount(im.rowCount)
 im.ConnectRoleNames(im.roleNames)
 im.ConnectAddItem(im.addItem)
 im.ConnectReset(im.reset)
}

func (im *ItemModel) roleNames() map[int]*core.QByteArray {
 return im.Roles()
}

func (im *ItemModel) data(index *core.QModelIndex, role int) *core.QVariant {
 if !index.IsValid() {
  return core.NewQVariant()
 }
 if index.Row() >= len(im.Items()) {
  return core.NewQVariant()
 }

 i := im.Items()[index.Row()]

 switch role {
  case Description:
   return core.NewQVariant14(i.Description)
  case Location:
   return core.NewQVariant14(i.Location)
  case Quantity:
   return core.NewQVariant14(i.Quantity)
  default:
   return core.NewQVariant()
 }
}

func (im *ItemModel) rowCount(parent *core.QModelIndex) int {
 return len(im.Items())
}

type Item struct {
 gorm.Model

 Description string
 Location    string
 Quantity    string
}

type ItemDB struct {
 dbType     string
 dbHost     string
 dbPort     string
 dbName     string
 dbUsername string
 dbPassword string
}

// Opens the database and returns a database object.
// Be sure to call db.Close() when you are done with it.
func (id *ItemDB) Open() (*gorm.DB, error) {
 var db *gorm.DB
 var err error
 switch id.dbType {
  case "sqlite":
   db, err = gorm.Open("sqlite3", id.dbHost)
  case "mysql":
   db, err = gorm.Open("mysql", id.dbUsername+":"+id.dbPassword+"@tcp("+id.dbHost+":"+id.dbPort+")/"+id.dbName+"?charset=utf8&parseTime=True&loc=Local")
  case "mssql":
   db, err = gorm.Open("mssql", "sqlserver://"+id.dbUsername+":"+id.dbPassword+"@"+id.dbHost+":"+id.dbPort+"?database="+id.dbName)
  default:
   db, err = gorm.Open("postgres", "host="+id.dbHost+" port="+id.dbPort+" user="+id.dbUsername+" dbname="+id.dbName+" password="+id.dbPassword+" sslmode=disable")
 }
 if err != nil {
  return nil, errors.New("Could not connect to database: " + err.Error())
 }
 return db, nil
}

var itemDb ItemDB

func (im *ItemModel) loadItemsShim(t string, h string, p string, n string, u string, k string) {
 go im.loadItems(t, h, p, n, u, k)
}

func (im *ItemModel) loadItems(t string, h string, p string, n string, u string, k string) {
 // Lock the database. If it's already locked, wait for it to be unlocked.
 dbMutex.Lock()
 defer dbMutex.Unlock()
 // Set the DB info, as this is the first time it's been used.
 itemDb = ItemDB{t, h, p, n, u, k}
 db, err := itemDb.Open()
 if err != nil {
  qmlBridge.ErrorLoadingItems(err.Error())
  return
 }
 defer db.Close()
 if err := db.AutoMigrate(&Item{}).Error; err != nil {
  qmlBridge.ErrorLoadingItems("Failed to automatically migrate database.")
  return
 }
 var items []Item
 if err := db.Find(&items).Error; err != nil {
  qmlBridge.ErrorLoadingItems("Failed to load items from database.")
  return
 }
 // Convert the array of Items into an array of *Items
 pItems := make([]*Item, len(items))
 for i, _ := range items {
  pItems[i] = &items[i]
 }
 im.SetItems(pItems)
 qmlBridge.ItemsLoaded(len(im.Items()))
}

func (im *ItemModel) newItemShim(d string, l string, q string) {
 go im.buildItem(d, l, q)
}

func (im *ItemModel) buildItem(d string, l string, q string) {
 // Lock the database. If it's already locked, wait for it to be unlocked.
 dbMutex.Lock()
 defer dbMutex.Unlock()
 db, err := itemDb.Open()
 if err != nil {
  qmlBridge.Error("Could not open DB to create item: " + err.Error())
  return
 }
 defer db.Close()
 item := Item{Description: d, Location: l, Quantity: q}
 if len(im.Items()) >= 1 {
  qmlBridge.ItemsLoaded(len(im.Items()))
 }
 if err := db.Create(&item); err.Error != nil {
  qmlBridge.Error("Error Saving item: " + err.Error.Error())
  return
 }
 im.AddItem(&item)
}

func (im *ItemModel) addItem(i *Item) {
 im.BeginInsertRows(core.NewQModelIndex(), len(im.Items()), len(im.Items()))
 im.SetItems(append(im.Items(), i))
 im.EndInsertRows()
 if len(im.Items()) == 1 {
  qmlBridge.ItemsLoaded(len(im.Items()))
 }
}

func (im *ItemModel) editItemShim(i int, d string, l string, q string) {
 go im.editItem(i, d, l, q)
}

func (im *ItemModel) editItem(i int, d string, l string, q string) {
 // Lock the database. If it's already locked, wait for it to be unlocked.
 dbMutex.Lock()
 defer dbMutex.Unlock()
 // Check for out-of-range index. This can occur if an item has been deleted but not yet removed from the list.
 if i < 0 || i >= len(im.Items()) {
  qmlBridge.Error("Could not edit item: Index not found.")
  return
 }
 db, err := itemDb.Open()
 if err != nil {
  qmlBridge.Error("Could not open DB to edit item: " + err.Error())
  return
 }
 defer db.Close()
 nr := im.Items()[i]
 nr.Description = d
 nr.Location = l
 nr.Quantity = q
 if err := db.Save(nr); err.Error != nil {
  qmlBridge.Error("Could not save item: " + err.Error.Error())
  return
 }
 ni := im.Items()
 ni[i] = nr
 im.SetItems(ni)
 im.DataChanged(im.CreateIndex(i, 0, unsafe.Pointer(new(uintptr))), im.CreateIndex(i, 0, unsafe.Pointer(new(uintptr))), []int{Description, Location, Quantity})
}

func (im *ItemModel) removeItemShim(i int) {
 go im.removeItem(i)
}

func (im *ItemModel) removeItem(i int) {
 // Lock the database. If it's already locked, wait for it to be unlocked.
 dbMutex.Lock()
 defer dbMutex.Unlock()
 // Check for out-of-range index. This can occur if an item has been deleted but not yet removed from the list.
 if i < 0 || i >= len(im.Items()) {
  qmlBridge.Error("Could not delete item: Index not found.")
  return
 }
 db, err := itemDb.Open()
 if err != nil {
  qmlBridge.Error("Could not open DB to delete item: " + err.Error())
  return
 }
 defer db.Close()
 if err := db.Delete(im.Items()[i]); err.Error != nil {
  qmlBridge.Error("Could not delete item: " + err.Error.Error())
  return
 }
 im.BeginRemoveRows(core.NewQModelIndex(), i, i)
 im.SetItems(append(im.Items()[:i], im.Items()[i+1:]...))
 im.EndRemoveRows()
}

func (im *ItemModel) reset() {
 im.BeginRemoveRows(core.NewQModelIndex(), 0, len(im.Items())-1)
 im.SetItems([]*Item{})
 im.EndRemoveRows()
}
