const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);
//
exports.sendNotifications = functions.database.ref('/messages/{id}').onWrite(event =>{
    const snapshot = event.data;
    const uid = snapshot.val().toID;
    const text = snapshot.val().text;
    //const name = snapshot.val().displayName;
    const payload = {
        notification: {
            title: `New Message From ${snapshot.val().displayName}`,
            body: text,
            badge: '1',
            sound: 'default',
        }
    };
    return admin.database().ref(`users/${uid}/fcmToken`).once('value').then(allToken => {
        if (allToken.val()){
            const token = Object.keys(allToken.val());
            return admin.messaging().sendToDevice(token, payload).then(response => {
                
            });
        };
    });
});

//exports.sendNotifications = functions.database.ref('/messages/{messageId}').onWrite(event => {
//  const snapshot = event.data;
//  const uid = snapshot.val().toID;
//  
//  console.log('uid', uid);
//  // Only send a notification when a new message has been created.
//  if (snapshot.previous.val()) {
//    return;
//  }
//
//  // Notification details.
//  const text = snapshot.val().text;
//  const payload = {
//    notification: {
//      title: `${snapshot.val().name} posted ${text ? 'a message' : 'an image'}`,
//      body: text ? (text.length <= 100 ? text : text.substring(0, 97) + '...') : '',
//      click_action: `https://${functions.config().firebase.authDomain}`
//    }
//  };
//
//  // Get the list of device tokens.
//  return admin.database().ref(`users/${uid}/fcmToken`).once('value').then(allTokens => {
//   
//    if (allTokens.val()) {
//       
//      // Listing all tokens.
//       const tokens = Object.keys(allTokens.val());
//         console.log('FCM', tokens);
//
//      // Send notifications to all tokens.
//      return admin.messaging().sendToDevice(tokens, payload).then(response => {
//      });
//    };
//  });
//});