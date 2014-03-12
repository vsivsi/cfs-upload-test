myFiles = new FS.Collection "filesColl", { stores: [new FS.Store.GridFS("filesGrid",{})] }
# myFiles = new FS.Collection "filesColl", { stores: [new FS.Store.FileSystem("filesFS", {path: "~/uploads"})] }

if Meteor.isClient

   Meteor.subscribe('allFiles')

   Template.uploadDB.events(
      'dropped .fileDrop' : (e) ->
         console.log 'Whoa, watch it buddy!'
         loggedIn = Meteor.userId()
         for f, i in e.originalEvent.dataTransfer.files
            f.metadata = {owner: loggedIn} if loggedIn
            myFiles.insert f, (err, id) ->
               throw err if err
               console.log "File #{i}: #{id} in GridFS"

      'click .del-file' : (e, t) ->
        console.log "Remove!", e, t, this
        myFiles.remove({_id: this._id})
   )

   Template.uploadDB.files = () ->
      myFiles.find({})

   Template.uploadDB.fetchFile = () ->
      this._id

   Template.uploadDB.numeralSize = () ->
      this.size
      # numeral(this.size).format('0.0 b')

if Meteor.isServer
   # code to run on server at startup

   Meteor.startup () ->

      # ## Uncomment below to wipe the myFiles GridFS store
      # # myFiles.remove({})

      Meteor.publish 'allFiles', () ->
         myFiles.find({})

      # # HTTP.publish 'thoseFiles', () ->
      # #    myFiles.find({})

      myFiles.allow
         download: (userId, file) ->
            test = (not file.metadata?.owner?) or file.metadata.owner is userId
            console.log "Download fired for #{file.name} #{test} #{userId} #{file.metadata?.owner}"
            test

         remove: (userId, file) ->
            test = (not file.metadata?.owner?) or file.metadata.owner is userId
            console.log "Remove fired for #{file.name} #{test} #{userId} #{file.metadata?.owner}"
            test

         update: (userId, file, fn, mod) ->
            test = (not file.metadata?.owner?) or file.metadata.owner is userId
            console.log "Update fired for #{file.name} #{test} #{userId} #{file.metadata?.owner} #{JSON.stringify(fn)} #{JSON.stringify(mod)}"
            test

         insert: (userId, file) ->
            test = (not file.metadata?.owner?) or file.metadata.owner is userId
            console.log "Insert fired for #{file.name} #{test} #{userId} #{file.metadata?.owner}"
            test

      Meteor.users.deny({update: () -> true })




















