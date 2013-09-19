const HOME_LATITUDE = <your_home_latitude>;
const HOME_LONGITUDE = <your_home_longitude>;
const EARTH_MEAN_RADIUS_KM = 6371.009;

// from Christian Brosch's EasyGPSTracker Android app we will receive a POST
// with a lot of data, in plain form and also in XML, like:
// user=myuser&latitude=40.76573512&longitude=-111.90425061&speed=3.0923293&
// bearing=85.8&passwd=&comm=&profil=Pedestrian&action=comm&xml=....same data as XML....
// use the actual params, easier than parsing XML

user <- null;
latitude <- 0;
longitude <- 0;
distance <- 0;

function toRadian(a) {
  return a*PI/180;
}

function calculateDistance(lat1, lat2, lon1, lon2) {
  local dLat = toRadian(lat2-lat1);
  local dLon = toRadian(lon2-lon1);
  local lat1 = toRadian(lat1);
  local lat2 = toRadian(lat2);

  local a = math.sin(dLat/2) * math.sin(dLat/2) +
        math.sin(dLon/2) * math.sin(dLon/2) *
        math.cos(lat1) * math.cos(lat2); 
  local c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a)); 
  local dist = EARTH_MEAN_RADIUS_KM * c;
  distance = dist;
}

// HTTP Request handlers expect two parameters:
// request: the incoming request
// response: the response we send back to whoever made the request
function requestHandler(request, response) {
  local latStr = null;
  local lonStr = null;
  
  response.header("Access-Control-Allow-Origin", "*");
   
  if(request.method=="OPTIONS"){
    response.header("Access-Control-Allow-Methods", "POST, GET, OPTIONS");
    response.header("Access-Control-Allow-Headers", "origin, x-csrftoken, content-type, accept"); 
    // send a response back to whoever made the request
    response.send(200,"OK.OPTIONS");
  }

  if(request.method=="POST"){
    server.log("body:"+request.body);
    local keys = http.urldecode(request.body);
    foreach(idx,val in keys) {
      // server.log("index="+idx+" value="+val+"\n");
      if(idx == "latitude") {
          latStr = val;
      } else if(idx == "longitude") {
          lonStr = val;
      } else if(idx == "user") {
          user = val;
      }
    }
  }

  // the following code outside the if(POST)
  // to allow for GET in the future

  if(latStr == null || lonStr == null ||
        latStr.len() == 0 || lonStr.len() == 0) {
    server.log("latStr: "+latStr);
    server.log("lonStr: "+lonStr);
    // send response without distance and code 1 (error)
    sendResponse(response, 1, "missing lat and/or long");
    return;
  }
  latitude = latStr.tofloat();
  longitude = lonStr.tofloat();

  server.log("lat: "+latitude);
  server.log("long: "+longitude);

  // validate latitude
  if(latitude < -90 || latitude > 90) {
    // send response with code 1 (error)
    sendResponse(response, 1, "invalid latitude");
    return;
  }

  // validate longitude
  if(longitude < -180 || latitude > 180) {
    // send response with code 1 (error)
    sendResponse(response, 1, "invalid longitude");
    return;
  }

  server.log("user: "+user);
  // do this only if user is present
  if(user == null || user.len() == 0) {
    // send response with code 1 (error)
    sendResponse(response, 1, "invalid user");
    return;
  }

  calculateDistance(HOME_LATITUDE, latitude, HOME_LONGITUDE, longitude);

  server.log("distance: "+distance);

  // send response with distance and code 0 (success)
  sendResponse(response, 0, "distance: "+distance);
  
  // send distance and user to the imp
  local data = {
      distance = distance
      user = user
  };
  device.send("dist", data);
}

// your agent code should only ever have ONE http.onrequest call.
http.onrequest(requestHandler);





// the function below generates a response in XML format
// as expected by the  EasyGPSTracker app
const beginMsg = "<?xml version='1.0' standalone='yes'?><root>  <result>";
const midMsg = "</result>  <message>    <type>info</type>    <content>";
const endMsg = "</content>  </message></root>";

function sendResponse(res, code, msg) {
    res.header("Content-Type", "text/xml");
    local xmlMsg = beginMsg + code + midMsg + msg + endMsg;
    res.send(200,xmlMsg);
}
