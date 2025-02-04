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
            title: `${snapshot.val().displayName} Messaged You!`,
            body: text,
            badge: '1',
            sound: 'default',
        }
    };
    return admin.database().ref(`users/${uid}/fcmToken`).once('value').then(allToken => {
        if (allToken.val()){
            const token = Object.keys(allToken.val());
          console.log('FCM is',token);
            return admin.messaging().sendToDevice(token, payload).then(response => {
                
            });
        };
    });
});

exports.sendNotificationsInquire = functions.database.ref('/users/{id}/Sent Inquires/{inquireID}').onCreate(event =>{
    const snapshot = event.data;
    const uid = snapshot.val().artistToken;

    const payload = {
        notification: {
            title: `New Inquiry From ${snapshot.val().ClientName}`,
            body: 'Come Check It Out!',
            badge: '1',
            sound: 'default',
        }
    };
    return admin.database().ref(`users/${uid}/fcmToken`).once('value').then(allToken => {
        if (allToken.val()){
            const token = Object.keys(allToken.val());
          console.log('FCM is',token);
            return admin.messaging().sendToDevice(token, payload).then(response => {
                
            });
        };
    });
});
exports.sendNotificationsInquireAnswer = functions.database.ref('/users/{id}/Sent Inquires/{inquireID}').onUpdate(event =>{
    const snapshot = event.data;
    const uid = snapshot.val().token;

    const payload = {
        notification: {
            title: `${snapshot.val().ClientName} Has Answered Your Inquiry`,
            body: 'Come Check It Out!',
            badge: '1',
            sound: 'default',
        }
    };
    return admin.database().ref(`users/${uid}/fcmToken`).once('value').then(allToken => {
        if (allToken.val()){
            const token = Object.keys(allToken.val());
          console.log('FCM is',token);
            return admin.messaging().sendToDevice(token, payload).then(response => {
                
            });
        };
    });
});

//exports.updateRating = functions.database.ref('/users/{id}/Ratings/').onUpdate(event =>{
//    const post = event.data.val()
//    const id = event.params
//    return event.data.ref(`users/${id}/Rating`).set(post)
// 
//    
//    
//})

//exports.scoreOneAverage = functions.database.ref('/users/{id}/Ratings')
//  .onWrite(event => {
//    const scores = event.data.val();
//    const avgSum = 0;
//    const id = event.params
//    _.forOwn(scores, (scoreKey, scoreValue) => {
//      avgSum += scoreValue;
//    });
//    return event.data.ref(`users/${id}/Rating`).set(avgSum / _.size(scores)); // this is your average! Do with it what you like
//    console.log(avgSum / _.size(scores))
//  });

