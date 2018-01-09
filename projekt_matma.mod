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
1. Ustali� konkretny przep�yw, znale�� dla niego �cie�k�
2. Zwi�kszy� przep�yw tak, �eby si� nie zmie�ci�, dla niego wyznacz now� �cie�k�
3. We� pod uwag�, �e to �wiat�ow�d


*/

/*
tuple Path {
int src; //i
int dst; //j
//int flow; //przepustowosc, u nas przepustowosc = odleglosc
}
*/
tuple Coordinates { // wsp�rz�dne nod�w (miast)
float x; // wsp�rz�dna x
float y; // wsp�rz�dna y
}
/*
tuple Link {
float i;
float j;
}
*/


//int n = ...; // liczba nod�w (miast)
//range Nodes=1..n; //nody (miasta) to liczby od 1 do n
{string} Nodes = ...;

tuple arc
 {
   string source;
   string destination;
   //int u; // zmienna czy ��cze jest zainstalowane
 }   
 
 {arc} Arcs with source in Nodes, destination in Nodes = ...;

//setof(Link) Links = {<i,j> | i,j in Nodes : i!=j};

float c[Arcs]; // koszt ��cza = odleg�o�� fizyczna
float k[Arcs]; // koszt otwarcia ��cza
float Capacity[Arcs] = ...; // ile ��cze ud�wignie = link bandwidth

Coordinates nodeLocation[Nodes]=...;
execute {

	function distance(Node1, Node2){ // obliczam odleg�o�ci mi�dzy nodami za pomoc� wylosowanych wsp�rz�dnych
		return Opl.sqrt(Opl.pow(Node1.x-Node2.x,2)+Opl.pow(Node1.y-Node2.y,2));	
	}
/*
	for (var source in Nodes) { // losuj� wsp�rz�dne nod�w
		nodeLocation[source].x=Opl.rand(100);
		nodeLocation[source].y=Opl.rand(100);	
	}
	*/
	
	for (var e in Arcs){ // ka�dy koszt to dystans mi�dzy nodami
		// koszt u�ycia danego ��cza
		c[e] = distance(nodeLocation[e.source], nodeLocation[e.destination]);
		// linearyzacja 
		// koszt budowy nowego ��cza
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
 dvar float+ y[Arcs]; // u�ycie przep�ywno�ci -> przep�ywno�� do zainstalowania (link load?)
 dvar float+ x[Demands][Paths]; // wielko�� przep�ywu realizuj�cego zapotrzebowanie
int W = 99999;
int u[Arcs] = ...;
int M = 10; // wielko�� modu�u - w naszym przypadku jest to wi�zka 10Gbps



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
 	cos2: (sum(j in Paths, n in Demands) delta[i][n][j]*x[n][j] ) <= M*y[i]; // czyli 1* ruch kt�ry zapodajemy musi by� mniejszy od u�ycia przep�ywno�ci
 	// y = wielko�� wi�zki * ilo�� wi�zek
 	forall(n in Demands){
	cos3: (sum(j in Paths) x[n][j] )>= Volume[n]; //ruch kt�ry ostatecznie zapodajemy musi by� co najmniej taki sam jak ten ��dany
   	} 	
   	
 	} 	  	
 }

//uncapacitated design - chcemy okre�li�, jak du�o capacity potrzebujemy �eby zaspokoi� demand
//capacitated design - mamy dan� sie� i znamy jej capacity, znamy demand, problemem jest jak alokowa� flow - minimalnym kosztem
 