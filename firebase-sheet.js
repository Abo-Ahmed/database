
// Authenticating
FB = new Firebase('https://xxx.firebase.io')
FB.auth(TOKEN, (err, result) => { ···})
FB.authAnonymously(···)
FB.authWithPassword(···)
FB.authWithOAuthPopup(···)
FB.authWithOAuthToken(···)

// Using
Users = FB.child('users')
// Create
user = Users.push(first: "Frank", last: "Sinatra")
// Retrieve
user = Users.child('alan')  // gets `users/alan`
// Update
user.set(first: "Miles", last: "Davis")
user.update(first: "Miles")
user.setWithPriority({ ··· }, priority)
// Destroy
user.remove()
// Getting
user.name()  // primary id

user.once('value', (snap) => {
  snap.name()  // primary id
  snap.val()   // value
}, (err) => {
  ···
})
// traversal
user.parent()

// Querying
Users = FB.child('users')
Users
  .startAt(1000)
  .limit(50)
  .equalTo(priority, [name])
  .on 'child_added', (snap) -> ···

// Lists
Posts = FB.child('posts')
post = Posts.push({ title: "How to do things", author: "alan" })
