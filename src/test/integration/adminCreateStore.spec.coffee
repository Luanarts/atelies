require './support/_specHelper'
Store     = require '../../models/store'
User      = require '../../models/user'

describe 'Admin home page', ->
  exampleStore = userSeller = browser = null
  before (done) -> whenServerLoaded done
  after -> browser.destroy() if browser?
  describe 'creates a store', (done) ->
    before (done) ->
      cleanDB (error) ->
        return done error if error
        userSeller = generator.user.c()
        userSeller.save()
        exampleStore = generator.store.a()
        browser = newBrowser browser
        browser.loginPage.navigateAndLoginWith userSeller, ->
          browser.adminCreateStorePage.visit (error) ->
            return done error if error
            browser.adminCreateStorePage.setFieldsAs exampleStore
            browser.adminCreateStorePage.clickCreateStoreButton done
    it 'is at the admin store page', ->
      expect(browser.location.toString()).to.equal "http://localhost:8000/admin#manageStore/#{exampleStore.slug}"
    xit 'shows store created message', -> #failing, zombie is not updating its content
      expect(browser.text('#message')).to.equal "Loja criada com sucesso"
    it 'created a new store with correct information', (done) ->
      Store.findBySlug exampleStore.slug, (error, store) ->
        return done error if error
        expect(store).not.to.be.null
        expect(store.slug).to.equal exampleStore.slug
        expect(store.name).to.equal exampleStore.name
        expect(store.phoneNumber).to.equal exampleStore.phoneNumber
        expect(store.city).to.equal exampleStore.city
        expect(store.state).to.equal exampleStore.state
        expect(store.otherUrl).to.equal exampleStore.otherUrl
        expect(store.banner).to.equal exampleStore.banner
        done()
    it 'added the store to the user', (done) ->
      User.findById userSeller.id, (err, user) ->
        return done err if err
        user.stores.length.should.equal 1
        done()

  describe 'does not create a store (missing or wrong info)', (done) ->
    before (done) ->
      cleanDB (error) ->
        return done error if error
        userSeller = generator.user.c()
        userSeller.save()
        browser = newBrowser browser
        exampleStore = generator.store.empty()
        browser.loginPage.navigateAndLoginWith userSeller, ->
          browser.adminCreateStorePage.visit (error) ->
            return done error if error
            exampleStore.banner = "abc"
            exampleStore.otherUrl = "def"
            browser.adminCreateStorePage.setFieldsAs exampleStore
            browser.adminCreateStorePage.clickCreateStoreButton done
    it 'is at the store create page', ->
      expect(browser.location.toString()).to.equal "http://localhost:8000/admin#createStore"
    xit 'does not show store created message', ->
      expect(browser.query('#message')).to.be.undefined #zombiejs has problems updating content
    it 'shows validation messages', ->
      expect(browser.text("label[for='name']")).to.equal "Informe o nome da loja."
      expect(browser.text("label[for='city']")).to.equal "Informe a cidade."
      expect(browser.text("label[for='banner']")).to.equal "Informe um link válido para o banner, começando com http ou https."
      expect(browser.text("label[for='otherUrl']")).to.equal "Informe um link válido para o outro site, começando com http ou https."
    it 'did not create a store with missing info', (done) ->
      Store.find (error, stores) ->
        return done error if error
        expect(stores.length).to.equal 0
        done()
