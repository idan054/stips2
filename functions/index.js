
// How I Made it: https://www.youtube.com/watch?v=iIVlRZIo2-c&t=591s

const functions = require("firebase-functions");
const express = require("express");
// const cors = require("cors");
const moment = require("moment")
const admin = require("firebase-admin");
admin.initializeApp();

// const functions = require("firebase-functions");
// const express = require("express");
// const cors = require("cors");
// const admin = require("firebase-admin")


const collections_app = express();
const document_app = express();

  function currentTime()  {
    // var created_Time  = moment().utcOffset(0, true).format()
    let currentTimeStr  = Date()
    let currentTimeNum = Math.floor(new Date() / 1000)

  return { currentTimeStr, currentTimeNum} ;
}

// Get Specific data by choose document
document_app.get('/', async (req,
               res) => {

  //etc. example.com/user/000000?sex=female
  const query = req.query;// query = {sex:"female"}
  const collectionPath = query["collectionPath"] // Collection/DocReference/InnerCollection
  const doc = query["doc"]
  const currentTimeStr = currentTime()["currentTimeStr"]
  const currentTimeNum = currentTime()["currentTimeNum"]


  const snapshot = await admin.firestore().collection(collectionPath).doc(doc).get();

    let req_doc = snapshot.id;
    // let createTime = snapshot.createTime;
    let data = snapshot.data();

  res.status(200).send(JSON.stringify({
    "req_doc":req_doc,
    "last_edit_str": currentTimeStr,
    "last_edit_num": currentTimeNum,
    data}
    ));

})

// Put (update) data by choose document
document_app.put('/', async (req,
               res) => {

  //etc. example.com/user/000000?sex=female
  const query = req.query; // query = {sex:"female"}
  const collectionPath = query["collectionPath"] // Collection/DocReference/InnerCollection
  const doc = query["doc"]

  const  currentTimeStr = currentTime()["currentTimeStr"]
  const  currentTimeNum = currentTime()["currentTimeNum"]

  const reqBody = req.body
  await admin.firestore().collection(collectionPath).doc(doc).update(
{ "last_edit_str": currentTimeStr,
        "last_edit_num": currentTimeNum,
        ...reqBody},  // "..." to ignore reqBody{}
    );

  res.status(200).send({
      "doc_ref": doc,
      "last_edit_str": currentTimeStr,
      "last_edit_num": currentTimeNum,
      ...reqBody}); // "..." to ignore reqBody{}
  //  Cannot .send(JSON.stringify(snapshot.data())) because its not a get Request
})

// Delete chosen document
document_app.delete('/', async (req,
               res) => {

  //etc. example.com/user/000000?sex=female
  const query = req.query;// query = {sex:"female"}
  const collectionPath = query["collectionPath"] // Collection/DocReference/InnerCollection
  const doc = query["doc"]

  await admin.firestore().collection(collectionPath).doc(doc).delete();

  res.status(200).send();
})

// Get full data by choose collections
collections_app.get('/', async (req,
               res) => {
  // const {collection} = req.query;

  //etc. example.com/user/000000?sex=female
  const query = req.query;// query = {sex:"female"}
  const collectionPath = query["collectionPath"] // Collection/DocReference/InnerCollection

  // const params = req.params; //params = {id:"000000"}
  // // const collectionPath = params["collectionPath"] // Collection/DocReference/InnerCollection

  // const reqBody = req.body
  // const collectionPath = reqBody["collectionPath"] // Collection/DocReference/InnerCollection

  // My Get req.url: https://us-central1-bubbleflow-mitmit.cloudfunctions.net/database_GetPost?collectionPath=users

  // const reqBody = req.body
  // const collectionPath = reqBody["collectionPath"] // Collection/DocReference/InnerCollection

  const snapshot = await admin.firestore().collection(collectionPath).get();

  let users = [];
  snapshot.forEach(doc => {
    // let id = doc.id;
    // let createTime = doc.createTime;
    let data = doc.data();

    // users.push({id, ...data, createTime})
    users.push({...data}) //"...data" to: "email": "ccc@ccc.com" Instead: "data": { "email": "ccc@ccc.com", }
  });

  res.status(200).send(JSON.stringify(users));
})

// Post any data by req.body & choose collections
collections_app.post("/", async (req, res) => {
  const reqBody = req.body
  const collectionPath = reqBody["collectionPath"] // Collection/DocReference/InnerCollection

  const currentTimeStr = currentTime()["currentTimeStr"]
  const currentTimeNum = currentTime()["currentTimeNum"]

  // await admin.firestore().collection(collectionPath).doc(doc_id).set(reqBody)
  const snapshot = await admin.firestore().collection(collectionPath).add(reqBody);


  await admin.firestore().collection(collectionPath).doc(snapshot.id)
      .update({
        "doc_ref":snapshot.id,
        "created_time_str":currentTimeStr,
        "created_time_num":currentTimeNum,
        "last_edit_str": currentTimeStr,
        "last_edit_num": currentTimeNum,
      }); // Add the doc id

    // 100-199: (Informational) Missing data error "collectionPath is missing on reqBody"
    // 200-299: (Success)
    // 300-399: (Redirection) No permission error "You have no permission to charge"
    // 400-499: (Client error) User error like "Pass needs to be at least 6 char"
    // 500-599: (Server error)


  res.status(200).send({
        "doc_ref":snapshot.id,
        "created_time_str":currentTimeStr,
        "created_time_num":currentTimeNum,
        "last_edit_str": currentTimeStr,
        "last_edit_num": currentTimeNum,
      ...reqBody});  // "..." to ignore reqBody{}
//  Cannot .send(JSON.stringify(snapshot.data())) because its not a get Request

})

exports.GetPost_Collections = functions.https.onRequest(collections_app);
exports.GetPutDelete_doc = functions.https.onRequest(document_app);


// Create and Deploy Your First Cloud Functions
// https://firebase.google.com/docs/functions/write-firebase-functions

function reqListener () {
  console.log(this.responseText);
  }

function myTimer() {
      functions.logger.info(' each 10 second...', {structuredData: true});

        console.log('Start');
        let getJSON = (callback) => {
        var req = new XMLHttpRequest();
        req.open('GET', 'https://stips.co.il/api?name=messages.count&api_params={}', true);
        req.Unload = reqListener;
        req.setRequestHeader('cookie', '_ga=GA1.3.1825806670.1665392721; trc_cookie_storage=taboola%2520global%253Auser-id%3Dd2dd1445-4920-4fb8-be51-8fbdb9ac41e0-tucta3d65d3; _cc_id=44c1e92eaf382ec56c0c41419928a37; ASPSESSIONIDAEQTACST=LFLPEDLBFKGKNDLCMDPPIIHF; ASPSESSIONIDSGSSABRQ=GNIOOKEDMKFMPAABGBHFFPBH; _gid=GA1.3.484646642.1673977098; Login%5FUser=hashedpassword=LGHoHMsrnDDoFLsFHGEDFLEpLpsnsIHE&mail=vqn0ov6LD%2BI%40tznvy%2Ep1z&rememberme=true&stype=75r4&id=GHLLII&password=; _gat=1')
        req.responseType = 'json';
        req.send();
}



exports.helloWorld = functions.https.onRequest((request, response) => {
  var myVar = setInterval(myTimer, 1000 * 10); //setting the loop with time interval

  response.send("Hello from Firebase!");
});

