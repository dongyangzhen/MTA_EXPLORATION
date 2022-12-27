// Global variables
Table tripTable;
Trips[] trip;
int totalFrames = 36000;
int totalMinutes = 86400*5;
float minLat = 40.957101;
float maxLat = 40.553458;
float minLon = -74.062687;
float maxLon =  -73.741668;
PImage img;
ArrayList routes;
PImage sign;

void setup(){
  size(586, 973);
  img = loadImage("map.png");
  sign = loadImage("sign.png");
  loadData();
  loadRoute();
  println("All done...");
}

void loadRoute(){
    // routes
  String[] routesraw = loadStrings("routes.txt");
  routes = new ArrayList();
  for (int i = 1;i<routesraw.length;i++)
  {
    String[] t = routesraw[i].split(",(?=([^\"]*\"[^\"]*\")*[^\"]*$)");
    routes.add(new Route());
    Route r = (Route) routes.get(routes.size()-1);
    r.route_id = "_"+t[0]+".";
    if (t.length>7) {
      r.route_color = unhex("FF"+t[7]);
    }
    else 
    {
      r.route_color = unhex("FF9999FF");
    }
  }
}

void loadData(){
  tripTable = loadTable("trip1226.csv", "header");
  println(str(tripTable.getRowCount()) + " records loaded...");
  trip = new Trips[tripTable.getRowCount()];
  for (int i=0; i<tripTable.getRowCount(); i++){ //******** take this back up to the full dataset *********
    int duration = round(map(tripTable.getInt(i, "tripduration"), 0, totalMinutes, 0, totalFrames));
    String[] starttime = split(split(tripTable.getString(i, "starttime"), " ")[1], ":");
    String[] endtime = split(split(tripTable.getString(i, "stoptime"), " ")[1], ":");
    float startSecond = int(starttime[0]) * 3600 + int(starttime[1]) * 60 + int(starttime[2]);
    float endSecond = int(endtime[0]) * 3600 + int(endtime[1]) * 60 + int(endtime[2]);
    int startFrame = floor(map(startSecond, 0, totalMinutes, 0, totalFrames));
    int endFrame = floor(map(endSecond, 0, totalMinutes, 0, totalFrames));
    String startStation = tripTable.getString(i, "start station name");
    String endStation = tripTable.getString(i, "end station name");
    float startX = map(tripTable.getFloat(i, "start station longitude"), minLon, maxLon, 0, 586);
    float startY = map(tripTable.getFloat(i, "start station latitude"), minLat, maxLat, 0, 973);
    float endX = map(tripTable.getFloat(i, "end station longitude"), minLon, maxLon, 0, 586);
    float endY = map(tripTable.getFloat(i, "end station latitude"), minLat, maxLat, 0, 973);
    int tripid = tripTable.getInt(i, "tripid");
    String train = tripTable.getString(i, "trip");
    int col = unhex("FF"+tripTable.getString(i,"route_color"));
    trip[i] = new Trips(duration, startFrame, endFrame, startStation, endStation, startX, startY, endX, endY, tripid, train, col);
  }
}

void draw(){
  image(img, 0, 0);
  tint(255);
  image(sign,0,0);
  noStroke();
  fill(0, 0, 0, 20);
  rect(0, 0, 800, 800);
  fill(250);
  for (int i=0; i<trip.length; i++){
    trip[i].plotRide();
  }
}

class Trips{
  // Class properties
  PVector start, end;
  int tripFrames, startFrame, endFrame;
  String trainid;
  int cols;
  
  // Class constructor
  Trips(int duration, int start_frame, int end_frame, String startStation, String endStation, float startX, float startY, float endX, float endY, int tripid, String train, int col){
    start = new PVector(startX, startY);
    end = new PVector(endX, endY);
    tripFrames = duration;
    startFrame = start_frame;
    endFrame = end_frame;
    trainid = train;
    cols = col;
  }
  

  // Class methods
  void plotRide(){
    fill(cols);
    if (frameCount >= startFrame && frameCount < endFrame){
      float percentTravelled = (float(frameCount) - float(startFrame)) / float(tripFrames);
      PVector currentPosition = new PVector(lerp(start.x, end.x, percentTravelled), lerp(start.y, end.y, percentTravelled));
      ellipse(currentPosition.x, currentPosition.y, 6, 6);
    }
    else{
    }
  }
}


void checkcolors(String id)
{
  // lookup route colors
  for (int i = 0;i<routes.size();i++)
  {
    Route r = (Route) routes.get(i);
    if (id.contains(r.route_id))
    {
      fill(#EE352E);
    }
  }
}

class Route
{
  String route_id;
  int route_color;
}
