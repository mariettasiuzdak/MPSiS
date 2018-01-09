/*********************************************
 * OPL 12.7.1.0 Model
 * Author: Marietta
 * Creation Date: 20 gru 2017 at 22:28:49
 *********************************************/
/*********************************************
 * OPL 12.7.1.0 Model
 * Author: Marietta
 * Creation Date: 28 lis 2017 at 20:36:34
 *********************************************/

/*
- mamy nody
1. Ustaliæ konkretny przep³yw, znaleŸæ dla niego œcie¿kê
2. Zwiêkszyæ przep³yw tak, ¿eby siê nie zmieœci³, dla niego wyznacz now¹ œcie¿kê
3. WeŸ pod uwagê, ¿e to œwiat³owód


*/

/*
tuple Path {
int src; //i
int dst; //j
//int flow; //przepustowosc, u nas przepustowosc = odleglosc
}
*/
tuple Coordinates { // wspó³rzêdne nodów (miast)
float x; // wspó³rzêdna x
float y; // wspó³rzêdna y
}
/*
tuple Link {
float i;
float j;
}
*/


//int n = ...; // liczba nodów (miast)
//range Nodes=1..n; //nody (miasta) to liczby od 1 do n
{string} Nodes = ...;

tuple arc
 {
   string source;
   string destination;
   //int u; // zmienna czy ³¹cze jest zainstalowane
 }   
 
 {arc} Arcs with source in Nodes, destination in Nodes = ...;

//setof(Link) Links = {<i,j> | i,j in Nodes : i!=j};

float c[Arcs]; // koszt ³¹cza = odleg³oœæ fizyczna
float k[Arcs]; // koszt otwarcia ³¹cza
float Capacity[Arcs] = ...; // ile ³¹cze udŸwignie = link bandwidth

Coordinates nodeLocation[Nodes]=...;
execute {

	function distance(Node1, Node2){ // obliczam odleg³oœci miêdzy nodami za pomoc¹ wylosowanych wspó³rzêdnych
		return Opl.sqrt(Opl.pow(Node1.x-Node2.x,2)+Opl.pow(Node1.y-Node2.y,2));	
	}
/*
	for (var source in Nodes) { // losujê wspó³rzêdne nodów
		nodeLocation[source].x=Opl.rand(100);
		nodeLocation[source].y=Opl.rand(100);	
	}
	*/
	
	for (var e in Arcs){ // ka¿dy koszt to dystans miêdzy nodami
		// koszt u¿ycia danego ³¹cza
		c[e] = distance(nodeLocation[e.source], nodeLocation[e.destination]);
		// linearyzacja 
		// koszt budowy nowego ³¹cza
		/*
		if (c[e] < 2) {
		k[e] = 3/20*c[e];
		} else if ((c[e] >= 2) && (c[e] < 10))	{
		k[e] = 3/20*c[e];		
		} else {
		k[e] = 3/20*c[e];		
		}
		*/
		//tutaj linearyzacja na poprawnie
		//k[e]= 3/20*(c[e]^2);
		k[e]= (Opl.sqrt((20/3)*(c[e])) + c[e]);
		
	}
//sprobuj linearyzacje	
	writeln("Nodes:", Nodes,".");
}

//dvar boolean x[Arcs];

tuple demand
 {
   string source;
   string destination;
 }   
 
 {demand} Demands with source in Nodes, destination in Nodes = ...;
 

float Volume[Demands] = ...;

//dvar boolean u[Arcs];
int Path = ...;
range Paths = 1..Path;
 
int delta[Arcs][Demands][Paths] = ...; // edp, edges = arcs
 dvar float+ y[Arcs]; // u¿ycie przep³ywnoœci -> przep³ywnoœæ do zainstalowania (link load?)
 dvar float+ x[Demands][Paths]; // wielkoœæ przep³ywu realizuj¹cego zapotrzebowanie
int W = 99999;
int u[Arcs] = ...;
int M = 10; // wielkoœæ modu³u - w naszym przypadku jest to wi¹zka 10Gbps



dexpr float B = sum(i in Arcs) (c[i]*y[i] + k[i]*u[i]);
//minimize sum(i in Arcs) (c[i]*y[i] + k[i]*u[i]);
 
 minimize B;
 
 
subject to
 {
 	forall(i in Arcs){
 	if (u[i] != 0){
 	cos1 : M*y[i] <= W*u[i]; 
	} 		
 	cos12 : M*y[i] <= Capacity[i];
 	cos2: (sum(j in Paths, n in Demands) delta[i][n][j]*x[n][j] ) <= M*y[i]; // czyli 1* ruch który zapodajemy musi byæ mniejszy od u¿ycia przep³ywnoœci
 	// y = wielkoœæ wi¹zki * iloœæ wi¹zek
 	forall(n in Demands){
	cos3: (sum(j in Paths) x[n][j] )>= Volume[n]; //ruch który ostatecznie zapodajemy musi byæ co najmniej taki sam jak ten ¿¹dany
   	} 	
   	
 	} 	  	
 }

//uncapacitated design - chcemy okreœliæ, jak du¿o capacity potrzebujemy ¿eby zaspokoiæ demand
//capacitated design - mamy dan¹ sieæ i znamy jej capacity, znamy demand, problemem jest jak alokowaæ flow - minimalnym kosztem
 