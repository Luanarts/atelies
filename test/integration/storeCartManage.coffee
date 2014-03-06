require './support/_specHelper'
Store               = require '../../app/models/store'
Product             = require '../../app/models/product'
StoreCartPage       = require './support/pages/storeCartPage'
StoreProductPage    = require './support/pages/storeProductPage'

describe 'Store shopping cart page (manage)', ->
  page = storeProductPage = store = product1 = product2 = store2 = product3 = null
  before ->
    page = new StoreCartPage()
    storeProductPage = new StoreProductPage page
    cleanDB (error) ->
      store = generator.store.a()
      store.save()
      product1 = generator.product.a()
      product1.save()
      product2 = generator.product.b()
      product2.save()
      whenServerLoaded()

  describe 'with two items, when remove one item', ->
    before ->
      page.clearLocalStorage()
      .then -> storeProductPage.visit 'store_1', 'name_1'
      .then storeProductPage.purchaseItem
      .then -> storeProductPage.visit 'store_1', 'name_2'
      .then storeProductPage.purchaseItem
      #.then -> page.itemsQuantity (q) -> q.should.equal 2
      .then -> page.removeItem product1
    it 'shows a cart with one item', -> page.itemsQuantity().should.become 1
    it 'shows item id', -> page.id().should.become product2._id.toString()

  describe 'when setting quantity', ->
    before ->
      page.clearLocalStorage()
      .then -> storeProductPage.visit 'store_1', 'name_1'
      .then storeProductPage.purchaseItem
      .then -> page.updateQuantity product1, 3
      .then -> page.visit 'store_1'
    it 'is at the cart location', -> page.currentUrl().should.become "http://localhost:8000/store_1/cart"
    it 'shows a cart with one item', -> page.itemsQuantity().should.become 1
    it 'shows quantity of three', -> page.quantity().should.become 3

  describe 'when setting quantity to incorrect value', ->
    before ->
      page.clearLocalStorage()
      .then -> storeProductPage.visit 'store_1', 'name_1'
      .then storeProductPage.purchaseItem
      .then -> page.updateQuantity product1, 'abc'
    it 'shows error message', -> page.errorMessageForSelector('.quantity').should.become "A quantidade deve ser um número."
    it 'shows original quantity', -> page.visit('store_1').then page.quantity().should.become 1

  describe 'clearing cart', ->
    before ->
      page.clearLocalStorage()
      .then -> storeProductPage.visit 'store_1', 'name_1'
      .then storeProductPage.purchaseItem
      .then page.clearCart
    it 'shows an empty cart', -> page.itemsQuantity().should.become 0
