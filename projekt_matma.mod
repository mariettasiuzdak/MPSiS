/*********************************************
 * OPL 12.7.1.0 Model
 * Author: Marietta
 * Creation Date: 28 lis 2017 at 20:36:34
 *********************************************/

tuple Coordinates { // wspó³rzêdne nodów (miast)
	float x; // wspó³rzêdna x
	float y; // wspó³rzêdna y
}

{string} Nodes = ...;

tuple arc {
   string source;
   string destination;
 }   
 
 {arc} Arcs with source in Nodes, destination in Nodes = ...;


float c[Arcs]; // koszt ³¹cza = odleg³oœæ fizyczna
float k[Arcs]; // koszt otwarcia ³¹cza
float Capacity[Arcs] = ...; // link bandwidth

Coordinates nodeLocation[Nodes]=...;
execute {

	function distance(Node1, Node2){ // obliczam odleg³oœci miêdzy nodami
		return Opl.sqrt(Opl.pow(Node1.x-Node2.x,2)+Opl.pow(Node1.y-Node2.y,2));	
	}

	for (var e in Arcs){ // ka¿dy koszt to dystans miêdzy nodami
		// koszt u¿ycia danego ³¹cza
		c[e] = distance(nodeLocation[e.source], nodeLocation[e.destination]);
		// koszt budowy nowego ³¹cza
		k[e]= 3/20*(c[e]^2);
		
	}
	writeln("Nodes:", Nodes,".");
}

tuple demand
 {
   string source;
   string destination;
 }   
 
 {demand} Demands with source in Nodes, destination in Nodes = ...;
 
float Volume[Demands] = ...;

int Path = ...;
range Paths = 1..Path;
 
int delta[Arcs][Demands][Paths] = ...; // edp, edges = arcs
dvar float+ y[Arcs]; // u¿ycie przep³ywnoœci -> przep³ywnoœæ do zainstalowania 
dvar float+ x[Demands][Paths]; // wielkoœæ przep³ywu realizuj¹cego zapotrzebowanie
int W = 99999;
int u[Arcs] = ...;
//int u_wildcard[Arcs] = ...;
float M = 0.4; // wielkoœæ modu³u/wi¹zki

dexpr float B = sum(i in Arcs) (c[i]*y[i] + k[i]*u[i]);
//minimize sum(i in Arcs) (c[i]*y[i] + k[i]*u[i]);
 
minimize B;
 
subject to
 {
 	forall(i in Arcs){
 	if (u[i] != 0){
 	cos1 : M*y[i] <= W*u[i]; 
	} 	
 	cos2 : M*y[i] <= Capacity[i];
 	cos3: (sum(j in Paths, n in Demands) delta[i][n][j]*x[n][j] ) <= M*y[i]; // czyli 1* ruch który puszczamy musi byæ mniejszy od u¿ycia przep³ywnoœci
 	// y = wielkoœæ wi¹zki * iloœæ wi¹zek
 	forall(n in Demands){
	cos4: (sum(j in Paths) x[n][j] )>= Volume[n]; //ruch który ostatecznie puszczamy musi byæ co najmniej taki sam jak ten ¿¹dany
   	} 	
 	} 	  	
 }
